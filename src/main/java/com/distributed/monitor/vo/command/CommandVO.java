package com.distributed.monitor.vo.command;

import lombok.Data;
import java.util.Map;

/**
 * 命令VO
 */
@Data
public class CommandVO {
    
    private Long commandId;
    
    private String commandCode;
    
    private String commandName;
    
    private String commandType;
    
    private String description;
    
    private Map<String, Object> paramSchema;
    
    private Boolean isActive;
}

