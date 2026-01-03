package com.distributed.monitor.service;

import com.distributed.monitor.common.PageResult;
import com.distributed.monitor.dto.command.SendCommandDTO;
import com.distributed.monitor.vo.command.CommandLogVO;
import com.distributed.monitor.vo.command.CommandVO;

import java.util.List;
import java.util.Map;

/**
 * 命令服务接口
 */
public interface CommandService {
    
    /**
     * 获取命令列表
     */
    List<CommandVO> getCommandList(String commandType);
    
    /**
     * 发送控制命令
     */
    Map<String, Object> sendCommand(Long deviceId, SendCommandDTO dto);
    
    /**
     * 获取命令执行日志
     */
    CommandLogVO getCommandLog(Long id);
    
    /**
     * 获取命令执行历史
     */
    PageResult<CommandLogVO> getCommandHistory(Long deviceId, Integer page, Integer pageSize);
}

