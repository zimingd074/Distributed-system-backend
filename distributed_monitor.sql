/*
 Navicat Premium Data Transfer

 Source Server         : localhost_3306_1
 Source Server Type    : MySQL
 Source Server Version : 80044 (8.0.44)
 Source Host           : localhost:3306
 Source Schema         : distributed_monitor

 Target Server Type    : MySQL
 Target Server Version : 80044 (8.0.44)
 File Encoding         : 65001

 Date: 14/12/2025 22:30:29
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for alert_record
-- ----------------------------
DROP TABLE IF EXISTS `alert_record`;
CREATE TABLE `alert_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '告警ID',
  `alert_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '告警编号',
  `rule_id` bigint NULL DEFAULT NULL COMMENT '规则ID',
  `device_id` bigint NOT NULL COMMENT '设备ID',
  `alert_level` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '告警级别',
  `alert_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '告警类型',
  `alert_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '告警消息',
  `alert_data` json NULL COMMENT '告警数据',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '处理状态：pending-待处理 confirmed-已确认 resolved-已解决 ignored-已忽略',
  `alert_time` datetime NOT NULL COMMENT '告警时间',
  `confirmed_user_id` bigint NULL DEFAULT NULL COMMENT '确认用户ID',
  `confirmed_time` datetime NULL DEFAULT NULL COMMENT '确认时间',
  `resolved_user_id` bigint NULL DEFAULT NULL COMMENT '解决用户ID',
  `resolved_time` datetime NULL DEFAULT NULL COMMENT '解决时间',
  `resolve_remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '处理备注',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `alert_no`(`alert_no` ASC) USING BTREE,
  UNIQUE INDEX `uk_alert_no`(`alert_no` ASC) USING BTREE,
  INDEX `idx_rule_id`(`rule_id` ASC) USING BTREE,
  INDEX `idx_device_id`(`device_id` ASC) USING BTREE,
  INDEX `idx_alert_level`(`alert_level` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_alert_time`(`alert_time` ASC) USING BTREE,
  INDEX `confirmed_user_id`(`confirmed_user_id` ASC) USING BTREE,
  INDEX `resolved_user_id`(`resolved_user_id` ASC) USING BTREE,
  CONSTRAINT `alert_record_ibfk_1` FOREIGN KEY (`rule_id`) REFERENCES `alert_rule` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `alert_record_ibfk_2` FOREIGN KEY (`device_id`) REFERENCES `device` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `alert_record_ibfk_3` FOREIGN KEY (`confirmed_user_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `alert_record_ibfk_4` FOREIGN KEY (`resolved_user_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '告警记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of alert_record
-- ----------------------------

-- ----------------------------
-- Table structure for alert_rule
-- ----------------------------
DROP TABLE IF EXISTS `alert_rule`;
CREATE TABLE `alert_rule`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '规则ID',
  `rule_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '规则名称',
  `rule_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '规则编码',
  `rule_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '规则类型：offline-离线 threshold-阈值 abnormal-异常',
  `device_group_id` bigint NULL DEFAULT NULL COMMENT '应用设备分组ID（为空表示全局）',
  `condition_expr` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '条件表达式',
  `alert_level` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'warning' COMMENT '告警级别：info-信息 warning-警告 error-错误 critical-严重',
  `alert_message` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '告警消息模板（门禁场景相关）',
  `is_active` tinyint NOT NULL DEFAULT 1 COMMENT '是否启用：0-否 1-是',
  `notify_users` json NULL COMMENT '通知用户ID列表',
  `notify_methods` json NULL COMMENT '通知方式：email, sms, webhook',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `rule_code`(`rule_code` ASC) USING BTREE,
  UNIQUE INDEX `uk_rule_code`(`rule_code` ASC) USING BTREE,
  INDEX `idx_rule_type`(`rule_type` ASC) USING BTREE,
  INDEX `idx_is_active`(`is_active` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '告警规则表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of alert_rule
-- ----------------------------
-- 门禁场景预置告警规则（替代通用监控指标）
INSERT INTO `alert_rule` VALUES (1, '门未关超时', 'door_not_closed_timeout', 'threshold', NULL, 'door_open_duration > 30', 'error', '设备 {device_name} 门未关闭超过30秒', 1, NULL, NULL, '2025-12-11 17:22:03', '2025-12-11 17:22:03');
INSERT INTO `alert_rule` VALUES (2, '异常开启', 'door_unexpected_open', 'abnormal', NULL, 'door_status = \"open\" AND door_controller_status != \"normal\"', 'warning', '设备 {device_name} 检测到异常开启', 1, NULL, NULL, '2025-12-11 17:22:03', '2025-12-11 17:22:03');
INSERT INTO `alert_rule` VALUES (3, '门禁通信中断', 'door_comm_lost', 'offline', NULL, 'last_heartbeat_time IS NULL OR TIMESTAMPDIFF(SECOND, last_heartbeat_time, NOW()) > 300', 'error', '设备 {device_name} 与服务器通信中断', 1, NULL, NULL, '2025-12-11 17:22:03', '2025-12-11 17:22:03');

-- ----------------------------
-- Table structure for device
-- ----------------------------
DROP TABLE IF EXISTS `device`;
CREATE TABLE `device`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '设备ID',
  `device_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备编码（唯一标识，设备身份识别依据，不可修改）',
  `device_secret` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备密钥（加密存储，用于设备认证，仅在创建时生成）',
  `device_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备名称',
  `device_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备类型',
  `group_id` bigint NULL DEFAULT NULL COMMENT '所属分组ID',
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP地址（辅助信息，不作为设备标识，设备可能动态变化）',
  `port` int NULL DEFAULT NULL COMMENT '端口号（辅助信息，不作为设备标识）',
  `mac_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'MAC地址',
  `location` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物理位置',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备描述',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'offline' COMMENT '设备状态：online-在线 offline-离线 fault-故障 maintain-维护',
  `online_status` tinyint NOT NULL DEFAULT 0 COMMENT '在线状态：0-离线 1-在线',
  `ws_connected` tinyint NOT NULL DEFAULT 0 COMMENT 'WebSocket连接状态：0-未连接 1-已连接',
  `ws_session_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'WebSocket会话ID',
  `last_heartbeat_time` datetime NULL DEFAULT NULL COMMENT '最后心跳时间',
  `last_auth_time` datetime NULL DEFAULT NULL COMMENT '最后认证时间',
  `register_time` datetime NULL DEFAULT NULL COMMENT '注册时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `device_code`(`device_code` ASC) USING BTREE,
  INDEX `idx_device_code`(`device_code` ASC) USING BTREE,
  INDEX `idx_group_id`(`group_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_online_status`(`online_status` ASC) USING BTREE,
  INDEX `idx_last_heartbeat`(`last_heartbeat_time` ASC) USING BTREE,
  UNIQUE INDEX `device_code_2`(`device_code` ASC) USING BTREE,
  INDEX `idx_device_secret`(`device_secret` ASC) USING BTREE,
  CONSTRAINT `device_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `device_group` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备表 - 注意：device_code是唯一标识，ip_address和port仅作辅助信息，不作为身份识别依据' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of device
-- ----------------------------
INSERT INTO `device` VALUES (2, 'DEV-001', '6f2140afc80aee28a47627d46615e74e', 'test01', 'controller', NULL, '127.0.0.1', 8081, '', '', '', 'offline', 0, 0, NULL, NULL, NULL, '2025-12-13 18:18:37', '2025-12-13 18:18:37', '2025-12-14 22:11:52');

-- ----------------------------
-- Table structure for device_auth_token
-- ----------------------------
DROP TABLE IF EXISTS `device_auth_token`;
CREATE TABLE `device_auth_token`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Token ID',
  `device_id` bigint NOT NULL COMMENT '设备ID',
  `device_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备编码',
  `access_token` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '访问令牌',
  `refresh_token` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '刷新令牌',
  `token_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'Bearer' COMMENT '令牌类型',
  `expires_in` int NOT NULL COMMENT '过期时间（秒）',
  `issued_at` datetime NOT NULL COMMENT '颁发时间',
  `expires_at` datetime NOT NULL COMMENT '过期时间',
  `last_used_at` datetime NULL DEFAULT NULL COMMENT '最后使用时间',
  `is_revoked` tinyint NOT NULL DEFAULT 0 COMMENT '是否已撤销：0-否 1-是',
  `revoked_at` datetime NULL DEFAULT NULL COMMENT '撤销时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_device_id`(`device_id` ASC) USING BTREE,
  INDEX `idx_device_code`(`device_code` ASC) USING BTREE,
  INDEX `idx_access_token`(`access_token`(100) ASC) USING BTREE,
  INDEX `idx_expires_at`(`expires_at` ASC) USING BTREE,
  INDEX `idx_is_revoked`(`is_revoked` ASC) USING BTREE,
  CONSTRAINT `device_auth_token_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备认证Token表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of device_auth_token
-- ----------------------------

-- ----------------------------
-- Table structure for device_command
-- ----------------------------
DROP TABLE IF EXISTS `device_command`;
CREATE TABLE `device_command`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '命令ID',
  `command_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '命令编码',
  `command_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '命令名称',
  `command_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '命令类型：control-控制 config-配置 query-查询',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '命令描述',
  `param_schema` json NULL COMMENT '参数模式（JSON Schema）',
  `is_active` tinyint NOT NULL DEFAULT 1 COMMENT '是否启用：0-否 1-是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_command_code`(`command_code` ASC) USING BTREE,
  INDEX `idx_command_type`(`command_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '控制命令表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of device_command
-- ----------------------------
-- 门禁场景命令（增加开门/关门）
INSERT INTO `device_command` VALUES (1, 'open_door', '开门', 'control', '开门，包含持续时间参数（秒）', NULL, 1, '2025-12-11 17:22:03', '2025-12-11 17:22:03');
INSERT INTO `device_command` VALUES (2, 'close_door', '关门', 'control', '关门', NULL, 1, '2025-12-11 17:22:03', '2025-12-11 17:22:03');
INSERT INTO `device_command` VALUES (3, 'get_status', '获取状态', 'query', '查询设备当前门状态', NULL, 1, '2025-12-11 17:22:03', '2025-12-11 17:22:03');
INSERT INTO `device_command` VALUES (4, 'update_config', '更新配置', 'config', '更新设备配置信息', NULL, 1, '2025-12-11 17:22:03', '2025-12-11 17:22:03');

-- ----------------------------
-- Table structure for device_command_log
-- ----------------------------
DROP TABLE IF EXISTS `device_command_log`;
CREATE TABLE `device_command_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `device_id` bigint NOT NULL COMMENT '设备ID',
  `command_id` bigint NOT NULL COMMENT '命令ID',
  `command_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '命令编码',
  `command_params` json NULL COMMENT '命令参数',
  `execute_user_id` bigint NULL DEFAULT NULL COMMENT '执行用户ID',
  `execute_time` datetime NOT NULL COMMENT '执行时间',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '执行状态：pending-待执行 sending-发送中 success-成功 failed-失败 timeout-超时',
  `response_data` json NULL COMMENT '响应数据',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '错误信息',
  `response_time` datetime NULL DEFAULT NULL COMMENT '响应时间',
  `duration` int NULL DEFAULT NULL COMMENT '执行耗时（毫秒）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_device_id`(`device_id` ASC) USING BTREE,
  INDEX `idx_command_id`(`command_id` ASC) USING BTREE,
  INDEX `idx_execute_time`(`execute_time` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_execute_user`(`execute_user_id` ASC) USING BTREE,
  CONSTRAINT `device_command_log_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `device_command_log_ibfk_2` FOREIGN KEY (`command_id`) REFERENCES `device_command` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `device_command_log_ibfk_3` FOREIGN KEY (`execute_user_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '命令执行记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of device_command_log
-- ----------------------------
INSERT INTO `device_command_log` VALUES (1, 2, 1, 'start', NULL, 1, '2025-12-14 00:38:11', 'sending', NULL, NULL, NULL, NULL, '2025-12-14 00:38:10');

-- ----------------------------
-- Table structure for device_config
-- ----------------------------
DROP TABLE IF EXISTS `device_config`;
CREATE TABLE `device_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `device_id` bigint NOT NULL COMMENT '设备ID',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配置键',
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '配置值',
  `config_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'string' COMMENT '配置类型：string number boolean json',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '配置说明',
  `is_synced` tinyint NOT NULL DEFAULT 0 COMMENT '是否已同步：0-未同步 1-已同步',
  `sync_time` datetime NULL DEFAULT NULL COMMENT '同步时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_device_config`(`device_id` ASC, `config_key` ASC) USING BTREE,
  INDEX `idx_device_id`(`device_id` ASC) USING BTREE,
  INDEX `idx_is_synced`(`is_synced` ASC) USING BTREE,
  CONSTRAINT `device_config_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of device_config
-- ----------------------------

-- ----------------------------
-- Table structure for device_group
-- ----------------------------
DROP TABLE IF EXISTS `device_group`;
CREATE TABLE `device_group`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '分组ID',
  `group_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分组名称',
  `group_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分组编码',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父分组ID',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '描述',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序权重',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `group_code`(`group_code` ASC) USING BTREE,
  INDEX `idx_group_code`(`group_code` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备分组表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of device_group
-- ----------------------------
INSERT INTO `device_group` VALUES (1, '默认分组', 'default', 0, '系统默认设备分组', 0, '2025-12-11 17:22:03', '2025-12-11 17:22:03');
INSERT INTO `device_group` VALUES (2, '生产环境', 'production', 0, '生产环境设备', 100, '2025-12-11 17:22:03', '2025-12-11 17:22:03');
INSERT INTO `device_group` VALUES (3, '测试环境', 'testing', 0, '测试环境设备', 90, '2025-12-11 17:22:03', '2025-12-11 17:22:03');
INSERT INTO `device_group` VALUES (4, '开发环境', 'development', 0, '开发环境设备', 80, '2025-12-11 17:22:03', '2025-12-11 17:22:03');

-- ----------------------------
-- Table structure for device_heartbeat
-- ----------------------------
DROP TABLE IF EXISTS `device_heartbeat`;
CREATE TABLE `device_heartbeat`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `device_id` bigint NOT NULL COMMENT '设备ID',
  `heartbeat_time` datetime NOT NULL COMMENT '心跳时间',
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '上报IP地址',
  `response_time` int NULL DEFAULT NULL COMMENT '响应时间（毫秒）',
  `extra_data` json NULL COMMENT '额外数据',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_device_id`(`device_id` ASC) USING BTREE,
  INDEX `idx_heartbeat_time`(`heartbeat_time` ASC) USING BTREE,
  INDEX `idx_device_heartbeat`(`device_id` ASC, `heartbeat_time` ASC) USING BTREE,
  CONSTRAINT `device_heartbeat_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备心跳记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of device_heartbeat
-- ----------------------------

-- ----------------------------
-- Table structure for device_status_history
-- ----------------------------
DROP TABLE IF EXISTS `device_status_history`;
CREATE TABLE `device_status_history`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `device_id` bigint NOT NULL COMMENT '设备ID',
  `status_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '状态类型（门禁场景）',
  `status_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '状态值（JSON格式）',
  `door_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'closed' COMMENT '门状态：open/closed',
  `door_controller_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'normal' COMMENT '门禁控制器状态（normal/fault/...）',
  `report_time` datetime NOT NULL COMMENT '上报时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_device_id`(`device_id` ASC) USING BTREE,
  INDEX `idx_report_time`(`report_time` ASC) USING BTREE,
  INDEX `idx_device_report`(`device_id` ASC, `report_time` ASC) USING BTREE,
  CONSTRAINT `device_status_history_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备状态历史表（门禁场景）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of device_status_history
-- ----------------------------

-- ----------------------------
-- Table structure for device_websocket_session
-- ----------------------------
DROP TABLE IF EXISTS `device_websocket_session`;
CREATE TABLE `device_websocket_session`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '会话ID',
  `device_id` bigint NOT NULL COMMENT '设备ID',
  `device_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备编码',
  `session_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'WebSocket会话标识',
  `client_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户端IP地址',
  `connect_time` datetime NOT NULL COMMENT '连接时间',
  `last_heartbeat_time` datetime NULL DEFAULT NULL COMMENT '最后心跳时间',
  `last_message_time` datetime NULL DEFAULT NULL COMMENT '最后消息时间',
  `disconnect_time` datetime NULL DEFAULT NULL COMMENT '断开时间',
  `disconnect_reason` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '断开原因',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0-已断开 1-已连接',
  `message_count` bigint NOT NULL DEFAULT 0 COMMENT '消息总数',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `session_id`(`session_id` ASC) USING BTREE,
  UNIQUE INDEX `uk_session_id`(`session_id` ASC) USING BTREE,
  INDEX `idx_device_id`(`device_id` ASC) USING BTREE,
  INDEX `idx_device_code`(`device_code` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_connect_time`(`connect_time` ASC) USING BTREE,
  CONSTRAINT `device_websocket_session_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备WebSocket会话表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of device_websocket_session
-- ----------------------------

-- ----------------------------
-- Table structure for report_config
-- ----------------------------
DROP TABLE IF EXISTS `report_config`;
CREATE TABLE `report_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '报表ID',
  `report_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '报表名称',
  `report_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '报表编码',
  `report_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '报表类型：device-设备 status-状态 alert-告警 command-命令',
  `report_template` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '报表模板路径',
  `query_sql` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '查询SQL',
  `params_schema` json NULL COMMENT '参数模式',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '报表描述',
  `is_active` tinyint NOT NULL DEFAULT 1 COMMENT '是否启用',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `report_code`(`report_code` ASC) USING BTREE,
  UNIQUE INDEX `uk_report_code`(`report_code` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '统计报表配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of report_config
-- ----------------------------

-- ----------------------------
-- Table structure for report_generate_log
-- ----------------------------
DROP TABLE IF EXISTS `report_generate_log`;
CREATE TABLE `report_generate_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `report_id` bigint NOT NULL COMMENT '报表ID',
  `report_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '报表名称',
  `generate_user_id` bigint NULL DEFAULT NULL COMMENT '生成用户ID',
  `params` json NULL COMMENT '生成参数',
  `file_format` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '文件格式：excel pdf',
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '文件路径',
  `file_size` bigint NULL DEFAULT NULL COMMENT '文件大小（字节）',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'generating' COMMENT '生成状态：generating-生成中 success-成功 failed-失败',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '错误信息',
  `generate_time` datetime NOT NULL COMMENT '生成时间',
  `complete_time` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_report_id`(`report_id` ASC) USING BTREE,
  INDEX `idx_generate_user`(`generate_user_id` ASC) USING BTREE,
  INDEX `idx_generate_time`(`generate_time` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  CONSTRAINT `report_generate_log_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `report_config` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `report_generate_log_ibfk_2` FOREIGN KEY (`generate_user_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '报表生成记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of report_generate_log
-- ----------------------------

-- ----------------------------
-- Table structure for sys_operation_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_operation_log`;
CREATE TABLE `sys_operation_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id` bigint NULL DEFAULT NULL COMMENT '操作用户ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作用户名',
  `operation_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作类型',
  `operation_module` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作模块',
  `operation_desc` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作描述',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请求方法',
  `request_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请求URL',
  `request_params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '请求参数',
  `response_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '响应数据',
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `user_agent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户代理',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0-失败 1-成功',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '错误信息',
  `execute_time` int NULL DEFAULT NULL COMMENT '执行耗时（毫秒）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_operation_type`(`operation_type` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  CONSTRAINT `sys_operation_log_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统操作日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_operation_log
-- ----------------------------

-- ----------------------------
-- Table structure for sys_permission
-- ----------------------------
DROP TABLE IF EXISTS `sys_permission`;
CREATE TABLE `sys_permission`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '权限ID',
  `permission_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '权限编码',
  `permission_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '权限名称',
  `resource_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '资源类型：menu-菜单 button-按钮 api-接口',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父权限ID',
  `resource_path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '资源路径',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '描述',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序权重',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `permission_code`(`permission_code` ASC) USING BTREE,
  INDEX `idx_permission_code`(`permission_code` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 24 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_permission
-- ----------------------------
INSERT INTO `sys_permission` VALUES (1, 'system', '系统管理', 'menu', 0, '/system', NULL, 0, '2025-12-11 17:22:03');
INSERT INTO `sys_permission` VALUES (2, 'system:user', '用户管理', 'menu', 1, '/system/user', NULL, 0, '2025-12-11 17:22:03');
INSERT INTO `sys_permission` VALUES (3, 'system:user:view', '查看用户', 'button', 2, NULL, NULL, 0, '2025-12-11 17:22:03');
INSERT INTO `sys_permission` VALUES (4, 'system:user:add', '新增用户', 'button', 2, NULL, NULL, 0, '2025-12-11 17:22:03');
INSERT INTO `sys_permission` VALUES (5, 'system:user:edit', '编辑用户', 'button', 2, NULL, NULL, 0, '2025-12-11 17:22:03');
INSERT INTO `sys_permission` VALUES (6, 'system:user:delete', '删除用户', 'button', 2, NULL, NULL, 0, '2025-12-11 17:22:03');
INSERT INTO `sys_permission` VALUES (7, 'device', '设备管理', 'menu', 0, '/device', NULL, 0, '2025-12-11 17:22:03');
INSERT INTO `sys_permission` VALUES (8, 'device:list', '设备列表', 'menu', 7, '/device/list', NULL, 0, '2025-12-11 17:22:03');
INSERT INTO `sys_permission` VALUES (9, 'device:view', '查看设备', 'button', 8, NULL, NULL, 0, '2025-12-11 17:22:03');
INSERT INTO `sys_permission` VALUES (10, 'device:add', '添加设备', 'button', 8, NULL, NULL, 0, '2025-12-11 17:22:03');
INSERT INTO `sys_permission` VALUES (11, 'device:edit', '编辑设备', 'button', 8, NULL, NULL, 0, '2025-12-11 17:22:03');
INSERT INTO `sys_permission` VALUES (12, 'device:delete', '删除设备', 'button', 8, NULL, NULL, 0, '2025-12-11 17:22:03');
INSERT INTO `sys_permission` VALUES (13, 'device:config', '设备配置', 'button', 8, NULL, NULL, 0, '2025-12-11 17:22:03');
INSERT INTO `sys_permission` VALUES (14, 'device:control', '设备控制', 'button', 8, NULL, NULL, 0, '2025-12-11 17:22:03');
INSERT INTO `sys_permission` VALUES (15, 'monitor', '监控中心', 'menu', 0, '/monitor', NULL, 0, '2025-12-11 17:22:03');
INSERT INTO `sys_permission` VALUES (16, 'monitor:dashboard', '监控面板', 'menu', 15, '/monitor/dashboard', NULL, 0, '2025-12-11 17:22:03');
INSERT INTO `sys_permission` VALUES (17, 'monitor:status', '状态监控', 'menu', 15, '/monitor/status', NULL, 0, '2025-12-11 17:22:03');
INSERT INTO `sys_permission` VALUES (18, 'alert', '告警管理', 'menu', 0, '/alert', NULL, 0, '2025-12-11 17:22:03');
INSERT INTO `sys_permission` VALUES (19, 'alert:list', '告警列表', 'menu', 18, '/alert/list', NULL, 0, '2025-12-11 17:22:03');
INSERT INTO `sys_permission` VALUES (20, 'alert:handle', '处理告警', 'button', 19, NULL, NULL, 0, '2025-12-11 17:22:03');
INSERT INTO `sys_permission` VALUES (21, 'report', '报表管理', 'menu', 0, '/report', NULL, 0, '2025-12-11 17:22:03');
INSERT INTO `sys_permission` VALUES (22, 'report:view', '查看报表', 'menu', 21, '/report/view', NULL, 0, '2025-12-11 17:22:03');
INSERT INTO `sys_permission` VALUES (23, 'report:export', '导出报表', 'button', 22, NULL, NULL, 0, '2025-12-11 17:22:03');

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色编码',
  `role_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '角色描述',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0-禁用 1-正常',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `role_code`(`role_code` ASC) USING BTREE,
  INDEX `idx_role_code`(`role_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, 'admin', '系统管理员', '拥有系统所有权限', 1, '2025-12-11 17:22:03', '2025-12-11 17:22:03');
INSERT INTO `sys_role` VALUES (2, 'monitor', '监控人员', '可查看监控数据、发送控制命令', 1, '2025-12-11 17:22:03', '2025-12-11 17:22:03');
INSERT INTO `sys_role` VALUES (3, 'viewer', '访客', '只能查看监控数据', 1, '2025-12-11 17:22:03', '2025-12-11 17:22:03');

-- ----------------------------
-- Table structure for sys_role_permission
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_permission`;
CREATE TABLE `sys_role_permission`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `permission_id` bigint NOT NULL COMMENT '权限ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_role_permission`(`role_id` ASC, `permission_id` ASC) USING BTREE,
  INDEX `idx_role_id`(`role_id` ASC) USING BTREE,
  INDEX `idx_permission_id`(`permission_id` ASC) USING BTREE,
  CONSTRAINT `sys_role_permission_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `sys_role_permission_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `sys_permission` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色权限关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_permission
-- ----------------------------

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码（加密存储）',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '真实姓名',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `avatar_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像URL',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0-禁用 1-正常',
  `is_admin` tinyint NOT NULL DEFAULT 0 COMMENT '是否管理员：0-否 1-是',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '最后登录IP',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  INDEX `idx_username`(`username` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'admin', '$2a$10$encrypted_password_here', '系统管理员', 'admin@example.com', NULL, NULL, 1, 1, '2025-12-14 20:02:17', '0:0:0:0:0:0:0:1', '2025-12-11 17:22:03', '2025-12-14 20:02:17');

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_role`(`user_id` ASC, `role_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_role_id`(`role_id` ASC) USING BTREE,
  CONSTRAINT `sys_user_role_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `sys_user_role_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户角色关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------

-- ----------------------------
-- Table structure for websocket_session
-- ----------------------------
DROP TABLE IF EXISTS `websocket_session`;
CREATE TABLE `websocket_session`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '会话ID',
  `session_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '会话标识',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户ID',
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `connect_time` datetime NOT NULL COMMENT '连接时间',
  `last_heartbeat_time` datetime NULL DEFAULT NULL COMMENT '最后心跳时间',
  `disconnect_time` datetime NULL DEFAULT NULL COMMENT '断开时间',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0-已断开 1-已连接',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `session_id`(`session_id` ASC) USING BTREE,
  INDEX `idx_session_id`(`session_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  CONSTRAINT `websocket_session_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'WebSocket会话表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of websocket_session
-- ----------------------------

-- ----------------------------
-- View structure for v_device_alert_statistics
-- ----------------------------
DROP VIEW IF EXISTS `v_device_alert_statistics`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_device_alert_statistics` AS select `d`.`id` AS `device_id`,`d`.`device_code` AS `device_code`,`d`.`device_name` AS `device_name`,count(`ar`.`id`) AS `total_alerts`,sum((case when (`ar`.`alert_level` = 'critical') then 1 else 0 end)) AS `critical_count`,sum((case when (`ar`.`alert_level` = 'error') then 1 else 0 end)) AS `error_count`,sum((case when (`ar`.`alert_level` = 'warning') then 1 else 0 end)) AS `warning_count`,sum((case when (`ar`.`status` = 'pending') then 1 else 0 end)) AS `pending_count` from (`device` `d` left join `alert_record` `ar` on((`d`.`id` = `ar`.`device_id`))) group by `d`.`id`,`d`.`device_code`,`d`.`device_name`;

-- ----------------------------
-- View structure for v_device_connection_status
-- ----------------------------
DROP VIEW IF EXISTS `v_device_connection_status`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_device_connection_status` AS select `d`.`id` AS `id`,`d`.`device_code` AS `device_code`,`d`.`device_name` AS `device_name`,`d`.`device_type` AS `device_type`,`d`.`online_status` AS `online_status`,`d`.`ws_connected` AS `ws_connected`,`d`.`ws_session_id` AS `ws_session_id`,`d`.`last_heartbeat_time` AS `last_heartbeat_time`,`d`.`last_auth_time` AS `last_auth_time`,`dws`.`connect_time` AS `ws_connect_time`,`dws`.`last_heartbeat_time` AS `ws_last_heartbeat`,`dws`.`status` AS `ws_status`,timestampdiff(SECOND,`d`.`last_heartbeat_time`,now()) AS `seconds_since_heartbeat`,timestampdiff(SECOND,`dws`.`last_heartbeat_time`,now()) AS `ws_seconds_since_heartbeat` from (`device` `d` left join `device_websocket_session` `dws` on(((`d`.`ws_session_id` = `dws`.`session_id`) and (`dws`.`status` = 1))));

-- ----------------------------
-- View structure for v_device_online_status
-- ----------------------------
DROP VIEW IF EXISTS `v_device_online_status`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_device_online_status` AS select `d`.`id` AS `id`,`d`.`device_code` AS `device_code`,`d`.`device_name` AS `device_name`,`d`.`device_type` AS `device_type`,`dg`.`group_name` AS `group_name`,`d`.`ip_address` AS `ip_address`,`d`.`status` AS `status`,`d`.`online_status` AS `online_status`,`d`.`last_heartbeat_time` AS `last_heartbeat_time`,timestampdiff(SECOND,`d`.`last_heartbeat_time`,now()) AS `offline_seconds` from (`device` `d` left join `device_group` `dg` on((`d`.`group_id` = `dg`.`id`)));

-- ----------------------------
-- Procedure structure for sp_check_device_offline
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_check_device_offline`;
delimiter ;;
CREATE PROCEDURE `sp_check_device_offline`()
BEGIN
  DECLARE offline_threshold INT DEFAULT 300; -- 5分钟
  
  -- 更新设备在线状态
  UPDATE device 
  SET online_status = 0, 
      status = 'offline'
  WHERE TIMESTAMPDIFF(SECOND, last_heartbeat_time, NOW()) > offline_threshold
  AND online_status = 1;
  
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for sp_clean_disconnected_sessions
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_clean_disconnected_sessions`;
delimiter ;;
CREATE PROCEDURE `sp_clean_disconnected_sessions`()
BEGIN
  -- 清理状态为已断开且超过1小时的会话记录
  UPDATE device_websocket_session 
  SET status = 0 
  WHERE status = 1 
  AND last_heartbeat_time < DATE_SUB(NOW(), INTERVAL 5 MINUTE);
  
  -- 删除已断开超过24小时的会话记录
  DELETE FROM device_websocket_session 
  WHERE status = 0 
  AND disconnect_time < DATE_SUB(NOW(), INTERVAL 24 HOUR);
  
  -- 更新设备的WebSocket连接状态
  UPDATE device d
  LEFT JOIN device_websocket_session dws ON d.ws_session_id = dws.session_id AND dws.status = 1
  SET d.ws_connected = 0, d.ws_session_id = NULL
  WHERE d.ws_connected = 1 AND dws.id IS NULL;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for sp_clean_expired_device_tokens
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_clean_expired_device_tokens`;
delimiter ;;
CREATE PROCEDURE `sp_clean_expired_device_tokens`()
BEGIN
  -- 删除已过期的Token
  DELETE FROM device_auth_token 
  WHERE expires_at < NOW() 
  OR is_revoked = 1;
  
  -- 清理长时间未使用的Token（超过7天）
  DELETE FROM device_auth_token 
  WHERE last_used_at IS NULL 
  AND issued_at < DATE_SUB(NOW(), INTERVAL 7 DAY);
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for sp_clean_history_data
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_clean_history_data`;
delimiter ;;
CREATE PROCEDURE `sp_clean_history_data`(IN days INT)
BEGIN
  DECLARE delete_date DATETIME;
  SET delete_date = DATE_SUB(NOW(), INTERVAL days DAY);
  
  -- 清理设备状态历史
  DELETE FROM device_status_history WHERE created_at < delete_date;
  
  -- 清理设备心跳记录
  DELETE FROM device_heartbeat WHERE created_at < delete_date;
  
  -- 清理已解决的告警记录（保留90天）
  DELETE FROM alert_record 
  WHERE status = 'resolved' 
  AND resolved_time < DATE_SUB(NOW(), INTERVAL 90 DAY);
  
  -- 清理操作日志
  DELETE FROM sys_operation_log WHERE created_at < delete_date;
  
END
;;
delimiter ;

-- ----------------------------
-- Event structure for evt_check_device_offline
-- ----------------------------
DROP EVENT IF EXISTS `evt_check_device_offline`;
delimiter ;;
CREATE EVENT `evt_check_device_offline`
ON SCHEDULE
EVERY '1' MINUTE STARTS '2025-12-11 17:22:03'
DO CALL sp_check_device_offline()
;;
delimiter ;

-- ----------------------------
-- Event structure for evt_clean_disconnected_sessions
-- ----------------------------
DROP EVENT IF EXISTS `evt_clean_disconnected_sessions`;
delimiter ;;
CREATE EVENT `evt_clean_disconnected_sessions`
ON SCHEDULE
EVERY '5' MINUTE STARTS '2025-12-14 22:11:52'
DO CALL sp_clean_disconnected_sessions()
;;
delimiter ;

-- ----------------------------
-- Event structure for evt_clean_expired_device_tokens
-- ----------------------------
DROP EVENT IF EXISTS `evt_clean_expired_device_tokens`;
delimiter ;;
CREATE EVENT `evt_clean_expired_device_tokens`
ON SCHEDULE
EVERY '1' HOUR STARTS '2025-12-14 22:11:52'
DO CALL sp_clean_expired_device_tokens()
;;
delimiter ;

-- ----------------------------
-- Event structure for evt_clean_history_data
-- ----------------------------
DROP EVENT IF EXISTS `evt_clean_history_data`;
delimiter ;;
CREATE EVENT `evt_clean_history_data`
ON SCHEDULE
EVERY '1' DAY STARTS '2025-12-12 02:00:00'
DO CALL sp_clean_history_data(30)
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
