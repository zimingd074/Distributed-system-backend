package com.distributed.monitor.vo.device;

import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

/**
 * 设备统计VO
 */
@Data
public class DeviceStatisticsVO {
    
    private Integer totalCount;
    
    private Integer onlineCount;
    
    private Integer offlineCount;
    
    private Integer faultCount;
    
    private Integer maintainCount;
    
    private BigDecimal onlineRate;
    
    private List<GroupStatistics> groupStatistics;
    
    @Data
    public static class GroupStatistics {
        private Long groupId;
        private String groupName;
        private Integer deviceCount;
        private Integer onlineCount;
    }
}

