package com.distributed.monitor.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 系统操作日志实体
 */
@Data
public class SysOperationLog {
    
    /**
     * 日志ID
     */
    private Long id;
    
    /**
     * 操作用户ID
     */
    private Long userId;
    
    /**
     * 操作用户名
     */
    private String username;
    
    /**
     * 操作类型
     */
    private String operationType;
    
    /**
     * 操作模块
     */
    private String operationModule;
    
    /**
     * 操作描述
     */
    private String operationDesc;
    
    /**
     * 请求方法
     */
    private String requestMethod;
    
    /**
     * 请求URL
     */
    private String requestUrl;
    
    /**
     * 请求参数
     */
    private String requestParams;
    
    /**
     * 响应数据
     */
    private String responseData;
    
    /**
     * IP地址
     */
    private String ipAddress;
    
    /**
     * 用户代理
     */
    private String userAgent;
    
    /**
     * 状态：0-失败 1-成功
     */
    private Integer status;
    
    /**
     * 错误信息
     */
    private String errorMessage;
    
    /**
     * 执行耗时（毫秒）
     */
    private Integer executeTime;
    
    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
}

