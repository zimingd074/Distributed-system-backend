package com.distributed.monitor.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 角色权限关联实体
 */
@Data
public class SysRolePermission {
    
    /**
     * ID
     */
    private Long id;
    
    /**
     * 角色ID
     */
    private Long roleId;
    
    /**
     * 权限ID
     */
    private Long permissionId;
    
    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
}

