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

 Date: 03/01/2026 17:48:32
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
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '告警记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of alert_record
-- ----------------------------
INSERT INTO `alert_record` VALUES (1, 'ALT-1767365560021-2370', NULL, 2, 'warning', 'door_not_closed_timeout', 'door_not_closed_timeout from device DEV-001', '{\"doorStatus\": \"closed\"}', 'resolved', '2026-01-02 22:52:40', 1, '2026-01-02 22:52:54', 1, '2026-01-02 22:53:00', NULL, '2026-01-02 22:52:40', '2026-01-02 22:53:00');
INSERT INTO `alert_record` VALUES (2, 'ALT-1767431512119-9137', NULL, 11, 'warning', 'illegal_open', 'illegal_open from device DEV-010', '{\"doorStatus\": \"open\"}', 'pending', '2026-01-03 17:11:52', NULL, NULL, NULL, NULL, NULL, '2026-01-03 17:11:52', '2026-01-03 17:11:52');

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '告警规则表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of alert_rule
-- ----------------------------
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
  UNIQUE INDEX `device_code_2`(`device_code` ASC) USING BTREE,
  INDEX `idx_device_code`(`device_code` ASC) USING BTREE,
  INDEX `idx_group_id`(`group_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_online_status`(`online_status` ASC) USING BTREE,
  INDEX `idx_last_heartbeat`(`last_heartbeat_time` ASC) USING BTREE,
  INDEX `idx_device_secret`(`device_secret` ASC) USING BTREE,
  CONSTRAINT `device_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `device_group` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备表 - 注意：device_code是唯一标识，ip_address和port仅作辅助信息，不作为身份识别依据' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device
-- ----------------------------
INSERT INTO `device` VALUES (2, 'DEV-001', '6f2140afc80aee28a47627d46615e74e', 'test01', 'entrance', NULL, '127.0.0.1', 8081, '', '', '', 'offline', 0, 0, NULL, '2026-01-03 17:27:50', '2026-01-03 16:17:38', '2025-12-13 18:18:37', '2025-12-13 18:18:37', '2026-01-03 17:27:51');
INSERT INTO `device` VALUES (3, 'DEV-002', '5a93b8309b6c8709613e839f74fe612f', 'test02', 'entrance', NULL, '', 8080, '', '', '', 'offline', 0, 0, NULL, '2026-01-03 17:27:51', '2026-01-03 16:17:57', '2026-01-01 15:08:07', '2026-01-01 15:08:07', '2026-01-03 17:27:51');
INSERT INTO `device` VALUES (4, 'DEV-003', '5dc9da89a9a82120b8f49cf1cd700b19', 'test03', 'visitor', NULL, '', 8080, '', '', '', 'offline', 0, 0, NULL, '2026-01-03 17:27:51', '2026-01-03 16:18:10', '2026-01-01 15:09:47', '2026-01-01 15:09:47', '2026-01-03 17:27:52');
INSERT INTO `device` VALUES (5, 'DEV-004', '9c596d33514a707fc7e59e06f40f8822', 'test04', 'fire', NULL, '', 8080, '', '', '', 'offline', 0, 0, NULL, '2026-01-03 17:27:52', '2026-01-03 16:18:55', '2026-01-01 15:10:24', '2026-01-01 15:10:24', '2026-01-03 17:27:52');
INSERT INTO `device` VALUES (6, 'DEV-005', '1313bbaf2843cdf2c8a27ffbff63b28f', 'test05', 'entrance', NULL, '', 8080, '', '', '', 'offline', 0, 0, NULL, '2026-01-03 17:27:52', '2026-01-03 17:06:18', '2026-01-01 15:10:45', '2026-01-01 15:10:45', '2026-01-03 17:27:52');
INSERT INTO `device` VALUES (7, 'DEV-006', '269079aa38406b8069732ed069f58c63', 'test06', 'fire', NULL, '', 8080, '', '', '', 'offline', 0, 0, NULL, '2026-01-03 17:27:52', '2026-01-03 16:19:32', '2026-01-01 15:18:31', '2026-01-01 15:18:31', '2026-01-03 17:27:53');
INSERT INTO `device` VALUES (8, 'DEV-007', '4b4a473ff2e3057e0c0ef6caa6f7ab50', 'test07', 'entrance', NULL, '', 8080, '', '', '', 'offline', 0, 0, NULL, '2026-01-03 17:27:53', '2026-01-03 16:19:44', '2026-01-01 15:18:42', '2026-01-01 15:18:42', '2026-01-03 17:27:53');
INSERT INTO `device` VALUES (9, 'DEV-008', '10f91ad23def97418183b34f5729bd25', 'test08', 'entrance', NULL, '', 8080, '', '', '', 'offline', 0, 0, NULL, '2026-01-03 17:27:53', '2026-01-03 16:20:08', '2026-01-01 15:18:54', '2026-01-01 15:18:54', '2026-01-03 17:27:54');
INSERT INTO `device` VALUES (10, 'DEV-009', '5637e7be18a0a748c2971c4acb147712', 'test09', 'entrance', NULL, '', 8080, '', '', '', 'offline', 0, 0, NULL, '2026-01-03 17:27:54', '2026-01-03 16:20:18', '2026-01-01 15:19:45', '2026-01-01 15:19:45', '2026-01-03 17:27:54');
INSERT INTO `device` VALUES (11, 'DEV-010', '8252bbaecf4cd8b82caa580c63e07aee', 'test10', 'visitor', 2, '', 8080, '', '', '', 'offline', 0, 0, NULL, '2026-01-03 17:24:21', '2026-01-03 16:48:41', '2026-01-01 15:20:37', '2026-01-01 15:20:37', '2026-01-03 17:27:50');

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备认证Token表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '控制命令表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_command
-- ----------------------------
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
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '命令执行记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_command_log
-- ----------------------------
INSERT INTO `device_command_log` VALUES (1, 2, 1, 'start', NULL, 1, '2025-12-14 00:38:11', 'sending', NULL, NULL, NULL, NULL, '2025-12-14 00:38:10');
INSERT INTO `device_command_log` VALUES (2, 2, 1, 'open_door', NULL, 1, '2025-12-30 17:16:03', 'pending', NULL, NULL, NULL, NULL, '2025-12-30 17:16:03');
INSERT INTO `device_command_log` VALUES (3, 2, 1, 'open_door', '{\"duration\": 300}', 1, '2025-12-31 17:40:13', 'pending', NULL, NULL, NULL, NULL, '2025-12-31 17:40:12');
INSERT INTO `device_command_log` VALUES (4, 2, 1, 'open_door', '{\"duration\": 5}', 1, '2026-01-01 15:21:02', 'pending', NULL, NULL, NULL, NULL, '2026-01-01 15:21:02');
INSERT INTO `device_command_log` VALUES (5, 2, 1, 'open_door', '{\"duration\": 5}', 1, '2026-01-02 13:56:34', 'pending', NULL, NULL, NULL, NULL, '2026-01-02 13:56:34');
INSERT INTO `device_command_log` VALUES (6, 2, 1, 'open_door', '{\"duration\": 20}', 1, '2026-01-02 13:58:04', 'pending', NULL, NULL, NULL, NULL, '2026-01-02 13:58:04');
INSERT INTO `device_command_log` VALUES (7, 2, 1, 'open_door', '{\"duration\": 20}', 1, '2026-01-02 14:05:05', 'success', '{\"message\": \"门已关闭\"}', NULL, '2026-01-02 14:05:26', 21734, '2026-01-02 14:05:04');
INSERT INTO `device_command_log` VALUES (8, 2, 1, 'open_door', '{\"duration\": 5}', 1, '2026-01-02 15:01:04', 'success', '{\"message\": \"门已关闭\"}', NULL, '2026-01-02 15:01:11', 6983, '2026-01-02 15:01:04');
INSERT INTO `device_command_log` VALUES (9, 2, 1, 'open_door', '{\"duration\": 5}', 1, '2026-01-02 15:40:55', 'success', '{\"message\": \"门已关闭\"}', NULL, '2026-01-02 15:41:01', 6730, '2026-01-02 15:40:54');
INSERT INTO `device_command_log` VALUES (10, 2, 1, 'open_door', '{\"duration\": 20}', 1, '2026-01-02 15:41:08', 'success', '{\"message\": \"门已打开\", \"duration\": 20}', NULL, '2026-01-02 15:41:08', 542, '2026-01-02 15:41:07');
INSERT INTO `device_command_log` VALUES (11, 2, 1, 'open_door', '{\"duration\": 10}', 1, '2026-01-02 15:59:56', 'success', '{\"message\": \"门已关闭\"}', NULL, '2026-01-02 16:00:07', 11054, '2026-01-02 15:59:56');
INSERT INTO `device_command_log` VALUES (12, 2, 3, 'get_status', NULL, 1, '2026-01-02 16:00:25', 'pending', NULL, NULL, NULL, NULL, '2026-01-02 16:00:24');
INSERT INTO `device_command_log` VALUES (15, 6, 2, 'close_door', '{}', 1, '2026-01-03 16:59:32', 'success', '{\"message\": \"门已关闭\"}', NULL, '2026-01-03 16:59:32', 339, '2026-01-03 16:59:31');
INSERT INTO `device_command_log` VALUES (16, 6, 1, 'open_door', '{\"duration\": 10}', 1, '2026-01-03 16:59:46', 'success', '{\"message\": \"门已关闭\"}', NULL, '2026-01-03 16:59:58', 11680, '2026-01-03 16:59:46');

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
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_config
-- ----------------------------
INSERT INTO `device_config` VALUES (1, 11, 'heartbeat_interval', '60', 'number', '心跳间隔', 1, '2026-01-03 16:55:15', '2026-01-02 19:13:15', '2026-01-03 16:55:15');
INSERT INTO `device_config` VALUES (2, 11, 'report_interval', '300', 'number', '状态上报间隔', 1, '2026-01-02 20:03:31', '2026-01-02 19:13:47', '2026-01-02 20:03:31');

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备分组表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 679 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备心跳记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_heartbeat
-- ----------------------------
INSERT INTO `device_heartbeat` VALUES (1, 2, '2025-12-30 17:16:38', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2025-12-30 17:16:37');
INSERT INTO `device_heartbeat` VALUES (2, 2, '2025-12-31 17:39:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2025-12-31 17:39:36');
INSERT INTO `device_heartbeat` VALUES (3, 2, '2025-12-31 17:40:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2025-12-31 17:40:36');
INSERT INTO `device_heartbeat` VALUES (4, 2, '2025-12-31 17:41:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2025-12-31 17:41:36');
INSERT INTO `device_heartbeat` VALUES (5, 2, '2025-12-31 17:42:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2025-12-31 17:42:36');
INSERT INTO `device_heartbeat` VALUES (6, 2, '2025-12-31 17:43:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2025-12-31 17:43:36');
INSERT INTO `device_heartbeat` VALUES (7, 2, '2025-12-31 17:44:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2025-12-31 17:44:36');
INSERT INTO `device_heartbeat` VALUES (8, 2, '2025-12-31 17:45:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2025-12-31 17:45:36');
INSERT INTO `device_heartbeat` VALUES (9, 2, '2025-12-31 17:46:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2025-12-31 17:46:36');
INSERT INTO `device_heartbeat` VALUES (10, 2, '2025-12-31 17:47:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2025-12-31 17:47:36');
INSERT INTO `device_heartbeat` VALUES (11, 2, '2025-12-31 17:48:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2025-12-31 17:48:36');
INSERT INTO `device_heartbeat` VALUES (12, 2, '2025-12-31 17:49:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2025-12-31 17:49:36');
INSERT INTO `device_heartbeat` VALUES (13, 2, '2025-12-31 17:50:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2025-12-31 17:50:36');
INSERT INTO `device_heartbeat` VALUES (14, 2, '2025-12-31 17:51:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2025-12-31 17:51:36');
INSERT INTO `device_heartbeat` VALUES (15, 2, '2026-01-02 13:56:09', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 13:56:08');
INSERT INTO `device_heartbeat` VALUES (16, 2, '2026-01-02 13:57:46', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 13:57:45');
INSERT INTO `device_heartbeat` VALUES (17, 2, '2026-01-02 13:58:46', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 13:58:46');
INSERT INTO `device_heartbeat` VALUES (18, 2, '2026-01-02 14:04:25', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 14:04:25');
INSERT INTO `device_heartbeat` VALUES (19, 2, '2026-01-02 14:05:25', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 14:05:25');
INSERT INTO `device_heartbeat` VALUES (20, 2, '2026-01-02 14:06:26', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 14:06:26');
INSERT INTO `device_heartbeat` VALUES (21, 2, '2026-01-02 14:07:27', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 14:07:27');
INSERT INTO `device_heartbeat` VALUES (22, 2, '2026-01-02 14:08:27', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 14:08:27');
INSERT INTO `device_heartbeat` VALUES (23, 2, '2026-01-02 14:09:28', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 14:09:28');
INSERT INTO `device_heartbeat` VALUES (24, 2, '2026-01-02 14:10:29', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 14:10:29');
INSERT INTO `device_heartbeat` VALUES (25, 2, '2026-01-02 14:11:29', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 14:11:29');
INSERT INTO `device_heartbeat` VALUES (26, 2, '2026-01-02 14:12:30', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 14:12:30');
INSERT INTO `device_heartbeat` VALUES (27, 2, '2026-01-02 14:13:31', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 14:13:31');
INSERT INTO `device_heartbeat` VALUES (28, 2, '2026-01-02 14:14:32', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 14:14:32');
INSERT INTO `device_heartbeat` VALUES (29, 2, '2026-01-02 14:15:33', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 14:15:33');
INSERT INTO `device_heartbeat` VALUES (30, 2, '2026-01-02 14:16:34', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 14:16:34');
INSERT INTO `device_heartbeat` VALUES (31, 2, '2026-01-02 14:17:34', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 14:17:34');
INSERT INTO `device_heartbeat` VALUES (32, 2, '2026-01-02 14:18:35', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 14:18:35');
INSERT INTO `device_heartbeat` VALUES (33, 2, '2026-01-02 14:39:40', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 14:39:40');
INSERT INTO `device_heartbeat` VALUES (34, 2, '2026-01-02 15:00:32', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:00:31');
INSERT INTO `device_heartbeat` VALUES (35, 2, '2026-01-02 15:00:58', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:00:57');
INSERT INTO `device_heartbeat` VALUES (36, 3, '2026-01-02 15:01:31', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:01:31');
INSERT INTO `device_heartbeat` VALUES (37, 4, '2026-01-02 15:02:24', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:02:23');
INSERT INTO `device_heartbeat` VALUES (38, 4, '2026-01-02 15:03:24', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:03:24');
INSERT INTO `device_heartbeat` VALUES (39, 4, '2026-01-02 15:04:25', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:04:25');
INSERT INTO `device_heartbeat` VALUES (40, 4, '2026-01-02 15:05:26', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:05:26');
INSERT INTO `device_heartbeat` VALUES (41, 4, '2026-01-02 15:06:27', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:06:27');
INSERT INTO `device_heartbeat` VALUES (42, 2, '2026-01-02 15:10:39', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:10:39');
INSERT INTO `device_heartbeat` VALUES (43, 2, '2026-01-02 15:11:40', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:11:40');
INSERT INTO `device_heartbeat` VALUES (44, 2, '2026-01-02 15:12:41', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:12:41');
INSERT INTO `device_heartbeat` VALUES (45, 3, '2026-01-02 15:15:06', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:15:06');
INSERT INTO `device_heartbeat` VALUES (46, 2, '2026-01-02 15:25:48', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:25:48');
INSERT INTO `device_heartbeat` VALUES (47, 2, '2026-01-02 15:31:52', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:31:51');
INSERT INTO `device_heartbeat` VALUES (48, 2, '2026-01-02 15:32:08', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:32:08');
INSERT INTO `device_heartbeat` VALUES (49, 2, '2026-01-02 15:40:07', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:40:07');
INSERT INTO `device_heartbeat` VALUES (50, 2, '2026-01-02 15:41:07', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:41:07');
INSERT INTO `device_heartbeat` VALUES (51, 2, '2026-01-02 15:41:20', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:41:19');
INSERT INTO `device_heartbeat` VALUES (52, 2, '2026-01-02 15:42:20', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:42:20');
INSERT INTO `device_heartbeat` VALUES (53, 2, '2026-01-02 15:43:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:43:21');
INSERT INTO `device_heartbeat` VALUES (54, 2, '2026-01-02 15:44:22', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:44:22');
INSERT INTO `device_heartbeat` VALUES (55, 2, '2026-01-02 15:45:23', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:45:23');
INSERT INTO `device_heartbeat` VALUES (56, 2, '2026-01-02 15:46:24', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:46:24');
INSERT INTO `device_heartbeat` VALUES (57, 2, '2026-01-02 15:54:11', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:54:10');
INSERT INTO `device_heartbeat` VALUES (58, 2, '2026-01-02 15:55:11', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:55:11');
INSERT INTO `device_heartbeat` VALUES (59, 2, '2026-01-02 15:56:12', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:56:12');
INSERT INTO `device_heartbeat` VALUES (60, 2, '2026-01-02 15:57:13', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:57:13');
INSERT INTO `device_heartbeat` VALUES (61, 2, '2026-01-02 15:58:14', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:58:14');
INSERT INTO `device_heartbeat` VALUES (62, 2, '2026-01-02 15:59:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 15:59:36');
INSERT INTO `device_heartbeat` VALUES (63, 2, '2026-01-02 16:00:37', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 16:00:37');
INSERT INTO `device_heartbeat` VALUES (64, 11, '2026-01-02 20:03:13', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:03:12');
INSERT INTO `device_heartbeat` VALUES (65, 11, '2026-01-02 20:04:13', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:04:13');
INSERT INTO `device_heartbeat` VALUES (66, 11, '2026-01-02 20:05:14', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:05:14');
INSERT INTO `device_heartbeat` VALUES (67, 11, '2026-01-02 20:06:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:06:15');
INSERT INTO `device_heartbeat` VALUES (68, 11, '2026-01-02 20:07:16', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:07:16');
INSERT INTO `device_heartbeat` VALUES (69, 11, '2026-01-02 20:15:29', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:15:29');
INSERT INTO `device_heartbeat` VALUES (70, 11, '2026-01-02 20:20:58', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:20:58');
INSERT INTO `device_heartbeat` VALUES (71, 11, '2026-01-02 20:20:58', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:20:58');
INSERT INTO `device_heartbeat` VALUES (72, 11, '2026-01-02 20:21:58', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:21:58');
INSERT INTO `device_heartbeat` VALUES (73, 11, '2026-01-02 20:22:59', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:22:59');
INSERT INTO `device_heartbeat` VALUES (74, 11, '2026-01-02 20:24:00', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:24:00');
INSERT INTO `device_heartbeat` VALUES (75, 11, '2026-01-02 20:26:22', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:26:21');
INSERT INTO `device_heartbeat` VALUES (76, 11, '2026-01-02 20:27:22', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:27:22');
INSERT INTO `device_heartbeat` VALUES (77, 11, '2026-01-02 20:29:40', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:29:40');
INSERT INTO `device_heartbeat` VALUES (78, 11, '2026-01-02 20:30:41', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:30:41');
INSERT INTO `device_heartbeat` VALUES (79, 11, '2026-01-02 20:31:42', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:31:42');
INSERT INTO `device_heartbeat` VALUES (80, 11, '2026-01-02 20:34:25', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:34:25');
INSERT INTO `device_heartbeat` VALUES (81, 11, '2026-01-02 20:34:57', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:34:57');
INSERT INTO `device_heartbeat` VALUES (82, 11, '2026-01-02 20:35:57', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:35:57');
INSERT INTO `device_heartbeat` VALUES (83, 11, '2026-01-02 20:36:58', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:36:58');
INSERT INTO `device_heartbeat` VALUES (84, 11, '2026-01-02 20:37:59', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:37:59');
INSERT INTO `device_heartbeat` VALUES (85, 11, '2026-01-02 20:39:00', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:39:00');
INSERT INTO `device_heartbeat` VALUES (86, 11, '2026-01-02 20:42:22', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:42:22');
INSERT INTO `device_heartbeat` VALUES (87, 11, '2026-01-02 20:42:32', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:42:32');
INSERT INTO `device_heartbeat` VALUES (88, 11, '2026-01-02 20:42:53', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:42:53');
INSERT INTO `device_heartbeat` VALUES (89, 11, '2026-01-02 20:43:03', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:43:03');
INSERT INTO `device_heartbeat` VALUES (90, 11, '2026-01-02 20:43:13', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:43:13');
INSERT INTO `device_heartbeat` VALUES (91, 11, '2026-01-02 20:43:23', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:43:23');
INSERT INTO `device_heartbeat` VALUES (92, 11, '2026-01-02 20:43:33', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:43:33');
INSERT INTO `device_heartbeat` VALUES (93, 11, '2026-01-02 20:43:43', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:43:43');
INSERT INTO `device_heartbeat` VALUES (94, 11, '2026-01-02 20:46:56', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:46:56');
INSERT INTO `device_heartbeat` VALUES (95, 11, '2026-01-02 20:47:06', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 20:47:06');
INSERT INTO `device_heartbeat` VALUES (96, 11, '2026-01-02 21:42:31', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 21:42:31');
INSERT INTO `device_heartbeat` VALUES (97, 2, '2026-01-02 22:21:49', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 22:21:49');
INSERT INTO `device_heartbeat` VALUES (98, 2, '2026-01-02 22:22:49', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 22:22:49');
INSERT INTO `device_heartbeat` VALUES (99, 2, '2026-01-02 22:48:49', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 22:48:49');
INSERT INTO `device_heartbeat` VALUES (100, 2, '2026-01-02 22:49:49', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 22:49:49');
INSERT INTO `device_heartbeat` VALUES (101, 2, '2026-01-02 22:52:16', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 22:52:16');
INSERT INTO `device_heartbeat` VALUES (102, 2, '2026-01-02 22:53:17', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 22:53:17');
INSERT INTO `device_heartbeat` VALUES (103, 2, '2026-01-02 22:54:18', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 22:54:18');
INSERT INTO `device_heartbeat` VALUES (104, 2, '2026-01-02 22:55:18', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 22:55:18');
INSERT INTO `device_heartbeat` VALUES (105, 11, '2026-01-02 22:56:49', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 22:56:49');
INSERT INTO `device_heartbeat` VALUES (106, 11, '2026-01-02 22:57:49', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 22:57:49');
INSERT INTO `device_heartbeat` VALUES (107, 11, '2026-01-02 22:58:49', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 22:58:49');
INSERT INTO `device_heartbeat` VALUES (108, 11, '2026-01-02 22:59:49', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 22:59:49');
INSERT INTO `device_heartbeat` VALUES (109, 2, '2026-01-02 23:02:31', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 23:02:31');
INSERT INTO `device_heartbeat` VALUES (110, 2, '2026-01-02 23:03:31', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 23:03:31');
INSERT INTO `device_heartbeat` VALUES (111, 2, '2026-01-02 23:04:32', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 23:04:32');
INSERT INTO `device_heartbeat` VALUES (112, 2, '2026-01-02 23:05:33', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 23:05:33');
INSERT INTO `device_heartbeat` VALUES (113, 2, '2026-01-02 23:06:34', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 23:06:34');
INSERT INTO `device_heartbeat` VALUES (114, 2, '2026-01-02 23:07:35', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-02 23:07:35');
INSERT INTO `device_heartbeat` VALUES (115, 2, '2026-01-03 16:18:38', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:18:38');
INSERT INTO `device_heartbeat` VALUES (116, 3, '2026-01-03 16:18:57', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:18:57');
INSERT INTO `device_heartbeat` VALUES (117, 4, '2026-01-03 16:19:11', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:19:11');
INSERT INTO `device_heartbeat` VALUES (118, 2, '2026-01-03 16:19:39', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:19:39');
INSERT INTO `device_heartbeat` VALUES (119, 5, '2026-01-03 16:19:55', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:19:55');
INSERT INTO `device_heartbeat` VALUES (120, 3, '2026-01-03 16:19:58', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:19:58');
INSERT INTO `device_heartbeat` VALUES (121, 4, '2026-01-03 16:20:12', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:20:12');
INSERT INTO `device_heartbeat` VALUES (122, 6, '2026-01-03 16:20:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:20:21');
INSERT INTO `device_heartbeat` VALUES (123, 7, '2026-01-03 16:20:32', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:20:32');
INSERT INTO `device_heartbeat` VALUES (124, 8, '2026-01-03 16:20:45', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:20:45');
INSERT INTO `device_heartbeat` VALUES (125, 2, '2026-01-03 16:20:49', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:20:48');
INSERT INTO `device_heartbeat` VALUES (126, 5, '2026-01-03 16:20:56', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:20:56');
INSERT INTO `device_heartbeat` VALUES (127, 9, '2026-01-03 16:21:08', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:21:08');
INSERT INTO `device_heartbeat` VALUES (128, 4, '2026-01-03 16:21:13', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:21:13');
INSERT INTO `device_heartbeat` VALUES (129, 10, '2026-01-03 16:21:18', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:21:18');
INSERT INTO `device_heartbeat` VALUES (130, 6, '2026-01-03 16:21:22', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:21:22');
INSERT INTO `device_heartbeat` VALUES (131, 7, '2026-01-03 16:21:33', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:21:33');
INSERT INTO `device_heartbeat` VALUES (132, 8, '2026-01-03 16:21:46', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:21:46');
INSERT INTO `device_heartbeat` VALUES (133, 2, '2026-01-03 16:21:49', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:21:49');
INSERT INTO `device_heartbeat` VALUES (134, 5, '2026-01-03 16:21:57', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:21:57');
INSERT INTO `device_heartbeat` VALUES (135, 9, '2026-01-03 16:22:09', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:22:09');
INSERT INTO `device_heartbeat` VALUES (136, 4, '2026-01-03 16:22:14', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:22:14');
INSERT INTO `device_heartbeat` VALUES (137, 10, '2026-01-03 16:22:19', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:22:19');
INSERT INTO `device_heartbeat` VALUES (138, 6, '2026-01-03 16:22:23', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:22:23');
INSERT INTO `device_heartbeat` VALUES (139, 7, '2026-01-03 16:22:34', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:22:34');
INSERT INTO `device_heartbeat` VALUES (140, 8, '2026-01-03 16:22:47', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:22:47');
INSERT INTO `device_heartbeat` VALUES (141, 2, '2026-01-03 16:22:50', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:22:50');
INSERT INTO `device_heartbeat` VALUES (142, 5, '2026-01-03 16:22:58', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:22:58');
INSERT INTO `device_heartbeat` VALUES (143, 9, '2026-01-03 16:23:10', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:23:10');
INSERT INTO `device_heartbeat` VALUES (144, 4, '2026-01-03 16:23:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:23:15');
INSERT INTO `device_heartbeat` VALUES (145, 10, '2026-01-03 16:23:20', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:23:20');
INSERT INTO `device_heartbeat` VALUES (146, 6, '2026-01-03 16:23:24', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:23:24');
INSERT INTO `device_heartbeat` VALUES (147, 7, '2026-01-03 16:23:35', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:23:35');
INSERT INTO `device_heartbeat` VALUES (148, 8, '2026-01-03 16:23:48', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:23:48');
INSERT INTO `device_heartbeat` VALUES (149, 2, '2026-01-03 16:23:51', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:23:51');
INSERT INTO `device_heartbeat` VALUES (150, 5, '2026-01-03 16:23:59', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:23:59');
INSERT INTO `device_heartbeat` VALUES (151, 9, '2026-01-03 16:24:11', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:24:11');
INSERT INTO `device_heartbeat` VALUES (152, 4, '2026-01-03 16:24:16', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:24:16');
INSERT INTO `device_heartbeat` VALUES (153, 10, '2026-01-03 16:24:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:24:21');
INSERT INTO `device_heartbeat` VALUES (154, 6, '2026-01-03 16:24:25', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:24:25');
INSERT INTO `device_heartbeat` VALUES (155, 7, '2026-01-03 16:24:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:24:36');
INSERT INTO `device_heartbeat` VALUES (156, 8, '2026-01-03 16:24:49', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:24:49');
INSERT INTO `device_heartbeat` VALUES (157, 2, '2026-01-03 16:24:52', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:24:52');
INSERT INTO `device_heartbeat` VALUES (158, 5, '2026-01-03 16:25:00', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:25:00');
INSERT INTO `device_heartbeat` VALUES (159, 9, '2026-01-03 16:25:12', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:25:12');
INSERT INTO `device_heartbeat` VALUES (160, 4, '2026-01-03 16:25:17', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:25:17');
INSERT INTO `device_heartbeat` VALUES (161, 10, '2026-01-03 16:25:22', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:25:22');
INSERT INTO `device_heartbeat` VALUES (162, 6, '2026-01-03 16:25:26', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:25:26');
INSERT INTO `device_heartbeat` VALUES (163, 7, '2026-01-03 16:25:37', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:25:37');
INSERT INTO `device_heartbeat` VALUES (164, 10, '2026-01-03 16:26:23', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:26:23');
INSERT INTO `device_heartbeat` VALUES (165, 8, '2026-01-03 16:30:48', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:30:47');
INSERT INTO `device_heartbeat` VALUES (166, 2, '2026-01-03 16:31:13', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:31:12');
INSERT INTO `device_heartbeat` VALUES (167, 3, '2026-01-03 16:31:13', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:31:13');
INSERT INTO `device_heartbeat` VALUES (168, 4, '2026-01-03 16:31:14', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:31:13');
INSERT INTO `device_heartbeat` VALUES (169, 5, '2026-01-03 16:31:14', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:31:14');
INSERT INTO `device_heartbeat` VALUES (170, 6, '2026-01-03 16:31:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:31:14');
INSERT INTO `device_heartbeat` VALUES (171, 7, '2026-01-03 16:31:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:31:15');
INSERT INTO `device_heartbeat` VALUES (172, 9, '2026-01-03 16:31:16', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:31:16');
INSERT INTO `device_heartbeat` VALUES (173, 10, '2026-01-03 16:31:17', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:31:16');
INSERT INTO `device_heartbeat` VALUES (174, 8, '2026-01-03 16:31:48', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:31:48');
INSERT INTO `device_heartbeat` VALUES (175, 2, '2026-01-03 16:32:13', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:32:13');
INSERT INTO `device_heartbeat` VALUES (176, 3, '2026-01-03 16:32:14', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:32:14');
INSERT INTO `device_heartbeat` VALUES (177, 4, '2026-01-03 16:32:14', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:32:14');
INSERT INTO `device_heartbeat` VALUES (178, 6, '2026-01-03 16:32:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:32:15');
INSERT INTO `device_heartbeat` VALUES (179, 5, '2026-01-03 16:32:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:32:15');
INSERT INTO `device_heartbeat` VALUES (180, 9, '2026-01-03 16:32:16', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:32:16');
INSERT INTO `device_heartbeat` VALUES (181, 7, '2026-01-03 16:32:16', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:32:16');
INSERT INTO `device_heartbeat` VALUES (182, 10, '2026-01-03 16:32:17', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:32:17');
INSERT INTO `device_heartbeat` VALUES (183, 8, '2026-01-03 16:32:49', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:32:49');
INSERT INTO `device_heartbeat` VALUES (184, 2, '2026-01-03 16:33:14', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:33:14');
INSERT INTO `device_heartbeat` VALUES (185, 3, '2026-01-03 16:33:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:33:15');
INSERT INTO `device_heartbeat` VALUES (186, 4, '2026-01-03 16:33:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:33:15');
INSERT INTO `device_heartbeat` VALUES (187, 6, '2026-01-03 16:33:16', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:33:16');
INSERT INTO `device_heartbeat` VALUES (188, 5, '2026-01-03 16:33:16', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:33:16');
INSERT INTO `device_heartbeat` VALUES (189, 7, '2026-01-03 16:33:17', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:33:17');
INSERT INTO `device_heartbeat` VALUES (190, 9, '2026-01-03 16:33:17', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:33:17');
INSERT INTO `device_heartbeat` VALUES (191, 10, '2026-01-03 16:33:18', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:33:18');
INSERT INTO `device_heartbeat` VALUES (192, 8, '2026-01-03 16:33:50', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:33:50');
INSERT INTO `device_heartbeat` VALUES (193, 2, '2026-01-03 16:34:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:34:15');
INSERT INTO `device_heartbeat` VALUES (194, 3, '2026-01-03 16:34:16', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:34:16');
INSERT INTO `device_heartbeat` VALUES (195, 4, '2026-01-03 16:34:16', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:34:16');
INSERT INTO `device_heartbeat` VALUES (196, 5, '2026-01-03 16:34:17', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:34:17');
INSERT INTO `device_heartbeat` VALUES (197, 6, '2026-01-03 16:34:17', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:34:17');
INSERT INTO `device_heartbeat` VALUES (198, 9, '2026-01-03 16:34:18', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:34:18');
INSERT INTO `device_heartbeat` VALUES (199, 7, '2026-01-03 16:34:18', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:34:18');
INSERT INTO `device_heartbeat` VALUES (200, 10, '2026-01-03 16:34:19', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:34:19');
INSERT INTO `device_heartbeat` VALUES (201, 8, '2026-01-03 16:34:51', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:34:51');
INSERT INTO `device_heartbeat` VALUES (202, 2, '2026-01-03 16:35:16', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:35:16');
INSERT INTO `device_heartbeat` VALUES (203, 3, '2026-01-03 16:35:17', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:35:17');
INSERT INTO `device_heartbeat` VALUES (204, 4, '2026-01-03 16:35:17', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:35:17');
INSERT INTO `device_heartbeat` VALUES (205, 5, '2026-01-03 16:35:18', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:35:18');
INSERT INTO `device_heartbeat` VALUES (206, 6, '2026-01-03 16:35:18', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:35:18');
INSERT INTO `device_heartbeat` VALUES (207, 9, '2026-01-03 16:35:19', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:35:19');
INSERT INTO `device_heartbeat` VALUES (208, 7, '2026-01-03 16:35:19', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:35:19');
INSERT INTO `device_heartbeat` VALUES (209, 10, '2026-01-03 16:35:20', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:35:20');
INSERT INTO `device_heartbeat` VALUES (210, 8, '2026-01-03 16:35:52', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:35:52');
INSERT INTO `device_heartbeat` VALUES (211, 7, '2026-01-03 16:36:20', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:36:20');
INSERT INTO `device_heartbeat` VALUES (212, 8, '2026-01-03 16:36:53', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:36:53');
INSERT INTO `device_heartbeat` VALUES (213, 7, '2026-01-03 16:37:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:37:21');
INSERT INTO `device_heartbeat` VALUES (214, 2, '2026-01-03 16:37:42', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:37:41');
INSERT INTO `device_heartbeat` VALUES (215, 8, '2026-01-03 16:37:54', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:37:54');
INSERT INTO `device_heartbeat` VALUES (216, 7, '2026-01-03 16:38:22', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:38:22');
INSERT INTO `device_heartbeat` VALUES (217, 2, '2026-01-03 16:38:42', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:38:42');
INSERT INTO `device_heartbeat` VALUES (218, 8, '2026-01-03 16:38:55', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:38:55');
INSERT INTO `device_heartbeat` VALUES (219, 3, '2026-01-03 16:39:11', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:39:11');
INSERT INTO `device_heartbeat` VALUES (220, 4, '2026-01-03 16:39:12', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:39:11');
INSERT INTO `device_heartbeat` VALUES (221, 5, '2026-01-03 16:39:12', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:39:12');
INSERT INTO `device_heartbeat` VALUES (222, 6, '2026-01-03 16:39:12', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:39:12');
INSERT INTO `device_heartbeat` VALUES (223, 9, '2026-01-03 16:39:13', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:39:13');
INSERT INTO `device_heartbeat` VALUES (224, 10, '2026-01-03 16:39:14', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:39:13');
INSERT INTO `device_heartbeat` VALUES (225, 7, '2026-01-03 16:39:23', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:39:23');
INSERT INTO `device_heartbeat` VALUES (226, 2, '2026-01-03 16:39:43', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:39:43');
INSERT INTO `device_heartbeat` VALUES (227, 8, '2026-01-03 16:39:56', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:39:56');
INSERT INTO `device_heartbeat` VALUES (228, 3, '2026-01-03 16:40:12', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:40:12');
INSERT INTO `device_heartbeat` VALUES (229, 4, '2026-01-03 16:40:12', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:40:12');
INSERT INTO `device_heartbeat` VALUES (230, 5, '2026-01-03 16:40:13', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:40:13');
INSERT INTO `device_heartbeat` VALUES (231, 6, '2026-01-03 16:40:13', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:40:13');
INSERT INTO `device_heartbeat` VALUES (232, 9, '2026-01-03 16:40:14', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:40:14');
INSERT INTO `device_heartbeat` VALUES (233, 10, '2026-01-03 16:40:14', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:40:14');
INSERT INTO `device_heartbeat` VALUES (234, 7, '2026-01-03 16:40:24', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:40:24');
INSERT INTO `device_heartbeat` VALUES (235, 2, '2026-01-03 16:40:44', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:40:44');
INSERT INTO `device_heartbeat` VALUES (236, 8, '2026-01-03 16:40:57', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:40:57');
INSERT INTO `device_heartbeat` VALUES (237, 4, '2026-01-03 16:41:13', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:41:13');
INSERT INTO `device_heartbeat` VALUES (238, 3, '2026-01-03 16:41:13', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:41:13');
INSERT INTO `device_heartbeat` VALUES (239, 6, '2026-01-03 16:41:14', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:41:14');
INSERT INTO `device_heartbeat` VALUES (240, 5, '2026-01-03 16:41:14', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:41:14');
INSERT INTO `device_heartbeat` VALUES (241, 10, '2026-01-03 16:41:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:41:15');
INSERT INTO `device_heartbeat` VALUES (242, 9, '2026-01-03 16:41:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:41:15');
INSERT INTO `device_heartbeat` VALUES (243, 7, '2026-01-03 16:41:25', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:41:25');
INSERT INTO `device_heartbeat` VALUES (244, 2, '2026-01-03 16:41:45', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:41:45');
INSERT INTO `device_heartbeat` VALUES (245, 8, '2026-01-03 16:41:58', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:41:58');
INSERT INTO `device_heartbeat` VALUES (246, 3, '2026-01-03 16:42:14', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:42:14');
INSERT INTO `device_heartbeat` VALUES (247, 4, '2026-01-03 16:42:14', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:42:14');
INSERT INTO `device_heartbeat` VALUES (248, 6, '2026-01-03 16:42:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:42:15');
INSERT INTO `device_heartbeat` VALUES (249, 5, '2026-01-03 16:42:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:42:15');
INSERT INTO `device_heartbeat` VALUES (250, 10, '2026-01-03 16:42:16', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:42:16');
INSERT INTO `device_heartbeat` VALUES (251, 9, '2026-01-03 16:42:16', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:42:16');
INSERT INTO `device_heartbeat` VALUES (252, 7, '2026-01-03 16:42:26', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:42:26');
INSERT INTO `device_heartbeat` VALUES (253, 2, '2026-01-03 16:42:46', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:42:46');
INSERT INTO `device_heartbeat` VALUES (254, 8, '2026-01-03 16:42:59', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:42:59');
INSERT INTO `device_heartbeat` VALUES (255, 3, '2026-01-03 16:43:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:43:15');
INSERT INTO `device_heartbeat` VALUES (256, 4, '2026-01-03 16:43:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:43:15');
INSERT INTO `device_heartbeat` VALUES (257, 6, '2026-01-03 16:43:16', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:43:16');
INSERT INTO `device_heartbeat` VALUES (258, 5, '2026-01-03 16:43:16', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:43:16');
INSERT INTO `device_heartbeat` VALUES (259, 9, '2026-01-03 16:43:17', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:43:17');
INSERT INTO `device_heartbeat` VALUES (260, 10, '2026-01-03 16:43:17', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:43:17');
INSERT INTO `device_heartbeat` VALUES (261, 7, '2026-01-03 16:43:27', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:43:27');
INSERT INTO `device_heartbeat` VALUES (262, 2, '2026-01-03 16:43:47', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:43:47');
INSERT INTO `device_heartbeat` VALUES (263, 8, '2026-01-03 16:44:00', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:44:00');
INSERT INTO `device_heartbeat` VALUES (264, 3, '2026-01-03 16:44:16', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:44:16');
INSERT INTO `device_heartbeat` VALUES (265, 4, '2026-01-03 16:44:16', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:44:16');
INSERT INTO `device_heartbeat` VALUES (266, 5, '2026-01-03 16:44:17', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:44:17');
INSERT INTO `device_heartbeat` VALUES (267, 6, '2026-01-03 16:44:17', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:44:17');
INSERT INTO `device_heartbeat` VALUES (268, 10, '2026-01-03 16:44:18', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:44:18');
INSERT INTO `device_heartbeat` VALUES (269, 9, '2026-01-03 16:44:18', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:44:18');
INSERT INTO `device_heartbeat` VALUES (270, 7, '2026-01-03 16:44:28', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:44:28');
INSERT INTO `device_heartbeat` VALUES (271, 2, '2026-01-03 16:44:48', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:44:48');
INSERT INTO `device_heartbeat` VALUES (272, 8, '2026-01-03 16:45:01', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:45:01');
INSERT INTO `device_heartbeat` VALUES (273, 4, '2026-01-03 16:45:17', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:45:17');
INSERT INTO `device_heartbeat` VALUES (274, 3, '2026-01-03 16:45:17', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:45:17');
INSERT INTO `device_heartbeat` VALUES (275, 6, '2026-01-03 16:45:18', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:45:18');
INSERT INTO `device_heartbeat` VALUES (276, 5, '2026-01-03 16:45:18', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:45:18');
INSERT INTO `device_heartbeat` VALUES (277, 10, '2026-01-03 16:45:19', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:45:19');
INSERT INTO `device_heartbeat` VALUES (278, 9, '2026-01-03 16:45:19', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:45:19');
INSERT INTO `device_heartbeat` VALUES (279, 7, '2026-01-03 16:45:29', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:45:29');
INSERT INTO `device_heartbeat` VALUES (280, 2, '2026-01-03 16:45:49', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:45:49');
INSERT INTO `device_heartbeat` VALUES (281, 8, '2026-01-03 16:46:02', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:46:02');
INSERT INTO `device_heartbeat` VALUES (282, 3, '2026-01-03 16:46:18', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:46:18');
INSERT INTO `device_heartbeat` VALUES (283, 4, '2026-01-03 16:46:18', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:46:18');
INSERT INTO `device_heartbeat` VALUES (284, 6, '2026-01-03 16:46:19', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:46:19');
INSERT INTO `device_heartbeat` VALUES (285, 5, '2026-01-03 16:46:19', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:46:19');
INSERT INTO `device_heartbeat` VALUES (286, 10, '2026-01-03 16:46:20', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:46:20');
INSERT INTO `device_heartbeat` VALUES (287, 9, '2026-01-03 16:46:20', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:46:20');
INSERT INTO `device_heartbeat` VALUES (288, 7, '2026-01-03 16:46:30', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:46:30');
INSERT INTO `device_heartbeat` VALUES (289, 2, '2026-01-03 16:46:50', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:46:50');
INSERT INTO `device_heartbeat` VALUES (290, 8, '2026-01-03 16:47:03', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:47:03');
INSERT INTO `device_heartbeat` VALUES (291, 4, '2026-01-03 16:47:19', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:47:19');
INSERT INTO `device_heartbeat` VALUES (292, 3, '2026-01-03 16:47:19', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:47:19');
INSERT INTO `device_heartbeat` VALUES (293, 5, '2026-01-03 16:47:20', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:47:20');
INSERT INTO `device_heartbeat` VALUES (294, 6, '2026-01-03 16:47:20', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:47:20');
INSERT INTO `device_heartbeat` VALUES (295, 9, '2026-01-03 16:47:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:47:21');
INSERT INTO `device_heartbeat` VALUES (296, 10, '2026-01-03 16:47:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:47:21');
INSERT INTO `device_heartbeat` VALUES (297, 7, '2026-01-03 16:47:31', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:47:31');
INSERT INTO `device_heartbeat` VALUES (298, 2, '2026-01-03 16:47:51', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:47:51');
INSERT INTO `device_heartbeat` VALUES (299, 8, '2026-01-03 16:48:04', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:48:04');
INSERT INTO `device_heartbeat` VALUES (300, 3, '2026-01-03 16:48:20', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:48:20');
INSERT INTO `device_heartbeat` VALUES (301, 4, '2026-01-03 16:48:20', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:48:20');
INSERT INTO `device_heartbeat` VALUES (302, 5, '2026-01-03 16:48:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:48:21');
INSERT INTO `device_heartbeat` VALUES (303, 6, '2026-01-03 16:48:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:48:21');
INSERT INTO `device_heartbeat` VALUES (304, 10, '2026-01-03 16:48:22', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:48:22');
INSERT INTO `device_heartbeat` VALUES (305, 9, '2026-01-03 16:48:22', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:48:22');
INSERT INTO `device_heartbeat` VALUES (306, 7, '2026-01-03 16:48:32', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:48:32');
INSERT INTO `device_heartbeat` VALUES (307, 2, '2026-01-03 16:48:52', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:48:52');
INSERT INTO `device_heartbeat` VALUES (308, 8, '2026-01-03 16:49:05', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:49:05');
INSERT INTO `device_heartbeat` VALUES (309, 3, '2026-01-03 16:49:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:49:21');
INSERT INTO `device_heartbeat` VALUES (310, 4, '2026-01-03 16:49:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:49:21');
INSERT INTO `device_heartbeat` VALUES (311, 5, '2026-01-03 16:49:22', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:49:22');
INSERT INTO `device_heartbeat` VALUES (312, 6, '2026-01-03 16:49:22', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:49:22');
INSERT INTO `device_heartbeat` VALUES (313, 10, '2026-01-03 16:49:23', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:49:23');
INSERT INTO `device_heartbeat` VALUES (314, 9, '2026-01-03 16:49:23', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:49:23');
INSERT INTO `device_heartbeat` VALUES (315, 7, '2026-01-03 16:49:33', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:49:33');
INSERT INTO `device_heartbeat` VALUES (316, 11, '2026-01-03 16:49:41', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:49:41');
INSERT INTO `device_heartbeat` VALUES (317, 2, '2026-01-03 16:49:53', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:49:53');
INSERT INTO `device_heartbeat` VALUES (318, 8, '2026-01-03 16:50:06', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:50:06');
INSERT INTO `device_heartbeat` VALUES (319, 4, '2026-01-03 16:50:22', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:50:22');
INSERT INTO `device_heartbeat` VALUES (320, 3, '2026-01-03 16:50:22', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:50:22');
INSERT INTO `device_heartbeat` VALUES (321, 6, '2026-01-03 16:50:23', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:50:23');
INSERT INTO `device_heartbeat` VALUES (322, 5, '2026-01-03 16:50:23', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:50:23');
INSERT INTO `device_heartbeat` VALUES (323, 10, '2026-01-03 16:50:24', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:50:24');
INSERT INTO `device_heartbeat` VALUES (324, 9, '2026-01-03 16:50:24', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:50:24');
INSERT INTO `device_heartbeat` VALUES (325, 7, '2026-01-03 16:50:34', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:50:34');
INSERT INTO `device_heartbeat` VALUES (326, 11, '2026-01-03 16:50:42', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:50:42');
INSERT INTO `device_heartbeat` VALUES (327, 2, '2026-01-03 16:50:54', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:50:54');
INSERT INTO `device_heartbeat` VALUES (328, 8, '2026-01-03 16:51:07', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:51:07');
INSERT INTO `device_heartbeat` VALUES (329, 4, '2026-01-03 16:51:23', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:51:23');
INSERT INTO `device_heartbeat` VALUES (330, 3, '2026-01-03 16:51:23', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:51:23');
INSERT INTO `device_heartbeat` VALUES (331, 6, '2026-01-03 16:51:24', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:51:24');
INSERT INTO `device_heartbeat` VALUES (332, 5, '2026-01-03 16:51:24', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:51:24');
INSERT INTO `device_heartbeat` VALUES (333, 10, '2026-01-03 16:51:25', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:51:25');
INSERT INTO `device_heartbeat` VALUES (334, 9, '2026-01-03 16:51:25', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:51:25');
INSERT INTO `device_heartbeat` VALUES (335, 7, '2026-01-03 16:51:35', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:51:35');
INSERT INTO `device_heartbeat` VALUES (336, 11, '2026-01-03 16:51:42', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:51:42');
INSERT INTO `device_heartbeat` VALUES (337, 2, '2026-01-03 16:51:55', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:51:55');
INSERT INTO `device_heartbeat` VALUES (338, 8, '2026-01-03 16:52:08', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:52:08');
INSERT INTO `device_heartbeat` VALUES (339, 3, '2026-01-03 16:52:24', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:52:24');
INSERT INTO `device_heartbeat` VALUES (340, 4, '2026-01-03 16:52:24', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:52:24');
INSERT INTO `device_heartbeat` VALUES (341, 6, '2026-01-03 16:52:25', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:52:25');
INSERT INTO `device_heartbeat` VALUES (342, 5, '2026-01-03 16:52:25', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:52:25');
INSERT INTO `device_heartbeat` VALUES (343, 9, '2026-01-03 16:52:26', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:52:26');
INSERT INTO `device_heartbeat` VALUES (344, 10, '2026-01-03 16:52:26', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:52:26');
INSERT INTO `device_heartbeat` VALUES (345, 7, '2026-01-03 16:52:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:52:36');
INSERT INTO `device_heartbeat` VALUES (346, 11, '2026-01-03 16:52:42', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:52:42');
INSERT INTO `device_heartbeat` VALUES (347, 11, '2026-01-03 16:52:54', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:52:53');
INSERT INTO `device_heartbeat` VALUES (348, 2, '2026-01-03 16:52:56', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:52:56');
INSERT INTO `device_heartbeat` VALUES (349, 11, '2026-01-03 16:53:04', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:53:03');
INSERT INTO `device_heartbeat` VALUES (350, 8, '2026-01-03 16:53:09', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:53:09');
INSERT INTO `device_heartbeat` VALUES (351, 11, '2026-01-03 16:53:14', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:53:14');
INSERT INTO `device_heartbeat` VALUES (352, 11, '2026-01-03 16:53:24', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:53:24');
INSERT INTO `device_heartbeat` VALUES (353, 3, '2026-01-03 16:53:25', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:53:25');
INSERT INTO `device_heartbeat` VALUES (354, 4, '2026-01-03 16:53:25', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:53:25');
INSERT INTO `device_heartbeat` VALUES (355, 5, '2026-01-03 16:53:26', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:53:26');
INSERT INTO `device_heartbeat` VALUES (356, 6, '2026-01-03 16:53:26', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:53:26');
INSERT INTO `device_heartbeat` VALUES (357, 10, '2026-01-03 16:53:27', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:53:27');
INSERT INTO `device_heartbeat` VALUES (358, 9, '2026-01-03 16:53:27', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:53:27');
INSERT INTO `device_heartbeat` VALUES (359, 11, '2026-01-03 16:53:34', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:53:34');
INSERT INTO `device_heartbeat` VALUES (360, 7, '2026-01-03 16:53:37', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:53:37');
INSERT INTO `device_heartbeat` VALUES (361, 11, '2026-01-03 16:53:44', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:53:44');
INSERT INTO `device_heartbeat` VALUES (362, 11, '2026-01-03 16:53:54', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:53:54');
INSERT INTO `device_heartbeat` VALUES (363, 2, '2026-01-03 16:53:57', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:53:57');
INSERT INTO `device_heartbeat` VALUES (364, 11, '2026-01-03 16:54:04', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:54:04');
INSERT INTO `device_heartbeat` VALUES (365, 8, '2026-01-03 16:54:10', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:54:10');
INSERT INTO `device_heartbeat` VALUES (366, 11, '2026-01-03 16:54:14', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:54:13');
INSERT INTO `device_heartbeat` VALUES (367, 11, '2026-01-03 16:54:24', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:54:23');
INSERT INTO `device_heartbeat` VALUES (368, 4, '2026-01-03 16:54:26', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:54:26');
INSERT INTO `device_heartbeat` VALUES (369, 3, '2026-01-03 16:54:26', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:54:26');
INSERT INTO `device_heartbeat` VALUES (370, 6, '2026-01-03 16:54:27', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:54:27');
INSERT INTO `device_heartbeat` VALUES (371, 5, '2026-01-03 16:54:27', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:54:27');
INSERT INTO `device_heartbeat` VALUES (372, 10, '2026-01-03 16:54:28', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:54:28');
INSERT INTO `device_heartbeat` VALUES (373, 9, '2026-01-03 16:54:28', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:54:28');
INSERT INTO `device_heartbeat` VALUES (374, 11, '2026-01-03 16:54:34', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:54:34');
INSERT INTO `device_heartbeat` VALUES (375, 7, '2026-01-03 16:54:38', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:54:38');
INSERT INTO `device_heartbeat` VALUES (376, 11, '2026-01-03 16:54:44', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:54:44');
INSERT INTO `device_heartbeat` VALUES (377, 11, '2026-01-03 16:54:54', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:54:54');
INSERT INTO `device_heartbeat` VALUES (378, 2, '2026-01-03 16:54:58', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:54:58');
INSERT INTO `device_heartbeat` VALUES (379, 11, '2026-01-03 16:55:04', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:55:04');
INSERT INTO `device_heartbeat` VALUES (380, 8, '2026-01-03 16:55:11', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:55:11');
INSERT INTO `device_heartbeat` VALUES (381, 11, '2026-01-03 16:55:14', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:55:14');
INSERT INTO `device_heartbeat` VALUES (382, 4, '2026-01-03 16:55:27', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:55:27');
INSERT INTO `device_heartbeat` VALUES (383, 3, '2026-01-03 16:55:27', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:55:27');
INSERT INTO `device_heartbeat` VALUES (384, 5, '2026-01-03 16:55:28', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:55:28');
INSERT INTO `device_heartbeat` VALUES (385, 6, '2026-01-03 16:55:28', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:55:28');
INSERT INTO `device_heartbeat` VALUES (386, 10, '2026-01-03 16:55:29', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:55:29');
INSERT INTO `device_heartbeat` VALUES (387, 9, '2026-01-03 16:55:29', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:55:29');
INSERT INTO `device_heartbeat` VALUES (388, 7, '2026-01-03 16:55:39', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:55:39');
INSERT INTO `device_heartbeat` VALUES (389, 2, '2026-01-03 16:55:59', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:55:59');
INSERT INTO `device_heartbeat` VALUES (390, 8, '2026-01-03 16:56:12', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:56:12');
INSERT INTO `device_heartbeat` VALUES (391, 11, '2026-01-03 16:56:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:56:15');
INSERT INTO `device_heartbeat` VALUES (392, 4, '2026-01-03 16:56:28', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:56:28');
INSERT INTO `device_heartbeat` VALUES (393, 3, '2026-01-03 16:56:28', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:56:28');
INSERT INTO `device_heartbeat` VALUES (394, 5, '2026-01-03 16:56:29', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:56:29');
INSERT INTO `device_heartbeat` VALUES (395, 6, '2026-01-03 16:56:29', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:56:29');
INSERT INTO `device_heartbeat` VALUES (396, 10, '2026-01-03 16:56:30', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:56:30');
INSERT INTO `device_heartbeat` VALUES (397, 9, '2026-01-03 16:56:30', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:56:30');
INSERT INTO `device_heartbeat` VALUES (398, 7, '2026-01-03 16:56:40', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:56:40');
INSERT INTO `device_heartbeat` VALUES (399, 2, '2026-01-03 16:57:00', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:57:00');
INSERT INTO `device_heartbeat` VALUES (400, 8, '2026-01-03 16:57:13', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:57:13');
INSERT INTO `device_heartbeat` VALUES (401, 11, '2026-01-03 16:57:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:57:15');
INSERT INTO `device_heartbeat` VALUES (402, 3, '2026-01-03 16:57:29', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:57:29');
INSERT INTO `device_heartbeat` VALUES (403, 4, '2026-01-03 16:57:29', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:57:29');
INSERT INTO `device_heartbeat` VALUES (404, 6, '2026-01-03 16:57:30', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:57:30');
INSERT INTO `device_heartbeat` VALUES (405, 5, '2026-01-03 16:57:30', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:57:30');
INSERT INTO `device_heartbeat` VALUES (406, 10, '2026-01-03 16:57:31', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:57:31');
INSERT INTO `device_heartbeat` VALUES (407, 9, '2026-01-03 16:57:31', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:57:31');
INSERT INTO `device_heartbeat` VALUES (408, 7, '2026-01-03 16:57:41', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:57:41');
INSERT INTO `device_heartbeat` VALUES (409, 2, '2026-01-03 16:58:01', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:58:01');
INSERT INTO `device_heartbeat` VALUES (410, 8, '2026-01-03 16:58:14', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:58:14');
INSERT INTO `device_heartbeat` VALUES (411, 11, '2026-01-03 16:58:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:58:15');
INSERT INTO `device_heartbeat` VALUES (412, 3, '2026-01-03 16:58:30', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:58:30');
INSERT INTO `device_heartbeat` VALUES (413, 4, '2026-01-03 16:58:30', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:58:30');
INSERT INTO `device_heartbeat` VALUES (414, 5, '2026-01-03 16:58:31', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:58:31');
INSERT INTO `device_heartbeat` VALUES (415, 6, '2026-01-03 16:58:31', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:58:31');
INSERT INTO `device_heartbeat` VALUES (416, 9, '2026-01-03 16:58:32', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:58:32');
INSERT INTO `device_heartbeat` VALUES (417, 10, '2026-01-03 16:58:32', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:58:32');
INSERT INTO `device_heartbeat` VALUES (418, 7, '2026-01-03 16:58:42', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:58:42');
INSERT INTO `device_heartbeat` VALUES (419, 2, '2026-01-03 16:59:02', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:59:02');
INSERT INTO `device_heartbeat` VALUES (420, 8, '2026-01-03 16:59:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:59:15');
INSERT INTO `device_heartbeat` VALUES (421, 11, '2026-01-03 16:59:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:59:15');
INSERT INTO `device_heartbeat` VALUES (422, 4, '2026-01-03 16:59:31', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:59:31');
INSERT INTO `device_heartbeat` VALUES (423, 3, '2026-01-03 16:59:31', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:59:31');
INSERT INTO `device_heartbeat` VALUES (424, 5, '2026-01-03 16:59:32', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:59:32');
INSERT INTO `device_heartbeat` VALUES (425, 6, '2026-01-03 16:59:32', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:59:32');
INSERT INTO `device_heartbeat` VALUES (426, 9, '2026-01-03 16:59:33', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:59:33');
INSERT INTO `device_heartbeat` VALUES (427, 10, '2026-01-03 16:59:33', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:59:33');
INSERT INTO `device_heartbeat` VALUES (428, 7, '2026-01-03 16:59:43', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 16:59:43');
INSERT INTO `device_heartbeat` VALUES (429, 2, '2026-01-03 17:00:03', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:00:03');
INSERT INTO `device_heartbeat` VALUES (430, 11, '2026-01-03 17:00:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:00:15');
INSERT INTO `device_heartbeat` VALUES (431, 8, '2026-01-03 17:00:16', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:00:16');
INSERT INTO `device_heartbeat` VALUES (432, 3, '2026-01-03 17:00:32', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:00:32');
INSERT INTO `device_heartbeat` VALUES (433, 4, '2026-01-03 17:00:32', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:00:32');
INSERT INTO `device_heartbeat` VALUES (434, 6, '2026-01-03 17:00:33', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:00:33');
INSERT INTO `device_heartbeat` VALUES (435, 5, '2026-01-03 17:00:33', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:00:33');
INSERT INTO `device_heartbeat` VALUES (436, 9, '2026-01-03 17:00:34', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:00:34');
INSERT INTO `device_heartbeat` VALUES (437, 10, '2026-01-03 17:00:34', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:00:34');
INSERT INTO `device_heartbeat` VALUES (438, 7, '2026-01-03 17:00:44', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:00:44');
INSERT INTO `device_heartbeat` VALUES (439, 2, '2026-01-03 17:01:04', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:01:04');
INSERT INTO `device_heartbeat` VALUES (440, 11, '2026-01-03 17:01:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:01:15');
INSERT INTO `device_heartbeat` VALUES (441, 8, '2026-01-03 17:01:17', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:01:17');
INSERT INTO `device_heartbeat` VALUES (442, 3, '2026-01-03 17:01:33', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:01:33');
INSERT INTO `device_heartbeat` VALUES (443, 4, '2026-01-03 17:01:33', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:01:33');
INSERT INTO `device_heartbeat` VALUES (444, 6, '2026-01-03 17:01:33', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:01:33');
INSERT INTO `device_heartbeat` VALUES (445, 5, '2026-01-03 17:01:34', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:01:34');
INSERT INTO `device_heartbeat` VALUES (446, 9, '2026-01-03 17:01:35', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:01:35');
INSERT INTO `device_heartbeat` VALUES (447, 10, '2026-01-03 17:01:35', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:01:35');
INSERT INTO `device_heartbeat` VALUES (448, 7, '2026-01-03 17:01:45', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:01:45');
INSERT INTO `device_heartbeat` VALUES (449, 2, '2026-01-03 17:02:05', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:02:05');
INSERT INTO `device_heartbeat` VALUES (450, 8, '2026-01-03 17:02:18', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:02:18');
INSERT INTO `device_heartbeat` VALUES (451, 11, '2026-01-03 17:02:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:02:21');
INSERT INTO `device_heartbeat` VALUES (452, 3, '2026-01-03 17:02:34', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:02:34');
INSERT INTO `device_heartbeat` VALUES (453, 6, '2026-01-03 17:02:34', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:02:34');
INSERT INTO `device_heartbeat` VALUES (454, 4, '2026-01-03 17:02:34', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:02:34');
INSERT INTO `device_heartbeat` VALUES (455, 5, '2026-01-03 17:02:35', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:02:35');
INSERT INTO `device_heartbeat` VALUES (456, 9, '2026-01-03 17:02:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:02:36');
INSERT INTO `device_heartbeat` VALUES (457, 10, '2026-01-03 17:02:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:02:36');
INSERT INTO `device_heartbeat` VALUES (458, 7, '2026-01-03 17:02:46', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:02:46');
INSERT INTO `device_heartbeat` VALUES (459, 2, '2026-01-03 17:03:06', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:03:06');
INSERT INTO `device_heartbeat` VALUES (460, 8, '2026-01-03 17:03:19', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:03:19');
INSERT INTO `device_heartbeat` VALUES (461, 11, '2026-01-03 17:03:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:03:21');
INSERT INTO `device_heartbeat` VALUES (462, 6, '2026-01-03 17:03:34', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:03:34');
INSERT INTO `device_heartbeat` VALUES (463, 3, '2026-01-03 17:03:35', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:03:35');
INSERT INTO `device_heartbeat` VALUES (464, 4, '2026-01-03 17:03:35', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:03:35');
INSERT INTO `device_heartbeat` VALUES (465, 5, '2026-01-03 17:03:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:03:36');
INSERT INTO `device_heartbeat` VALUES (466, 10, '2026-01-03 17:03:37', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:03:37');
INSERT INTO `device_heartbeat` VALUES (467, 9, '2026-01-03 17:03:37', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:03:37');
INSERT INTO `device_heartbeat` VALUES (468, 7, '2026-01-03 17:03:47', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:03:47');
INSERT INTO `device_heartbeat` VALUES (469, 2, '2026-01-03 17:04:07', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:04:07');
INSERT INTO `device_heartbeat` VALUES (470, 8, '2026-01-03 17:04:20', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:04:20');
INSERT INTO `device_heartbeat` VALUES (471, 11, '2026-01-03 17:04:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:04:21');
INSERT INTO `device_heartbeat` VALUES (472, 6, '2026-01-03 17:04:35', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:04:35');
INSERT INTO `device_heartbeat` VALUES (473, 3, '2026-01-03 17:04:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:04:36');
INSERT INTO `device_heartbeat` VALUES (474, 4, '2026-01-03 17:04:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:04:36');
INSERT INTO `device_heartbeat` VALUES (475, 5, '2026-01-03 17:04:37', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:04:37');
INSERT INTO `device_heartbeat` VALUES (476, 10, '2026-01-03 17:04:38', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:04:38');
INSERT INTO `device_heartbeat` VALUES (477, 9, '2026-01-03 17:04:38', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:04:38');
INSERT INTO `device_heartbeat` VALUES (478, 7, '2026-01-03 17:04:48', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:04:48');
INSERT INTO `device_heartbeat` VALUES (479, 2, '2026-01-03 17:05:08', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:05:08');
INSERT INTO `device_heartbeat` VALUES (480, 11, '2026-01-03 17:05:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:05:21');
INSERT INTO `device_heartbeat` VALUES (481, 8, '2026-01-03 17:05:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:05:21');
INSERT INTO `device_heartbeat` VALUES (482, 6, '2026-01-03 17:05:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:05:36');
INSERT INTO `device_heartbeat` VALUES (483, 4, '2026-01-03 17:05:37', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:05:37');
INSERT INTO `device_heartbeat` VALUES (484, 3, '2026-01-03 17:05:37', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:05:37');
INSERT INTO `device_heartbeat` VALUES (485, 5, '2026-01-03 17:05:38', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:05:38');
INSERT INTO `device_heartbeat` VALUES (486, 9, '2026-01-03 17:05:39', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:05:39');
INSERT INTO `device_heartbeat` VALUES (487, 10, '2026-01-03 17:05:39', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:05:39');
INSERT INTO `device_heartbeat` VALUES (488, 7, '2026-01-03 17:05:49', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:05:49');
INSERT INTO `device_heartbeat` VALUES (489, 2, '2026-01-03 17:06:08', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:06:08');
INSERT INTO `device_heartbeat` VALUES (490, 11, '2026-01-03 17:06:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:06:15');
INSERT INTO `device_heartbeat` VALUES (491, 8, '2026-01-03 17:06:22', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:06:22');
INSERT INTO `device_heartbeat` VALUES (492, 3, '2026-01-03 17:06:38', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:06:38');
INSERT INTO `device_heartbeat` VALUES (493, 4, '2026-01-03 17:06:38', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:06:38');
INSERT INTO `device_heartbeat` VALUES (494, 5, '2026-01-03 17:06:39', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:06:39');
INSERT INTO `device_heartbeat` VALUES (495, 10, '2026-01-03 17:06:40', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:06:40');
INSERT INTO `device_heartbeat` VALUES (496, 9, '2026-01-03 17:06:40', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:06:40');
INSERT INTO `device_heartbeat` VALUES (497, 7, '2026-01-03 17:06:50', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:06:50');
INSERT INTO `device_heartbeat` VALUES (498, 2, '2026-01-03 17:07:09', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:07:09');
INSERT INTO `device_heartbeat` VALUES (499, 6, '2026-01-03 17:07:19', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:07:19');
INSERT INTO `device_heartbeat` VALUES (500, 11, '2026-01-03 17:07:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:07:21');
INSERT INTO `device_heartbeat` VALUES (501, 8, '2026-01-03 17:07:23', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:07:23');
INSERT INTO `device_heartbeat` VALUES (502, 4, '2026-01-03 17:07:39', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:07:39');
INSERT INTO `device_heartbeat` VALUES (503, 3, '2026-01-03 17:07:39', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:07:39');
INSERT INTO `device_heartbeat` VALUES (504, 5, '2026-01-03 17:07:40', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:07:40');
INSERT INTO `device_heartbeat` VALUES (505, 10, '2026-01-03 17:07:41', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:07:41');
INSERT INTO `device_heartbeat` VALUES (506, 9, '2026-01-03 17:07:41', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:07:41');
INSERT INTO `device_heartbeat` VALUES (507, 7, '2026-01-03 17:07:51', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:07:51');
INSERT INTO `device_heartbeat` VALUES (508, 2, '2026-01-03 17:08:10', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:08:10');
INSERT INTO `device_heartbeat` VALUES (509, 6, '2026-01-03 17:08:20', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:08:20');
INSERT INTO `device_heartbeat` VALUES (510, 11, '2026-01-03 17:08:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:08:21');
INSERT INTO `device_heartbeat` VALUES (511, 8, '2026-01-03 17:08:24', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:08:24');
INSERT INTO `device_heartbeat` VALUES (512, 4, '2026-01-03 17:08:40', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:08:40');
INSERT INTO `device_heartbeat` VALUES (513, 3, '2026-01-03 17:08:40', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:08:40');
INSERT INTO `device_heartbeat` VALUES (514, 5, '2026-01-03 17:08:41', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:08:41');
INSERT INTO `device_heartbeat` VALUES (515, 9, '2026-01-03 17:08:42', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:08:42');
INSERT INTO `device_heartbeat` VALUES (516, 10, '2026-01-03 17:08:42', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:08:42');
INSERT INTO `device_heartbeat` VALUES (517, 7, '2026-01-03 17:08:52', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:08:52');
INSERT INTO `device_heartbeat` VALUES (518, 2, '2026-01-03 17:09:11', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:09:11');
INSERT INTO `device_heartbeat` VALUES (519, 11, '2026-01-03 17:09:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:09:15');
INSERT INTO `device_heartbeat` VALUES (520, 6, '2026-01-03 17:09:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:09:21');
INSERT INTO `device_heartbeat` VALUES (521, 8, '2026-01-03 17:09:25', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:09:25');
INSERT INTO `device_heartbeat` VALUES (522, 3, '2026-01-03 17:09:41', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:09:41');
INSERT INTO `device_heartbeat` VALUES (523, 4, '2026-01-03 17:09:41', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:09:41');
INSERT INTO `device_heartbeat` VALUES (524, 5, '2026-01-03 17:09:42', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:09:42');
INSERT INTO `device_heartbeat` VALUES (525, 9, '2026-01-03 17:09:43', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:09:43');
INSERT INTO `device_heartbeat` VALUES (526, 10, '2026-01-03 17:09:43', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:09:43');
INSERT INTO `device_heartbeat` VALUES (527, 7, '2026-01-03 17:09:53', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:09:53');
INSERT INTO `device_heartbeat` VALUES (528, 2, '2026-01-03 17:10:12', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:10:12');
INSERT INTO `device_heartbeat` VALUES (529, 11, '2026-01-03 17:10:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:10:15');
INSERT INTO `device_heartbeat` VALUES (530, 6, '2026-01-03 17:10:22', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:10:22');
INSERT INTO `device_heartbeat` VALUES (531, 8, '2026-01-03 17:10:26', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:10:26');
INSERT INTO `device_heartbeat` VALUES (532, 3, '2026-01-03 17:10:42', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:10:42');
INSERT INTO `device_heartbeat` VALUES (533, 4, '2026-01-03 17:10:42', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:10:42');
INSERT INTO `device_heartbeat` VALUES (534, 5, '2026-01-03 17:10:43', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:10:43');
INSERT INTO `device_heartbeat` VALUES (535, 10, '2026-01-03 17:10:44', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:10:44');
INSERT INTO `device_heartbeat` VALUES (536, 9, '2026-01-03 17:10:44', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:10:44');
INSERT INTO `device_heartbeat` VALUES (537, 7, '2026-01-03 17:10:54', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:10:54');
INSERT INTO `device_heartbeat` VALUES (538, 2, '2026-01-03 17:11:13', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:11:13');
INSERT INTO `device_heartbeat` VALUES (539, 11, '2026-01-03 17:11:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:11:15');
INSERT INTO `device_heartbeat` VALUES (540, 6, '2026-01-03 17:11:23', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:11:23');
INSERT INTO `device_heartbeat` VALUES (541, 8, '2026-01-03 17:11:27', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:11:27');
INSERT INTO `device_heartbeat` VALUES (542, 3, '2026-01-03 17:11:43', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:11:43');
INSERT INTO `device_heartbeat` VALUES (543, 4, '2026-01-03 17:11:43', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:11:43');
INSERT INTO `device_heartbeat` VALUES (544, 5, '2026-01-03 17:11:44', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:11:44');
INSERT INTO `device_heartbeat` VALUES (545, 10, '2026-01-03 17:11:45', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:11:45');
INSERT INTO `device_heartbeat` VALUES (546, 9, '2026-01-03 17:11:45', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:11:45');
INSERT INTO `device_heartbeat` VALUES (547, 7, '2026-01-03 17:11:55', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:11:55');
INSERT INTO `device_heartbeat` VALUES (548, 2, '2026-01-03 17:12:14', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:12:14');
INSERT INTO `device_heartbeat` VALUES (549, 11, '2026-01-03 17:12:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:12:15');
INSERT INTO `device_heartbeat` VALUES (550, 6, '2026-01-03 17:12:24', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:12:24');
INSERT INTO `device_heartbeat` VALUES (551, 8, '2026-01-03 17:12:28', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:12:28');
INSERT INTO `device_heartbeat` VALUES (552, 3, '2026-01-03 17:12:44', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:12:44');
INSERT INTO `device_heartbeat` VALUES (553, 4, '2026-01-03 17:12:44', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:12:44');
INSERT INTO `device_heartbeat` VALUES (554, 5, '2026-01-03 17:12:45', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:12:45');
INSERT INTO `device_heartbeat` VALUES (555, 10, '2026-01-03 17:12:46', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:12:46');
INSERT INTO `device_heartbeat` VALUES (556, 9, '2026-01-03 17:12:46', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:12:46');
INSERT INTO `device_heartbeat` VALUES (557, 7, '2026-01-03 17:12:56', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:12:56');
INSERT INTO `device_heartbeat` VALUES (558, 2, '2026-01-03 17:13:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:13:15');
INSERT INTO `device_heartbeat` VALUES (559, 11, '2026-01-03 17:13:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:13:21');
INSERT INTO `device_heartbeat` VALUES (560, 6, '2026-01-03 17:13:25', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:13:25');
INSERT INTO `device_heartbeat` VALUES (561, 8, '2026-01-03 17:13:29', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:13:29');
INSERT INTO `device_heartbeat` VALUES (562, 4, '2026-01-03 17:13:45', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:13:45');
INSERT INTO `device_heartbeat` VALUES (563, 3, '2026-01-03 17:13:45', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:13:45');
INSERT INTO `device_heartbeat` VALUES (564, 5, '2026-01-03 17:13:46', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:13:46');
INSERT INTO `device_heartbeat` VALUES (565, 9, '2026-01-03 17:13:47', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:13:47');
INSERT INTO `device_heartbeat` VALUES (566, 10, '2026-01-03 17:13:47', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:13:47');
INSERT INTO `device_heartbeat` VALUES (567, 7, '2026-01-03 17:13:57', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:13:57');
INSERT INTO `device_heartbeat` VALUES (568, 11, '2026-01-03 17:14:15', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:14:15');
INSERT INTO `device_heartbeat` VALUES (569, 2, '2026-01-03 17:14:16', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:14:16');
INSERT INTO `device_heartbeat` VALUES (570, 6, '2026-01-03 17:14:26', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:14:26');
INSERT INTO `device_heartbeat` VALUES (571, 8, '2026-01-03 17:14:30', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:14:30');
INSERT INTO `device_heartbeat` VALUES (572, 4, '2026-01-03 17:14:46', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:14:46');
INSERT INTO `device_heartbeat` VALUES (573, 3, '2026-01-03 17:14:46', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:14:46');
INSERT INTO `device_heartbeat` VALUES (574, 5, '2026-01-03 17:14:47', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:14:47');
INSERT INTO `device_heartbeat` VALUES (575, 10, '2026-01-03 17:14:48', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:14:48');
INSERT INTO `device_heartbeat` VALUES (576, 9, '2026-01-03 17:14:48', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:14:48');
INSERT INTO `device_heartbeat` VALUES (577, 7, '2026-01-03 17:14:58', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:14:58');
INSERT INTO `device_heartbeat` VALUES (578, 2, '2026-01-03 17:15:17', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:15:17');
INSERT INTO `device_heartbeat` VALUES (579, 11, '2026-01-03 17:15:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:15:21');
INSERT INTO `device_heartbeat` VALUES (580, 6, '2026-01-03 17:15:27', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:15:27');
INSERT INTO `device_heartbeat` VALUES (581, 8, '2026-01-03 17:15:31', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:15:31');
INSERT INTO `device_heartbeat` VALUES (582, 4, '2026-01-03 17:15:47', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:15:47');
INSERT INTO `device_heartbeat` VALUES (583, 3, '2026-01-03 17:15:47', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:15:47');
INSERT INTO `device_heartbeat` VALUES (584, 5, '2026-01-03 17:15:48', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:15:48');
INSERT INTO `device_heartbeat` VALUES (585, 9, '2026-01-03 17:15:49', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:15:49');
INSERT INTO `device_heartbeat` VALUES (586, 10, '2026-01-03 17:15:49', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:15:49');
INSERT INTO `device_heartbeat` VALUES (587, 7, '2026-01-03 17:15:59', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:15:59');
INSERT INTO `device_heartbeat` VALUES (588, 2, '2026-01-03 17:16:18', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:16:18');
INSERT INTO `device_heartbeat` VALUES (589, 11, '2026-01-03 17:16:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:16:21');
INSERT INTO `device_heartbeat` VALUES (590, 6, '2026-01-03 17:16:28', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:16:28');
INSERT INTO `device_heartbeat` VALUES (591, 8, '2026-01-03 17:16:32', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:16:32');
INSERT INTO `device_heartbeat` VALUES (592, 3, '2026-01-03 17:16:48', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:16:48');
INSERT INTO `device_heartbeat` VALUES (593, 4, '2026-01-03 17:16:48', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:16:48');
INSERT INTO `device_heartbeat` VALUES (594, 5, '2026-01-03 17:16:49', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:16:49');
INSERT INTO `device_heartbeat` VALUES (595, 9, '2026-01-03 17:16:50', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:16:50');
INSERT INTO `device_heartbeat` VALUES (596, 10, '2026-01-03 17:16:50', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:16:50');
INSERT INTO `device_heartbeat` VALUES (597, 7, '2026-01-03 17:17:00', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:17:00');
INSERT INTO `device_heartbeat` VALUES (598, 2, '2026-01-03 17:17:19', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:17:19');
INSERT INTO `device_heartbeat` VALUES (599, 11, '2026-01-03 17:17:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:17:21');
INSERT INTO `device_heartbeat` VALUES (600, 6, '2026-01-03 17:17:29', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:17:29');
INSERT INTO `device_heartbeat` VALUES (601, 8, '2026-01-03 17:17:33', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:17:33');
INSERT INTO `device_heartbeat` VALUES (602, 4, '2026-01-03 17:17:49', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:17:49');
INSERT INTO `device_heartbeat` VALUES (603, 3, '2026-01-03 17:17:49', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:17:49');
INSERT INTO `device_heartbeat` VALUES (604, 5, '2026-01-03 17:17:50', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:17:50');
INSERT INTO `device_heartbeat` VALUES (605, 10, '2026-01-03 17:17:51', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:17:51');
INSERT INTO `device_heartbeat` VALUES (606, 9, '2026-01-03 17:17:51', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:17:51');
INSERT INTO `device_heartbeat` VALUES (607, 7, '2026-01-03 17:18:01', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:18:01');
INSERT INTO `device_heartbeat` VALUES (608, 2, '2026-01-03 17:18:20', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:18:20');
INSERT INTO `device_heartbeat` VALUES (609, 11, '2026-01-03 17:18:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:18:21');
INSERT INTO `device_heartbeat` VALUES (610, 6, '2026-01-03 17:18:30', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:18:30');
INSERT INTO `device_heartbeat` VALUES (611, 8, '2026-01-03 17:18:34', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:18:34');
INSERT INTO `device_heartbeat` VALUES (612, 4, '2026-01-03 17:18:50', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:18:50');
INSERT INTO `device_heartbeat` VALUES (613, 3, '2026-01-03 17:18:50', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:18:50');
INSERT INTO `device_heartbeat` VALUES (614, 5, '2026-01-03 17:18:51', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:18:51');
INSERT INTO `device_heartbeat` VALUES (615, 10, '2026-01-03 17:18:52', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:18:52');
INSERT INTO `device_heartbeat` VALUES (616, 9, '2026-01-03 17:18:52', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:18:52');
INSERT INTO `device_heartbeat` VALUES (617, 7, '2026-01-03 17:19:02', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:19:02');
INSERT INTO `device_heartbeat` VALUES (618, 11, '2026-01-03 17:19:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:19:21');
INSERT INTO `device_heartbeat` VALUES (619, 2, '2026-01-03 17:19:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:19:21');
INSERT INTO `device_heartbeat` VALUES (620, 6, '2026-01-03 17:19:31', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:19:31');
INSERT INTO `device_heartbeat` VALUES (621, 8, '2026-01-03 17:19:35', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:19:35');
INSERT INTO `device_heartbeat` VALUES (622, 4, '2026-01-03 17:19:51', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:19:51');
INSERT INTO `device_heartbeat` VALUES (623, 3, '2026-01-03 17:19:51', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:19:51');
INSERT INTO `device_heartbeat` VALUES (624, 5, '2026-01-03 17:19:52', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:19:52');
INSERT INTO `device_heartbeat` VALUES (625, 9, '2026-01-03 17:19:53', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:19:53');
INSERT INTO `device_heartbeat` VALUES (626, 10, '2026-01-03 17:19:53', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:19:53');
INSERT INTO `device_heartbeat` VALUES (627, 7, '2026-01-03 17:20:03', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:20:03');
INSERT INTO `device_heartbeat` VALUES (628, 11, '2026-01-03 17:20:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:20:21');
INSERT INTO `device_heartbeat` VALUES (629, 2, '2026-01-03 17:20:22', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:20:22');
INSERT INTO `device_heartbeat` VALUES (630, 6, '2026-01-03 17:20:32', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:20:32');
INSERT INTO `device_heartbeat` VALUES (631, 8, '2026-01-03 17:20:36', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:20:36');
INSERT INTO `device_heartbeat` VALUES (632, 3, '2026-01-03 17:20:52', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:20:52');
INSERT INTO `device_heartbeat` VALUES (633, 4, '2026-01-03 17:20:52', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:20:52');
INSERT INTO `device_heartbeat` VALUES (634, 5, '2026-01-03 17:20:53', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:20:53');
INSERT INTO `device_heartbeat` VALUES (635, 9, '2026-01-03 17:20:54', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:20:54');
INSERT INTO `device_heartbeat` VALUES (636, 10, '2026-01-03 17:20:54', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:20:54');
INSERT INTO `device_heartbeat` VALUES (637, 7, '2026-01-03 17:21:04', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:21:04');
INSERT INTO `device_heartbeat` VALUES (638, 11, '2026-01-03 17:21:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:21:21');
INSERT INTO `device_heartbeat` VALUES (639, 2, '2026-01-03 17:21:23', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:21:23');
INSERT INTO `device_heartbeat` VALUES (640, 6, '2026-01-03 17:21:33', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:21:33');
INSERT INTO `device_heartbeat` VALUES (641, 8, '2026-01-03 17:21:37', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:21:37');
INSERT INTO `device_heartbeat` VALUES (642, 3, '2026-01-03 17:21:53', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:21:53');
INSERT INTO `device_heartbeat` VALUES (643, 4, '2026-01-03 17:21:53', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:21:53');
INSERT INTO `device_heartbeat` VALUES (644, 5, '2026-01-03 17:21:54', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:21:54');
INSERT INTO `device_heartbeat` VALUES (645, 10, '2026-01-03 17:21:55', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:21:55');
INSERT INTO `device_heartbeat` VALUES (646, 9, '2026-01-03 17:21:55', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:21:55');
INSERT INTO `device_heartbeat` VALUES (647, 7, '2026-01-03 17:22:05', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:22:05');
INSERT INTO `device_heartbeat` VALUES (648, 11, '2026-01-03 17:22:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:22:21');
INSERT INTO `device_heartbeat` VALUES (649, 2, '2026-01-03 17:22:24', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:22:24');
INSERT INTO `device_heartbeat` VALUES (650, 6, '2026-01-03 17:22:34', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:22:34');
INSERT INTO `device_heartbeat` VALUES (651, 8, '2026-01-03 17:22:38', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:22:38');
INSERT INTO `device_heartbeat` VALUES (652, 4, '2026-01-03 17:22:54', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:22:54');
INSERT INTO `device_heartbeat` VALUES (653, 3, '2026-01-03 17:22:54', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:22:54');
INSERT INTO `device_heartbeat` VALUES (654, 5, '2026-01-03 17:22:55', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:22:55');
INSERT INTO `device_heartbeat` VALUES (655, 9, '2026-01-03 17:22:56', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:22:56');
INSERT INTO `device_heartbeat` VALUES (656, 10, '2026-01-03 17:22:56', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:22:56');
INSERT INTO `device_heartbeat` VALUES (657, 7, '2026-01-03 17:23:06', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:23:06');
INSERT INTO `device_heartbeat` VALUES (658, 11, '2026-01-03 17:23:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:23:21');
INSERT INTO `device_heartbeat` VALUES (659, 2, '2026-01-03 17:23:25', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:23:25');
INSERT INTO `device_heartbeat` VALUES (660, 6, '2026-01-03 17:23:35', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:23:35');
INSERT INTO `device_heartbeat` VALUES (661, 8, '2026-01-03 17:23:39', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:23:39');
INSERT INTO `device_heartbeat` VALUES (662, 3, '2026-01-03 17:23:55', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:23:55');
INSERT INTO `device_heartbeat` VALUES (663, 4, '2026-01-03 17:23:55', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:23:55');
INSERT INTO `device_heartbeat` VALUES (664, 5, '2026-01-03 17:23:56', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:23:56');
INSERT INTO `device_heartbeat` VALUES (665, 10, '2026-01-03 17:23:57', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:23:57');
INSERT INTO `device_heartbeat` VALUES (666, 9, '2026-01-03 17:23:57', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:23:57');
INSERT INTO `device_heartbeat` VALUES (667, 7, '2026-01-03 17:24:07', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:24:07');
INSERT INTO `device_heartbeat` VALUES (668, 11, '2026-01-03 17:24:21', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:24:21');
INSERT INTO `device_heartbeat` VALUES (669, 2, '2026-01-03 17:24:26', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:24:26');
INSERT INTO `device_heartbeat` VALUES (670, 2, '2026-01-03 17:27:50', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:27:50');
INSERT INTO `device_heartbeat` VALUES (671, 3, '2026-01-03 17:27:51', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:27:50');
INSERT INTO `device_heartbeat` VALUES (672, 4, '2026-01-03 17:27:51', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:27:51');
INSERT INTO `device_heartbeat` VALUES (673, 5, '2026-01-03 17:27:52', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:27:51');
INSERT INTO `device_heartbeat` VALUES (674, 6, '2026-01-03 17:27:52', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:27:51');
INSERT INTO `device_heartbeat` VALUES (675, 7, '2026-01-03 17:27:52', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:27:52');
INSERT INTO `device_heartbeat` VALUES (676, 8, '2026-01-03 17:27:53', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:27:52');
INSERT INTO `device_heartbeat` VALUES (677, 9, '2026-01-03 17:27:53', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:27:53');
INSERT INTO `device_heartbeat` VALUES (678, 10, '2026-01-03 17:27:54', NULL, NULL, '{\"uptime\": 259200, \"version\": \"1.0.0\"}', '2026-01-03 17:27:53');

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
) ENGINE = InnoDB AUTO_INCREMENT = 89 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备状态历史表（门禁场景）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of device_status_history
-- ----------------------------
INSERT INTO `device_status_history` VALUES (66, 2, 'access', NULL, 'closed', 'normal', '2026-01-02 15:02:31', '2026-01-02 23:02:31');
INSERT INTO `device_status_history` VALUES (67, 2, 'access', NULL, 'open', 'normal', '2026-01-02 15:02:43', '2026-01-02 23:02:43');
INSERT INTO `device_status_history` VALUES (68, 2, 'access', NULL, 'closed', 'normal', '2026-01-02 15:02:52', '2026-01-02 23:02:52');
INSERT INTO `device_status_history` VALUES (69, 3, 'access', NULL, 'closed', 'normal', '2026-01-03 08:17:56', '2026-01-03 16:17:56');
INSERT INTO `device_status_history` VALUES (70, 4, 'access', NULL, 'closed', 'normal', '2026-01-03 08:18:10', '2026-01-03 16:18:10');
INSERT INTO `device_status_history` VALUES (71, 5, 'access', NULL, 'closed', 'normal', '2026-01-03 08:18:54', '2026-01-03 16:18:54');
INSERT INTO `device_status_history` VALUES (72, 6, 'access', NULL, 'closed', 'normal', '2026-01-03 08:19:20', '2026-01-03 16:19:20');
INSERT INTO `device_status_history` VALUES (73, 7, 'access', NULL, 'closed', 'normal', '2026-01-03 08:19:32', '2026-01-03 16:19:32');
INSERT INTO `device_status_history` VALUES (74, 8, 'access', NULL, 'closed', 'normal', '2026-01-03 08:19:44', '2026-01-03 16:19:44');
INSERT INTO `device_status_history` VALUES (75, 9, 'access', NULL, 'closed', 'normal', '2026-01-03 08:20:07', '2026-01-03 16:20:07');
INSERT INTO `device_status_history` VALUES (76, 10, 'access', NULL, 'closed', 'normal', '2026-01-03 08:20:17', '2026-01-03 16:20:17');
INSERT INTO `device_status_history` VALUES (77, 2, 'access', NULL, 'open', 'normal', '2026-01-03 08:20:53', '2026-01-03 16:20:53');
INSERT INTO `device_status_history` VALUES (78, 2, 'access', NULL, 'closed', 'normal', '2026-01-03 08:21:24', '2026-01-03 16:21:24');
INSERT INTO `device_status_history` VALUES (79, 6, 'access', NULL, 'open', 'normal', '2026-01-03 08:21:49', '2026-01-03 16:21:49');
INSERT INTO `device_status_history` VALUES (80, 8, 'access', NULL, 'open', 'normal', '2026-01-03 08:22:27', '2026-01-03 16:22:27');
INSERT INTO `device_status_history` VALUES (81, 8, 'access', NULL, 'closed', 'normal', '2026-01-03 08:35:01', '2026-01-03 16:35:01');
INSERT INTO `device_status_history` VALUES (82, 11, 'access', NULL, 'closed', 'normal', '2026-01-03 08:48:41', '2026-01-03 16:48:41');
INSERT INTO `device_status_history` VALUES (83, 6, 'access', NULL, 'closed', 'normal', '2026-01-03 08:59:31', '2026-01-03 16:59:31');
INSERT INTO `device_status_history` VALUES (84, 6, 'access', NULL, 'open', 'normal', '2026-01-03 08:59:46', '2026-01-03 16:59:46');
INSERT INTO `device_status_history` VALUES (85, 6, 'access', NULL, 'closed', 'normal', '2026-01-03 08:59:57', '2026-01-03 16:59:57');
INSERT INTO `device_status_history` VALUES (86, 6, 'access', NULL, 'open', 'normal', '2026-01-03 09:04:21', '2026-01-03 17:04:21');
INSERT INTO `device_status_history` VALUES (87, 6, 'access', NULL, 'closed', 'normal', '2026-01-03 09:06:18', '2026-01-03 17:06:18');
INSERT INTO `device_status_history` VALUES (88, 11, 'access', NULL, 'open', 'normal', '2026-01-03 09:09:50', '2026-01-03 17:09:50');

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备WebSocket会话表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '统计报表配置表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '报表生成记录表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统操作日志表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 24 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '权限表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色权限关联表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'admin', '$2a$10$encrypted_password_here', '系统管理员', 'admin@example.com', NULL, NULL, 1, 1, '2026-01-03 17:32:49', '0:0:0:0:0:0:0:1', '2025-12-11 17:22:03', '2026-01-03 17:32:48');

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户角色关联表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'WebSocket会话表' ROW_FORMAT = DYNAMIC;

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
-- Procedure structure for sp_insert_status_history_if_changed
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_insert_status_history_if_changed`;
delimiter ;;
CREATE PROCEDURE `sp_insert_status_history_if_changed`(IN p_device_id BIGINT,
  IN p_status_type VARCHAR(50),
  IN p_status_value TEXT,
  IN p_door_status VARCHAR(20),
  IN p_door_controller_status VARCHAR(50),
  IN p_report_time DATETIME)
BEGIN
  DECLARE v_last_door_status VARCHAR(20) DEFAULT NULL;
  DECLARE v_last_door_controller_status VARCHAR(50) DEFAULT NULL;
  DECLARE v_status_changed TINYINT DEFAULT 0;
  
  -- 查询该设备最近一条状态历史记录
  SELECT door_status, door_controller_status
  INTO v_last_door_status, v_last_door_controller_status
  FROM device_status_history
  WHERE device_id = p_device_id
  ORDER BY report_time DESC, id DESC
  LIMIT 1;
  
  -- 判断状态是否发生变化
  -- 如果最近一条记录不存在，或者状态不同，则插入新记录
  IF v_last_door_status IS NULL THEN
    -- 没有历史记录，直接插入
    SET v_status_changed = 1;
  ELSEIF v_last_door_status != p_door_status OR v_last_door_controller_status != p_door_controller_status THEN
    -- 状态发生变化，插入新记录
    SET v_status_changed = 1;
  END IF;
  
  -- 只有状态变化时才插入
  IF v_status_changed = 1 THEN
    INSERT INTO device_status_history (
      device_id,
      status_type,
      status_value,
      door_status,
      door_controller_status,
      report_time
    ) VALUES (
      p_device_id,
      p_status_type,
      p_status_value,
      p_door_status,
      p_door_controller_status,
      p_report_time
    );
  END IF;
  
  -- 返回是否插入了记录（0=未插入，1=已插入）
  SELECT v_status_changed AS inserted;
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
