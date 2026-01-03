package com.distributed.monitor.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.StrUtil;
import cn.hutool.json.JSONUtil;
import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.dto.command.SendCommandDTO;
import com.distributed.monitor.entity.Device;
import com.distributed.monitor.entity.DeviceCommand;
import com.distributed.monitor.entity.DeviceCommandLog;
import com.distributed.monitor.entity.SysUser;
import com.distributed.monitor.exception.BusinessException;
import com.distributed.monitor.exception.NotFoundException;
import com.distributed.monitor.exception.UnauthorizedException;
import com.distributed.monitor.mapper.AuthMapper;
import com.distributed.monitor.mapper.CommandMapper;
import com.distributed.monitor.mapper.DeviceMapper;
import com.distributed.monitor.service.CommandService;
import com.distributed.monitor.util.RequestUtil;
import com.distributed.monitor.vo.command.CommandLogVO;
import com.distributed.monitor.vo.command.CommandVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 命令服务实现
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class CommandServiceImpl implements CommandService {
    
    private final CommandMapper commandMapper;
    private final DeviceMapper deviceMapper;
    private final AuthMapper authMapper;
    
    @Override
    public List<CommandVO> getCommandList(String commandType) {
        List<DeviceCommand> commandList = commandMapper.selectCommandList(commandType);
        return commandList.stream()
                .map(command -> {
                    CommandVO vo = BeanUtil.copyProperties(command, CommandVO.class);
                    vo.setCommandId(command.getId());
                    // 解析JSON Schema
                    if (StrUtil.isNotBlank(command.getParamSchema())) {
                        vo.setParamSchema(JSONUtil.parseObj(command.getParamSchema()));
                    }
                    vo.setIsActive(command.getIsActive() != null && command.getIsActive() == 1);
                    return vo;
                })
                .collect(Collectors.toList());
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> sendCommand(Long deviceId, SendCommandDTO dto) {
        // 检查设备是否存在
        Device device = deviceMapper.selectDeviceById(deviceId);
        if (device == null) {
            throw new NotFoundException("设备不存在");
        }
        
        // 查询命令信息
        DeviceCommand command = commandMapper.selectCommandByCode(dto.getCommandCode());
        if (command == null) {
            throw new NotFoundException("命令不存在");
        }
        
        // 检查命令是否启用
        if (command.getIsActive() == null || command.getIsActive() == 0) {
            throw new BusinessException("命令已禁用");
        }
        
        // 创建命令执行记录
        DeviceCommandLog commandLog = new DeviceCommandLog();
        commandLog.setDeviceId(deviceId);
        commandLog.setCommandId(command.getId());
        commandLog.setCommandCode(command.getCommandCode());
        commandLog.setCommandParams(JSONUtil.toJsonStr(dto.getCommandParams()));
        
        // 从请求中获取当前用户ID
        Long currentUserId = RequestUtil.getCurrentUserId();
        if (currentUserId == null) {
            throw new UnauthorizedException("未登录或Token无效");
        }
        commandLog.setExecuteUserId(currentUserId);
        
        commandLog.setExecuteTime(LocalDateTime.now());
        // 服务器创建命令后直接标记为 pending，设备通过轮询接口获取后再上报执行结果
        commandLog.setStatus("pending");
        
        // 插入命令执行记录
        commandMapper.insertCommandLog(commandLog);
        
        // 构建命令数据
        Map<String, Object> commandData = new HashMap<>();
        commandData.put("commandLogId", commandLog.getId());
        commandData.put("commandCode", command.getCommandCode());
        commandData.put("commandParams", dto.getCommandParams());
        commandData.put("executeTime", commandLog.getExecuteTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        
        // 尝试通过WebSocket发送命令到设备
        try {
            com.distributed.monitor.websocket.DeviceWebSocketServer.sendCommand(device.getDeviceCode(), commandData);
            log.info("Command sent via WebSocket to device: {}", device.getDeviceCode());
        } catch (Exception e) {
            log.warn("Failed to send command via WebSocket to device: {}, error: {}", 
                    device.getDeviceCode(), e.getMessage());
            // 如果WebSocket发送失败，命令仍然保存在数据库中，设备可以通过HTTP轮询获取
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("commandLogId", commandLog.getId());
        result.put("deviceId", deviceId);
        result.put("deviceName", device.getDeviceName());
        result.put("commandCode", command.getCommandCode());
        result.put("status", commandLog.getStatus());
        result.put("executeTime", commandLog.getExecuteTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        
        return result;
    }
    
    @Override
    public CommandLogVO getCommandLog(Long id) {
        DeviceCommandLog log = commandMapper.selectCommandLogById(id);
        if (log == null) {
            throw new NotFoundException("命令执行记录不存在");
        }
        
        CommandLogVO vo = BeanUtil.copyProperties(log, CommandLogVO.class);
        vo.setCommandLogId(log.getId());
        
        // 查询设备信息
        Device device = deviceMapper.selectDeviceById(log.getDeviceId());
        if (device != null) {
            vo.setDeviceName(device.getDeviceName());
        }
        
        // 查询命令信息
        DeviceCommand command = commandMapper.selectCommandByCode(log.getCommandCode());
        if (command != null) {
            vo.setCommandName(command.getCommandName());
        }
        
        // 解析JSON字段
        if (StrUtil.isNotBlank(log.getCommandParams())) {
            vo.setCommandParams(JSONUtil.parseObj(log.getCommandParams()));
        }
        if (StrUtil.isNotBlank(log.getResponseData())) {
            vo.setResponseData(JSONUtil.parseObj(log.getResponseData()));
        }
        
        // 查询执行用户信息
        if (log.getExecuteUserId() != null) {
            SysUser user = authMapper.selectUserById(log.getExecuteUserId());
            if (user != null) {
                vo.setExecuteUser(user.getUsername());
            } else {
                vo.setExecuteUser(null);
            }
        } else {
            vo.setExecuteUser(null);
        }
        
        return vo;
    }
    
    @Override
    public PageResult<CommandLogVO> getCommandHistory(Long deviceId, Integer page, Integer pageSize) {
        // 验证分页参数
        if (page == null || page < 1) {
            page = 1;
        }
        if (pageSize == null || pageSize < 1) {
            pageSize = 10;
        }
        if (pageSize > 100) {
            pageSize = 100; // 最大100
        }
        
        // 检查设备是否存在
        Device device = deviceMapper.selectDeviceById(deviceId);
        if (device == null) {
            throw new NotFoundException("设备不存在");
        }
        
        // 计算分页参数
        int offset = (page - 1) * pageSize;
        
        // 查询总数
        Long total = commandMapper.countCommandHistory(deviceId);
        
        // 查询列表
        List<DeviceCommandLog> logList = commandMapper.selectCommandHistory(deviceId, offset, pageSize);
        
        // 转换为VO（手动赋值以避免 Hutool 在 String->Map 转换时抛出异常）
        List<CommandLogVO> list = logList.stream()
                .map(log -> {
                    CommandLogVO vo = new CommandLogVO();
                    // 基本字段
                    vo.setCommandLogId(log.getId());
                    vo.setDeviceId(log.getDeviceId());
                    vo.setCommandCode(log.getCommandCode());
                    vo.setExecuteTime(log.getExecuteTime());
                    vo.setStatus(log.getStatus());
                    vo.setErrorMessage(log.getErrorMessage());
                    vo.setResponseTime(log.getResponseTime());
                    vo.setDuration(log.getDuration());

                    // 查询设备信息（使用不同的变量名避免与外部作用域的device冲突）
                    Device logDevice = deviceMapper.selectDeviceById(log.getDeviceId());
                    if (logDevice != null) {
                        vo.setDeviceName(logDevice.getDeviceName());
                    }

                    // 查询命令信息
                    DeviceCommand command = commandMapper.selectCommandByCode(log.getCommandCode());
                    if (command != null) {
                        vo.setCommandName(command.getCommandName());
                    }

                    // 解析JSON字段为 Map
                    if (StrUtil.isNotBlank(log.getCommandParams())) {
                        vo.setCommandParams(JSONUtil.parseObj(log.getCommandParams()));
                    }
                    if (StrUtil.isNotBlank(log.getResponseData())) {
                        vo.setResponseData(JSONUtil.parseObj(log.getResponseData()));
                    }

                    // 查询执行用户信息
                    if (log.getExecuteUserId() != null) {
                        SysUser user = authMapper.selectUserById(log.getExecuteUserId());
                        if (user != null) {
                            vo.setExecuteUser(user.getUsername());
                        } else {
                            vo.setExecuteUser(null);
                        }
                    } else {
                        vo.setExecuteUser(null);
                    }

                    return vo;
                })
                .collect(Collectors.toList());
        
        return new PageResult<>(total, list, page, pageSize);
    }
}

