package com.distributed.monitor.controller;

import com.distributed.monitor.annotation.NoAuth;
import com.distributed.monitor.common.Result;
import com.distributed.monitor.dto.auth.LoginDTO;
import com.distributed.monitor.service.AuthService;
import com.distributed.monitor.vo.auth.LoginVO;
import com.distributed.monitor.vo.auth.UserProfileVO;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * 认证授权控制器
 */
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {
    
    private final AuthService authService;
    
    /**
     * 1.1 用户登录
     */
    @NoAuth
    @PostMapping("/login")
    public Result<LoginVO> login(@Validated @RequestBody LoginDTO dto) {
        LoginVO loginVO = authService.login(dto);
        return Result.success("登录成功", loginVO);
    }
    
    /**
     * 1.2 用户登出
     */
    @PostMapping("/logout")
    public Result<Void> logout() {
        authService.logout();
        return Result.success("登出成功", null);
    }
    
    /**
     * 1.3 刷新Token
     * 注意：此接口需要refreshToken，不是accessToken
     */
    @NoAuth
    @PostMapping("/refresh")
    public Result<LoginVO> refreshToken(@RequestHeader("Authorization") String refreshToken) {
        LoginVO loginVO = authService.refreshToken(refreshToken);
        return Result.success("Token刷新成功", loginVO);
    }
    
    /**
     * 1.4 获取当前用户信息
     */
    @GetMapping("/profile")
    public Result<UserProfileVO> getProfile() {
        UserProfileVO profileVO = authService.getCurrentUserProfile();
        return Result.success("获取成功", profileVO);
    }
}

