package com.distributed.monitor.mapper;

import com.distributed.monitor.entity.SysUser;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 系统用户管理 Mapper（简单分页查询）
 */
@Mapper
public interface SysUserMapper {

    @Select("SELECT COUNT(1) FROM sys_user")
    long countAll();

    @Select("SELECT id, username, real_name AS realName, email, phone, avatar_url AS avatarUrl, status, is_admin AS isAdmin, last_login_time AS lastLoginTime, created_at AS createdAt, updated_at AS updatedAt " +
            "FROM sys_user ORDER BY id LIMIT #{limit} OFFSET #{offset}")
    List<SysUser> selectPage(@Param("offset") int offset, @Param("limit") int limit);

    @Select("SELECT id, username, real_name AS realName, email, phone, avatar_url AS avatarUrl, status, is_admin AS isAdmin, last_login_time AS lastLoginTime, created_at AS createdAt, updated_at AS updatedAt " +
            "FROM sys_user WHERE id = #{id}")
    SysUser selectById(@Param("id") Long id);

    @Select("SELECT id, username, real_name AS realName, email, phone, avatar_url AS avatarUrl, status, is_admin AS isAdmin, last_login_time AS lastLoginTime, created_at AS createdAt, updated_at AS updatedAt " +
            "FROM sys_user WHERE username = #{username}")
    SysUser selectByUsername(@Param("username") String username);

    @Insert("INSERT INTO sys_user(username, password, real_name, email, phone, avatar_url, status, is_admin, created_at, updated_at) " +
            "VALUES(#{username}, #{password}, #{realName}, #{email}, #{phone}, #{avatarUrl}, #{status}, #{isAdmin}, NOW(), NOW())")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(SysUser user);

    int update(SysUser user);

    @Delete("DELETE FROM sys_user WHERE id=#{id}")
    int delete(@Param("id") Long id);

    @Update("UPDATE sys_user SET password=#{password}, updated_at=NOW() WHERE id=#{id}")
    int resetPassword(@Param("id") Long id, @Param("password") String password);
}

