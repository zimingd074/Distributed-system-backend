package com.distributed.monitor.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 设备WebSocket会话实体
 */
@Data
public class DeviceWebSocketSession {
    
    /**
     * 会话ID
     */
    private Long id;
    
    /**
     * 设备ID
     */
    private Long deviceId;
    
    /**
     * 设备编码
     */
    private String deviceCode;
    
    /**
     * WebSocket会话标识
     */
    private String sessionId;
    
    /**
     * 客户端IP地址
     */
    private String clientIp;
    
    /**
     * 连接时间
     */
    private LocalDateTime connectTime;
    
    /**
     * 最后心跳时间
     */
    private LocalDateTime lastHeartbeatTime;
    
    /**
     * 最后消息时间
     */
    private LocalDateTime lastMessageTime;
    
    /**
     * 断开时间
     */
    private LocalDateTime disconnectTime;
    
    /**
     * 断开原因
     */
    private String disconnectReason;
    
    /**
     * 状态：0-已断开 1-已连接
     */
    private Integer status;
    
    /**
     * 消息总数
     */
    private Long messageCount;
    
    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
    
    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;
}

