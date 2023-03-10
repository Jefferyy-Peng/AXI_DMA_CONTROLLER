# AXI_DMA_CONTROLLER

## Introduction
* This is a DMA controller implemented based on AXI interface. It is consisted by a master and a slave module
* Now only support FIXED and INCR burst mode
* Bus width and max data width in each beat is runtime configurable. It also supports AXI Narrow transfers
* Unalligned Transmit and 4K address boundary handling is not supported yet

## File structure
* src
  * axi_dma_controller.v
  * axi_slave.v
  * top.v
* sim
  * axi_dma_ctl_tb.v

## Details
### Master
  * Parameters: *ADDR_WD*, *DATA_WD*, *localparam STRB_WD = DATA_WD / 8*

| Signal        | Meaning           | Width  |
| ------------- |:-------------:| -----:|
| clk      | Global clock | 1 |
| rst      | Global reset      |   1 |
| cmd_valid | DMA command valid      |    1 |
| cmd_src_addr      | DMA source address | ADDR_WD |
| cmd_dst_addr      | DMA destination address      |   ADDR_WD |
| cmd_burst | DMA burst mode    |    2 |
| cmd_len      | burst length | ADDR_WD |
| cmd_size      | Max Beat data width      |   3 |
| cmd_ready |  DMA command ready     |    1 |
| M_AXI_ARVALID      | Address read valid | 1 |
| M_AXI_ARADDR      | Address read      |   ADDR_WD |
| M_AXI_ARLEN | burst length      |    ADDR_WD |
| M_AXI_ARSIZE      | Max Beat data width  | 3 |
| M_AXI_ARBURST      | burst mode      |   2 |
| M_AXI_ARREADY | Address read ready      |    1 |
| M_AXI_RVALID      | Read valid | 1 |
| M_AXI_RDATA      | Read data      |   DATA_WD |
| M_AXI_RRESP | read response(Default OKAY)      |    2 |
| M_AXI_RLAST      | Read terminate signal | 1 |
| R_strobe      | Read Strobe, implementing Narrow Transmit      |   STRB_WD |
| M_AXI_RREADY | Read ready      |    1 |
| M_AXI_AWVALID      | Write address valid | 1 |
| M_AXI_AWADDR      | write address      |   ADDR_WD |
| M_AXI_AWSIZE | burst length      |    3 |
| M_AXI_AWBURST | burst mode     |    2 |
| M_AXI_AWREADY | Write address ready      |    1 |
| M_AXI_WVALID | Write valid      |    1 |
| M_AXI_WDATA | Write data      |    DATA_WD |
| M_AXI_WSTRB | Write strobe      |    STRB_WD |
| M_AXI_WLAST | Write terminate signal      |    1 |
| M_AXI_WREADY | Write ready      |    1 |
| M_AXI_BVALID | Response valid      |    1 |
| M_AXI_BRESP | Response signal      |    2 |
| M_AXI_BREADY | Response ready      |    1 |


### Slave
 * Parameters: *ADDR_WD*, *DATA_WD*, *localparam STRB_WD = DATA_WD / 8*

| Singal        | Meaning           | Width  |
| ------------- |:-------------:| -----:|
| clk      | Global clock | 1 |
| rst      | Global reset      |   1 |
| S_AXI_ARVALID      | Read address valid | 1 |
| S_AXI_ARADDR      | Read address      |   ADDR_WD |
| S_AXI_ARLEN | burst length      |    ADDR_WD |
| S_AXI_ARSIZE      | Max Beat data width | 3 |
| S_AXI_ARBURST      | burst mode      |   2 |
| S_AXI_ARREADY | Read address ready      |    1 |
| S_AXI_RVALID      | Read valid | 1 |
| S_AXI_RDATA      | Read data      |   DATA_WD |
| S_AXI_RRESP | read response(Default OKAY)      |    2 |
| S_AXI_RLAST      | Read terminate signal | 1 |
| R_strobe      | Read Strobe, implementing Narrow Transmit      |   STRB_WD |
| S_AXI_RREADY | Read ready      |    1 |
| S_AXI_AWVALID      | Write address valid | 1 |
| S_AXI_AWADDR      | Write address      |   ADDR_WD |
| S_AXI_AWSIZE | burst length      |    3 |
| S_AXI_AWBURST | burst mode      |    2 |
| S_AXI_AWREADY | Write address ready      |    1 |
| S_AXI_WVALID | Write valid      |    1 |
| S_AXI_WDATA | Write data      |    DATA_WD |
| S_AXI_WSTRB | Write strobe       |    STRB_WD |
| S_AXI_WLAST | Write terminate signal      |    1 |
| S_AXI_WREADY | Write ready      |    1 |
| S_AXI_BVALID | Response valid      |    1 |
| S_AXI_BRESP | Response signal      |    2 |
| S_AXI_BREADY | Response ready      |    1 |

## Simulation

* 32 bit bus read simulation
![image](https://user-images.githubusercontent.com/123399300/221536905-4605aceb-5c4d-49f0-899d-3c886ea214c3.png)

* 32 bit bus write simulation
![image](https://user-images.githubusercontent.com/123399300/221537203-4a486177-77dd-420b-8344-ed479438b988.png)

* 64 bit bus read simulation
![image](https://user-images.githubusercontent.com/123399300/221537719-4427493f-1d6e-432f-9620-128699425ddd.png)

* 64 bit bus write simulation
![image](https://user-images.githubusercontent.com/123399300/221537885-a72f6fdb-09f0-4d9a-a86c-2a3f20a3b99a.png)

