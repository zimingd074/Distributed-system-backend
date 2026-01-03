package com.distributed.monitor.service.impl;

import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.entity.AlertRule;
import com.distributed.monitor.exception.BusinessException;
import com.distributed.monitor.exception.NotFoundException;
import com.distributed.monitor.mapper.AlertRuleMapper;
import com.distributed.monitor.service.AdminAlertRuleService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 管理端告警规则服务实现
 */
@Service
@RequiredArgsConstructor
public class AdminAlertRuleServiceImpl implements AdminAlertRuleService {

    private final AlertRuleMapper alertRuleMapper;

    @Override
    public PageResult<AlertRule> listRules(String ruleType, Boolean isActive, int page, int pageSize) {
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
        
        long total = alertRuleMapper.countByCondition(ruleType, isActiveInt);
        List<AlertRule> rows = total == 0 ? Collections.emptyList() : 
                alertRuleMapper.selectPageByCondition(ruleType, isActiveInt, offset, safePageSize);
        return new PageResult<>(total, rows, safePage, safePageSize);
    }

    @Override
    public Map<String, Object> createRule(AlertRule rule) {
        // 验证必填字段
        if (rule.getRuleName() == null || rule.getRuleName().trim().isEmpty()) {
            throw new BusinessException("规则名称不能为空");
        }
        if (rule.getRuleCode() == null || rule.getRuleCode().trim().isEmpty()) {
            throw new BusinessException("规则编码不能为空");
        }
        if (rule.getRuleType() == null || rule.getRuleType().trim().isEmpty()) {
            throw new BusinessException("规则类型不能为空");
        }
        if (rule.getConditionExpr() == null || rule.getConditionExpr().trim().isEmpty()) {
            throw new BusinessException("条件表达式不能为空");
        }
        if (rule.getAlertLevel() == null || rule.getAlertLevel().trim().isEmpty()) {
            throw new BusinessException("告警级别不能为空");
        }
        
        // 检查规则编码是否已存在
        AlertRule existingRule = alertRuleMapper.selectByRuleCode(rule.getRuleCode());
        if (existingRule != null) {
            throw new BusinessException("规则编码已存在");
        }
        
        if (rule.getIsActive() == null) {
            rule.setIsActive(1);
        }
        alertRuleMapper.insert(rule);
        
        Map<String, Object> result = new HashMap<>();
        result.put("id", rule.getId());
        result.put("ruleCode", rule.getRuleCode());
        result.put("ruleName", rule.getRuleName());
        if (rule.getCreatedAt() != null) {
            result.put("createdAt", rule.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        } else {
            result.put("createdAt", null);
        }
        return result;
    }

    @Override
    public void updateRule(AlertRule rule) {
        AlertRule existingRule = alertRuleMapper.selectById(rule.getId());
        if (existingRule == null) {
            throw new NotFoundException("告警规则不存在");
        }
        
        // 只更新提供的字段（ruleCode不允许修改）
        if (rule.getRuleName() != null) {
            existingRule.setRuleName(rule.getRuleName());
        }
        if (rule.getConditionExpr() != null) {
            existingRule.setConditionExpr(rule.getConditionExpr());
        }
        if (rule.getAlertLevel() != null) {
            existingRule.setAlertLevel(rule.getAlertLevel());
        }
        if (rule.getAlertMessage() != null) {
            existingRule.setAlertMessage(rule.getAlertMessage());
        }
        if (rule.getIsActive() != null) {
            existingRule.setIsActive(rule.getIsActive());
        }
        
        alertRuleMapper.update(existingRule);
    }

    @Override
    public void deleteRule(Long id) {
        AlertRule existingRule = alertRuleMapper.selectById(id);
        if (existingRule == null) {
            throw new NotFoundException("告警规则不存在");
        }
        alertRuleMapper.delete(id);
    }
}

