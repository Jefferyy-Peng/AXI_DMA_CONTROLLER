`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/25 17:02:22
// Design Name: 
// Module Name: axi_dma_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


 `default_nettype none
  module axi_dma_controller #(
      parameter integer ADDR_WD = 32,
      parameter integer DATA_WD = 32,
      parameter integer DATA_WD_BYTE = DATA_WD / 8,
      localparam integer STRB_WD =  DATA_WD / 8
)(
    input wire clk, 
    input wire rst,
    // DMA Command
    input  wire                 cmd_valid,
    input  wire [ADDR_WD-1 : 0] cmd_src_addr,
    input  wire [ADDR_WD-1 : 0] cmd_dst_addr,
    input  wire [1:0]           cmd_burst,
    input  wire [ADDR_WD-1 : 0] cmd_len,
    input  wire [2:0]           cmd_size,
    output wire                 cmd_ready,
    // Read Address Channel
    output wire                 M_AXI_ARVALID,
    output wire [ADDR_WD-1 : 0] M_AXI_ARADDR,
    output wire [ADDR_WD-1:0]           M_AXI_ARLEN,
    output wire [2:0]           M_AXI_ARSIZE,
    output wire [1:0]           M_AXI_ARBURST,
    input  wire                 M_AXI_ARREADY,
    // Read Response Channel
    input  wire                 M_AXI_RVALID,
    input  wire [DATA_WD-1 : 0] M_AXI_RDATA,
    input  wire [1:0]           M_AXI_RRESP,
    input  wire                 M_AXI_RLAST,
    output wire                 M_AXI_RREADY,
    // Write Address Channel
    output wire                 M_AXI_AWVALID,
    output wire [ADDR_WD-1 : 0] M_AXI_AWADDR,
    output wire [ADDR_WD-1:0]           M_AXI_AWLEN,
    output wire [2:0]           M_AXI_AWSIZE,
    output wire [1:0]           M_AXI_AWBURST,
    input  wire                 M_AXI_AWREADY,
    // Write Data Channel
    output wire                 M_AXI_WVALID,
    output wire [DATA_WD-1 : 0] M_AXI_WDATA,
    output wire [STRB_WD-1 : 0] M_AXI_WSTRB,
    output wire                 M_AXI_WLAST,
    input  wire                 M_AXI_WREADY,
    // Write Response Channel
    input  wire                 M_AXI_BVALID,
    input  wire [1:0]           M_AXI_BRESP,
    output wire                 M_AXI_BREADY
 );

    reg  [DATA_WD - 1:0] mem [0 : 256]; 

    reg   [ADDR_WD-1 : 0]     r_cmd_src_addr            ;
    reg   [ADDR_WD-1 : 0]     r_cmd_dst_addr            ;
    reg   [1:0]               r_cmd_burst               ;
    reg   [ADDR_WD-1 : 0]     r_cmd_len                 ;
    reg   [2:0]               r_cmd_size                ;
    reg                       r_cmd_ready               ;

    reg [DATA_WD - 1:0]       r_m_axi_rdata             ;
    reg                       r_m_axi_rlast             ;
    reg                       r_m_axi_rready            ;

    reg [ADDR_WD - 1:0]       r_m_axi_araddr            ;
    reg                       r_m_axi_arvalid           ;
    reg [ADDR_WD - 1:0]       r_m_axi_arlen             ;

    reg [ADDR_WD - 1:0]       r_m_axi_awaddr            ;
    reg                       r_m_axi_awvalid           ;
    reg [ADDR_WD - 1:0]       r_m_axi_awlen             ;    

    reg [DATA_WD - 1:0]       r_m_axi_wdata             ;
    reg                       r_m_axi_wlast             ;
    reg                       r_m_axi_wvalid            ; 
    reg [8:0]                 r_write_cnt               ;  
    reg [8:0]                 r_read_cnt                ;  

    reg                       r_read_start              ;
    reg                       r_write_start             ; 

    assign cmd_ready        = r_cmd_ready               ;

    assign M_AXI_ARLEN      = r_m_axi_arlen             ; //in word
    assign M_AXI_ARSIZE     = r_cmd_size                  ;
    assign M_AXI_ARBURST    = r_cmd_burst                 ;
    assign M_AXI_ARADDR     = r_m_axi_araddr            ;
    assign M_AXI_ARVALID    = r_m_axi_arvalid           ;

    assign M_AXI_AWLEN      = r_m_axi_awlen             ; //in word
    assign M_AXI_AWSIZE     = r_cmd_size                  ;
    assign M_AXI_AWBURST    = r_cmd_burst                 ;
    assign M_AXI_AWADDR     = r_m_axi_awaddr            ;
    assign M_AXI_AWVALID    = r_m_axi_awvalid           ;

    //assign M_AXI_WSTRB      = {STRB_WD{1'b1}}           ; 
    assign M_AXI_WSTRB      = {4'b1010}           ; 
    assign M_AXI_WDATA      = r_m_axi_wdata             ; 
    assign M_AXI_WLAST      = r_m_axi_wlast             ; 
    assign M_AXI_WVALID     = r_m_axi_wvalid            ; 

    assign M_AXI_BREADY     = 1'b1                      ;
    
    assign M_AXI_RREADY     = r_m_axi_rready            ;
    

/*--------------------- dma control  -------------------------*/

    always@(posedge clk) begin
        if(rst) begin
            r_cmd_src_addr <= 0; 
            r_cmd_dst_addr <= 0;
            r_cmd_burst <= 0;
            r_cmd_len <= 0;
            r_cmd_size <= 0;
            r_m_axi_awlen <= 0;
            r_m_axi_arlen <= 0;
            r_read_start <= 0;
        end
        else if(cmd_valid && cmd_ready) begin
            r_cmd_src_addr <= cmd_src_addr;
            r_cmd_dst_addr <= cmd_dst_addr;
            r_cmd_burst <= cmd_burst;
            r_cmd_len <= cmd_len;
            r_cmd_size <= cmd_size;
            r_m_axi_awlen <= cmd_len/(DATA_WD_BYTE);
            r_m_axi_arlen <= cmd_len/(DATA_WD_BYTE);
            r_read_start <= 1;
        end
        else begin
            r_cmd_src_addr <= r_cmd_src_addr;
            r_cmd_dst_addr <= r_cmd_dst_addr;
            r_cmd_burst <= r_cmd_burst;
            r_cmd_len <= r_cmd_len;
            r_cmd_size <= r_cmd_size;
            r_read_start <= 0;
            r_m_axi_awlen <= r_m_axi_awlen;
            r_m_axi_arlen <= r_m_axi_arlen;
        end
    end

    always@(posedge clk) begin
        if(rst) 
            r_cmd_ready <= 1;
        else if(cmd_valid && cmd_ready)
            r_cmd_ready <= 0;
        else if(M_AXI_BREADY && M_AXI_BVALID)
            r_cmd_ready <= 1;
        else
            r_cmd_ready <= r_cmd_ready;
    end

/*--------------------- address read -------------------------*/

    always@(posedge clk) begin
        if(rst) 
            r_m_axi_araddr <= 'd0;
        else if(r_read_start)
            r_m_axi_araddr <= r_cmd_src_addr;
        else
            r_m_axi_araddr <= r_m_axi_araddr;
    end

    always@(posedge clk) begin
        if(rst || (M_AXI_ARREADY && M_AXI_ARVALID)) 
            r_m_axi_arvalid <= 'd0;
        else if(r_read_start)
            r_m_axi_arvalid <= 'd1;
        else
            r_m_axi_arvalid <= r_m_axi_arvalid;
    end
    
/*---------------------  read -------------------------------*/

    always@(posedge clk) begin
        if(rst)
            r_m_axi_rready <= 0;
        else if(M_AXI_ARREADY && M_AXI_ARVALID)
            r_m_axi_rready <= 1;
        else
            r_m_axi_rready <= r_m_axi_rready;
    end

    always@(posedge clk) begin
        if(rst) begin
            r_read_cnt <= 0;
            for(integer i = 0; i < 256; i = i + 1) begin
                mem[i] <= 0;
            end
        end
        else if(M_AXI_RVALID && M_AXI_RREADY) begin
            r_read_cnt <= r_read_cnt + 1;
            mem[r_read_cnt] <= M_AXI_RDATA;
            r_m_axi_rdata <= M_AXI_RDATA;
        end
        else begin
            r_read_cnt <= r_read_cnt;
            mem[r_read_cnt] <= mem[r_read_cnt];
            r_m_axi_rdata <= r_m_axi_rdata;
        end
    end

/*--------------------- address write -------------------------*/
    
    always@(posedge clk) begin
        if(rst)
            r_write_start <= 0;
        else if(M_AXI_RLAST)
            r_write_start <= 1;
        else
            r_write_start <= 0;
    end

    always@(posedge clk) begin
        if(rst)
            r_m_axi_awvalid <= 0;
        else if(r_write_start)
            r_m_axi_awvalid <= 1;
        else if(M_AXI_AWREADY && M_AXI_AWVALID)
            r_m_axi_awvalid <= 0;
        else
            r_m_axi_awvalid <= r_m_axi_awvalid;
    end

    always@(posedge clk) begin
        if(rst) 
            r_m_axi_awaddr <= 0;
        else if(r_write_start)
            r_m_axi_awaddr <= r_cmd_dst_addr;
        else
            r_m_axi_awaddr <= r_m_axi_awaddr;
    end

/*--------------------- write -------------------------------*/

    always@(posedge clk) begin
        if(rst) 
            r_m_axi_wvalid <= 0;
        else if(M_AXI_AWREADY && M_AXI_AWVALID)
            r_m_axi_wvalid <= 1;
        else
            r_m_axi_wvalid <= r_m_axi_wvalid;
    end

    always@(posedge clk) begin
        if(rst || M_AXI_WLAST) begin
            r_m_axi_wdata <= 0;
            r_write_cnt <= 1;
        end
        else if(M_AXI_WREADY && M_AXI_WVALID) begin
            r_m_axi_wdata <= mem[r_write_cnt];
            r_write_cnt <= r_write_cnt + 1;
        end
        else begin
            r_m_axi_wdata <= r_m_axi_wdata;
            r_write_cnt <= r_write_cnt;
        end
    end

    always@(posedge clk) begin
        if(rst) 
            r_m_axi_wlast <= 0;
        else if(r_write_cnt == M_AXI_AWLEN)
            r_m_axi_wlast <= 1;
        else
            r_m_axi_wlast <= 0;
    end

/*--------------------- write response -----------------------*/

assign M_AXI_BREADY = 1'b1;


endmodule




