package com.distributed.monitor.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 设备心跳记录实体
 */
@Data
public class DeviceHeartbeat {
    
    /**
     * 记录ID
     */
    private Long id;
    
    /**
     * 设备ID
     */
    private Long deviceId;
    
    /**
     * 心跳时间
     */
    private LocalDateTime heartbeatTime;
    
    /**
     * 上报IP地址
     */
    private String ipAddress;
    
    /**
     * 响应时间（毫秒）
     */
    private Integer responseTime;
    
    /**
     * 额外数据（JSON）
     */
    private String extraData;
    
    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
}

