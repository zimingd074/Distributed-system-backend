package com.distributed.monitor.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 设备实体
 */
@Data
public class Device {
    
    /**
     * 设备ID
     */
    private Long id;
    
    /**
     * 设备编码（唯一标识，设备身份识别依据，不可修改）
     */
    private String deviceCode;
    
    /**
     * 设备密钥（加密存储，用于设备认证，仅在创建时生成）
     */
    private String deviceSecret;
    
    /**
     * 设备名称
     */
    private String deviceName;
    
    /**
     * 设备类型
     */
    private String deviceType;
    
    /**
     * 所属分组ID
     */
    private Long groupId;
    
    /**
     * IP地址
     */
    private String ipAddress;
    
    /**
     * 端口号
     */
    private Integer port;
    
    /**
     * MAC地址
     */
    private String macAddress;
    
    /**
     * 物理位置
     */
    private String location;
    
    /**
     * 设备描述
     */
    private String description;
    
    /**
     * 设备状态：online-在线 offline-离线 fault-故障 maintain-维护
     */
    private String status;
    
    /**
     * 在线状态：0-离线 1-在线
     */
    private Integer onlineStatus;
    
    /**
     * WebSocket连接状态：0-未连接 1-已连接
     */
    private Integer wsConnected;
    
    /**
     * WebSocket会话ID
     */
    private String wsSessionId;
    
    /**
     * 最后心跳时间
     */
    private LocalDateTime lastHeartbeatTime;
    
    /**
     * 最后认证时间
     */
    private LocalDateTime lastAuthTime;
    
    /**
     * 注册时间
     */
    private LocalDateTime registerTime;
    
    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
    
    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;
}

