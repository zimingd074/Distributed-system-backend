package com.distributed.monitor.common;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serializable;
import java.util.List;

/**
 * 分页响应结果
 *
 * @param <T> 数据类型
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PageResult<T> implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    /**
     * 总记录数
     */
    private Long total;
    
    /**
     * 数据列表
     */
    private List<T> rows;
    
    /**
     * 当前页码
     */
    private Integer page;
    
    /**
     * 每页记录数
     */
    private Integer pageSize;
    
    /**
     * 总页数
     */
    private Integer totalPages;
    
    public PageResult(Long total, List<T> rows) {
        this.total = total;
        this.rows = rows;
    }
    
    public PageResult(Long total, List<T> rows, Integer page, Integer pageSize) {
        this.total = total;
        this.rows = rows;
        this.page = page;
        this.pageSize = pageSize;
        this.totalPages = (int) Math.ceil((double) total / pageSize);
    }
}

