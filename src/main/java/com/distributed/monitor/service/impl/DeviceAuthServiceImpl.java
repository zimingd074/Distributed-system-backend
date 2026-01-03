package com.distributed.monitor.service.impl;

import com.distributed.monitor.dto.deviceapi.DeviceLoginDTO;
import com.distributed.monitor.entity.Device;
import com.distributed.monitor.exception.BusinessException;
import com.distributed.monitor.exception.NotFoundException;
import com.distributed.monitor.mapper.DeviceMapper;
import com.distributed.monitor.service.DeviceAuthService;
import com.distributed.monitor.util.JwtUtil;
import com.distributed.monitor.vo.deviceapi.DeviceLoginVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
 * 设备认证服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceAuthServiceImpl implements DeviceAuthService {
    
    private final DeviceMapper deviceMapper;
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public DeviceLoginVO deviceLogin(DeviceLoginDTO dto) {
        // 根据设备编码查询设备
        Device device = deviceMapper.selectDeviceByCode(dto.getDeviceCode());
        if (device == null) {
            throw new NotFoundException("设备不存在");
        }
        
        // 验证设备密钥
        if (device.getDeviceSecret() == null || !device.getDeviceSecret().equals(dto.getDeviceSecret())) {
            log.warn("设备密钥验证失败，设备编码: {}", dto.getDeviceCode());
            throw new BusinessException("设备编码或密钥错误");
        }
        
        // 更新最后认证时间
        device.setLastAuthTime(LocalDateTime.now());
        device.setUpdatedAt(LocalDateTime.now());
        deviceMapper.updateDevice(device);
        
        // 生成JWT Token
        String accessToken = JwtUtil.generateDeviceAccessToken(device.getId(), device.getDeviceCode());
        String refreshToken = JwtUtil.generateDeviceRefreshToken(device.getId(), device.getDeviceCode());
        
        log.info("设备认证成功，设备编码: {}, 设备ID: {}", device.getDeviceCode(), device.getId());
        
        return DeviceLoginVO.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn((int) JwtUtil.getAccessTokenExpire())
                .deviceId(device.getId())
                .deviceCode(device.getDeviceCode())
                .build();
    }
    
    @Override
    public boolean validateDeviceCredentials(String deviceCode, String deviceSecret) {
        // 根据设备编码查询设备
        Device device = deviceMapper.selectDeviceByCode(deviceCode);
        if (device == null) {
            return false;
        }
        
        // 验证设备密钥
        if (device.getDeviceSecret() == null || !device.getDeviceSecret().equals(deviceSecret)) {
            return false;
        }
        
        return true;
    }
}

