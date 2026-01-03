package com.distributed.monitor.controller;

import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.common.Result;
import com.distributed.monitor.dto.command.SendCommandDTO;
import com.distributed.monitor.dto.device.*;
import com.distributed.monitor.service.CommandService;
import com.distributed.monitor.vo.command.CommandLogVO;
import com.distributed.monitor.vo.command.CommandVO;
import com.distributed.monitor.vo.device.*;
import com.distributed.monitor.service.DeviceService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 设备管理控制器
 */
@RestController
@RequestMapping("/devices")
@RequiredArgsConstructor
public class DeviceController {
    @Autowired
    private CommandService commandService;
    @Autowired
    private DeviceService deviceService;
    
    /**
     * 2.1 获取设备列表
     */
    @GetMapping
    public Result<PageResult<DeviceListVO>> getDeviceList(@Validated DeviceQueryDTO dto) {
        PageResult<DeviceListVO> pageResult = deviceService.getDeviceList(dto);
        return Result.success("获取成功", pageResult);
    }
    
    /**
     * 2.2 获取设备详情
     */
    @GetMapping("/{id}")
    public Result<DeviceDetailVO> getDeviceDetail(@PathVariable Long id) {
        DeviceDetailVO detailVO = deviceService.getDeviceDetail(id);
        return Result.success("获取成功", detailVO);
    }
    
    /**
     * 2.3 添加设备
     */
    @PostMapping
    public Result<Map<String, Object>> addDevice(@Validated @RequestBody DeviceAddDTO dto) {
        Map<String, Object> result = deviceService.addDevice(dto);
        return Result.success("添加成功", result);
    }
    
    /**
     * 2.4 更新设备信息
     */
    @PutMapping("/{id}")
    public Result<Void> updateDevice(@PathVariable Long id, @Validated @RequestBody DeviceUpdateDTO dto) {
        dto.setId(id);
        deviceService.updateDevice(dto);
        return Result.success("更新成功", null);
    }
    
    /**
     * 2.5 删除设备
     */
    @DeleteMapping("/{id}")
    public Result<Void> deleteDevice(@PathVariable Long id) {
        deviceService.deleteDevice(id);
        return Result.success("删除成功", null);
    }
    
    /**
     * 2.6 获取设备分组
     */
    @GetMapping("/device-groups")
    public Result<List<Map<String, Object>>> getDeviceGroups() {
        List<Map<String, Object>> groups = deviceService.getDeviceGroups();
        return Result.success("获取成功", groups);
    }
    
    /**
     * 2.7 获取设备统计
     */
    @GetMapping("/statistics")
    public Result<DeviceStatisticsVO> getDeviceStatistics() {
        DeviceStatisticsVO statisticsVO = deviceService.getDeviceStatistics();
        return Result.success("获取成功", statisticsVO);
    }
    
    /**
     * 3.1 获取设备配置
     */
    @GetMapping("/{id}/config")
    public Result<List<DeviceConfigVO>> getDeviceConfig(@PathVariable Long id) {
        List<DeviceConfigVO> configList = deviceService.getDeviceConfig(id);
        return Result.success("获取成功", configList);
    }
    
    /**
     * 3.2 更新设备配置
     */
    @PutMapping("/{id}/config")
    public Result<Map<String, Object>> updateDeviceConfig(
            @PathVariable Long id,
            @Validated @RequestBody DeviceConfigUpdateDTO dto) {
        Map<String, Object> result = deviceService.updateDeviceConfig(id, dto);
        return Result.success("配置更新成功", result);
    }
    
    /**
     * 3.3 同步配置到设备
     */
    @PostMapping("/{id}/config/sync")
    public Result<Map<String, Object>> syncDeviceConfig(@PathVariable Long id) {
        Map<String, Object> result = deviceService.syncDeviceConfig(id);
        // 如果通过 WebSocket 成功推送并标记为已同步，返回成功；否则返回失败并携带详细信息（前端可根据 data.status/pushedViaWebSocket 处理）
        Object pushedObj = result.get("pushedViaWebSocket");
        boolean pushedViaWebSocket = pushedObj instanceof Boolean ? (Boolean) pushedObj : false;
        if (pushedViaWebSocket) {
            return Result.success("配置同步成功", result);
        } else {
            return Result.fail("配置同步失败：设备不在线或推送失败，已排队等待设备确认", result);
        }
    }

    /**
     * 5.2.5 批量获取设备状态历史（按时间范围，支持多设备筛选）
     */
    @GetMapping("/status/history")
    public Result<PageResult<DeviceStatusVO>> getDeviceStatusHistoryBulk(@Validated DeviceStatusBulkQueryDTO dto) {
        PageResult<DeviceStatusVO> page = deviceService.getDeviceStatusHistoryBulk(dto);
        return Result.success("获取成功", page);
    }

    /**
     * 4.1 获取命令列表
     */
    @GetMapping("/commands")
    public Result<List<CommandVO>> getCommandList(@RequestParam(required = false) String commandType) {
        List<CommandVO> commands = commandService.getCommandList(commandType);
        return Result.success("获取成功", commands);
    }

    /**
     * 4.2 发送控制命令
     */
    @PostMapping("/{id}/commands")
    public Result<Map<String, Object>> sendCommand(
            @PathVariable Long id,
            @Validated @RequestBody SendCommandDTO dto) {
        Map<String, Object> result = commandService.sendCommand(id, dto);
        return Result.success("命令已发送", result);
    }

    /**
     * 4.3 查询命令执行状态
     */
    @GetMapping("/commands/logs/{id}")
    public Result<CommandLogVO> getCommandLog(@PathVariable Long id) {
        CommandLogVO commandLogVO = commandService.getCommandLog(id);
        return Result.success("获取成功", commandLogVO);
    }

    /**
     * 4.4 获取命令执行历史
     */
    @GetMapping("/{id}/commands/history")
    public Result<PageResult<CommandLogVO>> getCommandHistory(
            @PathVariable Long id,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<CommandLogVO> pageResult = commandService.getCommandHistory(id, page, pageSize);
        return Result.success("获取成功", pageResult);
    }
    
    /**
     * 5.1 获取设备实时状态
     */
    @GetMapping("/{id}/status")
    public Result<DeviceStatusVO> getDeviceStatus(@PathVariable Long id) {
        DeviceStatusVO statusVO = deviceService.getDeviceStatus(id);
        return Result.success("获取成功", statusVO);
    }
    
    /**
     * 5.2 获取设备状态历史
     */
    @GetMapping("/{id}/status/history")
    public Result<List<DeviceStatusVO>> getDeviceStatusHistory(
            @PathVariable Long id,
            @Validated DeviceStatusQueryDTO dto) {
        List<DeviceStatusVO> history = deviceService.getDeviceStatusHistory(id, dto);
        return Result.success("获取成功", history);
    }
    
    /**
     * 5.3 获取设备心跳记录
     */
    @GetMapping("/{id}/heartbeat")
    public Result<List<Map<String, Object>>> getDeviceHeartbeat(
            @PathVariable Long id,
            @RequestParam(required = false) String startTime,
            @RequestParam(required = false) String endTime,
            @RequestParam(required = false) Integer limit) {
        List<Map<String, Object>> heartbeats = deviceService.getDeviceHeartbeat(id, startTime, endTime, limit);
        return Result.success("获取成功", heartbeats);
    }
}

