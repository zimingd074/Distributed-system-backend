package com.distributed.monitor.vo.alert;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 告警列表VO
 */
@Data
public class AlertListVO {
    
    private Long alertId;
    
    private String alertNo;
    
    private Long deviceId;
    
    private String deviceName;
    
    private String alertLevel;
    
    private String alertType;
    
    private String alertMessage;
    
    private String status;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime alertTime;
    
    private String confirmedUser;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime confirmedTime;
}

