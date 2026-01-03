package com.distributed.monitor.dto.admin;

import lombok.Data;
import javax.validation.constraints.Email;
import javax.validation.constraints.Pattern;

/**
 * 更新用户DTO
 */
@Data
public class UserUpdateDTO {
    
    private String realName;
    
    @Email(message = "邮箱格式不正确")
    private String email;
    
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;
    
    private String avatarUrl;
    
    private Boolean status;
    
    private Boolean isAdmin;
}

