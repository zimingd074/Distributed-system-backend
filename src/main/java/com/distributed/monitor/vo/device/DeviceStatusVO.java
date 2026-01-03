package com.distributed.monitor.vo.device;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import java.time.LocalDateTime;
import java.time.LocalDateTime;
import java.util.Map;

/**
 * 设备状态VO
 */
@Data
public class DeviceStatusVO {
    
    private Long deviceId;
    
    private String deviceName;
    
    private Integer onlineStatus;
    
    private String doorStatus;
    
    private String doorControllerStatus;
    
    private Map<String, Object> customData;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime reportTime;
}

