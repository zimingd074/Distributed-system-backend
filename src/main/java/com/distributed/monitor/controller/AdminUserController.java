package com.distributed.monitor.controller;

import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.common.Result;
import com.distributed.monitor.dto.admin.UserCreateDTO;
import com.distributed.monitor.dto.admin.UserUpdateDTO;
import com.distributed.monitor.entity.SysUser;
import com.distributed.monitor.service.AdminUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 管理端-用户管理接口
 * 对应接口设计 /admin/users
 */
@RestController
@RequestMapping("/admin/users")
@RequiredArgsConstructor
public class AdminUserController {

    private final AdminUserService adminUserService;

    /**
     * GET /admin/users?page=1&pageSize=10
     */
    @GetMapping
    public Result<PageResult<SysUser>> listUsers(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<SysUser> result = adminUserService.listUsers(page, pageSize);
        return Result.success("获取成功", result);
    }

    /**
     * 创建用户
     */
    @PostMapping
    public Result<Map<String, Object>> createUser(@Validated @RequestBody UserCreateDTO dto) {
        Map<String, Object> result = adminUserService.createUser(dto);
        return Result.success("创建成功", result);
    }

    /**
     * 更新用户
     */
    @PutMapping("/{id}")
    public Result<Void> updateUser(@PathVariable Long id, @Validated @RequestBody UserUpdateDTO dto) {
        adminUserService.updateUser(id, dto);
        return Result.success("更新成功", null);
    }

    /**
     * 删除用户
     */
    @DeleteMapping("/{id}")
    public Result<Void> deleteUser(@PathVariable Long id) {
        adminUserService.deleteUser(id);
        return Result.success("删除成功", null);
    }

    /**
     * 重置密码
     */
    @PutMapping("/{id}/reset-password")
    public Result<Void> resetPassword(@PathVariable Long id, @RequestBody Map<String, String> body) {
        String password = body.get("password");
        adminUserService.resetPassword(id, password);
        return Result.success("重置成功", null);
    }
}

