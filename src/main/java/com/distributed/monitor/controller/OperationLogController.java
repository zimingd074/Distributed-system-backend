package com.distributed.monitor.controller;

import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.common.Result;
import com.distributed.monitor.service.OperationLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 操作日志控制器
 */
@RestController
@RequestMapping("/logs")
@RequiredArgsConstructor
public class OperationLogController {
    
    private final OperationLogService operationLogService;
    
    /**
     * 8.1 获取操作日志
     */
    @GetMapping("/operations")
    public Result<PageResult<Map<String, Object>>> getOperationLogs(
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) String operationType,
            @RequestParam(required = false) String operationModule,
            @RequestParam(required = false) String startTime,
            @RequestParam(required = false) String endTime,
            @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<Map<String, Object>> pageResult = operationLogService.getOperationLogs(
                userId, operationType, operationModule, startTime, endTime, status, page, pageSize);
        return Result.success("获取成功", pageResult);
    }
}

