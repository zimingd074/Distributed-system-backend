package com.distributed.monitor.websocket;

import cn.hutool.json.JSONUtil;
import com.distributed.monitor.entity.Device;
import com.distributed.monitor.entity.DeviceHeartbeat;
import com.distributed.monitor.entity.DeviceWebSocketSession;
import com.distributed.monitor.mapper.DeviceMapper;
import com.distributed.monitor.service.DeviceApiService;
import com.distributed.monitor.service.DeviceAuthService;
import com.distributed.monitor.dto.deviceapi.DeviceStatusReportDTO;
import com.distributed.monitor.dto.deviceapi.CommandResultDTO;
import com.distributed.monitor.vo.deviceapi.StatusReportResponseVO;
import com.distributed.monitor.mapper.AlertMapper;
import com.distributed.monitor.entity.AlertRecord;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import javax.websocket.*;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 设备WebSocket长连接服务
 * 对应接口设计中的 /device/ws
 */
@Component
@ServerEndpoint("/device/ws")
@Slf4j
public class DeviceWebSocketServer {
    
    /**
     * key: sessionId, value: DeviceSessionInfo
     */
    private static final Map<String, DeviceSessionInfo> SESSIONS = new ConcurrentHashMap<>();
    
    /**
     * key: deviceCode, value: sessionId
     */
    private static final Map<String, String> DEVICE_SESSIONS = new ConcurrentHashMap<>();
    
    /**
     * 设备会话信息
     */
    private static class DeviceSessionInfo {
        Session session;
        String deviceCode;
        Long deviceId;
        LocalDateTime connectTime;
        LocalDateTime lastHeartbeatTime;
        boolean authenticated;
        
        DeviceSessionInfo(Session session) {
            this.session = session;
            this.connectTime = LocalDateTime.now();
            this.authenticated = false;
        }
    }
    
    // Spring注入需要使用静态变量和setter方法
    private static DeviceMapper deviceMapper;
    private static DeviceAuthService deviceAuthService;
    private static DeviceApiService deviceApiService;
    private static AlertMapper alertMapper;
    
    @Autowired
    public void setDeviceMapper(DeviceMapper deviceMapper) {
        DeviceWebSocketServer.deviceMapper = deviceMapper;
    }
    
    @Autowired
    public void setDeviceAuthService(DeviceAuthService deviceAuthService) {
        DeviceWebSocketServer.deviceAuthService = deviceAuthService;
    }
    
    @Autowired
    public void setDeviceApiService(DeviceApiService deviceApiService) {
        DeviceWebSocketServer.deviceApiService = deviceApiService;
    }
    
    @Autowired
    public void setAlertMapper(AlertMapper alertMapper) {
        DeviceWebSocketServer.alertMapper = alertMapper;
    }
    
    @OnOpen
    public void onOpen(Session session) {
        String deviceCode = getQueryParam(session, "deviceCode");
        String deviceSecret = getQueryParam(session, "deviceSecret");
        
        DeviceSessionInfo sessionInfo = new DeviceSessionInfo(session);
        SESSIONS.put(session.getId(), sessionInfo);
        
        // 如果URL参数中有deviceCode和deviceSecret，立即验证
        if (deviceCode != null && deviceSecret != null) {
            if (authenticateDevice(session, deviceCode, deviceSecret, sessionInfo)) {
                // 认证成功，发送auth_ack消息，提示设备启动心跳
                Map<String, Object> authResponse = new HashMap<>();
                authResponse.put("authenticated", true);
                authResponse.put("heartbeatInterval", 60); // 建议心跳间隔（秒），设备收到后应立即启动心跳定时器
                sendMessage(session, createMessage("auth_ack", authResponse));
                log.info("Device WS connected and authenticated via URL params, sessionId={}, deviceCode={}", 
                        session.getId(), deviceCode);
            } else {
                closeSession(session, "Authentication failed");
                return;
            }
        } else {
            log.info("Device WS connected, waiting for auth message, sessionId={}, deviceCode={}", 
                    session.getId(), deviceCode);
        }
    }
    
