package com.distributed.monitor.config;

import com.distributed.monitor.interceptor.JwtAuthInterceptor;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Web MVC配置
 * 注册拦截器
 */
@Configuration
@RequiredArgsConstructor
public class WebMvcConfig implements WebMvcConfigurer {
    
    private final JwtAuthInterceptor jwtAuthInterceptor;
    
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(jwtAuthInterceptor)
                .addPathPatterns("/**")  // 拦截所有请求
                .excludePathPatterns(
                        // 排除静态资源
                        "/static/**",
                        "/public/**",
                        "/favicon.ico",
                        // 排除Swagger文档（如果有）
                        "/swagger-ui/**",
                        "/swagger-resources/**",
                        "/v2/api-docs",
                        "/v3/api-docs",
                        // 排除WebSocket连接（WebSocket有自己的认证机制）
                        "/ws/**",
                        "/device/ws",
                        // 排除登录接口（已在Controller上标记@NoAuth）
                        "/auth/login",
                        "/device/auth/login",
                        // 排除错误页面
                        "/error"
                );
    }
}

