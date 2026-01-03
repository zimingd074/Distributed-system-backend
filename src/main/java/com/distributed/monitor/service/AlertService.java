package com.distributed.monitor.service;

import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.dto.alert.AlertQueryDTO;
import com.distributed.monitor.dto.alert.AlertResolveDTO;
import com.distributed.monitor.vo.alert.AlertListVO;
import com.distributed.monitor.vo.alert.AlertStatisticsVO;

import java.util.Map;

/**
 * 告警服务接口
 */
public interface AlertService {
    
    /**
     * 获取告警列表
     */
    PageResult<AlertListVO> getAlertList(AlertQueryDTO dto);
    
    /**
     * 获取告警详情
     */
    Map<String, Object> getAlertDetail(Long id);
    
    /**
     * 确认告警
     */
    Map<String, Object> confirmAlert(Long id);
    
    /**
     * 解决告警
     */
    Map<String, Object> resolveAlert(Long id, AlertResolveDTO dto);
    
    /**
     * 忽略告警
     */
    Map<String, Object> ignoreAlert(Long id);
    
    /**
     * 获取告警统计
     */
    AlertStatisticsVO getAlertStatistics(String timeRange);
}

