package com.distributed.monitor.dto.deviceapi;

import lombok.Data;
import javax.validation.constraints.NotBlank;

/**
 * 设备认证登录DTO
 */
@Data
public class DeviceLoginDTO {
    
    @NotBlank(message = "设备编码不能为空")
    private String deviceCode;
    
    @NotBlank(message = "设备密钥不能为空")
    private String deviceSecret;
}

