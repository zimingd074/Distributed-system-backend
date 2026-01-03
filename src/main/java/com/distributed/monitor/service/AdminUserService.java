package com.distributed.monitor.service;

import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.dto.admin.UserCreateDTO;
import com.distributed.monitor.dto.admin.UserUpdateDTO;
import com.distributed.monitor.entity.SysUser;

import java.util.Map;

/**
 * 管理端用户管理服务
 */
public interface AdminUserService {

    /**
     * 分页查询用户列表
     */
    PageResult<SysUser> listUsers(int page, int pageSize);

    /**
     * 创建用户
     */
    Map<String, Object> createUser(UserCreateDTO dto);

    /**
     * 更新用户
     */
    void updateUser(Long id, UserUpdateDTO dto);

    /**
     * 删除用户
     */
    void deleteUser(Long id);

    /**
     * 重置密码
     */
    void resetPassword(Long id, String password);
}

