package com.distributed.monitor.service;

import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.entity.AlertRule;

import java.util.Map;

/**
 * 管理端告警规则服务
 */
public interface AdminAlertRuleService {

    PageResult<AlertRule> listRules(String ruleType, Boolean isActive, int page, int pageSize);

    Map<String, Object> createRule(AlertRule rule);

    void updateRule(AlertRule rule);

    void deleteRule(Long id);
}

