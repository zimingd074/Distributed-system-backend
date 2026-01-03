package com.distributed.monitor.dto.deviceapi;

import lombok.Data;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotEmpty;
import java.util.List;

/**
 * 配置同步确认DTO
 */
@Data
public class ConfigSyncConfirmDTO {
    
    /**
     * 设备编码
     */
    @NotBlank(message = "设备编码不能为空")
    private String deviceCode;
    
    /**
     * 设备密钥
     */
    @NotBlank(message = "设备密钥不能为空")
    private String deviceSecret;
    
    /**
     * 已同步的配置键列表
     */
    @NotEmpty(message = "配置键列表不能为空")
    private List<String> configKeys;
}

