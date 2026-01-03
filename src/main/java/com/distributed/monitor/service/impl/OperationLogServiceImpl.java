package com.distributed.monitor.service.impl;

import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.entity.SysOperationLog;
import com.distributed.monitor.mapper.OperationLogMapper;
import com.distributed.monitor.service.OperationLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 操作日志服务实现
 */
@Service
@RequiredArgsConstructor
public class OperationLogServiceImpl implements OperationLogService {
    
    private final OperationLogMapper operationLogMapper;
    
    @Override
    public PageResult<Map<String, Object>> getOperationLogs(
            Long userId, String operationType, String operationModule,
            String startTime, String endTime, Integer status,
            Integer page, Integer pageSize) {
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
        
        // 计算分页参数
        int offset = (page - 1) * pageSize;
        
        // 查询总数
        Long total = operationLogMapper.countOperationLogs(
                userId, operationType, operationModule, startTime, endTime, status);
        
        // 查询列表
        List<SysOperationLog> logList = operationLogMapper.selectOperationLogs(
                userId, operationType, operationModule, startTime, endTime, status,
                offset, pageSize);
        
        // 转换为Map
        List<Map<String, Object>> list = logList.stream()
                .map(log -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", log.getId());
                    map.put("userId", log.getUserId());
                    map.put("username", log.getUsername());
                    map.put("operationType", log.getOperationType());
                    map.put("operationModule", log.getOperationModule());
                    map.put("operationDesc", log.getOperationDesc());
                    map.put("requestMethod", log.getRequestMethod());
                    map.put("requestUrl", log.getRequestUrl());
                    map.put("ipAddress", log.getIpAddress());
                    map.put("status", log.getStatus());
                    map.put("errorMessage", log.getErrorMessage());
                    map.put("executeTime", log.getExecuteTime());
                    if (log.getCreatedAt() != null) {
                        map.put("createdAt", log.getCreatedAt().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
                    } else {
                        map.put("createdAt", null);
                    }
                    return map;
                })
                .collect(Collectors.toList());
        
        return new PageResult<>(total, list, page, pageSize);
    }
}

