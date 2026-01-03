package com.distributed.monitor;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.transaction.annotation.EnableTransactionManagement;

/**
 * 分布式机群监管系统启动类
 * 
 * @author Monitor System
 * @version 1.0.0
 */
@SpringBootApplication
@EnableTransactionManagement
@EnableScheduling
@MapperScan("com.distributed.monitor.mapper")
public class DistributedMonitorApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(DistributedMonitorApplication.class, args);
        System.out.println("\n========================================");
        System.out.println("分布式机群监管系统启动成功!");
        System.out.println("接口文档地址: http://localhost:8080/api");
        System.out.println("========================================\n");
    }
}

