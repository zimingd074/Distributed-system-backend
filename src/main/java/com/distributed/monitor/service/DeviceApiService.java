package com.distributed.monitor.service;

import com.distributed.monitor.dto.deviceapi.CommandResultDTO;
import com.distributed.monitor.dto.deviceapi.DeviceHeartbeatDTO;
import com.distributed.monitor.dto.deviceapi.DeviceStatusReportDTO;
import com.distributed.monitor.vo.deviceapi.HeartbeatResponseVO;
import com.distributed.monitor.vo.deviceapi.StatusReportResponseVO;

import java.util.List;
import java.util.Map;

/**
 * 设备端API服务接口
 */
public interface DeviceApiService {
    
    /**
     * 验证设备凭证（device_code和device_secret）
     */
    void validateDeviceCredentials(String deviceCode, String deviceSecret);
    
    /**
     * 处理设备心跳
     */
    HeartbeatResponseVO handleHeartbeat(DeviceHeartbeatDTO dto);
    
    /**
     * 处理状态上报
     */
    StatusReportResponseVO handleStatusReport(DeviceStatusReportDTO dto);
    
    /**
     * 获取待执行命令
     */
    List<Map<String, Object>> getPendingCommands(String deviceCode, String deviceSecret);
    
    /**
     * 上报命令执行结果
     */
    Map<String, Object> reportCommandResult(Long id, CommandResultDTO dto);
    
    /**
     * 获取设备配置
     */
    List<Map<String, Object>> getDeviceConfig(String deviceCode, String deviceSecret);
    
    /**
     * 确认配置同步
     */
    Map<String, Object> confirmConfigSync(String deviceCode, String deviceSecret, List<String> configKeys);
    
    /**
     * 处理状态上报（内部方法，不进行认证验证，用于WebSocket）
     */
    StatusReportResponseVO handleStatusReportInternal(DeviceStatusReportDTO dto);
    
    /**
     * 上报命令执行结果（内部方法，不进行认证验证，用于WebSocket）
     */
    Map<String, Object> reportCommandResultInternal(Long id, CommandResultDTO dto);
    
    /**
     * 确认配置同步（内部方法，不进行认证验证，用于WebSocket）
     */
    Map<String, Object> confirmConfigSyncInternal(String deviceCode, List<String> configKeys);
}

