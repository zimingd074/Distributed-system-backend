package com.distributed.monitor.mapper;

import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 角色-权限关联 Mapper
 */
@Mapper
public interface SysRolePermissionMapper {

    @Delete("DELETE FROM sys_role_permission WHERE role_id = #{roleId}")
    int deleteByRoleId(@Param("roleId") Long roleId);

    @Insert({
            "<script>",
            "INSERT INTO sys_role_permission(role_id, permission_id, created_at) VALUES",
            "<foreach collection='permissionIds' item='pid' separator=','>",
            "(#{roleId}, #{pid}, NOW())",
            "</foreach>",
            "</script>"
    })
    int insertBatch(@Param("roleId") Long roleId, @Param("permissionIds") List<Long> permissionIds);
}

