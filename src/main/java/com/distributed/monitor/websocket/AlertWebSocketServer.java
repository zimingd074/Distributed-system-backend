package com.distributed.monitor.websocket;

import com.distributed.monitor.util.JwtUtil;
import cn.hutool.json.JSONUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import javax.websocket.*;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.Collections;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 告警推送 WebSocket
 * 对应接口设计中的 /ws/alerts。
 */
@Component
@ServerEndpoint("/ws/alerts")
@Slf4j
public class AlertWebSocketServer {

    /**
     * key: sessionId, value: session
     */
    private static final Map<String, Session> SESSIONS = new ConcurrentHashMap<>();

    @OnOpen
    public void onOpen(Session session) {
        String token = getQueryParam(session, "token");
        
        // 验证Token
        if (token == null || token.isEmpty() || !JwtUtil.validateToken(token)) {
            log.warn("Alerts WS connection rejected: invalid token, sessionId={}", session.getId());
            try {
                session.close(new CloseReason(CloseReason.CloseCodes.CANNOT_ACCEPT, "Invalid token"));
            } catch (IOException e) {
                log.error("Failed to close session", e);
            }
            return;
        }
        
        SESSIONS.put(session.getId(), session);
        log.info("Alerts WS connected, sessionId={}, userId={}", session.getId(), JwtUtil.getUserIdFromToken(token));
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        if (message != null && "ping".equalsIgnoreCase(message.trim())) {
            safeSend(session, "{\"type\":\"pong\"}");
            return;
        }
        log.debug("Alerts WS message, sessionId={}, body={}", session.getId(), message);
    }

    @OnClose
    public void onClose(Session session) {
        SESSIONS.remove(session.getId());
        log.info("Alerts WS closed, sessionId={}", session.getId());
    }

    @OnError
    public void onError(Session session, Throwable error) {
        log.error("Alerts WS error, sessionId={}", session == null ? "n/a" : session.getId(), error);
    }

    /**
     * 推送告警消息给所有订阅者。
     * 
     * @param data 告警数据
     */
    public static void broadcastAlert(Object data) {
        // 如果已经是符合文档格式的Map，直接使用；否则包装为标准格式
        if (data instanceof Map) {
            Map<?, ?> map = (Map<?, ?>) data;
            // 如果已经包含type、timestamp、data字段，直接使用
            if (map.containsKey("type") && map.containsKey("timestamp") && map.containsKey("data")) {
                broadcast(data, SESSIONS, "alerts");
                return;
            }
        }
        // 否则包装为标准格式
        Map<String, Object> message = new java.util.HashMap<>();
        message.put("type", "new_alert");
        message.put("timestamp", System.currentTimeMillis());
        message.put("data", data);
        broadcast(message, SESSIONS, "alerts");
    }

    /**
     * 当前在线连接数。
     */
    public static int onlineCount() {
        return SESSIONS.size();
    }

    private static void broadcast(Object payload, Map<String, Session> sessions, String channelName) {
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

