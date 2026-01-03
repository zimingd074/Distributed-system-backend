package com.distributed.monitor.interceptor;

import com.distributed.monitor.annotation.NoAuth;
import com.distributed.monitor.util.JwtUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * JWT认证拦截器
 * 验证请求头中的Token
 */
@Component
public class JwtAuthInterceptor implements HandlerInterceptor {
    
    private static final Logger log = LoggerFactory.getLogger(JwtAuthInterceptor.class);
    
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 处理OPTIONS预检请求
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }
        
        // 如果不是HandlerMethod，直接放行（如静态资源）
        if (!(handler instanceof HandlerMethod)) {
            return true;
        }
        
        HandlerMethod handlerMethod = (HandlerMethod) handler;
        
        // 检查类或方法上是否有@NoAuth注解
        if (handlerMethod.getBeanType().isAnnotationPresent(NoAuth.class) ||
            handlerMethod.getMethod().isAnnotationPresent(NoAuth.class)) {
            return true;
        }
        
        // 获取Authorization请求头
        String authHeader = request.getHeader("Authorization");
        
        if (!StringUtils.hasText(authHeader) || !authHeader.startsWith("Bearer ")) {
            log.warn("请求缺少Token: {}", request.getRequestURI());
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"code\":401,\"msg\":\"未认证或Token无效\",\"data\":null}");
            return false;
        }
        
        // 提取Token
        String token = authHeader.substring(7);
        
        // 验证Token
        if (!JwtUtil.validateToken(token)) {
            log.warn("Token无效或已过期: {}", request.getRequestURI());
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"code\":401,\"msg\":\"Token无效或已过期\",\"data\":null}");
            return false;
        }
        
        // 验证是否为访问令牌（不是刷新令牌）
        // 注意：/auth/refresh接口允许使用refreshToken，已在Controller上标记@NoAuth，不会进入此拦截器
        if (JwtUtil.isRefreshToken(token)) {
            log.warn("使用了刷新令牌作为访问令牌: {}", request.getRequestURI());
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"code\":401,\"msg\":\"无效的Token类型，请使用访问令牌\",\"data\":null}");
            return false;
        }
        
        // Token验证通过，将用户信息存入request属性，供后续使用
        Long userId = JwtUtil.getUserIdFromToken(token);
        String username = JwtUtil.getUsernameFromToken(token);
        
        if (userId != null) {
            request.setAttribute("userId", userId);
            request.setAttribute("username", username);
        }
        
        return true;
    }
}

