package com.distributed.monitor.websocket;

import com.distributed.monitor.util.JwtUtil;
import javax.websocket.*;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

import cn.hutool.json.JSONUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.Collections;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 设备状态实时监控 WebSocket
 * 对应接口设计中的 /ws/monitor。
 */
@Component
@ServerEndpoint("/ws/monitor")
@Slf4j
public class MonitorWebSocketServer {

    /**
     * key: sessionId, value: session
     */
    private static final Map<String, Session> SESSIONS = new ConcurrentHashMap<>();

    @OnOpen
    public void onOpen(Session session) {
        String token = getQueryParam(session, "token");
        
        // 验证Token
        if (token == null || token.isEmpty() || !JwtUtil.validateToken(token)) {
            log.warn("Monitor WS connection rejected: invalid token, sessionId={}", session.getId());
            try {
                session.close(new CloseReason(CloseReason.CloseCodes.CANNOT_ACCEPT, "Invalid token"));
            } catch (IOException e) {
                log.error("Failed to close session", e);
            }
            return;
        }
        
        SESSIONS.put(session.getId(), session);
        log.info("Monitor WS connected, sessionId={}, userId={}", session.getId(), JwtUtil.getUserIdFromToken(token));
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        if (message != null && "ping".equalsIgnoreCase(message.trim())) {
            safeSend(session, "{\"type\":\"pong\"}");
            return;
        }
        log.debug("Monitor WS message, sessionId={}, body={}", session.getId(), message);
    }

    @OnClose
    public void onClose(Session session) {
        SESSIONS.remove(session.getId());
        log.info("Monitor WS closed, sessionId={}", session.getId());
    }

    @OnError
    public void onError(Session session, Throwable error) {
        log.error("Monitor WS error, sessionId={}", session == null ? "n/a" : session.getId(), error);
    }

    /**
     * 推送设备状态变化/更新消息给所有订阅者。
     * 
     * @param messageType 消息类型：device_status_change 或 device_status_update
     * @param data 消息数据
     */
    public static void broadcastStatus(String messageType, Object data) {
        Map<String, Object> message = new java.util.HashMap<>();
        message.put("type", messageType);
        message.put("timestamp", System.currentTimeMillis());
        message.put("data", data);
        broadcast(message, SESSIONS, "monitor");
    }
    
    /**
     * 推送设备状态变化/更新消息给所有订阅者（兼容旧方法）。
     * 
     * @param payload 消息负载（如果已经是符合文档格式的Map，则直接使用；否则包装为标准格式）
     */
    @Deprecated
    public static void broadcastStatus(Object payload) {
        if (payload instanceof Map) {
            Map<?, ?> map = (Map<?, ?>) payload;
            // 如果已经包含type、timestamp、data字段，直接使用
            if (map.containsKey("type") && map.containsKey("timestamp") && map.containsKey("data")) {
                broadcast(payload, SESSIONS, "monitor");
                return;
            }
        }
        // 否则包装为标准格式
        Map<String, Object> message = new java.util.HashMap<>();
        message.put("type", "device_status_update");
        message.put("timestamp", System.currentTimeMillis());
        message.put("data", payload);
        broadcast(message, SESSIONS, "monitor");
    }

    /**
     * 当前在线连接数。
     */
    public static int onlineCount() {
        return SESSIONS.size();
    }

    static void broadcast(Object payload, Map<String, Session> sessions, String channelName) {
        if (sessions.isEmpty()) {
            log.debug("{} channel has no active WebSocket sessions", channelName);
            return;
        }
        String json = payload instanceof String ? (String) payload : JSONUtil.toJsonStr(payload);
        int success = 0;
        int fail = 0;
        for (Session s : sessions.values()) {
            if (s != null && s.isOpen()) {
                try {
                    s.getBasicRemote().sendText(json);
                    success++;
                } catch (Exception e) {
                    log.error("Send message failed on {} channel, sessionId={}", channelName, s.getId(), e);
                    fail++;
                }
            }
        }
        log.info("Broadcast on {} done. success={}, fail={}, message={}", channelName, success, fail, json);
    }

    private static String getQueryParam(Session session, String key) {
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

    private static void safeSend(Session session, String message) {
        try {
            if (session != null && session.isOpen()) {
                session.getBasicRemote().sendText(message);
            }
        } catch (Exception e) {
            log.warn("Failed to send message to session {}", session == null ? "n/a" : session.getId(), e);
        }
    }
}

