package com.distributed.monitor.dto.device;

import lombok.Data;
import javax.validation.constraints.NotBlank;

/**
 * 设备状态历史查询DTO
 */
@Data
public class DeviceStatusQueryDTO {
    
    @NotBlank(message = "开始时间不能为空")
    private String startTime;
    
    @NotBlank(message = "结束时间不能为空")
    private String endTime;
    
    /**
     * 状态类型筛选
     */
    private String statusType;
    
    /**
     * 采样间隔：1m/5m/10m/30m/1h
     */
    private String interval;
}

