package com.distributed.monitor.service;

import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.dto.report.ReportGenerateDTO;
import org.springframework.core.io.Resource;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.Map;

/**
 * 报表服务接口
 */
public interface ReportService {
    
    /**
     * 获取报表配置列表
     */
    List<Map<String, Object>> getReportConfigs();
    
    /**
     * 生成报表
     */
    Map<String, Object> generateReport(ReportGenerateDTO dto);
    
    /**
     * 获取报表生成记录
     */
    PageResult<Map<String, Object>> getReportLogs(
            String reportCode, String status, String startTime, String endTime,
            Integer page, Integer pageSize);
    
    /**
     * 下载报表
     */
    ResponseEntity<Resource> downloadReport(Long id);
}

