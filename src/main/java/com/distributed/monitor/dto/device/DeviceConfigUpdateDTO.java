package com.distributed.monitor.dto.device;

import lombok.Data;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotEmpty;
import java.util.List;

/**
 * 更新设备配置DTO
 */
@Data
public class DeviceConfigUpdateDTO {
    
    @NotEmpty(message = "配置项列表不能为空")
    private List<ConfigItem> configs;
    
    @Data
    public static class ConfigItem {
        @NotBlank(message = "配置键不能为空")
        private String configKey;
        
        @NotBlank(message = "配置值不能为空")
        private String configValue;
    }
}

