package com.distributed.monitor.vo.auth;

import lombok.Data;
import java.util.List;

/**
 * 用户信息VO
 */
@Data
public class UserProfileVO {
    
    private Long userId;
    
    private String username;
    
    private String realName;
    
    private String email;
    
    private String phone;
    
    private String avatarUrl;
    
    private Boolean isAdmin;
    
    private List<RoleVO> roles;
    
    private List<String> permissions;
    
    @Data
    public static class RoleVO {
        private String roleCode;
        private String roleName;
    }
}

