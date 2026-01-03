package com.distributed.monitor.common;

import lombok.Data;
import java.io.Serializable;

/**
 * 统一响应结果类
 *
 * @param <T> 响应数据类型
 */
@Data
public class Result<T> implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    /**
     * 响应码：1-成功 0-业务失败
     */
    private Integer code;
    
    /**
     * 响应消息
     */
    private String msg;
    
    /**
     * 响应数据
     */
    private T data;
    
    /**
     * 时间戳
     */
    private Long timestamp;
    
    public Result() {
        this.timestamp = System.currentTimeMillis();
    }
    
    public Result(Integer code, String msg, T data) {
        this.code = code;
        this.msg = msg;
        this.data = data;
        this.timestamp = System.currentTimeMillis();
    }
    
    /**
     * 成功响应（无数据）
     */
    public static <T> Result<T> success() {
        return new Result<>(1, "操作成功", null);
    }
    
    /**
     * 成功响应（有数据）
     */
    public static <T> Result<T> success(T data) {
        return new Result<>(1, "操作成功", data);
    }
    
    /**
     * 成功响应（自定义消息）
     */
    public static <T> Result<T> success(String msg, T data) {
        return new Result<>(1, msg, data);
    }
    
    /**
     * 失败响应
     */
    public static <T> Result<T> fail(String msg) {
        return new Result<>(0, msg, null);
    }
    
    /**
     * 失败响应（带数据）
     */
    public static <T> Result<T> fail(String msg, T data) {
        return new Result<>(0, msg, data);
    }
    
    /**
     * 自定义响应
     */
    public static <T> Result<T> build(Integer code, String msg, T data) {
        return new Result<>(code, msg, data);
    }
}

