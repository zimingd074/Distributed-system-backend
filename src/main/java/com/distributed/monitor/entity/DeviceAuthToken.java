package com.distributed.monitor.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 设备认证Token实体（可选，用于Token管理）
 */
@Data
public class DeviceAuthToken {
    
    /**
     * Token ID
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
     * 访问令牌
     */
    private String accessToken;
    
    /**
     * 刷新令牌
     */
    private String refreshToken;
    
    /**
     * 令牌类型
     */
    private String tokenType;
    
    /**
     * 过期时间（秒）
     */
    private Integer expiresIn;
    
    /**
     * 颁发时间
     */
    private LocalDateTime issuedAt;
    
    /**
     * 过期时间
     */
    private LocalDateTime expiresAt;
    
    /**
     * 最后使用时间
     */
    private LocalDateTime lastUsedAt;
    
    /**
     * 是否已撤销：0-否 1-是
     */
    private Integer isRevoked;
    
    /**
     * 撤销时间
     */
    private LocalDateTime revokedAt;
    
    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
}

