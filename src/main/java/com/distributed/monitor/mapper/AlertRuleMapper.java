package com.distributed.monitor.mapper;

import com.distributed.monitor.entity.AlertRule;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 告警规则 Mapper
 */
@Mapper
public interface AlertRuleMapper {

    long countAll();
    
    long countByCondition(
            @Param("ruleType") String ruleType,
            @Param("isActive") Integer isActive);
    
    List<AlertRule> selectPage(
            @Param("offset") int offset,
            @Param("limit") int limit);
    
    List<AlertRule> selectPageByCondition(
            @Param("ruleType") String ruleType,
            @Param("isActive") Integer isActive,
            @Param("offset") int offset,
            @Param("limit") int limit);

    @Insert("INSERT INTO alert_rule(rule_name, rule_code, rule_type, device_group_id, condition_expr, alert_level, alert_message, is_active, notify_users, notify_methods, created_at, updated_at) " +
            "VALUES(#{ruleName}, #{ruleCode}, #{ruleType}, #{deviceGroupId}, #{conditionExpr}, #{alertLevel}, #{alertMessage}, #{isActive}, #{notifyUsers}, #{notifyMethods}, NOW(), NOW())")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(AlertRule rule);

    int update(AlertRule rule);
    
    AlertRule selectById(@Param("id") Long id);
    
    AlertRule selectByRuleCode(@Param("ruleCode") String ruleCode);

    @Delete("DELETE FROM alert_rule WHERE id=#{id}")
    int delete(@Param("id") Long id);
}

