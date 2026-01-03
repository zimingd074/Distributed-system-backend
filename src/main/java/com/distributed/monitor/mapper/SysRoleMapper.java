package com.distributed.monitor.mapper;

import com.distributed.monitor.entity.SysRole;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 角色管理 Mapper
 */
@Mapper
public interface SysRoleMapper {

    @Select("SELECT COUNT(1) FROM sys_role")
    long countAll();

    @Select("SELECT id, role_code AS roleCode, role_name AS roleName, description, status, created_at AS createdAt, updated_at AS updatedAt " +
            "FROM sys_role ORDER BY id LIMIT #{limit} OFFSET #{offset}")
    List<SysRole> selectPage(@Param("offset") int offset, @Param("limit") int limit);

    @Select("SELECT id, role_code AS roleCode, role_name AS roleName, description, status, created_at AS createdAt, updated_at AS updatedAt " +
            "FROM sys_role WHERE id = #{id}")
    SysRole selectById(@Param("id") Long id);
    
    @Select("SELECT id, role_code AS roleCode, role_name AS roleName, description, status, created_at AS createdAt, updated_at AS updatedAt " +
            "FROM sys_role WHERE role_code = #{roleCode}")
    SysRole selectByRoleCode(@Param("roleCode") String roleCode);

    @Insert("INSERT INTO sys_role(role_code, role_name, description, status, created_at, updated_at) " +
            "VALUES(#{roleCode}, #{roleName}, #{description}, #{status}, NOW(), NOW())")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(SysRole role);

    int update(SysRole role);

    @Delete("DELETE FROM sys_role WHERE id=#{id}")
    int delete(@Param("id") Long id);
}

