package com.distributed.monitor.dto.deviceapi;

import lombok.Data;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.util.Map;

/**
 * 设备心跳DTO
 */
@Data
public class DeviceHeartbeatDTO {
    
    @NotBlank(message = "设备编码不能为空")
    private String deviceCode;
    
    @NotBlank(message = "设备密钥不能为空")
    private String deviceSecret;
    
    @NotNull(message = "时间戳不能为空")
    private Long timestamp;
    
    /**
     * 额外数据
     */
    private Map<String, Object> extraData;
}

