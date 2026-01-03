package com.distributed.monitor.vo.device;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 设备详情VO
 */
@Data
public class DeviceDetailVO {
    
    private Long id;
    
    private String deviceCode;
    
    private String deviceName;
    
    private String deviceType;
    
    private Long groupId;
    
    private String groupName;
    
    private String ipAddress;
    
    private Integer port;
    
    private String macAddress;
    
    private String location;
    
    private String description;
    
    private String status;
    
    private Integer onlineStatus;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime lastHeartbeatTime;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime registerTime;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime createdAt;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime updatedAt;
    
    private CurrentStatus currentStatus;
    
    @Data
    public static class CurrentStatus {
        private String doorStatus;
        private String doorControllerStatus;
    }
}