    @OnMessage
    public void onMessage(String message, Session session) {
        DeviceSessionInfo sessionInfo = SESSIONS.get(session.getId());
        if (sessionInfo == null) {
            log.warn("Session not found, sessionId={}", session.getId());
            return;
        }
        
        try {
            Map<String, Object> msg = JSONUtil.parseObj(message);
            String type = (String) msg.get("type");
            
            if (type == null) {
                sendError(session, "INVALID_MESSAGE", "消息类型不能为空");
                return;
            }
            
            // 处理认证消息
            if ("auth".equals(type)) {
                handleAuthMessage(session, msg, sessionInfo);
                return;
            }
            
            // 未认证的消息（除了auth）需要先认证
            if (!sessionInfo.authenticated) {
                sendError(session, "UNAUTHORIZED", "请先进行设备认证");
                return;
            }
            
            // 更新最后消息时间
            sessionInfo.lastHeartbeatTime = LocalDateTime.now();
            
            // 处理不同类型的消息
            switch (type) {
                case "heartbeat":
                    handleHeartbeat(session, msg, sessionInfo);
                    break;
                case "status_report":
                    handleStatusReport(session, msg, sessionInfo);
                    break;
                case "command_received":
                    handleCommandReceived(session, msg, sessionInfo);
                    break;
                case "command_result":
                    handleCommandResult(session, msg, sessionInfo);
                    break;
                case "config_sync_confirm":
                    handleConfigSyncConfirm(session, msg, sessionInfo);
                    break;
                case "alert_report":
                    handleAlertReport(session, msg, sessionInfo);
                    break;
                case "ping":
                    sendMessage(session, createMessage("pong", null));
                    break;
                default:
                    log.warn("Unknown message type: {}, sessionId={}", type, session.getId());
                    sendError(session, "UNKNOWN_MESSAGE_TYPE", "未知的消息类型: " + type);
            }
        } catch (Exception e) {
            log.error("Error processing message, sessionId={}", session.getId(), e);
            sendError(session, "PROCESSING_ERROR", "消息处理失败: " + e.getMessage());
        }
    }
    
    @OnClose
    public void onClose(Session session) {
        DeviceSessionInfo sessionInfo = SESSIONS.remove(session.getId());
        if (sessionInfo != null && sessionInfo.deviceCode != null) {
            DEVICE_SESSIONS.remove(sessionInfo.deviceCode);
            
            // 更新设备WebSocket连接状态
            if (deviceMapper != null && sessionInfo.deviceId != null) {
                Device device = deviceMapper.selectDeviceById(sessionInfo.deviceId);
                if (device != null) {
                    device.setWsConnected(0);
                    device.setWsSessionId(null);
                    // 标记为离线
                    device.setOnlineStatus(0);
                    device.setStatus("offline");
                    device.setUpdatedAt(LocalDateTime.now());
                    deviceMapper.updateDevice(device);
                    
                    // 通知前端监控页面设备断开/状态变化
                    try {
                        Map<String, Object> statusChange = new HashMap<>();
                        statusChange.put("deviceId", device.getId());
                        statusChange.put("deviceCode", device.getDeviceCode());
                        statusChange.put("status", device.getStatus());
                        statusChange.put("onlineStatus", device.getOnlineStatus());
                        statusChange.put("wsConnected", device.getWsConnected());
                        statusChange.put("wsSessionId", device.getWsSessionId());
                        statusChange.put("updatedAt", device.getUpdatedAt());
                        MonitorWebSocketServer.broadcastStatus("device_status_change", statusChange);
                    } catch (Exception e) {
                        log.warn("Failed to broadcast device status change on close, deviceCode={}", sessionInfo.deviceCode, e);
                    }
                }
            }
            
            log.info("Device WS closed, sessionId={}, deviceCode={}", session.getId(), sessionInfo.deviceCode);
        } else {
            log.info("Device WS closed, sessionId={}", session.getId());
        }
    }
    
