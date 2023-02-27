# AXI_DMA_CONTROLLER

## 简介
* 基于AXI接口实现的DMA controller，包含主机，从机两个模块。
* 目前支持burst传输模式中的FIXED和INCR mode
* 可run time调整AXI总线传输长度以及单次传输最大位宽，支持AXI Narrow传输机制
* 可参数化调整总线以及数据位宽，最大数据位宽128bit
* 暂不支持地址非对齐传输以及4K地址边界处理

## 文件结构
* src
  * axi_dma_controller.v
  * axi_slave.v
  * top.v
* sim
  * axi_dma_ctl_tb.v

## 模块细节
### 主机
  * 参数： *ADDR_WD*, *DATA_WD*, *localparam STRB_WD = DATA_WD / 8*

| 信号        | 含义           | 位宽  |
| ------------- |:-------------:| -----:|
| clk      | 全局时钟 | 1 |
| rst      | 全局复位      |   1 |
| cmd_valid | DMA指令有效      |    1 |
| cmd_src_addr      | DMA指令源地址 | ADDR_WD |
| cmd_dst_addr      | DMA指令目的地址      |   ADDR_WD |
| cmd_burst | DMA指令突发传输模式    |    2 |
| cmd_len      | 突发传输 | ADDR_WD |
| cmd_size      | 单次传输最大位宽      |   3 |
| cmd_ready |  DMA指令就绪     |    1 |
| M_AXI_ARVALID      | 读地址有效 | 1 |
| M_AXI_ARADDR      | 读地址      |   ADDR_WD |
| M_AXI_ARLEN | burst长度      |    ADDR_WD |
| M_AXI_ARSIZE      | burst单次传输位宽 | 3 |
| M_AXI_ARBURST      | burst传输模式      |   2 |
| M_AXI_ARREADY | 读地址就绪      |    1 |
| M_AXI_RVALID      | 读有效 | 1 |
| M_AXI_RDATA      | 读数据      |   DATA_WD |
| M_AXI_RRESP | 读相应(默认OKAY)      |    2 |
| M_AXI_RLAST      | 读结束标志 | 1 |
| R_strobe      | 读结绳，实现Narrow机制      |   STRB_WD |
| M_AXI_RREADY | 读就绪      |    1 |
| M_AXI_AWVALID      | 写地址有效 | 1 |
| M_AXI_AWADDR      | 写地址      |   ADDR_WD |
| M_AXI_AWSIZE | burst长度      |    3 |
| M_AXI_AWBURST | burst模式      |    2 |
| M_AXI_AWREADY | 写地址就绪      |    1 |
| M_AXI_WVALID | 写有效      |    1 |
| M_AXI_WDATA | 写数据      |    DATA_WD |
| M_AXI_WSTRB | 写结绳      |    STRB_WD |
| M_AXI_WLAST | 写结束标志      |    1 |
| M_AXI_WREADY | 写就绪      |    1 |
| M_AXI_BVALID | 相应有效      |    1 |
| M_AXI_BRESP | 相应信号      |    2 |
| M_AXI_BREADY | 相应就绪      |    1 |


### 从机
 * 参数: *ADDR_WD*, *DATA_WD*, *localparam STRB_WD = DATA_WD / 8*

| 信号        | 含义           | 位宽  |
| ------------- |:-------------:| -----:|
| clk      | 全局时钟 | 1 |
| rst      | 全局复位      |   1 |
| S_AXI_ARVALID      | 读地址有效 | 1 |
| S_AXI_ARADDR      | 读地址      |   ADDR_WD |
| S_AXI_ARLEN | burst长度      |    ADDR_WD |
| S_AXI_ARSIZE      | burst单次传输位宽 | 3 |
| S_AXI_ARBURST      | burst传输模式      |   2 |
| S_AXI_ARREADY | 读地址就绪      |    1 |
| S_AXI_RVALID      | 读有效 | 1 |
| S_AXI_RDATA      | 读数据      |   DATA_WD |
| S_AXI_RRESP | 读相应(默认OKAY)      |    2 |
| S_AXI_RLAST      | 读结束标志 | 1 |
| R_strobe      | 读结绳，实现Narrow机制      |   STRB_WD |
| S_AXI_RREADY | 读就绪      |    1 |
| S_AXI_AWVALID      | 写地址有效 | 1 |
| S_AXI_AWADDR      | 写地址      |   ADDR_WD |
| S_AXI_AWSIZE | burst长度      |    3 |
| S_AXI_AWBURST | burst模式      |    2 |
| S_AXI_AWREADY | 写地址就绪      |    1 |
| S_AXI_WVALID | 写有效      |    1 |
| S_AXI_WDATA | 写数据      |    DATA_WD |
| S_AXI_WSTRB | 写结绳      |    STRB_WD |
| S_AXI_WLAST | 写结束标志      |    1 |
| S_AXI_WREADY | 写就绪      |    1 |
| S_AXI_BVALID | 相应有效      |    1 |
| S_AXI_BRESP | 相应信号      |    2 |
| S_AXI_BREADY | 相应就绪      |    1 |

## 读写仿真

* 32位总线读仿真
![image](https://user-images.githubusercontent.com/123399300/221536905-4605aceb-5c4d-49f0-899d-3c886ea214c3.png)

* 32位总线写仿真
![image](https://user-images.githubusercontent.com/123399300/221537203-4a486177-77dd-420b-8344-ed479438b988.png)

* 64位总线读仿真
![image](https://user-images.githubusercontent.com/123399300/221537719-4427493f-1d6e-432f-9620-128699425ddd.png)

* 64位总线写仿真
![image](https://user-images.githubusercontent.com/123399300/221537885-a72f6fdb-09f0-4d9a-a86c-2a3f20a3b99a.png)

