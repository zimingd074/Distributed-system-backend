package com.distributed.monitor.controller;

import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.common.Result;
import com.distributed.monitor.dto.alert.AlertQueryDTO;
import com.distributed.monitor.dto.alert.AlertResolveDTO;
import com.distributed.monitor.service.AlertService;
import com.distributed.monitor.vo.alert.AlertListVO;
import com.distributed.monitor.vo.alert.AlertStatisticsVO;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 告警管理控制器
 */
@RestController
@RequestMapping("/alerts")
@RequiredArgsConstructor
public class AlertController {
    
    private final AlertService alertService;
    
    /**
     * 6.1 获取告警列表
     */
    @GetMapping
    public Result<PageResult<AlertListVO>> getAlertList(@Validated AlertQueryDTO dto) {
        PageResult<AlertListVO> pageResult = alertService.getAlertList(dto);
        return Result.success("获取成功", pageResult);
    }
    
    /**
     * 6.2 获取告警详情
     */
    @GetMapping("/{id}")
    public Result<Map<String, Object>> getAlertDetail(@PathVariable Long id) {
        Map<String, Object> detail = alertService.getAlertDetail(id);
        return Result.success("获取成功", detail);
    }
    
    /**
     * 6.3 确认告警
     */
    @PutMapping("/{id}/confirm")
    public Result<Map<String, Object>> confirmAlert(@PathVariable Long id) {
        Map<String, Object> result = alertService.confirmAlert(id);
        return Result.success("告警已确认", result);
    }
    
    /**
     * 6.4 解决告警
     */
    @PutMapping("/{id}/resolve")
    public Result<Map<String, Object>> resolveAlert(
            @PathVariable Long id,
            @RequestBody AlertResolveDTO dto) {
        Map<String, Object> result = alertService.resolveAlert(id, dto);
        return Result.success("告警已解决", result);
    }
    
    /**
     * 6.5 忽略告警
     */
    @PutMapping("/{id}/ignore")
    public Result<Map<String, Object>> ignoreAlert(@PathVariable Long id) {
        Map<String, Object> result = alertService.ignoreAlert(id);
        return Result.success("告警已忽略", result);
    }
    
    /**
     * 6.6 获取告警统计
     */
    @GetMapping("/statistics")
    public Result<AlertStatisticsVO> getAlertStatistics(
            @RequestParam(required = false) String timeRange) {
        AlertStatisticsVO statisticsVO = alertService.getAlertStatistics(timeRange);
        return Result.success("获取成功", statisticsVO);
    }
}

