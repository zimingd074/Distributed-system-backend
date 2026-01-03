package com.distributed.monitor.vo.auth;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

/**
 * 登录响应VO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LoginVO {
    
    private String accessToken;
    
    private String refreshToken;
    
    private String tokenType;
    
    private Integer expiresIn;
    
    private Long userId;
    
    private String username;
    
    private String realName;
    
    private Boolean isAdmin;
    
    private List<String> roles;
    
    private List<String> permissions;
}

