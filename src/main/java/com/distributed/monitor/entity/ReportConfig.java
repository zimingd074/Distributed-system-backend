package com.distributed.monitor.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 统计报表配置实体
 */
@Data
public class ReportConfig {
    
    /**
     * 报表ID
     */
    private Long id;
    
    /**
     * 报表名称
     */
    private String reportName;
    
    /**
     * 报表编码
     */
    private String reportCode;
    
    /**
     * 报表类型：device-设备 status-状态 alert-告警 command-命令
     */
    private String reportType;
    
    /**
     * 报表模板路径
     */
    private String reportTemplate;
    
    /**
     * 查询SQL
     */
    private String querySql;
    
    /**
     * 参数模式（JSON）
     */
    private String paramsSchema;
    
    /**
     * 报表描述
     */
    private String description;
    
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

