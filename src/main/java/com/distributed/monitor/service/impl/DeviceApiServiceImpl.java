package com.distributed.monitor.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.json.JSONUtil;
import com.distributed.monitor.dto.deviceapi.CommandResultDTO;
import com.distributed.monitor.dto.deviceapi.DeviceHeartbeatDTO;
import com.distributed.monitor.dto.deviceapi.DeviceStatusReportDTO;
import com.distributed.monitor.entity.Device;
import com.distributed.monitor.entity.DeviceCommandLog;
import com.distributed.monitor.entity.DeviceConfig;
import com.distributed.monitor.entity.DeviceHeartbeat;
import com.distributed.monitor.entity.DeviceStatusHistory;
import com.distributed.monitor.exception.BusinessException;
import com.distributed.monitor.exception.NotFoundException;
import com.distributed.monitor.mapper.CommandMapper;
import com.distributed.monitor.mapper.DeviceMapper;
import com.distributed.monitor.exception.BusinessException;
import com.distributed.monitor.service.DeviceApiService;
import com.distributed.monitor.service.DeviceAuthService;
import com.distributed.monitor.vo.deviceapi.HeartbeatResponseVO;
import com.distributed.monitor.vo.deviceapi.StatusReportResponseVO;
import com.distributed.monitor.websocket.MonitorWebSocketServer;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 设备端API服务实现
 */
@Service
@RequiredArgsConstructor
public class DeviceApiServiceImpl implements DeviceApiService {
    
    private final DeviceMapper deviceMapper;
    private final CommandMapper commandMapper;
    private final DeviceAuthService deviceAuthService;
    
