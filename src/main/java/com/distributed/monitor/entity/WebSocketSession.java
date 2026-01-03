package com.distributed.monitor.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * WebSocket会话实体
 */
@Data
public class WebSocketSession {
    
    /**
     * 会话ID
     */
    private Long id;
    
    /**
     * 会话标识
     */
    private String sessionId;
    
    /**
     * 用户ID
     */
    private Long userId;
    
    /**
     * IP地址
     */
    private String ipAddress;
    
    /**
     * 连接时间
     */
    private LocalDateTime connectTime;
    
    /**
     * 最后心跳时间
     */
    private LocalDateTime lastHeartbeatTime;
    
    /**
     * 断开时间
     */
    private LocalDateTime disconnectTime;
    
    /**
     * 状态：0-已断开 1-已连接
     */
    private Integer status;
    
    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
}

