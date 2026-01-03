package com.distributed.monitor.service;

import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.dto.device.*;
import com.distributed.monitor.vo.device.*;


import java.util.List;
import java.util.Map;

/**
 * 设备服务接口
 */
public interface DeviceService {
    
    /**
     * 获取设备列表
     */
    PageResult<DeviceListVO> getDeviceList(DeviceQueryDTO dto);
    
    /**
     * 获取设备详情
     */
    DeviceDetailVO getDeviceDetail(Long id);
    
    /**
     * 添加设备
     */
    Map<String, Object> addDevice(DeviceAddDTO dto);
    
    /**
     * 更新设备
     */
    void updateDevice(DeviceUpdateDTO dto);
    
    /**
     * 删除设备
     */
    void deleteDevice(Long id);
    
    /**
     * 获取设备分组
     */
    List<Map<String, Object>> getDeviceGroups();
    
    /**
     * 获取设备统计
     */
    DeviceStatisticsVO getDeviceStatistics();
    
    /**
     * 获取设备配置
     */
    List<DeviceConfigVO> getDeviceConfig(Long id);
    
    /**
     * 更新设备配置
     */
    Map<String, Object> updateDeviceConfig(Long id, DeviceConfigUpdateDTO dto);
    
    /**
     * 同步配置到设备
     */
    Map<String, Object> syncDeviceConfig(Long id);
    
    /**
     * 获取设备实时状态
     */
    DeviceStatusVO getDeviceStatus(Long id);
    
    /**
     * 获取设备状态历史
     */
    List<DeviceStatusVO> getDeviceStatusHistory(Long id, DeviceStatusQueryDTO dto);
    
    /**
     * 批量获取设备状态历史（按时间范围，支持多设备筛选）
     */
    PageResult<DeviceStatusVO> getDeviceStatusHistoryBulk(DeviceStatusBulkQueryDTO dto);
    
    /**
     * 获取设备心跳记录
     */
    List<Map<String, Object>> getDeviceHeartbeat(Long id, String startTime, String endTime, Integer limit);
}

