package com.distributed.monitor.controller;

import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.common.Result;
import com.distributed.monitor.entity.AlertRule;
import com.distributed.monitor.service.AdminAlertRuleService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 管理端-告警规则
 * 对应接口设计 /admin/alert-rules
 */
@RestController
@RequestMapping("/admin/alert-rules")
@RequiredArgsConstructor
public class AdminAlertRuleController {

    private final AdminAlertRuleService adminAlertRuleService;

    @GetMapping
    public Result<PageResult<AlertRule>> listRules(
            @RequestParam(required = false) String ruleType,
            @RequestParam(required = false) Boolean isActive,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<AlertRule> result = adminAlertRuleService.listRules(ruleType, isActive, page, pageSize);
        return Result.success("获取成功", result);
    }

    @PostMapping
    public Result<Map<String, Object>> createRule(@RequestBody AlertRule rule) {
        Map<String, Object> result = adminAlertRuleService.createRule(rule);
        return Result.success("创建成功", result);
    }

    @PutMapping("/{id}")
    public Result<Void> updateRule(@PathVariable Long id, @RequestBody AlertRule rule) {
        rule.setId(id);
        adminAlertRuleService.updateRule(rule);
        return Result.success("更新成功", null);
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteRule(@PathVariable Long id) {
        adminAlertRuleService.deleteRule(id);
        return Result.success("删除成功", null);
    }
}

