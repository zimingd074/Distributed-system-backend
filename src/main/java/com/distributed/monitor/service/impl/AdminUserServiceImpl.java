package com.distributed.monitor.service.impl;

import cn.hutool.core.bean.BeanUtil;
import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.dto.admin.UserCreateDTO;
import com.distributed.monitor.dto.admin.UserUpdateDTO;
import com.distributed.monitor.entity.SysUser;
import com.distributed.monitor.exception.BusinessException;
import com.distributed.monitor.exception.NotFoundException;
import com.distributed.monitor.mapper.SysUserMapper;
import com.distributed.monitor.service.AdminUserService;
import com.distributed.monitor.util.PasswordUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 管理端用户管理服务实现
 */
@Service
@RequiredArgsConstructor
public class AdminUserServiceImpl implements AdminUserService {

    private final SysUserMapper sysUserMapper;

    @Override
    public PageResult<SysUser> listUsers(int page, int pageSize) {
        // 验证分页参数
        int safePage = Math.max(page, 1);
        int safePageSize = Math.max(pageSize, 1);
        if (safePageSize > 100) {
            safePageSize = 100; // 最大100
        }
        int offset = (safePage - 1) * safePageSize;

        long total = sysUserMapper.countAll();
        List<SysUser> rows = total == 0 ? Collections.emptyList() : sysUserMapper.selectPage(offset, safePageSize);

        // 注意：SysUser实体中的时间字段会自动序列化，但为了确保格式一致，
        // 如果前端需要特定格式，可以在Controller层或VO层处理
        return new PageResult<>(total, rows, safePage, safePageSize);
    }

    @Override
    public Map<String, Object> createUser(UserCreateDTO dto) {
        // 检查用户名是否已存在
        SysUser existingUser = sysUserMapper.selectByUsername(dto.getUsername());
        if (existingUser != null) {
            throw new BusinessException("用户名已存在");
        }

        // 转换为实体
        SysUser user = new SysUser();
        user.setUsername(dto.getUsername());
        user.setPassword(dto.getPassword());
        user.setRealName(dto.getRealName());
        user.setEmail(dto.getEmail());
        user.setPhone(dto.getPhone());
        user.setAvatarUrl(dto.getAvatarUrl());
        
        // 转换Boolean为Integer，设置默认值
        if (dto.getStatus() != null) {
            user.setStatus(dto.getStatus() ? 1 : 0);
        } else {
            user.setStatus(1); // 默认启用
        }
        
        if (dto.getIsAdmin() != null) {
            user.setIsAdmin(dto.getIsAdmin() ? 1 : 0);
        } else {
            user.setIsAdmin(0); // 默认非管理员
        }
        
        // 密码加密
        user.setPassword(PasswordUtil.encode(dto.getPassword()));
        
        sysUserMapper.insert(user);
        
        Map<String, Object> result = new HashMap<>();
        result.put("id", user.getId());
        result.put("username", user.getUsername());
        if (user.getCreatedAt() != null) {
            result.put("createdAt", user.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        } else {
            result.put("createdAt", null);
        }
        return result;
    }

    @Override
    public void updateUser(Long id, UserUpdateDTO dto) {
        SysUser existingUser = sysUserMapper.selectById(id);
        if (existingUser == null) {
            throw new NotFoundException("用户不存在");
        }

        // 只更新DTO中提供的非null字段
        if (dto.getRealName() != null) {
            existingUser.setRealName(dto.getRealName());
        }
        if (dto.getEmail() != null) {
            existingUser.setEmail(dto.getEmail());
        }
        if (dto.getPhone() != null) {
            existingUser.setPhone(dto.getPhone());
        }
        if (dto.getAvatarUrl() != null) {
            existingUser.setAvatarUrl(dto.getAvatarUrl());
        }
        
        // Boolean字段：如果为null则不更新，否则更新
        if (dto.getStatus() != null) {
            existingUser.setStatus(dto.getStatus() ? 1 : 0);
        }
        if (dto.getIsAdmin() != null) {
            existingUser.setIsAdmin(dto.getIsAdmin() ? 1 : 0);
        }

        sysUserMapper.update(existingUser);
    }

    @Override
    public void deleteUser(Long id) {
        SysUser existingUser = sysUserMapper.selectById(id);
        if (existingUser == null) {
            throw new NotFoundException("用户不存在");
        }
        sysUserMapper.delete(id);
    }

    @Override
    public void resetPassword(Long id, String password) {
        if (!StringUtils.hasText(password)) {
            throw new BusinessException("密码不能为空");
        }
        SysUser existingUser = sysUserMapper.selectById(id);
        if (existingUser == null) {
            throw new NotFoundException("用户不存在");
        }
        // 密码加密
        String hashedPassword = PasswordUtil.encode(password);
        sysUserMapper.resetPassword(id, hashedPassword);
    }
}

