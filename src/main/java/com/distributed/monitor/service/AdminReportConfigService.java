package com.distributed.monitor.service;

import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.entity.ReportConfig;

import java.util.Map;

/**
 * 管理端报表配置服务
 */
public interface AdminReportConfigService {

    PageResult<ReportConfig> listConfigs(String reportType, Boolean isActive, int page, int pageSize);

    Map<String, Object> createConfig(ReportConfig config);

    void updateConfig(ReportConfig config);

    void deleteConfig(Long id);
}

