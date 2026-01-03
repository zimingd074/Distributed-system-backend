package com.distributed.monitor.dto.deviceapi;

import lombok.Data;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.util.Map;

/**
 * 命令执行结果DTO
 */
@Data
public class CommandResultDTO {
    
    @NotBlank(message = "设备编码不能为空")
    private String deviceCode;
    
    @NotBlank(message = "设备密钥不能为空")
    private String deviceSecret;
    
    @NotBlank(message = "执行状态不能为空")
    private String status;
    
    private Map<String, Object> responseData;
    
    private String errorMessage;
    
    @NotNull(message = "执行耗时不能为空")
    private Integer duration;
}

