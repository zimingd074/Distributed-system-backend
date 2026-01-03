package com.distributed.monitor.dto.device;

import lombok.Data;
import javax.validation.constraints.NotBlank;
import java.util.List;

/**
 * 批量设备状态历史查询 DTO
 */
@Data
public class DeviceStatusBulkQueryDTO {
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

    /**
     * 设备ID列表
     */
    private List<Long> deviceIds;

    /**
     * 单一设备编码
     */
    private String deviceCode;

    /**
     * 设备分组ID
     */
    private Long groupId;

    /**
     * 分页
     */
    private Integer page = 1;
    private Integer pageSize = 50;

    /**
     * 排序：reportTime_desc / reportTime_asc
     */
    private String sort;
}


