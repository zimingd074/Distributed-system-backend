package com.distributed.monitor.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.json.JSONUtil;
import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.dto.report.ReportGenerateDTO;
import com.distributed.monitor.entity.ReportConfig;
import com.distributed.monitor.entity.ReportGenerateLog;
import com.distributed.monitor.exception.BusinessException;
import com.distributed.monitor.exception.NotFoundException;
import com.distributed.monitor.mapper.ReportMapper;
import com.distributed.monitor.mapper.DeviceMapper;
import com.distributed.monitor.mapper.AlertMapper;
import com.distributed.monitor.mapper.CommandMapper;
import com.distributed.monitor.dto.device.DeviceStatusBulkQueryDTO;
import com.distributed.monitor.dto.device.DeviceQueryDTO;
import com.distributed.monitor.dto.alert.AlertQueryDTO;
import com.distributed.monitor.entity.Device;
import com.distributed.monitor.entity.AlertRecord;
import com.distributed.monitor.entity.DeviceCommandLog;
import com.distributed.monitor.entity.DeviceStatusHistory;
import com.distributed.monitor.util.ReportFileGenerator;
import com.distributed.monitor.service.ReportService;
import com.distributed.monitor.util.RequestUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.File;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 报表服务实现
 */
@Service
@RequiredArgsConstructor
public class ReportServiceImpl implements ReportService {
    
    private final ReportMapper reportMapper;
    private final DeviceMapper deviceMapper;
    private final AlertMapper alertMapper;
    private final CommandMapper commandMapper;
    
