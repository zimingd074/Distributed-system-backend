package com.distributed.monitor.service.impl;

import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.entity.SysPermission;
import com.distributed.monitor.entity.SysRole;
import com.distributed.monitor.exception.BusinessException;
import com.distributed.monitor.exception.NotFoundException;
import com.distributed.monitor.mapper.SysPermissionMapper;
import com.distributed.monitor.mapper.SysRoleMapper;
import com.distributed.monitor.mapper.SysRolePermissionMapper;
import com.distributed.monitor.service.AdminRoleService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 管理端角色/权限服务实现
 */
@Service
@RequiredArgsConstructor
public class AdminRoleServiceImpl implements AdminRoleService {

    private final SysRoleMapper sysRoleMapper;
    private final SysPermissionMapper sysPermissionMapper;
    private final SysRolePermissionMapper sysRolePermissionMapper;

    @Override
    public PageResult<SysRole> listRoles(int page, int pageSize) {
        // 验证分页参数
        int safePage = Math.max(page, 1);
        int safePageSize = Math.max(pageSize, 1);
        if (safePageSize > 100) {
            safePageSize = 100; // 最大100
        }
        int offset = (safePage - 1) * safePageSize;
        long total = sysRoleMapper.countAll();
        List<SysRole> rows = total == 0 ? Collections.emptyList() : sysRoleMapper.selectPage(offset, safePageSize);
        return new PageResult<>(total, rows, safePage, safePageSize);
    }

    @Override
    public Map<String, Object> createRole(SysRole role) {
        // 验证必填字段
        if (role.getRoleCode() == null || role.getRoleCode().trim().isEmpty()) {
            throw new BusinessException("角色编码不能为空");
        }
        if (role.getRoleName() == null || role.getRoleName().trim().isEmpty()) {
            throw new BusinessException("角色名称不能为空");
        }
        
        // 检查角色编码是否已存在
        SysRole existingRole = sysRoleMapper.selectByRoleCode(role.getRoleCode());
        if (existingRole != null) {
            throw new BusinessException("角色编码已存在");
        }
        
        if (role.getStatus() == null) {
            role.setStatus(1);
        }
        sysRoleMapper.insert(role);
        
        Map<String, Object> result = new HashMap<>();
        result.put("id", role.getId());
        result.put("roleCode", role.getRoleCode());
        result.put("roleName", role.getRoleName());
        if (role.getCreatedAt() != null) {
            result.put("createdAt", role.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        } else {
            result.put("createdAt", null);
        }
        return result;
    }

    @Override
    public void updateRole(SysRole role) {
        SysRole existingRole = sysRoleMapper.selectById(role.getId());
        if (existingRole == null) {
            throw new NotFoundException("角色不存在");
        }
        
        // 只更新提供的字段（roleCode不允许修改）
        if (role.getRoleName() != null) {
            existingRole.setRoleName(role.getRoleName());
        }
        if (role.getDescription() != null) {
            existingRole.setDescription(role.getDescription());
        }
        if (role.getStatus() != null) {
            existingRole.setStatus(role.getStatus());
        }
        
        sysRoleMapper.update(existingRole);
    }

    @Override
    public void deleteRole(Long id) {
        SysRole existingRole = sysRoleMapper.selectById(id);
        if (existingRole == null) {
            throw new NotFoundException("角色不存在");
        }
        // 先删除角色权限关联
        sysRolePermissionMapper.deleteByRoleId(id);
        // 再删除角色
        sysRoleMapper.delete(id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> assignPermissions(Long roleId, List<Long> permissionIds) {
        // 检查角色是否存在
        SysRole role = sysRoleMapper.selectById(roleId);
        if (role == null) {
            throw new NotFoundException("角色不存在");
        }
        
        // 验证权限ID是否存在
        if (permissionIds != null && !permissionIds.isEmpty()) {
            List<SysPermission> allPermissions = sysPermissionMapper.selectAll();
            Set<Long> validPermissionIds = allPermissions.stream()
                    .map(SysPermission::getId)
                    .collect(Collectors.toSet());
            
            for (Long permissionId : permissionIds) {
                if (!validPermissionIds.contains(permissionId)) {
                    throw new NotFoundException("权限ID " + permissionId + " 不存在");
                }
            }
        }
        
        // 删除原有权限
        sysRolePermissionMapper.deleteByRoleId(roleId);
        
        // 分配新权限
        int assignedCount = 0;
        if (permissionIds != null && !permissionIds.isEmpty()) {
            sysRolePermissionMapper.insertBatch(roleId, permissionIds);
            assignedCount = permissionIds.size();
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("roleId", roleId);
        result.put("assignedCount", assignedCount);
        return result;
    }

    @Override
    public List<SysPermission> listPermissions() {
        List<SysPermission> allPermissions = sysPermissionMapper.selectAll();
        
        // 构建树形结构
        Map<Long, SysPermission> permissionMap = new HashMap<>();
        List<SysPermission> rootPermissions = new ArrayList<>();
        
        // 第一遍：建立映射
        for (SysPermission permission : allPermissions) {
            permissionMap.put(permission.getId(), permission);
        }
        
        // 第二遍：构建树形结构
        for (SysPermission permission : allPermissions) {
            Long parentId = permission.getParentId();
            if (parentId == null || parentId == 0) {
                // 根节点
                rootPermissions.add(permission);
            } else {
                // 子节点，添加到父节点的children中
                SysPermission parent = permissionMap.get(parentId);
                if (parent != null) {
                    if (parent.getChildren() == null) {
                        parent.setChildren(new ArrayList<>());
                    }
                    parent.getChildren().add(permission);
                }
            }
        }
        
        // 为没有子节点的权限设置空列表（符合接口文档要求）
        setEmptyChildrenForLeafNodes(rootPermissions);
        
        // 按sortOrder排序
        rootPermissions.sort(Comparator.comparing(SysPermission::getSortOrder, Comparator.nullsLast(Integer::compareTo)));
        sortPermissionTree(rootPermissions);
        
        return rootPermissions;
    }
    
    /**
     * 为叶子节点设置空children列表
     */
    private void setEmptyChildrenForLeafNodes(List<SysPermission> permissions) {
        if (permissions == null || permissions.isEmpty()) {
            return;
        }
        for (SysPermission permission : permissions) {
            if (permission.getChildren() == null || permission.getChildren().isEmpty()) {
                permission.setChildren(new ArrayList<>());
            } else {
                setEmptyChildrenForLeafNodes(permission.getChildren());
            }
        }
    }
    
    /**
     * 递归排序权限树
     */
    private void sortPermissionTree(List<SysPermission> permissions) {
        if (permissions == null || permissions.isEmpty()) {
            return;
        }
        permissions.sort(Comparator.comparing(SysPermission::getSortOrder, Comparator.nullsLast(Integer::compareTo)));
        for (SysPermission permission : permissions) {
            if (permission.getChildren() != null && !permission.getChildren().isEmpty()) {
                sortPermissionTree(permission.getChildren());
            }
        }
    }
}

