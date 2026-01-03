package com.distributed.monitor.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * JWT工具类
 */
@Slf4j
public class JwtUtil {
    
    /**
     * JWT密钥（实际生产环境应从配置文件读取）
     */
    private static final String SECRET = "distributed-monitor-system-secret-key-2025-12-13";
    
    /**
     * 访问令牌过期时间（秒）
     */
    private static final long ACCESS_TOKEN_EXPIRE = 7200; // 2小时
    
    /**
     * 刷新令牌过期时间（秒）
     */
    private static final long REFRESH_TOKEN_EXPIRE = 604800; // 7天
    
    /**
     * 获取签名密钥
     */
    private static SecretKey getSigningKey() {
        byte[] keyBytes = SECRET.getBytes(StandardCharsets.UTF_8);
        return Keys.hmacShaKeyFor(keyBytes);
    }
    
    /**
     * 生成访问令牌
     */
    public static String generateAccessToken(Long userId, String username) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);
        claims.put("username", username);
        claims.put("type", "access");
        
        return Jwts.builder()
                .setClaims(claims)
                .setSubject(username)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + ACCESS_TOKEN_EXPIRE * 1000))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }
    
    /**
     * 生成刷新令牌
     */
    public static String generateRefreshToken(Long userId, String username) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);
        claims.put("username", username);
        claims.put("type", "refresh");
        
        return Jwts.builder()
                .setClaims(claims)
                .setSubject(username)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + REFRESH_TOKEN_EXPIRE * 1000))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }
    
    /**
     * 解析令牌
     */
    public static Claims parseToken(String token) {
        try {
            return Jwts.parserBuilder()
                    .setSigningKey(getSigningKey())
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
        } catch (Exception e) {
            log.error("解析Token失败", e);
            return null;
        }
    }
    
    /**
     * 从令牌中获取用户ID
     */
    public static Long getUserIdFromToken(String token) {
        Claims claims = parseToken(token);
        if (claims == null) {
            return null;
        }
        Object userId = claims.get("userId");
        if (userId instanceof Integer) {
            return ((Integer) userId).longValue();
        } else if (userId instanceof Long) {
            return (Long) userId;
        }
        return null;
    }
    
    /**
     * 从令牌中获取用户名
     */
    public static String getUsernameFromToken(String token) {
        Claims claims = parseToken(token);
        return claims != null ? claims.getSubject() : null;
    }
    
    /**
     * 验证令牌是否有效
     */
    public static boolean validateToken(String token) {
        try {
            Claims claims = parseToken(token);
            return claims != null && claims.getExpiration().after(new Date());
        } catch (Exception e) {
            return false;
        }
    }
    
    /**
     * 验证是否为刷新令牌
     */
    public static boolean isRefreshToken(String token) {
        Claims claims = parseToken(token);
        if (claims == null) {
            return false;
        }
        Object type = claims.get("type");
        return "refresh".equals(type);
    }
    
    /**
     * 获取访问令牌过期时间（秒）
     */
    public static long getAccessTokenExpire() {
        return ACCESS_TOKEN_EXPIRE;
    }
    
    /**
     * 生成设备访问令牌
     */
    public static String generateDeviceAccessToken(Long deviceId, String deviceCode) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("deviceId", deviceId);
        claims.put("deviceCode", deviceCode);
        claims.put("type", "device_access");
        
        return Jwts.builder()
                .setClaims(claims)
                .setSubject(deviceCode)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + ACCESS_TOKEN_EXPIRE * 1000))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }
    
    /**
     * 生成设备刷新令牌
     */
    public static String generateDeviceRefreshToken(Long deviceId, String deviceCode) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("deviceId", deviceId);
        claims.put("deviceCode", deviceCode);
        claims.put("type", "device_refresh");
        
        return Jwts.builder()
                .setClaims(claims)
                .setSubject(deviceCode)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + REFRESH_TOKEN_EXPIRE * 1000))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }
    
    /**
     * 从令牌中获取设备ID
     */
    public static Long getDeviceIdFromToken(String token) {
        Claims claims = parseToken(token);
        if (claims == null) {
            return null;
        }
        Object deviceId = claims.get("deviceId");
        if (deviceId instanceof Integer) {
            return ((Integer) deviceId).longValue();
        } else if (deviceId instanceof Long) {
            return (Long) deviceId;
        }
        return null;
    }
    
    /**
     * 从令牌中获取设备编码
     */
    public static String getDeviceCodeFromToken(String token) {
        Claims claims = parseToken(token);
        return claims != null ? claims.getSubject() : null;
    }
    
    /**
     * 验证是否为设备令牌
     */
    public static boolean isDeviceToken(String token) {
        Claims claims = parseToken(token);
        if (claims == null) {
            return false;
        }
        Object type = claims.get("type");
        return "device_access".equals(type) || "device_refresh".equals(type);
    }
}

