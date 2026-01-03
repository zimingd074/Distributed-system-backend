package com.distributed.monitor.mapper;

import com.distributed.monitor.entity.SysPermission;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 权限管理 Mapper
 */
@Mapper
public interface SysPermissionMapper {

    @Select("SELECT id, permission_code AS permissionCode, permission_name AS permissionName, resource_type AS resourceType, parent_id AS parentId, resource_path AS resourcePath, description, sort_order AS sortOrder, created_at AS createdAt " +
            "FROM sys_permission ORDER BY sort_order ASC, id ASC")
    List<SysPermission> selectAll();
}

