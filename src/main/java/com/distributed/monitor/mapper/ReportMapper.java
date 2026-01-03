package com.distributed.monitor.mapper;

import com.distributed.monitor.entity.ReportConfig;
import com.distributed.monitor.entity.ReportGenerateLog;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 报表Mapper
 */
@Mapper
public interface ReportMapper {
    
    /**
     * 查询报表配置列表
     */
    List<ReportConfig> selectReportConfigs();
    
    /**
     * 根据编码查询报表配置
     */
    ReportConfig selectReportConfigByCode(@Param("reportCode") String reportCode);
    
    /**
     * 插入报表生成记录
     */
    void insertReportGenerateLog(@Param("log") ReportGenerateLog log);
    
    /**
     * 更新报表生成记录
     */
    void updateReportGenerateLog(@Param("log") ReportGenerateLog log);
    
    /**
     * 统计报表生成记录数量
     */
    Long countReportLogs(
            @Param("reportCode") String reportCode,
            @Param("status") String status,
            @Param("startTime") String startTime,
            @Param("endTime") String endTime);
    
    /**
     * 查询报表生成记录
     */
    List<ReportGenerateLog> selectReportLogs(
            @Param("reportCode") String reportCode,
            @Param("status") String status,
            @Param("startTime") String startTime,
            @Param("endTime") String endTime,
            @Param("offset") int offset,
            @Param("limit") int limit);
    
    /**
     * 根据ID查询报表生成记录
     */
    ReportGenerateLog selectReportLogById(@Param("id") Long id);
}

