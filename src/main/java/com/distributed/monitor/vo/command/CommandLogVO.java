package com.distributed.monitor.vo.command;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.Map;

/**
 * 命令执行记录VO
 */
@Data
public class CommandLogVO {
    
    private Long commandLogId;
    
    private Long deviceId;
    
    private String deviceName;
    
    private String commandCode;
    
    private String commandName;
    
    private Map<String, Object> commandParams;
    
    private String executeUser;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime executeTime;
    
    private String status;
    
    private Map<String, Object> responseData;
    
    private String errorMessage;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime responseTime;
    
    private Integer duration;
}