    @Override
    public List<Map<String, Object>> getReportConfigs() {
        List<ReportConfig> configList = reportMapper.selectReportConfigs();
        return configList.stream()
                .map(config -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", config.getId());
                    map.put("reportName", config.getReportName());
                    map.put("reportCode", config.getReportCode());
                    map.put("reportType", config.getReportType());
                    map.put("description", config.getDescription());
                    map.put("isActive", config.getIsActive() != null && config.getIsActive() == 1);
                    return map;
                })
                .collect(Collectors.toList());
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> generateReport(ReportGenerateDTO dto) {
        // 查询报表配置
        ReportConfig config = reportMapper.selectReportConfigByCode(dto.getReportCode());
        if (config == null) {
            throw new NotFoundException("报表配置不存在");
        }
        
        // normalize extension first: accept "excel"/"xlsx" -> xlsx
        String requestedFormat = dto.getFileFormat() != null ? dto.getFileFormat().trim().toLowerCase() : "xlsx";
        String ext;
        if ("excel".equals(requestedFormat) || "xlsx".equals(requestedFormat)) {
            ext = "xlsx";
        } else if ("pdf".equals(requestedFormat)) {
            ext = "pdf";
        } else {
            ext = requestedFormat;
        }

        // 创建报表生成记录
        ReportGenerateLog log = new ReportGenerateLog();
        log.setReportId(config.getId());
        log.setReportName(config.getReportName());
        // 从请求中获取当前用户ID
        Long currentUserId = RequestUtil.getCurrentUserId();
        if (currentUserId == null) {
            throw new com.distributed.monitor.exception.UnauthorizedException("未登录或Token无效");
        }
        log.setGenerateUserId(currentUserId);
        log.setParams(JSONUtil.toJsonStr(dto.getParams()));
        // 使用规范化的扩展名作为 fileFormat（存入数据库，用于下载文件名）
        log.setFileFormat(ext);
        log.setStatus("generating");
        log.setGenerateTime(LocalDateTime.now());

        // 插入生成记录
        reportMapper.insertReportGenerateLog(log);

        // 生成报表文件（同步实现）
        String tmpDir = System.getProperty("java.io.tmpdir") + File.separator + "distributed-reports";
        String fileName = config.getReportCode() + "_" + System.currentTimeMillis() + "." + ext;
        File outFile = new File(tmpDir, fileName);

        try {
            // 根据报表编码查询并组装数据
            List<String> headers;
            List<List<String>> rows;
            headers = null;
            rows = null;

            String reportCode = dto.getReportCode();
            ReportGenerateDTO.ReportParams params = dto.getParams();
            if ("DEVICE".equalsIgnoreCase(reportCode)) {
                DeviceQueryDTO dq = new DeviceQueryDTO();
                dq.setPage(1);
                dq.setPageSize(1000000);
                List<Device> devices = deviceMapper.selectDeviceList(dq, 0, 1000000);
                headers = java.util.Arrays.asList("ID", "设备编码", "设备名称", "类型", "分组ID", "IP", "端口", "MAC", "位置", "状态", "在线", "最后心跳", "注册时间");
                rows = devices.stream().map(d -> java.util.Arrays.asList(
                        d.getId() != null ? String.valueOf(d.getId()) : "",
                        d.getDeviceCode(),
                        d.getDeviceName(),
                        d.getDeviceType(),
                        d.getGroupId() != null ? String.valueOf(d.getGroupId()) : "",
                        d.getIpAddress(),
                        d.getPort() != null ? String.valueOf(d.getPort()) : "",
                        d.getMacAddress(),
                        d.getLocation(),
                        d.getStatus(),
                        d.getOnlineStatus() != null ? String.valueOf(d.getOnlineStatus()) : "",
                        d.getLastHeartbeatTime() != null ? d.getLastHeartbeatTime().toString() : "",
                        d.getRegisterTime() != null ? d.getRegisterTime().toString() : ""
                )).collect(Collectors.toList());

            } else if ("ALERT".equalsIgnoreCase(reportCode)) {
                AlertQueryDTO aq = new AlertQueryDTO();
                if (params != null) {
                    aq.setStartTime(params.getStartTime());
                    aq.setEndTime(params.getEndTime());
                }
                aq.setPage(1);
                aq.setPageSize(1000000);
                List<AlertRecord> alerts = alertMapper.selectAlertList(aq, 0, 1000000);
                headers = java.util.Arrays.asList("ID", "告警编号", "规则ID", "设备ID", "级别", "类型", "消息", "状态", "告警时间");
                rows = alerts.stream().map(a -> java.util.Arrays.asList(
                        a.getId() != null ? String.valueOf(a.getId()) : "",
                        a.getAlertNo(),
                        a.getRuleId() != null ? String.valueOf(a.getRuleId()) : "",
                        a.getDeviceId() != null ? String.valueOf(a.getDeviceId()) : "",
                        a.getAlertLevel(),
                        a.getAlertType(),
                        a.getAlertMessage(),
                        a.getStatus(),
                        a.getAlertTime() != null ? a.getAlertTime().toString() : ""
                )).collect(Collectors.toList());

            } else if ("COMMAND".equalsIgnoreCase(reportCode)) {
                // 支持按设备ID列表导出命令历史
                headers = java.util.Arrays.asList("ID", "设备ID", "命令ID", "命令编码", "参数", "执行用户", "执行时间", "状态", "响应时间", "耗时");
                rows = new java.util.ArrayList<>();
                if (params != null && params.getDeviceIds() != null && !params.getDeviceIds().isEmpty()) {
                    for (Long deviceId : params.getDeviceIds()) {
                        List<DeviceCommandLog> logs = commandMapper.selectCommandHistory(deviceId, 0, 1000000);
                        for (DeviceCommandLog l : logs) {
                            rows.add(java.util.Arrays.asList(
                                    l.getId() != null ? String.valueOf(l.getId()) : "",
                                    l.getDeviceId() != null ? String.valueOf(l.getDeviceId()) : "",
                                    l.getCommandId() != null ? String.valueOf(l.getCommandId()) : "",
                                    l.getCommandCode(),
                                    l.getCommandParams(),
                                    l.getExecuteUserId() != null ? String.valueOf(l.getExecuteUserId()) : "",
                                    l.getExecuteTime() != null ? l.getExecuteTime().toString() : "",
                                    l.getStatus(),
                                    l.getResponseTime() != null ? l.getResponseTime().toString() : "",
                                    l.getDuration() != null ? String.valueOf(l.getDuration()) : ""
                            ));
                        }
                    }
                }

            } else if ("STATUS".equalsIgnoreCase(reportCode)) {
                // 设备状态历史（支持批量）
                DeviceStatusBulkQueryDTO sbq = new DeviceStatusBulkQueryDTO();
                if (params != null) {
                    sbq.setStartTime(params.getStartTime());
                    sbq.setEndTime(params.getEndTime());
                    sbq.setDeviceIds(params.getDeviceIds());
                }
                List<DeviceStatusHistory> statusList = deviceMapper.selectDeviceStatusHistoryBulk(
                        sbq.getDeviceIds(), null, null, sbq, 0, 1000000);
                headers = java.util.Arrays.asList("ID", "设备ID", "类型", "门状态", "控制器状态", "状态值", "上报时间");
                rows = statusList.stream().map(s -> java.util.Arrays.asList(
                        s.getId() != null ? String.valueOf(s.getId()) : "",
                        s.getDeviceId() != null ? String.valueOf(s.getDeviceId()) : "",
                        s.getStatusType(),
                        s.getDoorStatus(),
                        s.getDoorControllerStatus(),
                        s.getStatusValue(),
                        s.getReportTime() != null ? s.getReportTime().toString() : ""
                )).collect(Collectors.toList());

            } else {
                throw new BusinessException("未支持的报表编码：" + reportCode);
            }

            // ensure headers/rows non-null and rows length matches headers (pad if necessary)
            if (headers == null) {
                headers = new java.util.ArrayList<>();
            }
            if (rows == null) {
                rows = new java.util.ArrayList<>();
            }
            for (int r = 0; r < rows.size(); r++) {
                List<String> row = rows.get(r);
                if (row == null) {
                    row = new java.util.ArrayList<>();
                    rows.set(r, row);
                }
                while (row.size() < headers.size()) {
                    row.add("");
                }
            }

            // 生成文件
            if ("xlsx".equalsIgnoreCase(ext)) {
                ReportFileGenerator.generateExcel(headers, rows, outFile);
            } else if ("pdf".equalsIgnoreCase(ext)) {
                ReportFileGenerator.generatePdf(headers, rows, outFile);
            } else {
                throw new BusinessException("不支持的文件格式：" + dto.getFileFormat());
            }

            // 更新日志
            log.setFilePath(outFile.getAbsolutePath());
            log.setFileSize(outFile.length());
            log.setStatus("success");
            log.setCompleteTime(LocalDateTime.now());
            reportMapper.updateReportGenerateLog(log);

        } catch (Exception e) {
            log.setStatus("failed");
            log.setErrorMessage(e.getMessage());
            log.setCompleteTime(LocalDateTime.now());
            reportMapper.updateReportGenerateLog(log);
            throw new BusinessException("生成报表失败：" + e.getMessage());
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("reportLogId", log.getId());
        result.put("reportName", log.getReportName());
        result.put("status", log.getStatus());
        if (log.getGenerateTime() != null) {
            result.put("generateTime", log.getGenerateTime().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        } else {
            result.put("generateTime", null);
        }
        
        return result;
    }
    
    @Override
    public PageResult<Map<String, Object>> getReportLogs(
            String reportCode, String status, String startTime, String endTime,
            Integer page, Integer pageSize) {
        // 验证分页参数
        if (page == null || page < 1) {
            page = 1;
        }
        if (pageSize == null || pageSize < 1) {
            pageSize = 10;
        }
        if (pageSize > 100) {
            pageSize = 100; // 最大100
        }
        
        // 计算分页参数
        int offset = (page - 1) * pageSize;
        
        // 查询总数
        Long total = reportMapper.countReportLogs(reportCode, status, startTime, endTime);
        
        // 查询列表
        List<ReportGenerateLog> logList = reportMapper.selectReportLogs(
                reportCode, status, startTime, endTime, offset, pageSize);
        
        // 转换为Map
        List<Map<String, Object>> list = logList.stream()
                .map(log -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", log.getId());
                    map.put("reportName", log.getReportName());
                    map.put("reportCode", log.getReportCode());
                    map.put("fileFormat", log.getFileFormat());
                    map.put("fileSize", log.getFileSize());
                    map.put("status", log.getStatus());
                    if (log.getGenerateTime() != null) {
                        map.put("generateTime", log.getGenerateTime().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
                    } else {
                        map.put("generateTime", null);
                    }
                    if (log.getCompleteTime() != null) {
                        map.put("completeTime", log.getCompleteTime().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
                    } else {
                        map.put("completeTime", null);
                    }
                    map.put("errorMessage", log.getErrorMessage());
                    return map;
                })
                .collect(Collectors.toList());
        
        return new PageResult<>(total, list, page, pageSize);
    }
    
    @Override
    public ResponseEntity<Resource> downloadReport(Long id) {
        ReportGenerateLog log = reportMapper.selectReportLogById(id);
        if (log == null) {
            throw new NotFoundException("报表记录不存在");
        }
        
        if (!"success".equals(log.getStatus())) {
            throw new BusinessException("报表尚未生成完成");
        }
        
        if (log.getFilePath() == null) {
            throw new NotFoundException("报表文件路径不存在");
        }
        
        // 读取文件
        File file = new File(log.getFilePath());
        if (!file.exists()) {
            throw new NotFoundException("报表文件不存在");
        }
        
        Resource resource = new FileSystemResource(file);
        
        // 设置响应头
        HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.CONTENT_DISPOSITION, 
                "attachment; filename=\"" + log.getReportName() + "." + log.getFileFormat() + "\"");
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        
        return ResponseEntity.ok()
                .headers(headers)
                .body(resource);
    }
}

