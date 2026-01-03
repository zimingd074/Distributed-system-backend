package com.distributed.monitor.dto.device;

import lombok.Data;
import javax.validation.constraints.NotNull;

/**
 * 更新设备DTO
 */
@Data
public class DeviceUpdateDTO {
    
    @NotNull(message = "设备ID不能为空")
    private Long id;
    
    private String deviceName;
    
    private String deviceType;
    
    private Long groupId;
    
    private String ipAddress;
    
    private Integer port;
    
    private String macAddress;
    
    private String location;
    
    private String description;
    
    private String status;
}

