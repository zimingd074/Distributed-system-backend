package com.distributed.monitor.mapper;

import com.distributed.monitor.dto.device.DeviceQueryDTO;
import com.distributed.monitor.dto.device.DeviceStatusQueryDTO;
import com.distributed.monitor.entity.Device;
import com.distributed.monitor.entity.DeviceConfig;
import com.distributed.monitor.entity.DeviceGroup;
import com.distributed.monitor.entity.DeviceHeartbeat;
import com.distributed.monitor.entity.DeviceStatusHistory;
import com.distributed.monitor.vo.device.DeviceStatisticsVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 设备Mapper
 */
@Mapper
public interface DeviceMapper {
    
    /**
     * 统计设备数量
     */
    Long countDevices(@Param("dto") DeviceQueryDTO dto);
    
    /**
     * 查询设备列表
     */
    List<Device> selectDeviceList(
            @Param("dto") DeviceQueryDTO dto,
            @Param("offset") int offset,
            @Param("limit") int limit);
    
    /**
     * 根据ID查询设备
     */
    Device selectDeviceById(@Param("id") Long id);
    
    /**
     * 根据设备编码查询设备
     */
    Device selectDeviceByCode(@Param("deviceCode") String deviceCode);
    
    /**
     * 根据ID查询设备分组
     */
    DeviceGroup selectDeviceGroupById(@Param("id") Long id);
    
    /**
     * 检查设备编码是否存在
     */
    boolean existsByDeviceCode(@Param("deviceCode") String deviceCode);
    
    /**
     * 检查设备ID是否存在
     */
    boolean existsById(@Param("id") Long id);
    
    /**
     * 插入设备
     */
    void insertDevice(@Param("device") Device device);
    
    /**
     * 更新设备
     */
    void updateDevice(@Param("device") Device device);
    
    /**
     * 删除设备
     */
    void deleteDevice(@Param("id") Long id);
    
    /**
     * 查询设备分组列表
     */
    List<DeviceGroup> selectDeviceGroups();
    
    /**
     * 查询设备统计
     */
    DeviceStatisticsVO selectDeviceStatistics();
    
    /**
     * 查询分组统计
     */
    List<DeviceStatisticsVO.GroupStatistics> selectGroupStatistics();
    
    /**
     * 查询设备配置
     */
    List<DeviceConfig> selectDeviceConfig(@Param("id") Long id);
    
    /**
     * 查询未同步的配置
     */
    List<DeviceConfig> selectUnsyncedConfig(@Param("id") Long id);
    
    /**
     * 更新或插入配置
     */
    void updateOrInsertConfig(@Param("config") DeviceConfig config);
    
    /**
     * 标记配置为已同步
     * @param deviceId 设备ID
     * @param configKeys 配置键列表（如果为空或null，则更新该设备所有未同步的配置）
     * @param syncTime 同步时间
     */
    void markConfigAsSynced(
            @Param("deviceId") Long deviceId,
            @Param("configKeys") List<String> configKeys,
            @Param("syncTime") LocalDateTime syncTime);
    
    /**
     * 查询设备最新状态历史
     */
    DeviceStatusHistory selectDeviceLatestStatusHistory(@Param("id") Long id);
    
    /**
     * 查询设备状态历史
     */
    List<DeviceStatusHistory> selectDeviceStatusHistory(
            @Param("id") Long id,
            @Param("dto") DeviceStatusQueryDTO dto);
    
    /**
     * 批量查询设备状态历史（支持设备列表 / deviceCode / groupId 筛选），带分页
     */
    List<DeviceStatusHistory> selectDeviceStatusHistoryBulk(
            @Param("deviceIds") List<Long> deviceIds,
            @Param("deviceCode") String deviceCode,
            @Param("groupId") Long groupId,
            @Param("dto") com.distributed.monitor.dto.device.DeviceStatusBulkQueryDTO dto,
            @Param("offset") int offset,
            @Param("limit") int limit);

    /**
     * 计数（用于分页）
     */
    Long countDeviceStatusHistoryBulk(
            @Param("deviceIds") List<Long> deviceIds,
            @Param("deviceCode") String deviceCode,
            @Param("groupId") Long groupId,
            @Param("dto") com.distributed.monitor.dto.device.DeviceStatusBulkQueryDTO dto);
    
    /**
     * 查询设备心跳记录
     */
    List<com.distributed.monitor.entity.DeviceHeartbeat> selectDeviceHeartbeat(
            @Param("id") Long id,
            @Param("startTime") String startTime,
            @Param("endTime") String endTime,
            @Param("limit") Integer limit);
    
    /**
     * 插入设备心跳记录
     */
    void insertHeartbeat(@Param("heartbeat") DeviceHeartbeat heartbeat);
    
    /**
     * 插入设备状态历史记录
     */
    void insertStatusHistory(@Param("statusHistory") DeviceStatusHistory statusHistory);
}

