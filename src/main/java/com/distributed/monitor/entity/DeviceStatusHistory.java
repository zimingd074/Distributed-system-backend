package com.distributed.monitor.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 设备状态历史实体
 */
@Data
public class DeviceStatusHistory {
    
    /**
     * 记录ID
     */
    private Long id;
    
    /**
     * 设备ID
     */
    private Long deviceId;
    
    /**
     * 状态类型
     */
    private String statusType;
    
    /**
     * 状态值（JSON格式）
     */
    private String statusValue;
    
    /**
     * 门状态：open/closed
     */
    private String doorStatus;

    /**
     * 门禁控制器状态（normal/fault/...）
     */
    private String doorControllerStatus;
    
    /**
     * 自定义数据（JSON）
     */
    private String customData;
    
    /**
     * 上报时间
     */
    private LocalDateTime reportTime;
    
    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
}

