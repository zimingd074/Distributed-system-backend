package com.distributed.monitor.dto.command;

import lombok.Data;
import javax.validation.constraints.NotBlank;
import java.util.Map;

/**
 * 发送控制命令DTO
 */
@Data
public class SendCommandDTO {
    
    @NotBlank(message = "命令编码不能为空")
    private String commandCode;
    
    /**
     * 命令参数
     */
    private Map<String, Object> commandParams;
}

