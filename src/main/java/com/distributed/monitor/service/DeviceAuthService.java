package com.distributed.monitor.service;

import com.distributed.monitor.dto.deviceapi.DeviceLoginDTO;
import com.distributed.monitor.vo.deviceapi.DeviceLoginVO;

/**
 * 设备认证服务接口
 */
public interface DeviceAuthService {
    
    /**
     * 设备认证登录
     */
    DeviceLoginVO deviceLogin(DeviceLoginDTO dto);
    
    /**
     * 验证设备凭证（device_code和device_secret）
     */
    boolean validateDeviceCredentials(String deviceCode, String deviceSecret);
}

