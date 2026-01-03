package com.distributed.monitor.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.StrUtil;
import cn.hutool.json.JSONUtil;
import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.dto.alert.AlertQueryDTO;
import com.distributed.monitor.dto.alert.AlertResolveDTO;
import com.distributed.monitor.entity.AlertRecord;
import com.distributed.monitor.entity.Device;
import com.distributed.monitor.entity.SysUser;
import com.distributed.monitor.exception.NotFoundException;
import com.distributed.monitor.mapper.AlertMapper;
import com.distributed.monitor.mapper.AuthMapper;
import com.distributed.monitor.mapper.DeviceMapper;
import com.distributed.monitor.service.AlertService;
import com.distributed.monitor.util.RequestUtil;
import com.distributed.monitor.vo.alert.AlertListVO;
import com.distributed.monitor.vo.alert.AlertStatisticsVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 告警服务实现
 */
@Service
@RequiredArgsConstructor
public class AlertServiceImpl implements AlertService {
    
    private final AlertMapper alertMapper;
    private final DeviceMapper deviceMapper;
    private final AuthMapper authMapper;
    
    @Override
    public PageResult<AlertListVO> getAlertList(AlertQueryDTO dto) {
        // 验证分页参数
        if (dto.getPage() == null || dto.getPage() < 1) {
            dto.setPage(1);
        }
        if (dto.getPageSize() == null || dto.getPageSize() < 1) {
            dto.setPageSize(10);
        }
        if (dto.getPageSize() > 100) {
            dto.setPageSize(100); // 最大100
        }
        
        // 计算分页参数
        int offset = (dto.getPage() - 1) * dto.getPageSize();
        
        // 查询总数
        Long total = alertMapper.countAlerts(dto);
        
        // 查询告警列表
        List<AlertRecord> alertList = alertMapper.selectAlertList(dto, offset, dto.getPageSize());
        
        // 转换为VO
        List<AlertListVO> list = alertList.stream()
                .map(alert -> {
                    AlertListVO vo = BeanUtil.copyProperties(alert, AlertListVO.class);
                    vo.setAlertId(alert.getId());
                    
                    // 查询设备信息
                    Device device = deviceMapper.selectDeviceById(alert.getDeviceId());
                    if (device != null) {
                        vo.setDeviceName(device.getDeviceName());
                    }
                    
                    // 查询确认用户信息
                    if (alert.getConfirmedUserId() != null) {
                        SysUser confirmedUser = authMapper.selectUserById(alert.getConfirmedUserId());
                        if (confirmedUser != null) {
                            vo.setConfirmedUser(confirmedUser.getUsername());
                        }
                        vo.setConfirmedTime(alert.getConfirmedTime());
                    }
                    
                    return vo;
                })
                .collect(Collectors.toList());
        
        return new PageResult<>(total, list, dto.getPage(), dto.getPageSize());
    }
    