    @OnError
    public void onError(Session session, Throwable error) {
        log.error("Device WS error, sessionId={}", session == null ? "n/a" : session.getId(), error);
    }
    
    /**
     * 处理认证消息
     */
    private void handleAuthMessage(Session session, Map<String, Object> msg, DeviceSessionInfo sessionInfo) {
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> data = (Map<String, Object>) msg.get("data");
            if (data == null) {
                sendError(session, "INVALID_AUTH", "认证数据不能为空");
                return;
            }
            
            String deviceCode = (String) data.get("deviceCode");
            String deviceSecret = (String) data.get("deviceSecret");
            
            if (deviceCode == null || deviceSecret == null) {
                sendError(session, "INVALID_AUTH", "设备编码和设备密钥不能为空");
                return;
            }
            
            if (authenticateDevice(session, deviceCode, deviceSecret, sessionInfo)) {
                Map<String, Object> authResponse = new HashMap<>();
                authResponse.put("authenticated", true);
                authResponse.put("heartbeatInterval", 60); // 建议心跳间隔（秒），设备收到后应立即启动心跳定时器
                sendMessage(session, createMessage("auth_ack", authResponse));
                log.info("Device authenticated via message, sessionId={}, deviceCode={}", 
                        session.getId(), deviceCode);
            } else {
                sendError(session, "AUTH_FAILED", "设备认证失败");
            }
        } catch (Exception e) {
            log.error("Error handling auth message, sessionId={}", session.getId(), e);
            sendError(session, "AUTH_ERROR", "认证处理失败: " + e.getMessage());
        }
    }
    
    /**
     * 认证设备
     */
    private boolean authenticateDevice(Session session, String deviceCode, String deviceSecret, 
                                       DeviceSessionInfo sessionInfo) {
        if (deviceAuthService == null) {
            log.error("DeviceAuthService is not initialized");
            return false;
        }
        
        // 验证设备凭证
        if (!deviceAuthService.validateDeviceCredentials(deviceCode, deviceSecret)) {
            return false;
        }
        
        // 查询设备信息
        Device device = deviceMapper != null ? deviceMapper.selectDeviceByCode(deviceCode) : null;
        if (device == null) {
            return false;
        }
        
        // 如果该设备已有连接，关闭旧连接
        String oldSessionId = DEVICE_SESSIONS.get(deviceCode);
        if (oldSessionId != null && !oldSessionId.equals(session.getId())) {
            DeviceSessionInfo oldSessionInfo = SESSIONS.get(oldSessionId);
            if (oldSessionInfo != null && oldSessionInfo.session != null && oldSessionInfo.session.isOpen()) {
                try {
                    oldSessionInfo.session.close(new CloseReason(CloseReason.CloseCodes.NORMAL_CLOSURE, 
                            "New connection from same device"));
                } catch (IOException e) {
                    log.error("Failed to close old session", e);
                }
            }
            SESSIONS.remove(oldSessionId);
        }
        
        // 更新会话信息
        sessionInfo.deviceCode = deviceCode;
        sessionInfo.deviceId = device.getId();
        sessionInfo.authenticated = true;
        DEVICE_SESSIONS.put(deviceCode, session.getId());
        
        // 更新设备WebSocket连接状态，并标记为在线
        device.setWsConnected(1);
        device.setWsSessionId(session.getId());
        device.setLastAuthTime(LocalDateTime.now());
        device.setOnlineStatus(1);
        device.setStatus("online");
        device.setUpdatedAt(LocalDateTime.now());
        deviceMapper.updateDevice(device);
        
        // 通知前端监控页面设备已连接/状态变化
        try {
            Map<String, Object> statusChange = new HashMap<>();
            statusChange.put("deviceId", device.getId());
            statusChange.put("deviceCode", device.getDeviceCode());
            statusChange.put("status", device.getStatus());
            statusChange.put("onlineStatus", device.getOnlineStatus());
            statusChange.put("wsConnected", device.getWsConnected());
            statusChange.put("wsSessionId", device.getWsSessionId());
            statusChange.put("lastHeartbeatTime", device.getLastHeartbeatTime());
            statusChange.put("lastAuthTime", device.getLastAuthTime());
            statusChange.put("updatedAt", device.getUpdatedAt());
            MonitorWebSocketServer.broadcastStatus("device_status_change", statusChange);
        } catch (Exception e) {
            log.warn("Failed to broadcast device status change on auth, deviceCode={}", deviceCode, e);
        }
        
        return true;
    }
    
    /**
     * 处理心跳消息
     */
    private void handleHeartbeat(Session session, Map<String, Object> msg, DeviceSessionInfo sessionInfo) {
        @SuppressWarnings("unchecked")
        Map<String, Object> data = msg.get("data") != null ? 
                (Map<String, Object>) msg.get("data") : Collections.emptyMap();
        
        Map<String, Object> response = new HashMap<>();
        response.put("received", true);
        response.put("serverTime", System.currentTimeMillis());
        response.put("nextHeartbeatInterval", 60);
        
        sendMessage(session, createMessage("heartbeat_ack", response));
        
        // 更新最后心跳时间
        sessionInfo.lastHeartbeatTime = LocalDateTime.now();
        
        // 更新设备最后心跳时间并插入心跳记录
        if (deviceMapper != null && sessionInfo.deviceId != null) {
            Device device = deviceMapper.selectDeviceById(sessionInfo.deviceId);
            if (device != null) {
                LocalDateTime now = LocalDateTime.now();
                device.setLastHeartbeatTime(now);
                device.setOnlineStatus(1);
                device.setStatus("online");
                device.setUpdatedAt(now);
                deviceMapper.updateDevice(device);
                
                // 插入心跳记录到数据库（与HTTP方式保持一致）
                DeviceHeartbeat heartbeat = new DeviceHeartbeat();
                heartbeat.setDeviceId(device.getId());
                heartbeat.setHeartbeatTime(now);
                // 从消息数据中提取IP地址
                @SuppressWarnings("unchecked")
                Map<String, Object> extraData = data.get("extraData") != null ? 
                        (Map<String, Object>) data.get("extraData") : Collections.emptyMap();
                if (extraData.get("ipAddress") != null) {
                    heartbeat.setIpAddress(String.valueOf(extraData.get("ipAddress")));
                }
                // 保存额外数据
                if (!extraData.isEmpty()) {
                    heartbeat.setExtraData(JSONUtil.toJsonStr(extraData));
                }
                heartbeat.setCreatedAt(now);
                deviceMapper.insertHeartbeat(heartbeat);
                
                // 通知前端监控页面设备状态更新（心跳）
                try {
                    Map<String, Object> heartbeatStatus = new HashMap<>();
                    heartbeatStatus.put("deviceId", device.getId());
                    heartbeatStatus.put("deviceCode", device.getDeviceCode());
                    heartbeatStatus.put("onlineStatus", device.getOnlineStatus());
                    heartbeatStatus.put("lastHeartbeatTime", device.getLastHeartbeatTime());
                    heartbeatStatus.put("status", device.getStatus());
                    MonitorWebSocketServer.broadcastStatus("device_status_update", heartbeatStatus);
                } catch (Exception e) {
                    log.warn("Failed to broadcast device heartbeat status, deviceId={}", device.getId(), e);
                }
            }
        }
    }
    
    /**
     * 处理状态上报消息
     */
    private void handleStatusReport(Session session, Map<String, Object> msg, DeviceSessionInfo sessionInfo) {
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> data = (Map<String, Object>) msg.get("data");
            if (data == null) {
                sendError(session, "INVALID_DATA", "状态数据不能为空");
                return;
            }
            
            // 构建DeviceStatusReportDTO
            DeviceStatusReportDTO dto = new DeviceStatusReportDTO();
            dto.setDeviceCode(sessionInfo.deviceCode);
            dto.setDeviceSecret(""); // WebSocket已认证，不需要再次验证
            dto.setStatusType((String) data.get("statusType"));
            
            // 门禁相关状态字段
            if (data.get("doorStatus") != null) {
                dto.setDoorStatus(String.valueOf(data.get("doorStatus")));
            }
            if (data.get("doorControllerStatus") != null) {
                dto.setDoorControllerStatus(String.valueOf(data.get("doorControllerStatus")));
            }
            @SuppressWarnings("unchecked")
            Map<String, Object> customData = (Map<String, Object>) data.get("customData");
            dto.setCustomData(customData);
            
            String reportTime = (String) data.get("reportTime");
            if (reportTime == null || reportTime.isEmpty()) {
                reportTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            }
            dto.setReportTime(reportTime);
            
            // 调用DeviceApiService处理状态上报（使用内部方法，跳过认证验证）
            StatusReportResponseVO responseVO = null;
            if (deviceApiService != null) {
                try {
                    responseVO = deviceApiService.handleStatusReportInternal(dto);
                } catch (Exception e) {
                    log.error("Error processing status report via WebSocket, deviceCode={}", 
                            sessionInfo.deviceCode, e);
                    sendError(session, "PROCESSING_ERROR", "状态上报处理失败: " + e.getMessage());
                    return;
                }
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("received", true);
            response.put("statusId", responseVO != null ? responseVO.getStatusId() : System.currentTimeMillis());
            
            sendMessage(session, createMessage("status_report_ack", response));
            
            // 额外广播：把门禁/状态变化推送到监控通道，确保前端实时更新
            try {
                Device device = deviceMapper.selectDeviceByCode(sessionInfo.deviceCode);
                if (device != null) {
                    Map<String, Object> statusUpdate = new HashMap<>();
                    statusUpdate.put("deviceId", device.getId());
                    statusUpdate.put("deviceCode", device.getDeviceCode());
                    statusUpdate.put("onlineStatus", device.getOnlineStatus());
                    statusUpdate.put("status", device.getStatus());
                    statusUpdate.put("lastHeartbeatTime", device.getLastHeartbeatTime());
                    // 包含上报中的门禁字段（如果存在）
                    if (dto.getDoorStatus() != null) {
                        statusUpdate.put("doorStatus", dto.getDoorStatus());
                    }
                    if (dto.getDoorControllerStatus() != null) {
                        statusUpdate.put("doorControllerStatus", dto.getDoorControllerStatus());
                    }
                    statusUpdate.put("statusId", response.get("statusId"));
                    MonitorWebSocketServer.broadcastStatus("device_status_update", statusUpdate);
                }
            } catch (Exception e) {
                log.warn("Failed to broadcast status_report update, deviceCode={}", sessionInfo.deviceCode, e);
            }
        } catch (Exception e) {
            log.error("Error handling status report, sessionId={}", session.getId(), e);
            sendError(session, "PROCESSING_ERROR", "状态上报处理失败: " + e.getMessage());
        }
    }
    
    /**
     * 处理命令接收确认
     */
    private void handleCommandReceived(Session session, Map<String, Object> msg, DeviceSessionInfo sessionInfo) {
        // TODO: 实现命令接收确认处理逻辑
        log.info("Command received acknowledged, sessionId={}, deviceCode={}", 
                session.getId(), sessionInfo.deviceCode);
    }
    
    /**
     * 处理命令执行结果
     */
    private void handleCommandResult(Session session, Map<String, Object> msg, DeviceSessionInfo sessionInfo) {
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> data = (Map<String, Object>) msg.get("data");
            if (data == null) {
                sendError(session, "INVALID_DATA", "命令结果数据不能为空");
                return;
            }
            
            Object commandLogIdObj = data.get("commandLogId");
            if (commandLogIdObj == null) {
                sendError(session, "INVALID_DATA", "命令日志ID不能为空");
                return;
            }
            
            Long commandLogId = Long.valueOf(commandLogIdObj.toString());
            
            // 构建CommandResultDTO
            CommandResultDTO dto = new CommandResultDTO();
            dto.setDeviceCode(sessionInfo.deviceCode);
            dto.setDeviceSecret(""); // WebSocket已认证，不需要再次验证
            
            // 安全处理 status 字段（可能为 JSONNull）
            Object statusObj = data.get("status");
            dto.setStatus(statusObj != null && !(statusObj instanceof cn.hutool.json.JSONNull) ? 
                    String.valueOf(statusObj) : null);
            
            @SuppressWarnings("unchecked")
            Map<String, Object> responseData = (Map<String, Object>) data.get("responseData");
            dto.setResponseData(responseData);
            
            // 安全处理 errorMessage 字段（可能为 JSONNull）
            Object errorMessageObj = data.get("errorMessage");
            dto.setErrorMessage(errorMessageObj != null && !(errorMessageObj instanceof cn.hutool.json.JSONNull) ? 
                    String.valueOf(errorMessageObj) : null);
            
            Object durationObj = data.get("duration");
            if (durationObj != null && !(durationObj instanceof cn.hutool.json.JSONNull)) {
                dto.setDuration(Integer.valueOf(durationObj.toString()));
            }
            
            // 调用DeviceApiService处理命令结果（使用内部方法，跳过认证验证）
            if (deviceApiService != null) {
                try {
                    Map<String, Object> result = deviceApiService.reportCommandResultInternal(commandLogId, dto);
                    log.info("Command result processed via WebSocket, deviceCode={}, commandLogId={}", 
                            sessionInfo.deviceCode, commandLogId);
                } catch (Exception e) {
                    log.error("Error processing command result via WebSocket, deviceCode={}, commandLogId={}", 
                            sessionInfo.deviceCode, commandLogId, e);
                    sendError(session, "PROCESSING_ERROR", "命令结果处理失败: " + e.getMessage());
                    return;
                }
            }
        } catch (Exception e) {
            log.error("Error handling command result, sessionId={}", session.getId(), e);
            sendError(session, "PROCESSING_ERROR", "命令结果处理失败: " + e.getMessage());
        }
    }
    
    /**
     * 处理配置同步确认
     */
    private void handleConfigSyncConfirm(Session session, Map<String, Object> msg, DeviceSessionInfo sessionInfo) {
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> data = (Map<String, Object>) msg.get("data");
            if (data == null) {
                sendError(session, "INVALID_DATA", "配置同步确认数据不能为空");
                return;
            }
            
            @SuppressWarnings("unchecked")
            java.util.List<String> configKeys = (java.util.List<String>) data.get("configKeys");
            if (configKeys == null || configKeys.isEmpty()) {
                sendError(session, "INVALID_DATA", "配置键列表不能为空");
                return;
            }
            
            // 调用DeviceApiService处理配置同步确认（使用内部方法，跳过认证验证）
            if (deviceApiService != null) {
                try {
                    Map<String, Object> result = deviceApiService.confirmConfigSyncInternal(
                            sessionInfo.deviceCode, configKeys);
                    log.info("Config sync confirmed via WebSocket, deviceCode={}, configKeys={}, confirmedCount={}", 
                            sessionInfo.deviceCode, configKeys, result.get("confirmedCount"));
                } catch (Exception e) {
                    log.error("Error processing config sync confirm via WebSocket, deviceCode={}", 
                            sessionInfo.deviceCode, e);
                    sendError(session, "PROCESSING_ERROR", "配置同步确认处理失败: " + e.getMessage());
                    return;
                }
            }
        } catch (Exception e) {
            log.error("Error handling config sync confirm, sessionId={}", session.getId(), e);
            sendError(session, "PROCESSING_ERROR", "配置同步确认处理失败: " + e.getMessage());
        }
    }
    
    /**
     * 处理设备上报告警
     */
    private void handleAlertReport(Session session, Map<String, Object> msg, DeviceSessionInfo sessionInfo) {
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> data = (Map<String, Object>) msg.get("data");
            if (data == null) {
                sendError(session, "INVALID_DATA", "告警数据不能为空");
                return;
            }

            // 基本字段校验
            String deviceCode = (String) data.get("deviceCode");
            if (deviceCode == null || !deviceCode.equals(sessionInfo.deviceCode)) {
                sendError(session, "INVALID_DEVICE", "deviceCode 不匹配或为空");
                return;
            }
            String alertType = (String) data.get("alertType");
            if (alertType == null || alertType.isEmpty()) {
                sendError(session, "INVALID_DATA", "alertType 不能为空");
                return;
            }

            // 构建告警记录
            AlertRecord alert = new AlertRecord();
            // 生成告警编号（简单实现）
            String alertNo = "ALT-" + System.currentTimeMillis() + "-" + (int)(Math.random() * 10000);
            alert.setAlertNo(alertNo);
            // 如果设备ID已知，从 sessionInfo 取得
            alert.setDeviceId(sessionInfo.deviceId);
            alert.setAlertType(alertType);
            Object severityObj = data.get("severity");
            alert.setAlertLevel(severityObj != null ? String.valueOf(severityObj) : "warning");
            Object alertMessageObj = data.get("alertMessage");
            alert.setAlertMessage(alertMessageObj != null ? String.valueOf(alertMessageObj) : null);
            Object alertDataObj = data.get("alertData");
            if (alertDataObj != null) {
                alert.setAlertData(JSONUtil.toJsonStr(alertDataObj));
            }
            // alertTime 解析
            String alertTimeStr = (String) data.get("alertTime");
            if (alertTimeStr != null && !alertTimeStr.isEmpty()) {
                try {
                    alert.setAlertTime(LocalDateTime.parse(alertTimeStr, DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
                } catch (Exception ignore) {
                    alert.setAlertTime(LocalDateTime.now());
                }
            } else {
                alert.setAlertTime(LocalDateTime.now());
            }
            alert.setStatus("pending");

            // 写入数据库
            if (alertMapper != null) {
                try {
                    alertMapper.insertAlert(alert);
                } catch (Exception e) {
                    log.error("Failed to insert alert_record, deviceCode={}, error={}", sessionInfo.deviceCode, e.getMessage(), e);
                    sendError(session, "DB_ERROR", "写入告警失败: " + e.getMessage());
                    return;
                }
            } else {
                log.error("AlertMapper not initialized");
                sendError(session, "SERVER_ERROR", "告警处理器未初始化");
                return;
            }

            // 发送 ack 给设备
            Map<String, Object> ack = new HashMap<>();
            ack.put("received", true);
            ack.put("alertId", alert.getId());
            ack.put("status", "stored");
            sendMessage(session, createMessage("alert_ack", ack));

            // 推送到前端告警通道
            try {
                Map<String, Object> push = new HashMap<>();
                push.put("alertId", alert.getId());
                push.put("alertNo", alert.getAlertNo());
                push.put("deviceId", alert.getDeviceId());
                push.put("deviceCode", sessionInfo.deviceCode);
                push.put("alertLevel", alert.getAlertLevel());
                push.put("alertType", alert.getAlertType());
                push.put("alertMessage", alert.getAlertMessage());
                push.put("alertData", alert.getAlertData() != null ? JSONUtil.parseObj(alert.getAlertData()) : null);
                push.put("alertTime", alert.getAlertTime());
                com.distributed.monitor.websocket.AlertWebSocketServer.broadcastAlert(push);
            } catch (Exception e) {
                log.warn("Failed to broadcast alert to frontend, alertId={}, deviceCode={}", alert.getId(), sessionInfo.deviceCode, e);
            }
        } catch (Exception e) {
            log.error("Error handling alert report, sessionId={}", session.getId(), e);
            sendError(session, "PROCESSING_ERROR", "告警上报处理失败: " + e.getMessage());
        }
    }
    
    /**
     * 向设备发送命令
     */
    public static void sendCommand(String deviceCode, Map<String, Object> commandData) {
        String sessionId = DEVICE_SESSIONS.get(deviceCode);
        if (sessionId == null) {
            log.warn("Device not connected, deviceCode={}", deviceCode);
            return;
        }
        
        DeviceSessionInfo sessionInfo = SESSIONS.get(sessionId);
        if (sessionInfo == null || sessionInfo.session == null || !sessionInfo.session.isOpen()) {
            log.warn("Device session not found or closed, deviceCode={}", deviceCode);
            DEVICE_SESSIONS.remove(deviceCode);
            return;
        }
        
        sendMessage(sessionInfo.session, createMessage("command", commandData));
    }
    
    /**
     * 向设备推送配置更新
     */
    public static void pushConfig(String deviceCode, Map<String, Object> configData) {
        String sessionId = DEVICE_SESSIONS.get(deviceCode);
        if (sessionId == null) {
            log.warn("Device not connected, deviceCode={}", deviceCode);
            return;
        }
        
        DeviceSessionInfo sessionInfo = SESSIONS.get(sessionId);
        if (sessionInfo == null || sessionInfo.session == null || !sessionInfo.session.isOpen()) {
            log.warn("Device session not found or closed, deviceCode={}", deviceCode);
            DEVICE_SESSIONS.remove(deviceCode);
            return;
        }
        
        sendMessage(sessionInfo.session, createMessage("config_update", configData));
    }
    
    /**
     * 向设备发送错误通知
     */
    public static void sendErrorNotification(String deviceCode, String errorCode, String errorMessage) {
        String sessionId = DEVICE_SESSIONS.get(deviceCode);
        if (sessionId == null) {
            log.warn("Device not connected, deviceCode={}", deviceCode);
            return;
        }
        
        DeviceSessionInfo sessionInfo = SESSIONS.get(sessionId);
        if (sessionInfo == null || sessionInfo.session == null || !sessionInfo.session.isOpen()) {
            log.warn("Device session not found or closed, deviceCode={}", deviceCode);
            DEVICE_SESSIONS.remove(deviceCode);
            return;
        }
        
        Map<String, Object> errorData = new HashMap<>();
        errorData.put("errorCode", errorCode);
        errorData.put("errorMessage", errorMessage);
        errorData.put("deviceCode", deviceCode);
        
        sendMessage(sessionInfo.session, createMessage("error", errorData));
    }
    
    /**
     * 创建标准消息格式
     */
    private static Map<String, Object> createMessage(String type, Map<String, Object> data) {
        Map<String, Object> message = new java.util.HashMap<>();
        message.put("type", type);
        message.put("timestamp", System.currentTimeMillis());
        if (data != null) {
            message.put("data", data);
        }
        return message;
    }
    
    /**
     * 发送消息
     */
    private static void sendMessage(Session session, Map<String, Object> message) {
        try {
            if (session != null && session.isOpen()) {
                session.getBasicRemote().sendText(JSONUtil.toJsonStr(message));
            }
        } catch (Exception e) {
            log.error("Failed to send message to session {}", session == null ? "n/a" : session.getId(), e);
        }
    }
    
    /**
     * 发送错误消息
     */
    private void sendError(Session session, String errorCode, String errorMessage) {
        Map<String, Object> errorData = new HashMap<>();
        errorData.put("errorCode", errorCode);
        errorData.put("errorMessage", errorMessage);
        sendMessage(session, createMessage("error", errorData));
    }
    
    /**
     * 关闭会话
     */
    private void closeSession(Session session, String reason) {
        try {
            if (session != null && session.isOpen()) {
                session.close(new CloseReason(CloseReason.CloseCodes.CANNOT_ACCEPT, reason));
            }
        } catch (IOException e) {
            log.error("Failed to close session", e);
        }
    }
    
    /**
     * 获取查询参数
     */
    private String getQueryParam(Session session, String key) {
        try {
            return session.getRequestParameterMap()
                    .getOrDefault(key, Collections.emptyList())
                    .stream()
                    .findFirst()
                    .orElse(null);
        } catch (Exception e) {
            return null;
        }
    }
    
    /**
     * 获取当前在线设备数
     */
    public static int getOnlineDeviceCount() {
        return DEVICE_SESSIONS.size();
    }
    
    /**
     * 检查设备是否在线
     */
    public static boolean isDeviceOnline(String deviceCode) {
        return DEVICE_SESSIONS.containsKey(deviceCode);
    }
}

