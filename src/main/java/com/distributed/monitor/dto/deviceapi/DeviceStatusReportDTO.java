package com.distributed.monitor.dto.deviceapi;

import lombok.Data;
import javax.validation.constraints.NotBlank;
import java.util.Map;

/**
 * 设备状态上报DTO
 */
@Data
public class DeviceStatusReportDTO {
    
    @NotBlank(message = "设备编码不能为空")
    private String deviceCode;
    
    @NotBlank(message = "设备密钥不能为空")
    private String deviceSecret;
    
    @NotBlank(message = "状态类型不能为空")
    private String statusType;
    
    /**
     * 门状态：open/closed
     */
    private String doorStatus;

    /**
     * 门禁控制器状态，例如 normal/fault
     */
    private String doorControllerStatus;
    
    private Map<String, Object> customData;
    
    @NotBlank(message = "上报时间不能为空")
    private String reportTime;
}