    @Override
    public Map<String, Object> getAlertDetail(Long id) {
        AlertRecord alert = alertMapper.selectAlertById(id);
        if (alert == null) {
            throw new NotFoundException("告警不存在");
        }
        
        Map<String, Object> detail = new HashMap<>();
        detail.put("alertId", alert.getId());
        detail.put("alertNo", alert.getAlertNo());
        detail.put("ruleId", alert.getRuleId());
        detail.put("deviceId", alert.getDeviceId());
        detail.put("alertLevel", alert.getAlertLevel());
        detail.put("alertType", alert.getAlertType());
        detail.put("alertMessage", alert.getAlertMessage());
        detail.put("status", alert.getStatus());
        if (alert.getAlertTime() != null) {
            detail.put("alertTime", alert.getAlertTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        } else {
            detail.put("alertTime", null);
        }
        if (alert.getCreatedAt() != null) {
            detail.put("createdAt", alert.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        } else {
            detail.put("createdAt", null);
        }
        if (alert.getUpdatedAt() != null) {
            detail.put("updatedAt", alert.getUpdatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        } else {
            detail.put("updatedAt", null);
        }
        
        // 查询设备信息
        Device device = deviceMapper.selectDeviceById(alert.getDeviceId());
        if (device != null) {
            detail.put("deviceName", device.getDeviceName());
        }
        
        // 解析JSON字段
        if (StrUtil.isNotBlank(alert.getAlertData())) {
            detail.put("alertData", JSONUtil.parseObj(alert.getAlertData()));
        } else {
            detail.put("alertData", null);
        }
        
        // 查询确认用户信息
        if (alert.getConfirmedUserId() != null) {
            detail.put("confirmedUserId", alert.getConfirmedUserId());
            SysUser confirmedUser = authMapper.selectUserById(alert.getConfirmedUserId());
            if (confirmedUser != null) {
                detail.put("confirmedUser", confirmedUser.getUsername());
            } else {
                detail.put("confirmedUser", null);
            }
            if (alert.getConfirmedTime() != null) {
                detail.put("confirmedTime", alert.getConfirmedTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            } else {
                detail.put("confirmedTime", null);
            }
        } else {
            detail.put("confirmedUserId", null);
            detail.put("confirmedUser", null);
            detail.put("confirmedTime", null);
        }
        
        // 查询解决用户信息
        if (alert.getResolvedUserId() != null) {
            detail.put("resolvedUserId", alert.getResolvedUserId());
            SysUser resolvedUser = authMapper.selectUserById(alert.getResolvedUserId());
            if (resolvedUser != null) {
                detail.put("resolvedUser", resolvedUser.getUsername());
            } else {
                detail.put("resolvedUser", null);
            }
            if (alert.getResolvedTime() != null) {
                detail.put("resolvedTime", alert.getResolvedTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            } else {
                detail.put("resolvedTime", null);
            }
            detail.put("resolveRemark", alert.getResolveRemark());
        } else {
            detail.put("resolvedUserId", null);
            detail.put("resolvedUser", null);
            detail.put("resolvedTime", null);
            detail.put("resolveRemark", null);
        }
        
        return detail;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> confirmAlert(Long id) {
        AlertRecord alert = alertMapper.selectAlertById(id);
        if (alert == null) {
            throw new NotFoundException("告警不存在");
        }
        
        // 从请求中获取当前用户ID
        Long currentUserId = RequestUtil.getCurrentUserId();
        if (currentUserId == null) {
            throw new com.distributed.monitor.exception.UnauthorizedException("未登录或Token无效");
        }
        
        // 更新告警状态
        alertMapper.updateAlertStatus(id, "confirmed", currentUserId, null);
        
        // 查询更新后的告警信息
        AlertRecord updatedAlert = alertMapper.selectAlertById(id);
        
        // 查询确认用户信息
        String confirmedUser = null;
        if (updatedAlert.getConfirmedUserId() != null) {
            SysUser user = authMapper.selectUserById(updatedAlert.getConfirmedUserId());
            if (user != null) {
                confirmedUser = user.getUsername();
            }
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("alertId", id);
        result.put("status", "confirmed");
        result.put("confirmedUser", confirmedUser);
        if (updatedAlert.getConfirmedTime() != null) {
            result.put("confirmedTime", updatedAlert.getConfirmedTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        } else {
            result.put("confirmedTime", null);
        }
        
        return result;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> resolveAlert(Long id, AlertResolveDTO dto) {
        AlertRecord alert = alertMapper.selectAlertById(id);
        if (alert == null) {
            throw new NotFoundException("告警不存在");
        }
        
        // 从请求中获取当前用户ID
        Long currentUserId = RequestUtil.getCurrentUserId();
        if (currentUserId == null) {
            throw new com.distributed.monitor.exception.UnauthorizedException("未登录或Token无效");
        }
        
        // 更新告警状态
        alertMapper.updateAlertStatus(id, "resolved", currentUserId, dto.getResolveRemark());
        
        // 查询更新后的告警信息
        AlertRecord updatedAlert = alertMapper.selectAlertById(id);
        
        // 查询解决用户信息
        String resolvedUser = null;
        if (updatedAlert.getResolvedUserId() != null) {
            SysUser user = authMapper.selectUserById(updatedAlert.getResolvedUserId());
            if (user != null) {
                resolvedUser = user.getUsername();
            }
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("alertId", id);
        result.put("status", "resolved");
        result.put("resolvedUser", resolvedUser);
        if (updatedAlert.getResolvedTime() != null) {
            result.put("resolvedTime", updatedAlert.getResolvedTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        } else {
            result.put("resolvedTime", null);
        }
        
        return result;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> ignoreAlert(Long id) {
        AlertRecord alert = alertMapper.selectAlertById(id);
        if (alert == null) {
            throw new NotFoundException("告警不存在");
        }
        
        // 从请求中获取当前用户ID
        Long currentUserId = RequestUtil.getCurrentUserId();
        if (currentUserId == null) {
            throw new com.distributed.monitor.exception.UnauthorizedException("未登录或Token无效");
        }
        
        // 更新告警状态
        alertMapper.updateAlertStatus(id, "ignored", currentUserId, null);
        
        Map<String, Object> result = new HashMap<>();
        result.put("alertId", id);
        result.put("status", "ignored");
        
        return result;
    }
    
    @Override
    public AlertStatisticsVO getAlertStatistics(String timeRange) {
        AlertStatisticsVO statistics = alertMapper.selectAlertStatistics(timeRange);
        
        if (statistics == null) {
            statistics = new AlertStatisticsVO();
            statistics.setTotalCount(0);
            statistics.setPendingCount(0);
            statistics.setConfirmedCount(0);
            statistics.setResolvedCount(0);
            statistics.setCriticalCount(0);
            statistics.setErrorCount(0);
            statistics.setWarningCount(0);
        }
        
        // 查询级别分布
        List<AlertStatisticsVO.LevelDistribution> levelDistribution = 
                alertMapper.selectAlertLevelDistribution(timeRange);
        statistics.setLevelDistribution(levelDistribution != null ? levelDistribution : new ArrayList<>());
        
        // 查询类型分布
        List<AlertStatisticsVO.TypeDistribution> typeDistribution = 
                alertMapper.selectAlertTypeDistribution(timeRange);
        statistics.setTypeDistribution(typeDistribution != null ? typeDistribution : new ArrayList<>());
        
        return statistics;
    }
}

