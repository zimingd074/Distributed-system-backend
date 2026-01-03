package com.distributed.monitor.controller;

import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.common.Result;
import com.distributed.monitor.entity.ReportConfig;
import com.distributed.monitor.service.AdminReportConfigService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 管理端-报表配置
 * 对应接口设计 /admin/report-configs
 */
@RestController
@RequestMapping("/admin/report-configs")
@RequiredArgsConstructor
public class AdminReportConfigController {

    private final AdminReportConfigService adminReportConfigService;

    @GetMapping
    public Result<PageResult<ReportConfig>> listConfigs(
            @RequestParam(required = false) String reportType,
            @RequestParam(required = false) Boolean isActive,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<ReportConfig> result = adminReportConfigService.listConfigs(reportType, isActive, page, pageSize);
        return Result.success("获取成功", result);
    }

    @PostMapping
    public Result<Map<String, Object>> createConfig(@RequestBody ReportConfig config) {
        Map<String, Object> result = adminReportConfigService.createConfig(config);
        return Result.success("创建成功", result);
    }

    @PutMapping("/{id}")
    public Result<Void> updateConfig(@PathVariable Long id, @RequestBody ReportConfig config) {
        config.setId(id);
        adminReportConfigService.updateConfig(config);
        return Result.success("更新成功", null);
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteConfig(@PathVariable Long id) {
        adminReportConfigService.deleteConfig(id);
        return Result.success("删除成功", null);
    }
}

