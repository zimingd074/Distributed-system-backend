package com.distributed.monitor.dto.report;

import lombok.Data;
import javax.validation.constraints.NotBlank;
import java.util.List;
import java.util.Map;

/**
 * 生成报表DTO
 */
@Data
public class ReportGenerateDTO {
    
    @NotBlank(message = "报表编码不能为空")
    private String reportCode;
    
    @NotBlank(message = "文件格式不能为空")
    private String fileFormat;
    
    /**
     * 报表参数
     */
    private ReportParams params;
    
    @Data
    public static class ReportParams {
        private String startTime;
        private String endTime;
        private List<Long> deviceIds;
        private Map<String, Object> customParams;
    }
}

