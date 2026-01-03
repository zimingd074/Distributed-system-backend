package com.distributed.monitor.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 设备配置实体
 */
@Data
public class DeviceConfig {
    
    /**
     * 配置ID
     */
    private Long id;
    
    /**
     * 设备ID
     */
    private Long deviceId;
    
    /**
     * 配置键
     */
    private String configKey;
    
    /**
     * 配置值
     */
    private String configValue;
    
    /**
     * 配置类型：string number boolean json
     */
    private String configType;
    
    /**
     * 配置说明
     */
    private String description;
    
    /**
     * 是否已同步：0-未同步 1-已同步
     */
    private Integer isSynced;
    
    /**
     * 同步时间
     */
    private LocalDateTime syncTime;
    
    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
    
    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;
}

