package com.distributed.monitor.controller;

import com.distributed.monitor.annotation.NoAuth;
import com.distributed.monitor.common.Result;
import com.distributed.monitor.dto.deviceapi.CommandResultDTO;
import com.distributed.monitor.dto.deviceapi.ConfigSyncConfirmDTO;
import com.distributed.monitor.dto.deviceapi.DeviceHeartbeatDTO;
import com.distributed.monitor.dto.deviceapi.DeviceLoginDTO;
import com.distributed.monitor.dto.deviceapi.DeviceStatusReportDTO;
import com.distributed.monitor.service.DeviceApiService;
import com.distributed.monitor.service.DeviceAuthService;
import com.distributed.monitor.vo.deviceapi.DeviceLoginVO;
import com.distributed.monitor.vo.deviceapi.HeartbeatResponseVO;
import com.distributed.monitor.vo.deviceapi.StatusReportResponseVO;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 设备端API控制器（供分布式机器调用）
 */
@NoAuth
@RestController
@RequestMapping("/device")
@RequiredArgsConstructor
public class DeviceApiController {
    
    private final DeviceApiService deviceApiService;
    private final DeviceAuthService deviceAuthService;
    
    /**
     * 13.0 设备认证登录
     */
    @PostMapping("/auth/login")
    @NoAuth
    public Result<DeviceLoginVO> deviceLogin(@Validated @RequestBody DeviceLoginDTO dto) {
        DeviceLoginVO loginVO = deviceAuthService.deviceLogin(dto);
        return Result.success("设备认证成功", loginVO);
    }
    
    /**
     * 13.1 设备心跳
     */
    @PostMapping("/heartbeat")
    public Result<HeartbeatResponseVO> heartbeat(@Validated @RequestBody DeviceHeartbeatDTO dto) {
        HeartbeatResponseVO responseVO = deviceApiService.handleHeartbeat(dto);
        return Result.success("心跳接收成功", responseVO);
    }
    
    /**
     * 13.2 上报设备状态
     */
    @PostMapping("/status")
    public Result<StatusReportResponseVO> reportStatus(@Validated @RequestBody DeviceStatusReportDTO dto) {
        StatusReportResponseVO responseVO = deviceApiService.handleStatusReport(dto);
        return Result.success("状态上报成功", responseVO);
    }
    
    /**
     * 13.3 获取待执行命令
     */
    @GetMapping("/commands/pending")
    public Result<List<Map<String, Object>>> getPendingCommands(
            @RequestParam String deviceCode,
            @RequestParam String deviceSecret) {
        List<Map<String, Object>> commands = deviceApiService.getPendingCommands(deviceCode, deviceSecret);
        return Result.success("获取成功", commands);
    }
    
    /**
     * 13.4 上报命令执行结果
     */
    @PutMapping("/commands/{id}/result")
    public Result<Map<String, Object>> reportCommandResult(
            @PathVariable Long id,
            @Validated @RequestBody CommandResultDTO dto) {
        Map<String, Object> result = deviceApiService.reportCommandResult(id, dto);
        return Result.success("命令结果已接收", result);
    }
    
    /**
     * 13.5 获取配置信息
     */
    @GetMapping("/config")
    public Result<List<Map<String, Object>>> getDeviceConfig(
            @RequestParam String deviceCode,
            @RequestParam String deviceSecret) {
        List<Map<String, Object>> configs = deviceApiService.getDeviceConfig(deviceCode, deviceSecret);
        return Result.success("获取成功", configs);
    }
    
    /**
     * 13.6 确认配置同步
     */
    @PostMapping("/config/confirm")
    public Result<Map<String, Object>> confirmConfigSync(
            @Validated @RequestBody ConfigSyncConfirmDTO dto) {
        Map<String, Object> result = deviceApiService.confirmConfigSync(
                dto.getDeviceCode(), dto.getDeviceSecret(), dto.getConfigKeys());
        return Result.success("配置同步确认成功", result);
    }
}

