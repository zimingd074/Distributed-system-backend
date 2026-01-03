package com.distributed.monitor.exception;

/**
 * 资源不存在异常
 * 用于处理资源查找失败的情况
 */
public class NotFoundException extends BusinessException {
    
    private static final long serialVersionUID = 1L;
    
    public NotFoundException(String message) {
        super(404, message);
    }
    
    public NotFoundException(String message, Throwable cause) {
        super(404, message, cause);
    }
}

