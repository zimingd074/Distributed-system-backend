package com.distributed.monitor.dto.admin;

import lombok.Data;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Email;
import javax.validation.constraints.Pattern;

/**
 * 创建用户DTO
 */
@Data
public class UserCreateDTO {
    
    @NotBlank(message = "用户名不能为空")
    private String username;
    
    @NotBlank(message = "密码不能为空")
    private String password;
    
    private String realName;
    
    @Email(message = "邮箱格式不正确")
    private String email;
    
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;
    
    private String avatarUrl;
    
    private Boolean status;
    
    private Boolean isAdmin;
}

