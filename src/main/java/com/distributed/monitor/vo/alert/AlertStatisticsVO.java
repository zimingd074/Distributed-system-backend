package com.distributed.monitor.vo.alert;

import lombok.Data;
import java.util.List;

/**
 * 告警统计VO
 */
@Data
public class AlertStatisticsVO {
    
    private Integer totalCount;
    
    private Integer pendingCount;
    
    private Integer confirmedCount;
    
    private Integer resolvedCount;
    
    private Integer criticalCount;
    
    private Integer errorCount;
    
    private Integer warningCount;
    
    private List<LevelDistribution> levelDistribution;
    
    private List<TypeDistribution> typeDistribution;
    
    @Data
    public static class LevelDistribution {
        private String level;
        private Integer count;
    }
    
    @Data
    public static class TypeDistribution {
        private String type;
        private Integer count;
    }
}

