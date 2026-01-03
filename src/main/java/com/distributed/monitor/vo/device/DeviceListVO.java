package com.distributed.monitor.vo.device;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 设备列表VO
 */
@Data
public class DeviceListVO {
    
    private Long id;
    
    private String deviceCode;
    
    private String deviceName;
    
    private String deviceType;
    
    private Long groupId;
    
    private String groupName;
    
    private String ipAddress;
    
    private String location;
    
    private String status;
    
    private Integer onlineStatus;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime lastHeartbeatTime;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime registerTime;
}

