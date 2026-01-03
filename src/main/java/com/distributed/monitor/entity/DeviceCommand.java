package com.distributed.monitor.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 控制命令实体
 */
@Data
public class DeviceCommand {
    
    /**
     * 命令ID
     */
    private Long id;
    
    /**
     * 命令编码
     */
    private String commandCode;
    
    /**
     * 命令名称
     */
    private String commandName;
    
    /**
     * 命令类型：control-控制 config-配置 query-查询
     */
    private String commandType;
    
    /**
     * 命令描述
     */
    private String description;
    
    /**
     * 参数模式（JSON Schema）
     */
    private String paramSchema;
    
    /**
     * 是否启用：0-否 1-是
     */
    private Integer isActive;
    
    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
    
    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;
}

