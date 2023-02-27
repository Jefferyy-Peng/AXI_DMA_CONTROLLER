`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/25 23:16:00
// Design Name: 
// Module Name: top
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
  module top #(
      parameter integer ADDR_WD = 32,
      parameter integer DATA_WD = 32,
      localparam        DATA_WD_BYTE = DATA_WD / 8,
      localparam        STRB_WD = DATA_WD / 8
      //localparam        BUS_LANES = BUS_SIZE / 8
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
    output wire                 cmd_ready
 );
// Read Address Channel
wire                 M_AXI_ARVALID;
wire [ADDR_WD-1 : 0] M_AXI_ARADDR;
wire [ADDR_WD-1:0]   M_AXI_ARLEN;
wire [2:0]           M_AXI_ARSIZE;
wire [1:0]           M_AXI_ARBURST;
wire                 M_AXI_ARREADY;
// Read Response Channel
wire                 M_AXI_RVALID;
wire [DATA_WD-1 : 0] M_AXI_RDATA;
wire [1:0]           M_AXI_RRESP;
wire                 M_AXI_RLAST;
wire                 M_AXI_RREADY;
wire [STRB_WD-1 : 0] R_strobe;
//wire [BUS_SIZE-1 :0] M_AXI_RBUS;
// Write Address Channel
wire                 M_AXI_AWVALID;
wire [ADDR_WD-1 : 0] M_AXI_AWADDR;
wire [ADDR_WD-1:0]   M_AXI_AWLEN;
wire [2:0]           M_AXI_AWSIZE;
wire [1:0]           M_AXI_AWBURST;
wire                 M_AXI_AWREADY;
// Write Data Channel
wire                 M_AXI_WVALID;
wire [DATA_WD-1 : 0] M_AXI_WDATA;
wire [STRB_WD-1 : 0] M_AXI_WSTRB;
wire                 M_AXI_WLAST;
wire                 M_AXI_WREADY;
//wire [BUS_SIZE-1: 0] M_AXI_WBUS;
// Write Response Channel
wire                 M_AXI_BVALID;
wire [1:0]           M_AXI_BRESP;
wire                 M_AXI_BREADY;

//byte lane
//wire [$clog2(BUS_LANES) - 1 : 0] AXI_BUS_LANES_SEL;

// always@(posedge clk) begin
//     if(rst)
//         AXI_BUS_LANES_SEL <= 0;
//     else 
//         AXI_BUS_LANES_SEL <= AXI_BUS_LANES_SEL + 1;
// end

 axi_dma_controller #(
    .ADDR_WD(ADDR_WD),
    .DATA_WD(DATA_WD)
 )axi_dma_ctl (
    .clk(clk),
    .rst(rst),
    .cmd_valid(cmd_valid), 
    .cmd_src_addr(cmd_src_addr), 
    .cmd_dst_addr(cmd_dst_addr),
    .cmd_burst(cmd_burst),
    .cmd_len(cmd_len),
    .cmd_size(cmd_size),
    .cmd_ready(cmd_ready),
    .M_AXI_ARVALID(M_AXI_ARVALID),
    .M_AXI_ARADDR(M_AXI_ARADDR),
    .M_AXI_ARLEN(M_AXI_ARLEN),
    .M_AXI_ARSIZE(M_AXI_ARSIZE),
    .M_AXI_ARBURST(M_AXI_ARBURST),
    .M_AXI_ARREADY(M_AXI_ARREADY),
    .M_AXI_RVALID(M_AXI_RVALID),
    .M_AXI_RDATA(M_AXI_RDATA),
    .M_AXI_RRESP(M_AXI_RRESP),
    .M_AXI_RLAST(M_AXI_RLAST),
    .M_AXI_RREADY(M_AXI_RREADY),
    .M_AXI_AWVALID(M_AXI_AWVALID),
    .M_AXI_AWADDR(M_AXI_AWADDR),
    .M_AXI_AWLEN(M_AXI_AWLEN),
    .M_AXI_AWSIZE(M_AXI_AWSIZE),
    .M_AXI_AWBURST(M_AXI_AWBURST),
    .M_AXI_AWREADY(M_AXI_AWREADY),
    .M_AXI_WVALID(M_AXI_WVALID),
    .M_AXI_WDATA(M_AXI_WDATA),
    .M_AXI_WSTRB(M_AXI_WSTRB),
    .M_AXI_WLAST(M_AXI_WLAST),
    .M_AXI_WREADY(M_AXI_WREADY),
    .M_AXI_BVALID(M_AXI_BVALID),
    .M_AXI_BRESP(M_AXI_BRESP),
    .M_AXI_BREADY(M_AXI_BREADY),
    .R_strobe(R_strobe)
    );

    axi_slave #(
    .ADDR_WD(ADDR_WD),
    .DATA_WD(DATA_WD)
    )SLAVE (
        .clk(clk),
        .rst(rst),
        .S_AXI_ARVALID(M_AXI_ARVALID),
        .S_AXI_ARADDR(M_AXI_ARADDR),
        .S_AXI_ARLEN(M_AXI_ARLEN),
        .S_AXI_ARSIZE(M_AXI_ARSIZE),
        .S_AXI_ARBURST(M_AXI_ARBURST),
        .S_AXI_ARREADY(M_AXI_ARREADY),
        .S_AXI_RVALID(M_AXI_RVALID),
        .S_AXI_RDATA(M_AXI_RDATA),
        .S_AXI_RRESP(M_AXI_RRESP),
        .S_AXI_RLAST(M_AXI_RLAST),
        .S_AXI_RREADY(M_AXI_RREADY),
        .S_AXI_AWVALID(M_AXI_AWVALID),
        .S_AXI_AWADDR(M_AXI_AWADDR),
        .S_AXI_AWLEN(M_AXI_AWLEN),
        .S_AXI_AWSIZE(M_AXI_AWSIZE),
        .S_AXI_AWBURST(M_AXI_AWBURST),
        .S_AXI_AWREADY(M_AXI_AWREADY),
        .S_AXI_WVALID(M_AXI_WVALID),
        .S_AXI_WDATA(M_AXI_WDATA),
        .S_AXI_WSTRB(M_AXI_WSTRB),
        .S_AXI_WLAST(M_AXI_WLAST),
        .S_AXI_WREADY(M_AXI_WREADY),
        .S_AXI_BVALID(M_AXI_BVALID),
        .S_AXI_BRESP(M_AXI_BRESP),
        .S_AXI_BREADY(M_AXI_BREADY),
        .R_strobe(R_strobe)
    );


endmodule