    @Override
    public void validateDeviceCredentials(String deviceCode, String deviceSecret) {
        if (!deviceAuthService.validateDeviceCredentials(deviceCode, deviceSecret)) {
            throw new BusinessException("设备编码或密钥错误");
        }
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public HeartbeatResponseVO handleHeartbeat(DeviceHeartbeatDTO dto) {
        // 验证设备凭证
        validateDeviceCredentials(dto.getDeviceCode(), dto.getDeviceSecret());
        
        // 根据设备编码查询设备
        Device device = deviceMapper.selectDeviceByCode(dto.getDeviceCode());
        if (device == null) {
            throw new NotFoundException("设备不存在");
        }
        
        // 更新设备最后心跳时间
        device.setLastHeartbeatTime(LocalDateTime.now());
        device.setOnlineStatus(1);
        device.setStatus("online");
        device.setUpdatedAt(LocalDateTime.now());
        deviceMapper.updateDevice(device);
        
        // 记录心跳
        DeviceHeartbeat heartbeat = new DeviceHeartbeat();
        heartbeat.setDeviceId(device.getId());
        heartbeat.setHeartbeatTime(LocalDateTime.now());
        heartbeat.setIpAddress(dto.getExtraData() != null ? 
                String.valueOf(dto.getExtraData().get("ipAddress")) : null);
        heartbeat.setExtraData(JSONUtil.toJsonStr(dto.getExtraData()));
        heartbeat.setCreatedAt(LocalDateTime.now());
        
        // 插入心跳记录到数据库
        deviceMapper.insertHeartbeat(heartbeat);
        
        return HeartbeatResponseVO.builder()
                .received(true)
                .serverTime(System.currentTimeMillis())
                .nextHeartbeatInterval(60)
                .build();
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public StatusReportResponseVO handleStatusReport(DeviceStatusReportDTO dto) {
        // 验证设备凭证
        validateDeviceCredentials(dto.getDeviceCode(), dto.getDeviceSecret());
        
        // 根据设备编码查询设备
        Device device = deviceMapper.selectDeviceByCode(dto.getDeviceCode());
        if (device == null) {
            throw new NotFoundException("设备不存在");
        }
        
        // 创建状态历史记录
        DeviceStatusHistory statusHistory = new DeviceStatusHistory();
        statusHistory.setDeviceId(device.getId());
        statusHistory.setStatusType(dto.getStatusType());
        // 门禁场景字段
        statusHistory.setDoorStatus(dto.getDoorStatus());
        statusHistory.setDoorControllerStatus(dto.getDoorControllerStatus());
        // 把自定义结构序列化到 statusValue 字段存储（数据库中使用 status_value 列）
        statusHistory.setStatusValue(JSONUtil.toJsonStr(dto.getCustomData()));
        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            statusHistory.setReportTime(LocalDateTime.parse(dto.getReportTime(), formatter));
        } catch (Exception e) {
            statusHistory.setReportTime(LocalDateTime.now());
        }
        statusHistory.setCreatedAt(LocalDateTime.now());

        // 仅在门状态发生变化时才插入历史记录，避免重复保存相同的 open/closed 状态
        DeviceStatusHistory latestHistory = deviceMapper.selectDeviceLatestStatusHistory(device.getId());
        boolean shouldInsert = true;
        if (dto.getDoorStatus() != null && latestHistory != null) {
            String lastDoorStatus = latestHistory.getDoorStatus();
            if (lastDoorStatus != null && lastDoorStatus.equals(dto.getDoorStatus())) {
                // 状态未变化，复用最近记录的 ID 并跳过插入
                statusHistory.setId(latestHistory.getId());
                shouldInsert = false;
            }
        }

        if (shouldInsert) {
            deviceMapper.insertStatusHistory(statusHistory);
        }
        
        // 更新设备在线状态
        device.setLastHeartbeatTime(LocalDateTime.now());
        device.setOnlineStatus(1);
        device.setStatus("online");
        device.setUpdatedAt(LocalDateTime.now());
        deviceMapper.updateDevice(device);
        
        // 广播：把门禁/状态变化推送到监控通道，确保前端实时更新
        try {
            Map<String, Object> statusUpdate = new HashMap<>();
            statusUpdate.put("deviceId", device.getId());
            statusUpdate.put("deviceCode", device.getDeviceCode());
            statusUpdate.put("onlineStatus", device.getOnlineStatus());
            statusUpdate.put("status", device.getStatus());
            statusUpdate.put("lastHeartbeatTime", device.getLastHeartbeatTime());
            statusUpdate.put("doorStatus", dto.getDoorStatus());
            statusUpdate.put("doorControllerStatus", dto.getDoorControllerStatus());
            statusUpdate.put("statusId", statusHistory.getId());
            MonitorWebSocketServer.broadcastStatus("device_status_update", statusUpdate);
        } catch (Exception ignored) {
            // 不影响业务
        }
        
        // 通知前端监控页面设备状态更新（包含门禁状态字段）
        try {
            Map<String, Object> statusUpdate = new HashMap<>();
            statusUpdate.put("deviceId", device.getId());
            statusUpdate.put("deviceCode", device.getDeviceCode());
            statusUpdate.put("onlineStatus", device.getOnlineStatus());
            statusUpdate.put("status", device.getStatus());
            statusUpdate.put("lastHeartbeatTime", device.getLastHeartbeatTime());
            // 门禁相关状态
            statusUpdate.put("doorStatus", dto.getDoorStatus());
            statusUpdate.put("doorControllerStatus", dto.getDoorControllerStatus());
            statusUpdate.put("statusId", statusHistory.getId());
            MonitorWebSocketServer.broadcastStatus("device_status_update", statusUpdate);
        } catch (Exception e) {
            // 保证业务逻辑不受广播失败影响
        }
        
        return StatusReportResponseVO.builder()
                .received(true)
                .statusId(statusHistory.getId())
                .build();
    }
    
    @Override
    public List<Map<String, Object>> getPendingCommands(String deviceCode, String deviceSecret) {
        // 验证设备凭证
        validateDeviceCredentials(deviceCode, deviceSecret);
        
        // 根据设备编码查询设备
        Device device = deviceMapper.selectDeviceByCode(deviceCode);
        if (device == null) {
            throw new NotFoundException("设备不存在");
        }
        
        // 查询待执行命令
        List<DeviceCommandLog> commandList = commandMapper.selectPendingCommands(device.getId());
        
        return commandList.stream()
                .map(log -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("commandLogId", log.getId());
                    map.put("commandCode", log.getCommandCode());
                    if (log.getCommandParams() != null) {
                        map.put("commandParams", JSONUtil.parseObj(log.getCommandParams()));
                    }
                    // 格式化executeTime为字符串
                    if (log.getExecuteTime() != null) {
                        map.put("executeTime", log.getExecuteTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
                    } else {
                        map.put("executeTime", null);
                    }
                    return map;
                })
                .collect(Collectors.toList());
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> reportCommandResult(Long id, CommandResultDTO dto) {
        // 查询命令执行记录
        DeviceCommandLog log = commandMapper.selectCommandLogById(id);
        if (log == null) {
            throw new NotFoundException("命令执行记录不存在");
        }
        
        // 验证设备凭证
        validateDeviceCredentials(dto.getDeviceCode(), dto.getDeviceSecret());
        
        // 验证设备编码
        Device device = deviceMapper.selectDeviceById(log.getDeviceId());
        if (device == null || !device.getDeviceCode().equals(dto.getDeviceCode())) {
            throw new BusinessException("设备编码不匹配");
        }
        
        // 更新命令执行结果
        log.setStatus(dto.getStatus());
        log.setResponseData(JSONUtil.toJsonStr(dto.getResponseData()));
        log.setErrorMessage(dto.getErrorMessage());
        log.setResponseTime(LocalDateTime.now());
        log.setDuration(dto.getDuration());
        
        commandMapper.updateCommandLog(log);
        
        Map<String, Object> result = new HashMap<>();
        result.put("received", true);
        result.put("commandLogId", log.getId());
        
        return result;
    }
    
    @Override
    public List<Map<String, Object>> getDeviceConfig(String deviceCode, String deviceSecret) {
        // 验证设备凭证
        validateDeviceCredentials(deviceCode, deviceSecret);
        
        // 根据设备编码查询设备
        Device device = deviceMapper.selectDeviceByCode(deviceCode);
        if (device == null) {
            throw new NotFoundException("设备不存在");
        }
        
        // 查询设备配置
        List<DeviceConfig> configList = deviceMapper.selectDeviceConfig(device.getId());
        
        return configList.stream()
                .map(config -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("configKey", config.getConfigKey());
                    map.put("configValue", config.getConfigValue());
                    map.put("configType", config.getConfigType());
                    map.put("description", config.getDescription());
                    return map;
                })
                .collect(Collectors.toList());
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> confirmConfigSync(String deviceCode, String deviceSecret, List<String> configKeys) {
        // 验证设备凭证
        validateDeviceCredentials(deviceCode, deviceSecret);
        
        // 根据设备编码查询设备
        Device device = deviceMapper.selectDeviceByCode(deviceCode);
        if (device == null) {
            throw new NotFoundException("设备不存在");
        }
        
        // 标记配置为已同步
        LocalDateTime syncTime = LocalDateTime.now();
        // 根据configKeys更新对应的配置项同步状态
        deviceMapper.markConfigAsSynced(device.getId(), configKeys, syncTime);
        
        Map<String, Object> result = new HashMap<>();
        result.put("confirmed", true);
        result.put("confirmedCount", configKeys != null ? configKeys.size() : 0);
        
        return result;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public StatusReportResponseVO handleStatusReportInternal(DeviceStatusReportDTO dto) {
        // 不进行认证验证，直接处理（用于WebSocket）
        
        // 根据设备编码查询设备
        Device device = deviceMapper.selectDeviceByCode(dto.getDeviceCode());
        if (device == null) {
            throw new NotFoundException("设备不存在");
        }
        
        // 创建状态历史记录
        DeviceStatusHistory statusHistory = new DeviceStatusHistory();
        statusHistory.setDeviceId(device.getId());
        statusHistory.setStatusType(dto.getStatusType());
        // 门禁场景字段（WebSocket内部调用不做凭证验证）
        statusHistory.setDoorStatus(dto.getDoorStatus());
        statusHistory.setDoorControllerStatus(dto.getDoorControllerStatus());
        // 把自定义结构序列化到 statusValue 字段存储（数据库中使用 status_value 列）
        statusHistory.setStatusValue(JSONUtil.toJsonStr(dto.getCustomData()));
        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            statusHistory.setReportTime(LocalDateTime.parse(dto.getReportTime(), formatter));
        } catch (Exception e) {
            statusHistory.setReportTime(LocalDateTime.now());
        }
        statusHistory.setCreatedAt(LocalDateTime.now());

        // 仅在门状态发生变化时才插入历史记录，避免重复保存相同的 open/closed 状态
        DeviceStatusHistory latestHistoryInternal = deviceMapper.selectDeviceLatestStatusHistory(device.getId());
        boolean shouldInsertInternal = true;
        if (dto.getDoorStatus() != null && latestHistoryInternal != null) {
            String lastDoorStatus = latestHistoryInternal.getDoorStatus();
            if (lastDoorStatus != null && lastDoorStatus.equals(dto.getDoorStatus())) {
                // 状态未变化，复用最近记录的 ID 并跳过插入
                statusHistory.setId(latestHistoryInternal.getId());
                shouldInsertInternal = false;
            }
        }

        if (shouldInsertInternal) {
            deviceMapper.insertStatusHistory(statusHistory);
        }
        
        // 更新设备在线状态
        device.setLastHeartbeatTime(LocalDateTime.now());
        device.setOnlineStatus(1);
        device.setStatus("online");
        device.setUpdatedAt(LocalDateTime.now());
        deviceMapper.updateDevice(device);
        
        return StatusReportResponseVO.builder()
                .received(true)
                .statusId(statusHistory.getId())
                .build();
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> reportCommandResultInternal(Long id, CommandResultDTO dto) {
        // 不进行认证验证，直接处理（用于WebSocket）
        
        // 查询命令执行记录
        DeviceCommandLog log = commandMapper.selectCommandLogById(id);
        if (log == null) {
            throw new NotFoundException("命令执行记录不存在");
        }
        
        // 验证设备编码
        Device device = deviceMapper.selectDeviceById(log.getDeviceId());
        if (device == null || !device.getDeviceCode().equals(dto.getDeviceCode())) {
            throw new BusinessException("设备编码不匹配");
        }
        
        // 更新命令执行结果
        log.setStatus(dto.getStatus());
        log.setResponseData(JSONUtil.toJsonStr(dto.getResponseData()));
        log.setErrorMessage(dto.getErrorMessage());
        log.setResponseTime(LocalDateTime.now());
        log.setDuration(dto.getDuration());
        
        commandMapper.updateCommandLog(log);
        
        // 如果响应数据中包含门禁状态（doorStatus / doorControllerStatus），将其写入状态历史并通知前端
        if (dto.getResponseData() != null && (!dto.getResponseData().isEmpty())) {
            Object doorStatusObj = dto.getResponseData().get("doorStatus");
            Object doorControllerStatusObj = dto.getResponseData().get("doorControllerStatus");
            if (doorStatusObj != null || doorControllerStatusObj != null) {
                DeviceStatusHistory statusHistory = new DeviceStatusHistory();
                statusHistory.setDeviceId(device.getId());
                statusHistory.setStatusType("command_result");
                if (doorStatusObj != null) {
                    statusHistory.setDoorStatus(String.valueOf(doorStatusObj));
                }
                if (doorControllerStatusObj != null) {
                    statusHistory.setDoorControllerStatus(String.valueOf(doorControllerStatusObj));
                }
                statusHistory.setStatusValue(JSONUtil.toJsonStr(dto.getResponseData()));
                statusHistory.setReportTime(LocalDateTime.now());
                statusHistory.setCreatedAt(LocalDateTime.now());

                // 仅在门状态发生变化时才插入历史记录，避免重复保存相同的 open/closed 状态
                String newDoorStatus = statusHistory.getDoorStatus();
                DeviceStatusHistory latestCmdHistory = deviceMapper.selectDeviceLatestStatusHistory(device.getId());
                boolean shouldInsertCmd = true;
                if (newDoorStatus != null && latestCmdHistory != null) {
                    String lastDoorStatus = latestCmdHistory.getDoorStatus();
                    if (lastDoorStatus != null && lastDoorStatus.equals(newDoorStatus)) {
                        statusHistory.setId(latestCmdHistory.getId());
                        shouldInsertCmd = false;
                    }
                }

                if (shouldInsertCmd) {
                    deviceMapper.insertStatusHistory(statusHistory);
                }

                // 更新设备的最新在线/状态时间戳（保持在线）
                device.setLastHeartbeatTime(LocalDateTime.now());
                device.setOnlineStatus(1);
                device.setStatus("online");
                device.setUpdatedAt(LocalDateTime.now());
                deviceMapper.updateDevice(device);

                // 广播到监控通道，包含门禁字段
                try {
                    Map<String, Object> statusUpdate = new HashMap<>();
                    statusUpdate.put("deviceId", device.getId());
                    statusUpdate.put("deviceCode", device.getDeviceCode());
                    statusUpdate.put("onlineStatus", device.getOnlineStatus());
                    statusUpdate.put("status", device.getStatus());
                    statusUpdate.put("lastHeartbeatTime", device.getLastHeartbeatTime());
                    statusUpdate.put("doorStatus", statusHistory.getDoorStatus());
                    statusUpdate.put("doorControllerStatus", statusHistory.getDoorControllerStatus());
                    statusUpdate.put("statusId", statusHistory.getId());
                    com.distributed.monitor.websocket.MonitorWebSocketServer.broadcastStatus("device_status_update", statusUpdate);
                } catch (Exception ignored) {
                    // 不影响主流程
                }
            }
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("received", true);
        result.put("commandLogId", log.getId());
        
        return result;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> confirmConfigSyncInternal(String deviceCode, List<String> configKeys) {
        // 不进行认证验证，直接处理（用于WebSocket）
        
        // 根据设备编码查询设备
        Device device = deviceMapper.selectDeviceByCode(deviceCode);
        if (device == null) {
            throw new NotFoundException("设备不存在");
        }
        
        // 标记配置为已同步
        LocalDateTime syncTime = LocalDateTime.now();
        // 根据configKeys更新对应的配置项同步状态
        deviceMapper.markConfigAsSynced(device.getId(), configKeys, syncTime);
        
        Map<String, Object> result = new HashMap<>();
        result.put("confirmed", true);
        result.put("confirmedCount", configKeys != null ? configKeys.size() : 0);
        
        return result;
    }
}

