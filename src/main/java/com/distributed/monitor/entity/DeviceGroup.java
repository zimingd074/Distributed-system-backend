package com.distributed.monitor.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 设备分组实体
 */
@Data
public class DeviceGroup {
    
    /**
     * 分组ID
     */
    private Long id;
    
    /**
     * 分组名称
     */
    private String groupName;
    
    /**
     * 分组编码
     */
    private String groupCode;
    
    /**
     * 父分组ID
     */
    private Long parentId;
    
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
     * 更新时间
     */
    private LocalDateTime updatedAt;
}

