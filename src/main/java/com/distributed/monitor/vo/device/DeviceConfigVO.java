package com.distributed.monitor.vo.device;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 设备配置VO
 */
@Data
public class DeviceConfigVO {
    
    private Long configId;
    
    private String configKey;
    
    private String configValue;
    
    private String configType;
    
    private String description;
    
    private Boolean isSynced;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime syncTime;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime updatedAt;
}

