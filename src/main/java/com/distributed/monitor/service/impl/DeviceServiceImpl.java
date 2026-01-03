package com.distributed.monitor.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.StrUtil;
import cn.hutool.crypto.digest.DigestUtil;
import cn.hutool.json.JSONUtil;
import java.security.SecureRandom;
import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.dto.device.*;
import com.distributed.monitor.entity.Device;
import com.distributed.monitor.entity.DeviceConfig;
import com.distributed.monitor.entity.DeviceGroup;
import com.distributed.monitor.entity.DeviceStatusHistory;
import com.distributed.monitor.exception.BusinessException;
import com.distributed.monitor.exception.NotFoundException;
import com.distributed.monitor.mapper.DeviceMapper;
import com.distributed.monitor.service.DeviceService;
import com.distributed.monitor.vo.device.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 设备服务实现
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class DeviceServiceImpl implements DeviceService {
    
    private final DeviceMapper deviceMapper;
    
    // 明确声明 logger，避免 Lombok 注解在某些编译环境下没有被处理时找不到 log 的情况
    private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(DeviceServiceImpl.class);
    
    @Override
    public PageResult<DeviceListVO> getDeviceList(DeviceQueryDTO dto) {
        // 计算分页参数
        int offset = (dto.getPage() - 1) * dto.getPageSize();
        
        // 查询总数
        Long total = deviceMapper.countDevices(dto);
        
        // 查询设备实体列表
        List<Device> deviceList = deviceMapper.selectDeviceList(dto, offset, dto.getPageSize());
        
        // 转换为VO
        List<DeviceListVO> list = deviceList.stream()
                .map(device -> {
                    DeviceListVO vo = BeanUtil.copyProperties(device, DeviceListVO.class);
                    // 查询分组名称
                    if (device.getGroupId() != null) {
                        DeviceGroup group = deviceMapper.selectDeviceGroupById(device.getGroupId());
                        if (group != null) {
                            vo.setGroupName(group.getGroupName());
                        }
                    }
                    return vo;
                })
                .collect(Collectors.toList());
        
        return new PageResult<>(total, list, dto.getPage(), dto.getPageSize());
    }
    
    @Override
    public DeviceDetailVO getDeviceDetail(Long id) {
        // 查询设备实体
        Device device = deviceMapper.selectDeviceById(id);
        if (device == null) {
            throw new NotFoundException("设备不存在");
        }
        
        // 转换为VO
        DeviceDetailVO detail = BeanUtil.copyProperties(device, DeviceDetailVO.class);
        
        // 查询分组名称
        if (device.getGroupId() != null) {
            DeviceGroup group = deviceMapper.selectDeviceGroupById(device.getGroupId());
            if (group != null) {
                detail.setGroupName(group.getGroupName());
            }
        }
        
        // 查询当前状态
        DeviceStatusHistory latestStatus = deviceMapper.selectDeviceLatestStatusHistory(id);
        if (latestStatus != null) {
            DeviceDetailVO.CurrentStatus currentStatus = new DeviceDetailVO.CurrentStatus();
            currentStatus.setDoorStatus(latestStatus.getDoorStatus());
            currentStatus.setDoorControllerStatus(latestStatus.getDoorControllerStatus());
            detail.setCurrentStatus(currentStatus);
        }
        
        return detail;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> addDevice(DeviceAddDTO dto) {
        // 检查设备编码是否已存在
        if (deviceMapper.existsByDeviceCode(dto.getDeviceCode())) {
            throw new BusinessException("设备编码已存在");
        }
        
        // DTO转Entity
        Device device = BeanUtil.copyProperties(dto, Device.class);
        device.setStatus("offline");
        device.setOnlineStatus(0);
        device.setWsConnected(0);
        device.setRegisterTime(LocalDateTime.now());
        device.setCreatedAt(LocalDateTime.now());
        device.setUpdatedAt(LocalDateTime.now());
        
        // 生成设备密钥（32位十六进制字符串）
        String deviceSecret = generateDeviceSecret(device.getDeviceCode());
        device.setDeviceSecret(deviceSecret);
        
        // 插入设备
        deviceMapper.insertDevice(device);
        
        Map<String, Object> result = new HashMap<>();
        result.put("id", device.getId());
        result.put("deviceCode", device.getDeviceCode());
        result.put("deviceName", device.getDeviceName());
        result.put("deviceSecret", deviceSecret); // 返回设备密钥（仅在创建时返回一次）
        result.put("createdAt", device.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        
        return result;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateDevice(DeviceUpdateDTO dto) {
        // 检查设备是否存在
        Device existDevice = deviceMapper.selectDeviceById(dto.getId());
        if (existDevice == null) {
            throw new NotFoundException("设备不存在");
        }
        
        // DTO转Entity，只更新非空字段
        Device device = BeanUtil.copyProperties(dto, Device.class);
        device.setUpdatedAt(LocalDateTime.now());
        
        deviceMapper.updateDevice(device);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteDevice(Long id) {
        // 检查设备是否存在
        if (!deviceMapper.existsById(id)) {
            throw new NotFoundException("设备不存在");
        }
        
        deviceMapper.deleteDevice(id);
    }
    
    @Override
    public List<Map<String, Object>> getDeviceGroups() {
        List<DeviceGroup> groups = deviceMapper.selectDeviceGroups();
        
        // 转换为Map列表
        List<Map<String, Object>> groupList = groups.stream()
                .map(group -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", group.getId());
                    map.put("groupName", group.getGroupName());
                    map.put("groupCode", group.getGroupCode());
                    map.put("parentId", group.getParentId() != null ? group.getParentId() : 0);
                    map.put("description", group.getDescription());
                    map.put("sortOrder", group.getSortOrder() != null ? group.getSortOrder() : 0);
                    map.put("children", new ArrayList<>()); // 初始化children
                    return map;
                })
                .collect(Collectors.toList());
        
        // 构建树形结构
        Map<Long, Map<String, Object>> groupMap = new HashMap<>();
        List<Map<String, Object>> rootGroups = new ArrayList<>();
        
        // 第一遍：建立索引
        for (Map<String, Object> group : groupList) {
            Long id = ((Number) group.get("id")).longValue();
            groupMap.put(id, group);
        }
        
        // 第二遍：构建树形结构
        for (Map<String, Object> group : groupList) {
            Long parentId = ((Number) group.get("parentId")).longValue();
            if (parentId == 0 || !groupMap.containsKey(parentId)) {
                // 根节点
                rootGroups.add(group);
            } else {
                // 子节点，添加到父节点的children中
                Map<String, Object> parent = groupMap.get(parentId);
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> children = (List<Map<String, Object>>) parent.get("children");
                children.add(group);
            }
        }
        
        return rootGroups;
    }
    
    @Override
    public DeviceStatisticsVO getDeviceStatistics() {
        // 获取基本统计
        DeviceStatisticsVO statistics = deviceMapper.selectDeviceStatistics();
        
        // 获取分组统计
        List<DeviceStatisticsVO.GroupStatistics> groupStatistics = deviceMapper.selectGroupStatistics();
        statistics.setGroupStatistics(groupStatistics);
        
        return statistics;
    }
    
    @Override
    public List<DeviceConfigVO> getDeviceConfig(Long id) {
        // 检查设备是否存在
        Device device = deviceMapper.selectDeviceById(id);
        if (device == null) {
            throw new NotFoundException("设备不存在");
        }
        
        List<DeviceConfig> configList = deviceMapper.selectDeviceConfig(id);
        return configList.stream()
                .map(config -> {
                    DeviceConfigVO vo = BeanUtil.copyProperties(config, DeviceConfigVO.class);
                    vo.setConfigId(config.getId());
                    vo.setIsSynced(config.getIsSynced() != null && config.getIsSynced() == 1);
                    return vo;
                })
                .collect(Collectors.toList());
    }
    
    @Override
    public PageResult<DeviceStatusVO> getDeviceStatusHistoryBulk(com.distributed.monitor.dto.device.DeviceStatusBulkQueryDTO dto) {
        // 分页参数
        Integer page = dto.getPage() == null || dto.getPage() < 1 ? 1 : dto.getPage();
        Integer pageSize = dto.getPageSize() == null || dto.getPageSize() < 1 ? 50 : dto.getPageSize();
        if (pageSize > 1000) {
            pageSize = 1000;
        }
        int offset = (page - 1) * pageSize;

        // 验证 interval
        if (dto.getInterval() != null && !dto.getInterval().isEmpty()) {
            String interval = dto.getInterval();
            if (!interval.matches("^(1m|5m|10m|30m|1h)$")) {
                throw new BusinessException("interval参数无效，支持的值：1m, 5m, 10m, 30m, 1h");
            }
        }

        // 计数和查询
        Long total = deviceMapper.countDeviceStatusHistoryBulk(dto.getDeviceIds(), dto.getDeviceCode(), dto.getGroupId(), dto);
        List<com.distributed.monitor.entity.DeviceStatusHistory> historyList = deviceMapper.selectDeviceStatusHistoryBulk(
                dto.getDeviceIds(), dto.getDeviceCode(), dto.getGroupId(), dto, offset, pageSize);

        List<DeviceStatusVO> rows = historyList.stream().map(h -> {
            DeviceStatusVO vo = new DeviceStatusVO();
            vo.setDeviceId(h.getDeviceId());
            // 设备名称
            Device d = deviceMapper.selectDeviceById(h.getDeviceId());
            if (d != null) {
                vo.setDeviceName(d.getDeviceName());
            }
            vo.setReportTime(h.getReportTime());
            vo.setDoorStatus(h.getDoorStatus());
            vo.setDoorControllerStatus(h.getDoorControllerStatus());
            if (StrUtil.isNotBlank(h.getStatusValue())) {
                try {
                    vo.setCustomData(JSONUtil.parseObj(h.getStatusValue()));
                } catch (Exception ignored) {
                }
            }
            return vo;
        }).collect(Collectors.toList());

        return new PageResult<>(total, rows, page, pageSize);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> updateDeviceConfig(Long id, DeviceConfigUpdateDTO dto) {
        // 检查设备是否存在
        Device device = deviceMapper.selectDeviceById(id);
        if (device == null) {
            throw new NotFoundException("设备不存在");
        }
        
        // 获取现有配置，用于保留configType和description
        List<DeviceConfig> existingConfigs = deviceMapper.selectDeviceConfig(id);
        Map<String, DeviceConfig> configMap = existingConfigs.stream()
                .collect(Collectors.toMap(DeviceConfig::getConfigKey, config -> config, (k1, k2) -> k1));
        
        int updatedCount = 0;
        for (DeviceConfigUpdateDTO.ConfigItem item : dto.getConfigs()) {
            DeviceConfig existingConfig = configMap.get(item.getConfigKey());
            
            DeviceConfig config = new DeviceConfig();
            config.setDeviceId(id);
            config.setConfigKey(item.getConfigKey());
            config.setConfigValue(item.getConfigValue());
            
            // 如果存在现有配置，保留configType和description；否则根据值推断类型
            if (existingConfig != null) {
                config.setConfigType(existingConfig.getConfigType());
                config.setDescription(existingConfig.getDescription());
            } else {
                // 根据配置值推断类型
                config.setConfigType(inferConfigType(item.getConfigValue()));
            }
            
            config.setIsSynced(0); // 更新后标记为未同步
            config.setUpdatedAt(LocalDateTime.now());
            
            deviceMapper.updateOrInsertConfig(config);
            updatedCount++;
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("updatedCount", updatedCount);
        result.put("needSync", true);
        
        return result;
    }
    
    /**
     * 根据配置值推断配置类型
     */
    private String inferConfigType(String configValue) {
        if (configValue == null || configValue.isEmpty()) {
            return "string";
        }
        
        // 尝试解析为数字
        try {
            Double.parseDouble(configValue);
            return "number";
        } catch (NumberFormatException e) {
            // 不是数字
        }
        
        // 检查是否为布尔值
        if ("true".equalsIgnoreCase(configValue) || "false".equalsIgnoreCase(configValue)) {
            return "boolean";
        }
        
        // 检查是否为JSON格式
        String trimmed = configValue.trim();
        if ((trimmed.startsWith("{") && trimmed.endsWith("}")) ||
            (trimmed.startsWith("[") && trimmed.endsWith("]"))) {
            return "json";
        }
        
        // 默认为字符串
        return "string";
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> syncDeviceConfig(Long id) {
        // 检查设备是否存在
        Device device = deviceMapper.selectDeviceById(id);
        if (device == null) {
            throw new NotFoundException("设备不存在");
        }
        
        // 获取未同步的配置项
        List<DeviceConfig> unsyncedConfigs = deviceMapper.selectUnsyncedConfig(id);
        
        if (unsyncedConfigs.isEmpty()) {
            // 没有需要同步的配置
            Map<String, Object> result = new HashMap<>();
            result.put("syncedCount", 0);
            result.put("syncTime", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            result.put("status", "success");
            return result;
        }
        
        // 构建配置数据
        List<Map<String, Object>> configList = unsyncedConfigs.stream()
                .map(config -> {
                    Map<String, Object> configMap = new HashMap<>();
                    configMap.put("configKey", config.getConfigKey());
                    configMap.put("configValue", config.getConfigValue());
                    configMap.put("configType", config.getConfigType());
                    configMap.put("description", config.getDescription());
                    return configMap;
                })
                .collect(Collectors.toList());
        
        Map<String, Object> configData = new HashMap<>();
        configData.put("configs", configList);
        configData.put("syncTime", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        
        LocalDateTime syncTime = LocalDateTime.now();
        boolean pushedViaWebSocket = false;
        
        // 尝试通过WebSocket推送配置到设备
        try {
            boolean isOnline = com.distributed.monitor.websocket.DeviceWebSocketServer.isDeviceOnline(device.getDeviceCode());
            if (isOnline) {
                com.distributed.monitor.websocket.DeviceWebSocketServer.pushConfig(device.getDeviceCode(), configData);
                log.info("Config pushed via WebSocket to device: {}", device.getDeviceCode());
                pushedViaWebSocket = true;
                
                // WebSocket推送成功，立即标记为已同步
                // 提取配置键列表
                List<String> configKeys = unsyncedConfigs.stream()
                        .map(DeviceConfig::getConfigKey)
                        .collect(Collectors.toList());
                deviceMapper.markConfigAsSynced(device.getId(), configKeys, syncTime);
                log.info("Config marked as synced after WebSocket push, deviceId={}, configKeys={}", 
                        device.getId(), configKeys);
            }
        } catch (Exception e) {
            log.warn("Failed to push config via WebSocket to device: {}, error: {}", 
                    device.getDeviceCode(), e.getMessage());
            // 如果WebSocket推送失败，配置仍然保存在数据库中，设备可以通过HTTP轮询获取
            // 不标记为已同步，等待设备通过HTTP接口获取并确认
        }
        
        // 如果设备不在线或WebSocket推送失败，不立即标记为已同步
        // 等待设备通过HTTP接口获取配置并确认同步，或设备上线后通过WebSocket确认
        
        Map<String, Object> result = new HashMap<>();
        result.put("syncedCount", pushedViaWebSocket ? unsyncedConfigs.size() : 0);
        result.put("syncTime", syncTime.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        result.put("status", pushedViaWebSocket ? "success" : "pending");
        result.put("pushedViaWebSocket", pushedViaWebSocket);
        
        return result;
    }
    
    @Override
    public DeviceStatusVO getDeviceStatus(Long id) {
        Device device = deviceMapper.selectDeviceById(id);
        if (device == null) {
            throw new NotFoundException("设备不存在");
        }
        
        DeviceStatusHistory latestStatus = deviceMapper.selectDeviceLatestStatusHistory(id);
        // 如果没有状态历史，则返回基础信息，避免直接抛 500
        if (latestStatus == null) {
            DeviceStatusVO vo = new DeviceStatusVO();
            vo.setDeviceId(device.getId());
            vo.setDeviceName(device.getDeviceName());
            vo.setOnlineStatus(device.getOnlineStatus());
            vo.setReportTime(LocalDateTime.now());
            vo.setDoorStatus("unknown");
            vo.setDoorControllerStatus("unknown");
            vo.setCustomData(null);
            return vo;
        }

        DeviceStatusVO vo = BeanUtil.copyProperties(latestStatus, DeviceStatusVO.class);
        vo.setDeviceId(device.getId());
        vo.setDeviceName(device.getDeviceName());
        vo.setOnlineStatus(device.getOnlineStatus());
        
        // 解析 statusValue JSON 字段（存放自定义数据）
        if (StrUtil.isNotBlank(latestStatus.getStatusValue())) {
            vo.setCustomData(JSONUtil.parseObj(latestStatus.getStatusValue()));
        }

        return vo;
    }
    
    @Override
    public List<DeviceStatusVO> getDeviceStatusHistory(Long id, DeviceStatusQueryDTO dto) {
        // 检查设备是否存在
        Device device = deviceMapper.selectDeviceById(id);
        if (device == null) {
            throw new NotFoundException("设备不存在");
        }
        
        // 验证interval参数（如果提供）
        if (dto.getInterval() != null && !dto.getInterval().isEmpty()) {
            String interval = dto.getInterval();
            if (!interval.matches("^(1m|5m|10m|30m|1h)$")) {
                throw new BusinessException("interval参数无效，支持的值：1m, 5m, 10m, 30m, 1h");
            }
        }
        
        List<DeviceStatusHistory> historyList = deviceMapper.selectDeviceStatusHistory(id, dto);
        
        // 根据接口文档，历史记录只返回状态字段，不包含deviceId, deviceName, onlineStatus
        return historyList.stream()
                .map(status -> {
                    DeviceStatusVO vo = new DeviceStatusVO();
                    vo.setReportTime(status.getReportTime());
                    vo.setDoorStatus(status.getDoorStatus());
                    vo.setDoorControllerStatus(status.getDoorControllerStatus());
                    // customData is a JSON string in status; parse if needed
                    // keep as map null here; DeviceStatusVO.customData populated elsewhere if necessary
                    // vo.setCustomData(...);
                    return vo;
                })
                .collect(Collectors.toList());
    }
    
    @Override
    public List<Map<String, Object>> getDeviceHeartbeat(Long id, String startTime, String endTime, Integer limit) {
        // 检查设备是否存在
        Device device = deviceMapper.selectDeviceById(id);
        if (device == null) {
            throw new NotFoundException("设备不存在");
        }
        
        // 参数验证和默认值设置
        if (limit == null || limit < 1) {
            limit = 100; // 默认100
        }
        if (limit > 1000) {
            limit = 1000; // 最大1000
        }
        
        // 如果没有指定时间范围，默认最近24小时
        if (startTime == null || startTime.isEmpty()) {
            startTime = LocalDateTime.now().minusHours(24).format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        }
        if (endTime == null || endTime.isEmpty()) {
            endTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        }
        
        List<com.distributed.monitor.entity.DeviceHeartbeat> heartbeats = 
                deviceMapper.selectDeviceHeartbeat(id, startTime, endTime, limit);
        
        return heartbeats.stream()
                .map(heartbeat -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", heartbeat.getId());
                    map.put("deviceId", heartbeat.getDeviceId());
                    map.put("heartbeatTime", heartbeat.getHeartbeatTime());
                    map.put("ipAddress", heartbeat.getIpAddress());
                    map.put("responseTime", heartbeat.getResponseTime());
                    map.put("createdAt", heartbeat.getCreatedAt());
                    
                    // 解析extraData JSON字段
                    if (StrUtil.isNotBlank(heartbeat.getExtraData())) {
                        map.put("extraData", JSONUtil.parseObj(heartbeat.getExtraData()));
                    } else {
                        map.put("extraData", null);
                    }
                    
                    return map;
                })
                .collect(Collectors.toList());
    }
    
    /**
     * 生成设备密钥
     * 使用设备编码、随机数和时间戳生成32位十六进制字符串
     */
    private String generateDeviceSecret(String deviceCode) {
        SecureRandom random = new SecureRandom();
        byte[] randomBytes = new byte[16];
        random.nextBytes(randomBytes);
        
        // 使用MD5生成32位十六进制字符串
        String randomStr = DigestUtil.md5Hex(deviceCode + System.currentTimeMillis() + new String(randomBytes));
        return randomStr;
    }
}

