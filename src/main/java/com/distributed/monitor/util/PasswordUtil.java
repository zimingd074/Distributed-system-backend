package com.distributed.monitor.util;

import cn.hutool.crypto.digest.BCrypt;
import lombok.extern.slf4j.Slf4j;

/**
 * 密码工具类
 * 用于生成和验证BCrypt密码哈希
 */
@Slf4j
public class PasswordUtil {
    
    /**
     * 生成BCrypt密码哈希
     * 
     * @param plainPassword 明文密码
     * @return BCrypt哈希值
     */
    public static String encode(String plainPassword) {
        return BCrypt.hashpw(plainPassword);
    }
    
    /**
     * 验证密码
     * 
     * @param plainPassword 明文密码
     * @param hashedPassword BCrypt哈希值
     * @return 是否匹配
     */
    public static boolean matches(String plainPassword, String hashedPassword) {
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (Exception e) {
            log.error("密码验证异常", e);
            return false;
        }
    }
    
    /**
     * 主方法：用于生成密码哈希（开发工具）
     * 运行此方法可以生成BCrypt哈希，用于更新数据库
     */
    public static void main(String[] args) {
        // 默认管理员密码：admin123
        String password = "admin123";
        String hash = encode(password);
        System.out.println("==========================================");
        System.out.println("密码: " + password);
        System.out.println("BCrypt哈希: " + hash);
        System.out.println("==========================================");
        System.out.println("SQL更新语句:");
        System.out.println("UPDATE sys_user SET password = '" + hash + "' WHERE username = 'admin';");
        System.out.println("==========================================");
    }
}

