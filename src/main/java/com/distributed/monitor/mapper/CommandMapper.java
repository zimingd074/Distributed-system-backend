package com.distributed.monitor.mapper;

import com.distributed.monitor.entity.DeviceCommand;
import com.distributed.monitor.entity.DeviceCommandLog;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 命令Mapper
 */
@Mapper
public interface CommandMapper {
    
    /**
     * 查询命令列表
     */
    List<DeviceCommand> selectCommandList(@Param("commandType") String commandType);
    
    /**
     * 根据命令编码查询命令
     */
    DeviceCommand selectCommandByCode(@Param("commandCode") String commandCode);
    
    /**
     * 插入命令执行记录
     */
    void insertCommandLog(@Param("log") DeviceCommandLog log);
    
    /**
     * 根据ID查询命令执行记录
     */
    DeviceCommandLog selectCommandLogById(@Param("id") Long id);
    
    /**
     * 更新命令执行记录
     */
    void updateCommandLog(@Param("log") DeviceCommandLog log);
    
    /**
     * 查询设备待执行命令
     */
    List<DeviceCommandLog> selectPendingCommands(@Param("deviceId") Long deviceId);
    
    /**
     * 统计命令执行历史数量
     */
    Long countCommandHistory(@Param("deviceId") Long deviceId);
    
    /**
     * 查询命令执行历史
     */
    List<DeviceCommandLog> selectCommandHistory(
            @Param("deviceId") Long deviceId,
            @Param("offset") int offset,
            @Param("limit") int limit);
}

