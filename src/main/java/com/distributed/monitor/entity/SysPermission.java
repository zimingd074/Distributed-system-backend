package com.distributed.monitor.entity;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 权限实体
 */
@Data
public class SysPermission {
    
    /**
     * 权限ID
     */
    private Long id;
    
    /**
     * 权限编码
     */
    private String permissionCode;
    
    /**
     * 权限名称
     */
    private String permissionName;
    
    /**
     * 资源类型：menu-菜单 button-按钮 api-接口
     */
    private String resourceType;
    
    /**
     * 父权限ID
     */
    private Long parentId;
    
    /**
     * 资源路径
     */
    private String resourcePath;
    
    /**
     * 描述
     */
    private String description;
    
    /**
     * 排序权重
     */
    private Integer sortOrder;
    
    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
    
    /**
     * 子权限列表（树形结构，不映射到数据库）
     */
    private List<SysPermission> children;
}

