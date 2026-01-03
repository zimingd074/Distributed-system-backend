package com.distributed.monitor.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 命令执行记录实体
 */
@Data
public class DeviceCommandLog {
    
    /**
     * 记录ID
     */
    private Long id;
    
    /**
     * 设备ID
     */
    private Long deviceId;
    
    /**
     * 命令ID
     */
    private Long commandId;
    
    /**
     * 命令编码
     */
    private String commandCode;
    
    /**
     * 命令参数（JSON）
     */
    private String commandParams;
    
    /**
     * 执行用户ID
     */
    private Long executeUserId;
    
    /**
     * 执行时间
     */
    private LocalDateTime executeTime;
    
    /**
     * 执行状态：pending-待执行 sending-发送中 success-成功 failed-失败 timeout-超时
     */
    private String status;
    
    /**
     * 响应数据（JSON）
     */
    private String responseData;
    
    /**
     * 错误信息
     */
    private String errorMessage;
    
    /**
     * 响应时间
     */
    private LocalDateTime responseTime;
    
    /**
     * 执行耗时（毫秒）
     */
    private Integer duration;
    
    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
}

