package com.distributed.monitor.controller;

import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.common.Result;
import com.distributed.monitor.dto.report.ReportGenerateDTO;
import com.distributed.monitor.service.ReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 报表管理控制器
 */
@RestController
@RequestMapping("/reports")
@RequiredArgsConstructor
public class ReportController {
    
    private final ReportService reportService;
    
    /**
     * 7.1 获取报表配置列表
     */
    @GetMapping("/configs")
    public Result<List<Map<String, Object>>> getReportConfigs() {
        List<Map<String, Object>> configs = reportService.getReportConfigs();
        return Result.success("获取成功", configs);
    }
    
    /**
     * 7.2 生成报表
     */
    @PostMapping("/generate")
    public Result<Map<String, Object>> generateReport(@Validated @RequestBody ReportGenerateDTO dto) {
        Map<String, Object> result = reportService.generateReport(dto);
        return Result.success("报表生成任务已创建", result);
    }
    
    /**
     * 7.3 获取报表生成记录
     */
    @GetMapping("/logs")
    public Result<PageResult<Map<String, Object>>> getReportLogs(
            @RequestParam(required = false) String reportCode,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String startTime,
            @RequestParam(required = false) String endTime,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<Map<String, Object>> pageResult = reportService.getReportLogs(
                reportCode, status, startTime, endTime, page, pageSize);
        return Result.success("获取成功", pageResult);
    }
    
    /**
     * 7.4 下载报表
     */
    @GetMapping("/download/{id}")
    public ResponseEntity<Resource> downloadReport(@PathVariable Long id) {
        return reportService.downloadReport(id);
    }
}

