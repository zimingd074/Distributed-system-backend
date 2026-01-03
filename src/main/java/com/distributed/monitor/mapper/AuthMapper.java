package com.distributed.monitor.mapper;

import com.distributed.monitor.entity.SysUser;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 认证Mapper
 */
@Mapper
public interface AuthMapper {
    
    /**
     * 根据用户名查询用户
     */
    SysUser selectUserByUsername(@Param("username") String username);
    
    /**
     * 根据用户ID查询用户
     */
    SysUser selectUserById(@Param("id") Long id);
    
    /**
     * 更新用户最后登录信息
     */
    void updateLastLoginInfo(
            @Param("id") Long id,
            @Param("lastLoginTime") java.time.LocalDateTime lastLoginTime,
            @Param("lastLoginIp") String lastLoginIp);
    
    /**
     * 查询用户的角色编码列表
     */
    List<String> selectUserRoleCodes(@Param("userId") Long userId);
    
    /**
     * 查询用户的角色列表（包含角色编码和名称）
     */
    List<Map<String, Object>> selectUserRoles(@Param("userId") Long userId);
    
    /**
     * 查询用户的权限编码列表
     */
    List<String> selectUserPermissionCodes(@Param("userId") Long userId);
}

