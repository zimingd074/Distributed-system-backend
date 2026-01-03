package com.distributed.monitor.mapper;

import com.distributed.monitor.entity.SysOperationLog;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 操作日志Mapper
 */
@Mapper
public interface OperationLogMapper {
    
    /**
     * 统计操作日志数量
     */
    Long countOperationLogs(
            @Param("userId") Long userId,
            @Param("operationType") String operationType,
            @Param("operationModule") String operationModule,
            @Param("startTime") String startTime,
            @Param("endTime") String endTime,
            @Param("status") Integer status);
    
    /**
     * 查询操作日志列表
     */
    List<SysOperationLog> selectOperationLogs(
            @Param("userId") Long userId,
            @Param("operationType") String operationType,
            @Param("operationModule") String operationModule,
            @Param("startTime") String startTime,
            @Param("endTime") String endTime,
            @Param("status") Integer status,
            @Param("offset") int offset,
            @Param("limit") int limit);
    
    /**
     * 插入操作日志
     */
    void insertOperationLog(@Param("log") SysOperationLog log);
}

