package com.distributed.monitor.exception;

/**
 * 未授权异常
 * 用于处理认证授权相关的错误
 */
public class UnauthorizedException extends BusinessException {
    
    private static final long serialVersionUID = 1L;
    
    public UnauthorizedException(String message) {
        super(401, message);
    }
    
    public UnauthorizedException(String message, Throwable cause) {
        super(401, message, cause);
    }
}

