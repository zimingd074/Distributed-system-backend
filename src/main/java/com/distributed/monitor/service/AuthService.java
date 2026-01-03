package com.distributed.monitor.service;

import com.distributed.monitor.dto.auth.LoginDTO;
import com.distributed.monitor.vo.auth.LoginVO;
import com.distributed.monitor.vo.auth.UserProfileVO;

/**
 * 认证服务接口
 */
public interface AuthService {
    
    /**
     * 用户登录
     */
    LoginVO login(LoginDTO dto);
    
    /**
     * 用户登出
     */
    void logout();
    
    /**
     * 刷新Token
     */
    LoginVO refreshToken(String refreshToken);
    
    /**
     * 获取当前用户信息
     */
    UserProfileVO getCurrentUserProfile();
}

