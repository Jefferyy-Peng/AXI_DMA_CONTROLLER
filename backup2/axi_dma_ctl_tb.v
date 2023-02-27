`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/25 17:45:07
// Design Name: 
// Module Name: axi_dma_ctl_tb
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

module test;

    parameter integer ADDR_WD = 32;
    parameter integer BUS_SIZE = 32;
    parameter CMD_SIZE = 3'b010;

    reg clk;
    reg rst;
    reg cmd_valid;
    reg [ADDR_WD-1 : 0] cmd_src_addr;
    reg [ADDR_WD-1 : 0] cmd_dst_addr;
    reg [1:0] cmd_burst;
    reg [ADDR_WD-1 : 0] cmd_len;
    reg [2:0] cmd_size;
    wire cmd_ready;
    // wire M_AXI_ARVALID;
    // wire M_AXI_ARADDR;
    // wire M_AXI_ARLEN;
    // wire M_AXI_ARSIZE;
    // wire M_AXI_ARBURST;
    // reg M_AXI_ARREADY;
    // reg M_AXI_RVALID;
    // reg M_AXI_RDATA;
    // reg M_AXI_RRESP;
    // reg M_AXI_RLAST;
    // wire M_AXI_RREADY;
    // wire M_AXI_AWVALID;
    // wire M_AXI_AWADDR;
    // wire M_AXI_AWLEN;
    // wire M_AXI_AWSIZE;
    // wire M_AXI_AWBURST;
    // reg M_AXI_AWREADY;
    // wire M_AXI_WVALID;
    // wire M_AXI_WDATA;
    // wire M_AXI_WSTRB;
    // wire M_AXI_WLAST;
    // reg M_AXI_WREADY;
    // reg M_AXI_BVALID;
    // reg M_AXI_BRESP;
    // wire M_AXI_BREADY;

    // reg  [DATA_WD - 1:0] mem [2**ADDR_WD - 1:0]; 
    // reg                  r_s_ar_ready;
    // reg                  r_s_aw_ready;

    parameter FIXED = 'd0;
    parameter INCR  = 'd1;
    parameter WRAP  = 'd2;

  
  // Instantiate design under test
  top #(
    .ADDR_WD(ADDR_WD),
    .DATA_WD(BUS_SIZE)
  )DUT(
    .clk(clk),
    .rst(rst),
    .cmd_valid(cmd_valid), 
    .cmd_src_addr(cmd_src_addr), 
    .cmd_dst_addr(cmd_dst_addr),
    .cmd_burst(cmd_burst),
    .cmd_len(cmd_len),
    .cmd_size(cmd_size),
    .cmd_ready(cmd_ready)
    // .M_AXI_ARVALID(M_AXI_ARVALID),
    // .M_AXI_ARADDR(M_AXI_ARADDR),
    // .M_AXI_ARLEN(M_AXI_ARLEN),
    // .M_AXI_ARSIZE(M_AXI_ARSIZE),
    // .M_AXI_ARBURST(M_AXI_ARBURST),
    // .M_AXI_ARREADY(M_AXI_ARREADY),
    // .M_AXI_RVALID(M_AXI_RVALID),
    // .M_AXI_RDATA(M_AXI_RDATA),
    // .M_AXI_RRESP(M_AXI_RRESP),
    // .M_AXI_RLAST(M_AXI_RLAST),
    // .M_AXI_RREADY(M_AXI_RREADY),
    // .M_AXI_AWVALID(M_AXI_AWVALID),
    // .M_AXI_AWADDR(M_AXI_AWADDR),
    // .M_AXI_AWLEN(M_AXI_AWLEN),
    // .M_AXI_AWSIZE(M_AXI_AWSIZE),
    // .M_AXI_AWBURST(M_AXI_AWBURST),
    // .M_AXI_AWREADY(M_AXI_AWREADY),
    // .M_AXI_WVALID(M_AXI_WVALID),
    // .M_AXI_WDATA(M_AXI_WDATA),
    // .M_AXI_WSTRB(M_AXI_WSTRB),
    // .M_AXI_WLAST(M_AXI_WLAST),
    // .M_AXI_WREADY(M_AXI_WREADY),
    // .M_AXI_BVALID(M_AXI_BVALID),
    // .M_AXI_BRESP(M_AXI_BRESP),
    // .M_AXI_BREADY(M_AXI_BREADY)
    );

initial begin   
    clk = 0;
    forever #5 clk = ~clk;
end
          
  initial begin
    // Dump waves
    // $dumpfile("dump.vcd");
    // $dumpvars(1);

    clk = 0;
    rst = 0;

    #100;
    rst = 1;
    #20;
    rst = 0;
    cmd_src_addr = 32'd128;
    cmd_dst_addr = 32'd512;
    cmd_valid = 1;
    cmd_burst = INCR;
    cmd_len   = 32;
    cmd_size  = 3'b000;
    #20;
    cmd_valid = 0;
    cmd_src_addr = 0;
    cmd_dst_addr = 0;
    cmd_burst = 0;
    cmd_len   = 0;
    cmd_size  = 0;
    #200;
    rst = 1;
    #20;
    rst = 0;
    cmd_src_addr = 32'd341;
    cmd_dst_addr = 32'd124;
    cmd_valid = 1;
    cmd_burst = INCR;
    cmd_len   = 1024;
    cmd_size  = 3'b010;
    #20;
    cmd_valid = 0;
    #300;




  end

//   always@( posedge clk ) begin
//     if(rst) begin
//       for(int i = 0; i < 2**ADDR_WD; i++) begin
//         mem[i] <= i;
//       end
//     end
//     else begin
//       for(int i = 0; i < 2**ADDR_WD; i++) begin
//         mem[i] <= mem[i];
//       end
//     end
//   end

  // always@( posedge clk ) begin
  //   if(r_s_ar_ready) begin
  //     M_AXI_ARREADY <= 1; 
  //   end
  //   else begin
  //     M_AXI_ARREADY <= 0; 
  //   end
  // end
    
  // always@( posedge clk ) begin
  //   if(r_s_aw_ready) begin
  //     M_AXI_AWREADY <= 1; 
  //   end
  //   else begin
  //     M_AXI_AWREADY <= 0; 
  //   end
  // end
  
  // task display;
  //   #1 $display("d:%0h, q:%0h, qb:%0h",
  //     d, q, qb);
  // endtask

endmodule