package com.distributed.monitor.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.crypto.digest.BCrypt;
import com.distributed.monitor.dto.auth.LoginDTO;
import com.distributed.monitor.exception.BusinessException;
import com.distributed.monitor.exception.NotFoundException;
import com.distributed.monitor.exception.UnauthorizedException;
import com.distributed.monitor.util.PasswordUtil;
import com.distributed.monitor.entity.SysUser;
import com.distributed.monitor.mapper.AuthMapper;
import com.distributed.monitor.service.AuthService;
import com.distributed.monitor.util.JwtUtil;
import com.distributed.monitor.vo.auth.LoginVO;
import com.distributed.monitor.vo.auth.UserProfileVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 认证服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {
    
    private final AuthMapper authMapper;
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public LoginVO login(LoginDTO dto) {
        // 查询用户
        SysUser user = authMapper.selectUserByUsername(dto.getUsername());
        if (user == null) {
            throw new BusinessException("用户名或密码错误");
        }
        
        // 验证密码（使用BCrypt）
        if (!StringUtils.hasText(user.getPassword())) {
            throw new BusinessException("用户密码未设置");
        }
        
        // 密码验证逻辑
        boolean passwordValid = false;
        String storedPassword = user.getPassword();
        
        // 检查是否为占位符密码（数据库初始化脚本中的占位符）
        boolean isPlaceholder = storedPassword.contains("encrypted_password_here");
        
        if (isPlaceholder) {
            // 占位符密码：开发环境允许使用明文密码验证
            // 默认密码：admin123（根据数据库初始化脚本注释）
            log.warn("检测到占位符密码，使用开发模式验证。用户名: {}", dto.getUsername());
            passwordValid = dto.getPassword().equals("admin123") || dto.getPassword().equals(storedPassword);
        } else if (storedPassword.startsWith("$2a$") || storedPassword.startsWith("$2b$")) {
            // BCrypt加密的密码（真正的BCrypt哈希应该有60个字符）
            if (storedPassword.length() < 60) {
                log.warn("BCrypt密码格式不正确，长度: {}, 用户名: {}", storedPassword.length(), dto.getUsername());
                // 格式不正确，尝试明文比较（开发环境）
                passwordValid = dto.getPassword().equals(storedPassword);
            } else {
                try {
                    passwordValid = PasswordUtil.matches(dto.getPassword(), storedPassword);
                    if (!passwordValid) {
                        log.debug("BCrypt密码验证失败，用户名: {}", dto.getUsername());
                    }
                } catch (Exception e) {
                    log.error("BCrypt密码验证异常，用户名: {}, 错误: {}", dto.getUsername(), e.getMessage());
                    // BCrypt验证异常，可能是格式问题，尝试明文比较（开发环境）
                    passwordValid = dto.getPassword().equals(storedPassword);
                }
            }
        } else {
            // 明文密码（仅用于开发测试）
            log.debug("使用明文密码验证，用户名: {}", dto.getUsername());
            passwordValid = dto.getPassword().equals(storedPassword);
        }
        
        if (!passwordValid) {
            log.warn("密码验证失败，用户名: {}", dto.getUsername());
            throw new BusinessException("用户名或密码错误");
        }
        
        log.info("密码验证成功，用户名: {}", dto.getUsername());
        
        // 检查用户状态
        if (user.getStatus() == null || user.getStatus() == 0) {
            throw new BusinessException("用户已被禁用");
        }
        
        // 获取客户端IP
        String clientIp = getClientIp();
        
        // 更新最后登录信息
        authMapper.updateLastLoginInfo(user.getId(), LocalDateTime.now(), clientIp);
        
        // 生成JWT Token
        String accessToken = JwtUtil.generateAccessToken(user.getId(), user.getUsername());
        String refreshToken = JwtUtil.generateRefreshToken(user.getId(), user.getUsername());
        
        // 查询用户角色和权限
        List<String> roleCodes = authMapper.selectUserRoleCodes(user.getId());
        List<String> permissionCodes = authMapper.selectUserPermissionCodes(user.getId());
        
        // 构建返回对象
        LoginVO loginVO = LoginVO.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn((int) JwtUtil.getAccessTokenExpire())
                .userId(user.getId())
                .username(user.getUsername())
                .realName(user.getRealName())
                .isAdmin(user.getIsAdmin() != null && user.getIsAdmin() == 1)
                .roles(roleCodes != null ? roleCodes : new ArrayList<>())
                .permissions(permissionCodes != null ? permissionCodes : new ArrayList<>())
                .build();
        
        return loginVO;
    }
    
    @Override
    public void logout() {
        // 清除Token的逻辑（如使用Redis存储Token黑名单，这里可以添加）
        // 当前实现为无状态JWT，客户端删除Token即可
        log.info("用户登出");
    }
    
    @Override
    public LoginVO refreshToken(String refreshToken) {
        // 移除Bearer前缀
        if (refreshToken != null && refreshToken.startsWith("Bearer ")) {
            refreshToken = refreshToken.substring(7);
        }
        
        // 验证刷新令牌
        if (!JwtUtil.validateToken(refreshToken)) {
            throw new UnauthorizedException("刷新令牌无效或已过期");
        }
        
        if (!JwtUtil.isRefreshToken(refreshToken)) {
            throw new UnauthorizedException("无效的刷新令牌类型");
        }
        
        // 从令牌中获取用户信息
        Long userId = JwtUtil.getUserIdFromToken(refreshToken);
        String username = JwtUtil.getUsernameFromToken(refreshToken);
        
        if (userId == null || username == null) {
            throw new UnauthorizedException("刷新令牌解析失败");
        }
        
        // 验证用户是否存在且状态正常
        SysUser user = authMapper.selectUserById(userId);
        if (user == null) {
            throw new NotFoundException("用户不存在");
        }
        
        if (user.getStatus() == null || user.getStatus() == 0) {
            throw new BusinessException("用户已被禁用");
        }
        
        // 生成新的令牌
        String newAccessToken = JwtUtil.generateAccessToken(userId, username);
        String newRefreshToken = JwtUtil.generateRefreshToken(userId, username);
        
        // 构建返回对象
        return LoginVO.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .tokenType("Bearer")
                .expiresIn((int) JwtUtil.getAccessTokenExpire())
                .build();
    }
    
    @Override
    public UserProfileVO getCurrentUserProfile() {
        // 从请求头中获取Token
        Long currentUserId = getCurrentUserId();
        if (currentUserId == null) {
            throw new UnauthorizedException("未登录或Token无效");
        }
        
        SysUser user = authMapper.selectUserById(currentUserId);
        if (user == null) {
            throw new NotFoundException("用户不存在");
        }
        
        UserProfileVO profileVO = BeanUtil.copyProperties(user, UserProfileVO.class);
        profileVO.setUserId(user.getId());
        profileVO.setIsAdmin(user.getIsAdmin() != null && user.getIsAdmin() == 1);
        
        // 查询用户角色和权限
        List<Map<String, Object>> roleList = authMapper.selectUserRoles(currentUserId);
        List<String> permissionCodes = authMapper.selectUserPermissionCodes(currentUserId);
        
        // 转换为RoleVO列表
        if (roleList != null && !roleList.isEmpty()) {
            List<UserProfileVO.RoleVO> roles = roleList.stream()
                    .map(roleMap -> {
                        UserProfileVO.RoleVO roleVO = new UserProfileVO.RoleVO();
                        roleVO.setRoleCode((String) roleMap.get("roleCode"));
                        roleVO.setRoleName((String) roleMap.get("roleName"));
                        return roleVO;
                    })
                    .collect(Collectors.toList());
            profileVO.setRoles(roles);
        } else {
            profileVO.setRoles(new ArrayList<>());
        }
        
        profileVO.setPermissions(permissionCodes != null ? permissionCodes : new ArrayList<>());
        
        return profileVO;
    }
    
    /**
     * 获取当前登录用户ID
     * 优先从request属性中获取（由拦截器设置），如果没有则从Token中解析
     */
    private Long getCurrentUserId() {
        try {
            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes == null) {
                return null;
            }
            
            HttpServletRequest request = attributes.getRequest();
            
            // 优先从request属性中获取（由拦截器设置）
            Object userIdObj = request.getAttribute("userId");
            if (userIdObj != null) {
                if (userIdObj instanceof Long) {
                    return (Long) userIdObj;
                } else if (userIdObj instanceof Integer) {
                    return ((Integer) userIdObj).longValue();
                }
            }
            
            // 如果request属性中没有，则从Token中解析（兼容性处理）
            String authHeader = request.getHeader("Authorization");
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String token = authHeader.substring(7);
                return JwtUtil.getUserIdFromToken(token);
            }
            
            return null;
        } catch (Exception e) {
            log.error("获取当前用户ID失败", e);
            return null;
        }
    }
    
    /**
     * 获取客户端IP地址
     */
    private String getClientIp() {
        try {
            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes == null) {
                return "127.0.0.1";
            }
            
            HttpServletRequest request = attributes.getRequest();
            String ip = request.getHeader("X-Forwarded-For");
            if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
                ip = request.getHeader("Proxy-Client-IP");
            }
            if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
                ip = request.getHeader("WL-Proxy-Client-IP");
            }
            if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
                ip = request.getRemoteAddr();
            }
            
            // 处理多个IP的情况
            if (ip != null && ip.contains(",")) {
                ip = ip.split(",")[0].trim();
            }
            
            return ip != null ? ip : "127.0.0.1";
        } catch (Exception e) {
            log.error("获取客户端IP失败", e);
            return "127.0.0.1";
        }
    }
}

