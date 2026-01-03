package com.distributed.monitor.vo.deviceapi;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 状态上报响应VO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StatusReportResponseVO {
    
    private Boolean received;
    
    private Long statusId;
}

