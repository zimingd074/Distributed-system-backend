package com.distributed.monitor.service;

import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.entity.SysPermission;
import com.distributed.monitor.entity.SysRole;

import java.util.List;
import java.util.Map;

/**
 * 管理端角色/权限服务
 */
public interface AdminRoleService {

    PageResult<SysRole> listRoles(int page, int pageSize);

    Map<String, Object> createRole(SysRole role);

    void updateRole(SysRole role);

    void deleteRole(Long id);

    Map<String, Object> assignPermissions(Long roleId, List<Long> permissionIds);

    List<SysPermission> listPermissions();
}

