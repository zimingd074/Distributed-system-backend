package com.distributed.monitor.mapper;

import com.distributed.monitor.dto.alert.AlertQueryDTO;
import com.distributed.monitor.entity.AlertRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 告警Mapper
 */
@Mapper
public interface AlertMapper {
    
    /**
     * 统计告警数量
     */
    Long countAlerts(@Param("dto") AlertQueryDTO dto);
    
    /**
     * 查询告警列表
     */
    List<AlertRecord> selectAlertList(
            @Param("dto") AlertQueryDTO dto,
            @Param("offset") int offset,
            @Param("limit") int limit);
    
    /**
     * 根据ID查询告警
     */
    AlertRecord selectAlertById(@Param("id") Long id);
    
    /**
     * 更新告警状态
     */
    void updateAlertStatus(
            @Param("id") Long id,
            @Param("status") String status,
            @Param("userId") Long userId,
            @Param("remark") String remark);
    
    /**
     * 查询告警统计
     */
    com.distributed.monitor.vo.alert.AlertStatisticsVO selectAlertStatistics(@Param("timeRange") String timeRange);
    
    /**
     * 查询告警级别分布
     */
    List<com.distributed.monitor.vo.alert.AlertStatisticsVO.LevelDistribution> selectAlertLevelDistribution(@Param("timeRange") String timeRange);
    
    /**
     * 查询告警类型分布
     */
    List<com.distributed.monitor.vo.alert.AlertStatisticsVO.TypeDistribution> selectAlertTypeDistribution(@Param("timeRange") String timeRange);

    /**
     * 插入告警记录
     */
    void insertAlert(@Param("alert") AlertRecord alert);
}

