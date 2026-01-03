package com.distributed.monitor.dto.alert;

import lombok.Data;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotNull;

/**
 * 告警查询DTO
 */
@Data
public class AlertQueryDTO {
    
    /**
     * 设备ID筛选
     */
    private Long deviceId;
    
    /**
     * 告警级别：info/warning/error/critical
     */
    private String alertLevel;
    
    /**
     * 状态：pending/confirmed/resolved/ignored
     */
    private String status;
    
    /**
     * 开始时间
     */
    private String startTime;
    
    /**
     * 结束时间
     */
    private String endTime;
    
    /**
     * 页码
     */
    @NotNull(message = "页码不能为空")
    @Min(value = 1, message = "页码必须大于0")
    private Integer page;
    
    /**
     * 每页记录数
     */
    @NotNull(message = "每页记录数不能为空")
    @Min(value = 1, message = "每页记录数必须大于0")
    private Integer pageSize;
}

