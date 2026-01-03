package com.distributed.monitor.vo.deviceapi;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 心跳响应VO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class HeartbeatResponseVO {
    
    private Boolean received;
    
    private Long serverTime;
    
    private Integer nextHeartbeatInterval;
}

