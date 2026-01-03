package com.distributed.monitor.service.impl;

import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.entity.ReportConfig;
import com.distributed.monitor.exception.BusinessException;
import com.distributed.monitor.exception.NotFoundException;
import com.distributed.monitor.mapper.AdminReportConfigMapper;
import com.distributed.monitor.service.AdminReportConfigService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 管理端报表配置服务实现
 */
@Service
@RequiredArgsConstructor
public class AdminReportConfigServiceImpl implements AdminReportConfigService {

    private final AdminReportConfigMapper adminReportConfigMapper;

    @Override
    public PageResult<ReportConfig> listConfigs(String reportType, Boolean isActive, int page, int pageSize) {
        // 验证分页参数
        int safePage = Math.max(page, 1);
        int safePageSize = Math.max(pageSize, 1);
        if (safePageSize > 100) {
            safePageSize = 100; // 最大100
        }
        int offset = (safePage - 1) * safePageSize;
        
        // 转换isActive Boolean为Integer
        Integer isActiveInt = null;
        if (isActive != null) {
            isActiveInt = isActive ? 1 : 0;
        }
        
        long total = adminReportConfigMapper.countByCondition(reportType, isActiveInt);
        List<ReportConfig> rows = total == 0 ? Collections.emptyList() : 
                adminReportConfigMapper.selectPageByCondition(reportType, isActiveInt, offset, safePageSize);
        return new PageResult<>(total, rows, safePage, safePageSize);
    }

    @Override
    public Map<String, Object> createConfig(ReportConfig config) {
        // 验证必填字段
        if (config.getReportName() == null || config.getReportName().trim().isEmpty()) {
            throw new BusinessException("报表名称不能为空");
        }
        if (config.getReportCode() == null || config.getReportCode().trim().isEmpty()) {
            throw new BusinessException("报表编码不能为空");
        }
        if (config.getReportType() == null || config.getReportType().trim().isEmpty()) {
            throw new BusinessException("报表类型不能为空");
        }
        
        // 检查报表编码是否已存在
        ReportConfig existingConfig = adminReportConfigMapper.selectByReportCode(config.getReportCode());
        if (existingConfig != null) {
            throw new BusinessException("报表编码已存在");
        }
        
        if (config.getIsActive() == null) {
            config.setIsActive(1);
        }
        adminReportConfigMapper.insert(config);
        
        Map<String, Object> result = new HashMap<>();
        result.put("id", config.getId());
        result.put("reportCode", config.getReportCode());
        result.put("reportName", config.getReportName());
        if (config.getCreatedAt() != null) {
            result.put("createdAt", config.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        } else {
            result.put("createdAt", null);
        }
        return result;
    }

    @Override
    public void updateConfig(ReportConfig config) {
        ReportConfig existingConfig = adminReportConfigMapper.selectById(config.getId());
        if (existingConfig == null) {
            throw new NotFoundException("报表配置不存在");
        }
        
        // 只更新提供的字段（reportCode不允许修改）
        if (config.getReportName() != null) {
            existingConfig.setReportName(config.getReportName());
        }
        if (config.getReportTemplate() != null) {
            existingConfig.setReportTemplate(config.getReportTemplate());
        }
        if (config.getQuerySql() != null) {
            existingConfig.setQuerySql(config.getQuerySql());
        }
        if (config.getDescription() != null) {
            existingConfig.setDescription(config.getDescription());
        }
        if (config.getIsActive() != null) {
            existingConfig.setIsActive(config.getIsActive());
        }
        
        adminReportConfigMapper.update(existingConfig);
    }

    @Override
    public void deleteConfig(Long id) {
        ReportConfig existingConfig = adminReportConfigMapper.selectById(id);
        if (existingConfig == null) {
            throw new NotFoundException("报表配置不存在");
        }
        adminReportConfigMapper.delete(id);
    }
}

