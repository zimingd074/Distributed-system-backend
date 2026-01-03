package com.distributed.monitor.vo.deviceapi;

import lombok.Builder;
import lombok.Data;

/**
 * 设备认证登录响应VO
 */
@Data
@Builder
public class DeviceLoginVO {
    
    /**
     * 访问令牌
     */
    private String accessToken;
    
    /**
     * 刷新令牌
     */
    private String refreshToken;
    
    /**
     * 令牌类型（Bearer）
     */
    private String tokenType;
    
    /**
     * 过期时间（秒）
     */
    private Integer expiresIn;
    
    /**
     * 设备ID
     */
    private Long deviceId;
    
    /**
     * 设备编码
     */
    private String deviceCode;
}

