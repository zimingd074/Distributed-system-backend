package com.distributed.monitor.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 报表生成记录实体
 */
@Data
public class ReportGenerateLog {
    
    /**
     * 记录ID
     */
    private Long id;
    
    /**
     * 报表ID
     */
    private Long reportId;
    
    /**
     * 报表名称
     */
    private String reportName;
    
    /**
     * 报表编码（从关联查询获取）
     */
    private String reportCode;
    
    /**
     * 生成用户ID
     */
    private Long generateUserId;
    
    /**
     * 生成参数（JSON）
     */
    private String params;
    
    /**
     * 文件格式：excel pdf
     */
    private String fileFormat;
    
    /**
     * 文件路径
     */
    private String filePath;
    
    /**
     * 文件大小（字节）
     */
    private Long fileSize;
    
    /**
     * 生成状态：generating-生成中 success-成功 failed-失败
     */
    private String status;
    
    /**
     * 错误信息
     */
    private String errorMessage;
    
    /**
     * 生成时间
     */
    private LocalDateTime generateTime;
    
    /**
     * 完成时间
     */
    private LocalDateTime completeTime;
    
    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
}

