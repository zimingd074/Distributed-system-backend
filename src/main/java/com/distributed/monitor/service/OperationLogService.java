package com.distributed.monitor.service;

import com.distributed.monitor.common.PageResult;

import java.util.Map;

/**
 * 操作日志服务接口
 */
public interface OperationLogService {
    
    /**
     * 获取操作日志
     */
    PageResult<Map<String, Object>> getOperationLogs(
            Long userId, String operationType, String operationModule, 
            String startTime, String endTime, Integer status,
            Integer page, Integer pageSize);
}

