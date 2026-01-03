package com.distributed.monitor.exception;

/**
 * 禁止访问异常
 * 用于处理权限不足的情况
 */
public class ForbiddenException extends BusinessException {
    
    private static final long serialVersionUID = 1L;
    
    public ForbiddenException(String message) {
        super(403, message);
    }
    
    public ForbiddenException(String message, Throwable cause) {
        super(403, message, cause);
    }
}

