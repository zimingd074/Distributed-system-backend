package com.distributed.monitor.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 告警记录实体
 */
@Data
public class AlertRecord {
    
    /**
     * 告警ID
     */
    private Long id;
    
    /**
     * 告警编号
     */
    private String alertNo;
    
    /**
     * 规则ID
     */
    private Long ruleId;
    
    /**
     * 设备ID
     */
    private Long deviceId;
    
    /**
     * 告警级别
     */
    private String alertLevel;
    
    /**
     * 告警类型
     */
    private String alertType;
    
    /**
     * 告警消息
     */
    private String alertMessage;
    
    /**
     * 告警数据（JSON）
     */
    private String alertData;
    
    /**
     * 处理状态：pending-待处理 confirmed-已确认 resolved-已解决 ignored-已忽略
     */
    private String status;
    
    /**
     * 告警时间
     */
    private LocalDateTime alertTime;
    
    /**
     * 确认用户ID
     */
    private Long confirmedUserId;
    
    /**
     * 确认时间
     */
    private LocalDateTime confirmedTime;
    
    /**
     * 解决用户ID
     */
    private Long resolvedUserId;
    
    /**
     * 解决时间
     */
    private LocalDateTime resolvedTime;
    
    /**
     * 处理备注
     */
    private String resolveRemark;
    
    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
    
    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;
}

