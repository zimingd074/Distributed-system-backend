package com.distributed.monitor.mapper;

import com.distributed.monitor.entity.ReportConfig;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 报表配置管理 Mapper（管理端 CRUD）
 */
@Mapper
public interface AdminReportConfigMapper {

    long countAll();
    
    long countByCondition(
            @Param("reportType") String reportType,
            @Param("isActive") Integer isActive);
    
    List<ReportConfig> selectPage(
            @Param("offset") int offset,
            @Param("limit") int limit);
    
    List<ReportConfig> selectPageByCondition(
            @Param("reportType") String reportType,
            @Param("isActive") Integer isActive,
            @Param("offset") int offset,
            @Param("limit") int limit);

    @Insert("INSERT INTO report_config(report_name, report_code, report_type, report_template, query_sql, params_schema, description, is_active, created_at, updated_at) " +
            "VALUES(#{reportName}, #{reportCode}, #{reportType}, #{reportTemplate}, #{querySql}, #{paramsSchema}, #{description}, #{isActive}, NOW(), NOW())")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(ReportConfig config);
    
    ReportConfig selectById(@Param("id") Long id);
    
    ReportConfig selectByReportCode(@Param("reportCode") String reportCode);

    int update(ReportConfig config);

    @Delete("DELETE FROM report_config WHERE id=#{id}")
    int delete(@Param("id") Long id);
}

