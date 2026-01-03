package com.distributed.monitor.controller;

import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.common.Result;
import com.distributed.monitor.entity.SysPermission;
import com.distributed.monitor.entity.SysRole;
import com.distributed.monitor.service.AdminRoleService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * 管理端-角色与权限
 * 对应接口设计 /admin/roles, /admin/permissions
 */
@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminRoleController {

    private final AdminRoleService adminRoleService;

    /**
     * 10.1 获取角色列表
     */
    @GetMapping("/roles")
    public Result<PageResult<SysRole>> listRoles(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<SysRole> result = adminRoleService.listRoles(page, pageSize);
        return Result.success("获取成功", result);
    }

    /**
     * 10.2 创建角色
     */
    @PostMapping("/roles")
    public Result<Map<String, Object>> createRole(@RequestBody SysRole role) {
        Map<String, Object> result = adminRoleService.createRole(role);
        return Result.success("创建成功", result);
    }

    /**
     * 10.3 更新角色
     */
    @PutMapping("/roles/{id}")
    public Result<Void> updateRole(@PathVariable Long id, @RequestBody SysRole role) {
        role.setId(id);
        adminRoleService.updateRole(role);
        return Result.success("更新成功", null);
    }

    /**
     * 10.4 删除角色
     */
    @DeleteMapping("/roles/{id}")
    public Result<Void> deleteRole(@PathVariable Long id) {
        adminRoleService.deleteRole(id);
        return Result.success("删除成功", null);
    }

    /**
     * 10.5 分配权限
     */
    @PutMapping("/roles/{id}/permissions")
    public Result<Map<String, Object>> assignPermissions(@PathVariable Long id, @RequestBody Map<String, List<Long>> body) {
        List<Long> permissionIds = body.get("permissionIds");
        if (permissionIds == null) {
            permissionIds = Collections.emptyList();
        }
        Map<String, Object> result = adminRoleService.assignPermissions(id, permissionIds);
        return Result.success("权限分配成功", result);
    }

    /**
     * 10.6 获取权限列表
     */
    @GetMapping("/permissions")
    public Result<List<SysPermission>> listPermissions() {
        List<SysPermission> list = adminRoleService.listPermissions();
        return Result.success("获取成功", list);
    }
}

