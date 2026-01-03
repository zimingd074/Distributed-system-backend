package com.distributed.monitor.util;

import lombok.extern.slf4j.Slf4j;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.http.HttpServletRequest;

/**
 * 请求工具类
 * 用于从请求中获取信息
 */
@Slf4j
public class RequestUtil {
    
    /**
     * 获取当前登录用户ID
     * 优先从request属性中获取（由拦截器设置），如果没有则从Token中解析
     */
    public static Long getCurrentUserId() {
        try {
            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes == null) {
                return null;
            }
            
            HttpServletRequest request = attributes.getRequest();
            
            // 优先从request属性中获取（由拦截器设置）
            Object userIdObj = request.getAttribute("userId");
            if (userIdObj != null) {
                if (userIdObj instanceof Long) {
                    return (Long) userIdObj;
                } else if (userIdObj instanceof Integer) {
                    return ((Integer) userIdObj).longValue();
                }
            }
            
            // 如果request属性中没有，则从Token中解析（兼容性处理）
            String authHeader = request.getHeader("Authorization");
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String token = authHeader.substring(7);
                return JwtUtil.getUserIdFromToken(token);
            }
            
            return null;
        } catch (Exception e) {
            log.error("获取当前用户ID失败", e);
            return null;
        }
    }
    
    /**
     * 获取当前登录用户名
     */
    public static String getCurrentUsername() {
        try {
            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes == null) {
                return null;
            }
            
            HttpServletRequest request = attributes.getRequest();
            
            // 优先从request属性中获取（由拦截器设置）
            Object usernameObj = request.getAttribute("username");
            if (usernameObj != null) {
                return usernameObj.toString();
            }
            
            // 如果request属性中没有，则从Token中解析
            String authHeader = request.getHeader("Authorization");
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String token = authHeader.substring(7);
                return JwtUtil.getUsernameFromToken(token);
            }
            
            return null;
        } catch (Exception e) {
            log.error("获取当前用户名失败", e);
            return null;
        }
    }
}

