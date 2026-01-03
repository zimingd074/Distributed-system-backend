package com.distributed.monitor.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.Arrays;
import java.util.List;

/**
 * 跨域配置
 * 解决前后端分离开发时的跨域问题
 */
@Configuration
public class CorsConfig implements WebMvcConfigurer {
    
    /**
     * 允许的前端地址（从配置文件读取，支持多个）
     * 开发环境：http://localhost:5173, http://localhost:3000
     * 生产环境：https://your-frontend-domain.com
     */
    @Value("${cors.allowed-origins:http://localhost:5173,http://localhost:3000,http://127.0.0.1:5173,http://127.0.0.1:3000}")
    private String allowedOrigins;
    
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        // 解析允许的源列表
        List<String> originList = Arrays.asList(allowedOrigins.split(","));
        
        registry.addMapping("/**")
                // 允许的源（前端地址）
                .allowedOriginPatterns(originList.toArray(new String[0]))
                // 允许的HTTP方法
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH")
                // 允许的请求头
                .allowedHeaders("*")
                // 允许暴露的响应头
                .exposedHeaders("Authorization", "Content-Type", "X-Total-Count")
                // 允许携带凭证（Cookie、Authorization等）
                .allowCredentials(true)
                // 预检请求的缓存时间（秒）
                .maxAge(3600);
    }
    
    /**
     * 使用CorsFilter方式配置（优先级更高，更灵活）
     * 支持所有路径，包括WebSocket握手请求
     */
    @Bean
    public CorsFilter corsFilter() {
        CorsConfiguration config = new CorsConfiguration();
        
        // 解析允许的源列表
        List<String> originList = Arrays.asList(allowedOrigins.split(","));
        for (String origin : originList) {
            config.addAllowedOriginPattern(origin.trim());
        }
        
        // 允许的HTTP方法
        config.addAllowedMethod("GET");
        config.addAllowedMethod("POST");
        config.addAllowedMethod("PUT");
        config.addAllowedMethod("DELETE");
        config.addAllowedMethod("OPTIONS");
        config.addAllowedMethod("PATCH");
        
        // 允许的请求头
        config.addAllowedHeader("*");
        
        // 允许暴露的响应头
        config.addExposedHeader("Authorization");
        config.addExposedHeader("Content-Type");
        config.addExposedHeader("X-Total-Count");
        
        // 允许携带凭证（重要：如果设置为true，allowedOrigins不能使用"*"）
        config.setAllowCredentials(true);
        
        // 预检请求的缓存时间
        config.setMaxAge(3600L);
        
        // 注册CORS配置到所有路径
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        
        return new CorsFilter(source);
    }
}

