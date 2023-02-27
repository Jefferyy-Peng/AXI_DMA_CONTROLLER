`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/26 17:38:38
// Design Name: 
// Module Name: ram
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


module ram#(
    parameter ADDR_WD = 32,
    parameter DATA_WD = 32,
    localparam DATA_WD_BYTE = DATA_WD / 8,
    localparam STRB_WD =  DATA_WD / 8
)(
    input wire                      clk,
    input wire                      rst,
    input wire [ADDR_WD - 1 : 0] mem_addr,
    input wire [DATA_WD - 1 : 0] mem_write_data,
    input wire [STRB_WD - 1 : 0] strobe,
    input wire mem_en,
    input wire mem_rh_wl,
    output wire [DATA_WD - 1 : 0] mem_read_data
    );
reg  [7:0] mem [0 : 8**12 - 1]; 

    /********************** mem initialize ***************************/
always@(posedge clk) begin
    if(rst) begin
        for(integer i = 0; i < 2**12; i = i + 1) begin
            mem[i] <= i;
        end
    end
    else begin
        for(integer i = 0; i < 2**12; i = i + 1) begin
            mem[i] <= mem[i];
        end
    end
end
/********************** mem read write ***************************/

always@(posedge clk)
    if(!mem_rh_wl) 
        mem[mem_addr] <= mem_en ? mem_write_data : mem[mem_addr];
    else 
        mem[mem_addr] <= mem[mem_addr];

//ram核心读
always@(posedge clk)
    if(mem_rh_wl)
        mem_read_data <= mem[mem_addr] ;  
    else 
        mem_read_data <= mem_read_data   ;

//ram地址
always@(posedge clk)
    if(rst || S_AXI_WLAST || S_AXI_RLAST)
        mem_addr <= 'd0;
    else if(w_aw_active)
        mem_addr <= r_awaddr;
    else if(w_ar_active)
        mem_addr <= r_araddr;
    else if(w_w_active || (r_rvalid & S_AXI_RREADY))
        mem_addr <= mem_addr + 1;
    else 
        mem_addr <= mem_addr;

//ram写端口
always@(posedge clk)
    if(w_w_active)
        mem_write_data <= S_AXI_WDATA       ;
    else    
        mem_write_data <= mem_write_data    ;

//ram读写控制
always@(posedge clk)
    if(w_ar_active)
        mem_rh_wl <= 'd1;
    else if(w_aw_active)
        mem_rh_wl <= 'd0;
    else 
        mem_rh_wl <= mem_rh_wl;

//ram写使能
always@(posedge clk)
    if(w_w_active)
        mem_en <= 'd1;
    else
        mem_en <= 'd0;
endmodule
