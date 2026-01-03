package com.distributed.monitor.dto.device;

import lombok.Data;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotNull;

/**
 * 设备查询DTO
 */
@Data
public class DeviceQueryDTO {
    
    /**
     * 关键词搜索（设备名称、编码）
     */
    private String keyword;
    
    /**
     * 设备分组ID
     */
    private Long groupId;
    
    /**
     * 设备类型
     */
    private String deviceType;
    
    /**
     * 状态筛选：online/offline/fault/maintain
     */
    private String status;
    
    /**
     * 在线状态：0-离线 1-在线
     */
    private Integer onlineStatus;
    
    /**
     * 页码，从1开始
     */
    @NotNull(message = "页码不能为空")
    @Min(value = 1, message = "页码必须大于0")
    private Integer page;
    
    /**
     * 每页记录数，最大100
     */
    @NotNull(message = "每页记录数不能为空")
    @Min(value = 1, message = "每页记录数必须大于0")
    private Integer pageSize;
}

