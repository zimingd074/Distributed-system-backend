package com.distributed.monitor.dto.device;

import lombok.Data;
import javax.validation.constraints.NotBlank;

/**
 * 添加设备DTO
 */
@Data
public class DeviceAddDTO {
    
    @NotBlank(message = "设备编码不能为空")
    private String deviceCode;
    
    @NotBlank(message = "设备名称不能为空")
    private String deviceName;
    
    @NotBlank(message = "设备类型不能为空")
    private String deviceType;
    
    private Long groupId;
    
    private String ipAddress;
    
    private Integer port;
    
    private String macAddress;
    
    private String location;
    
    private String description;
}

