package com.distributed.monitor.exception;

/**
 * 业务异常
 * 用于处理业务逻辑错误
 */
public class BusinessException extends RuntimeException {
    
    private static final long serialVersionUID = 1L;
    
    /**
     * 错误码（可选，用于区分不同类型的业务错误）
     */
    private Integer code;
    
    public BusinessException(String message) {
        super(message);
        this.code = 0; // 默认业务失败码
    }
    
    public BusinessException(Integer code, String message) {
        super(message);
        this.code = code;
    }
    
    public BusinessException(String message, Throwable cause) {
        super(message, cause);
        this.code = 0;
    }
    
    public BusinessException(Integer code, String message, Throwable cause) {
        super(message, cause);
        this.code = code;
    }
    
    public Integer getCode() {
        return code;
    }
    
    public void setCode(Integer code) {
        this.code = code;
    }
}

