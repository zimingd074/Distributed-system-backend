package com.distributed.monitor.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 告警规则实体
 */
@Data
public class AlertRule {
    
    /**
     * 规则ID
     */
    private Long id;
    
    /**
     * 规则名称
     */
    private String ruleName;
    
    /**
     * 规则编码
     */
    private String ruleCode;
    
    /**
     * 规则类型：offline-离线 threshold-阈值 abnormal-异常
     */
    private String ruleType;
    
    /**
     * 应用设备分组ID（为空表示全局）
     */
    private Long deviceGroupId;
    
    /**
     * 条件表达式
     */
    private String conditionExpr;
    
    /**
     * 告警级别：info-信息 warning-警告 error-错误 critical-严重
     */
    private String alertLevel;
    
    /**
     * 告警消息模板
     */
    private String alertMessage;
    
    /**
     * 是否启用：0-否 1-是
     */
    @JsonIgnore
    private Integer isActive;
    
    /**
     * 获取isActive的boolean值（用于JSON序列化）
     */
    @JsonProperty("isActive")
    public Boolean getIsActiveBoolean() {
        return isActive != null && isActive == 1;
    }
    
    /**
     * 设置isActive的boolean值（用于JSON反序列化）
     */
    public void setIsActiveBoolean(Boolean active) {
        this.isActive = (active != null && active) ? 1 : 0;
    }
    
    /**
     * 通知用户ID列表（JSON）
     */
    private String notifyUsers;
    
    /**
     * 通知方式（JSON）：email, sms, webhook
     */
    private String notifyMethods;
    
    /**
     * 创建时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime createdAt;
    
    /**
     * 更新时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime updatedAt;
}

