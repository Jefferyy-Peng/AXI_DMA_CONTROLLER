`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/25 21:37:46
// Design Name: 
// Module Name: axi_slave
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
module axi_slave#
	(   
        parameter ADDR_WD = 32,
        parameter DATA_WD = 32,
        localparam DATA_WD_BYTE = DATA_WD / 8,
        localparam STRB_WD =  DATA_WD / 8
	)
	(
        input wire clk, 
        input wire rst,

        // Read Address Channel
        input   wire                            S_AXI_ARVALID,
        input   wire [ADDR_WD-1 : 0]            S_AXI_ARADDR,
        input   wire [ADDR_WD-1:0]                      S_AXI_ARLEN,
        input   wire [2:0]                      S_AXI_ARSIZE,
        input   wire [1:0]                      S_AXI_ARBURST,
        output  wire                            S_AXI_ARREADY,
        // Read Response Channel
        output  wire                            S_AXI_RVALID,
        output  wire [DATA_WD-1 : 0]            S_AXI_RDATA,
        output  wire [1:0]                      S_AXI_RRESP,
        output  wire                            S_AXI_RLAST,
        output  wire [STRB_WD-1 : 0]            R_strobe,
        input   wire                            S_AXI_RREADY,
        // Write Address Channel
        input   wire                            S_AXI_AWVALID,
        input   wire [ADDR_WD-1 : 0]            S_AXI_AWADDR,
        input   wire [ADDR_WD-1:0]                      S_AXI_AWLEN,
        input   wire [2:0]                      S_AXI_AWSIZE,
        input   wire [1:0]                      S_AXI_AWBURST,
        output  wire                            S_AXI_AWREADY,
        // Write Data Channel
        input   wire                            S_AXI_WVALID,
        input   wire [DATA_WD-1 : 0]            S_AXI_WDATA,
        input   wire [STRB_WD-1 : 0]            S_AXI_WSTRB,
        input   wire                            S_AXI_WLAST,
        output  wire                            S_AXI_WREADY,
        // Write Response Channel
        output  wire                            S_AXI_BVALID,
        output  wire [1:0]                      S_AXI_BRESP,
        input   wire                            S_AXI_BREADY
);

/**********************参数***************************/

/**********************状�?�机*************************/

/**********************寄存�?*************************/


reg [ADDR_WD-1 : 0]  r_awaddr                                ;
reg [ADDR_WD-1:0]               r_awlen                                 ;
reg                             r_awready                               ;
reg                             r_wready                                ;
reg                             r_arready                               ;
reg [ADDR_WD-1 : 0]  r_araddr                                ;
reg [ADDR_WD-1:0]               r_arlen                                 ;
reg [8 : 0]                     r_read_cnt                              ;
reg [8 : 0]                     r_write_cnt                              ;
reg                             r_rvalid                                ;
reg [DATA_WD - 1:0]             r_rdata                                 ;
reg                             r_bvalid                                ;
reg                             r_w_active_1                            ;
reg [STRB_WD - 1:0]             r_r_strobe                              ;
reg [STRB_WD - 1:0]             r_r_strobe_1                              ;
reg [7 : 0]                     r_trans_num                             ;
reg [DATA_WD - 1:0]             WSTRB_word                              ;
//reg [DATA_WD - 1:0] r_w_strobe                                          ;

// reg [DATA_WD-1 : 0]  r_ram [0 : 255]                          ;
// reg [7:0]                       r_ram_addr                              ;
// reg [DATA_WD-1 : 0]  r_ram_write_data                        ;
// reg [DATA_WD-1 : 0]  r_ram_read_data                         ;
// reg                             r_ram_rh_wl                             ;
// reg                             r_ram_en                                ;

reg  [DATA_WD : 0] mem [0 : 2**12 - 1]; 
reg  [ADDR_WD : 0]   mem_addr  ;
reg [7 : 0]  mem_write_data                        ;
reg [7 : 0]  mem_read_data                         ;
reg          mem_rh_wl                             ;
reg          mem_en                                ;
reg [DATA_WD:0] r_w_strobe;

wire                 w_aw_active                                         ;
wire                 w_w_active                                          ;
wire                 w_b_active                                          ;
wire                 w_ar_active                                         ;
wire                 w_r_active                                          ;
wire [ADDR_WD-3 : 0] w_araddr_word                                       ;
wire [ADDR_WD-3 : 0] w_awaddr_word                                       ;
wire [7:0]           TRANS_PER_DATA                                      ;
 
assign               w_aw_active     = S_AXI_AWVALID   & S_AXI_AWREADY   ;
assign               w_w_active      = S_AXI_WVALID    & S_AXI_WREADY    ;
assign               w_b_active      = S_AXI_BVALID    & S_AXI_BREADY    ;
assign               w_ar_active     = S_AXI_ARVALID   & S_AXI_ARREADY   ;
assign               w_r_active      = S_AXI_RVALID    & S_AXI_RREADY    ;
assign               w_araddr_word   = r_araddr/DATA_WD_BYTE                        ;
assign               w_awaddr_word   = r_awaddr/DATA_WD_BYTE                        ;
assign               S_AXI_AWREADY   = r_awready                         ;
assign               S_AXI_WREADY    = r_wready                          ;
assign               S_AXI_ARREADY   = r_arready                         ;
 
assign               R_strobe        = r_r_strobe_1                        ;
assign               S_AXI_RDATA     = r_rdata                           ;
assign               S_AXI_RRESP     = 'd0                               ; //response OKAY
assign               S_AXI_RLAST     = (r_read_cnt == r_arlen ) ? 
                                       w_r_active : 1'b0                 ; 
assign               S_AXI_RVALID    = r_rvalid                          ;
assign               S_AXI_BRESP     = 'd0                               ;
assign               S_AXI_BVALID    = r_bvalid                          ;
assign TRANS_PER_DATA   = DATA_WD_BYTE/(2**(S_AXI_AWSIZE))   ;

always@ * begin
    for(integer j = 0; j < 4; j = j + 1) begin
        r_w_strobe[j*8 +:8] = {8{S_AXI_WSTRB[j]}};
    end
end

/********************** mem initialize ***************************/
integer i;
always@(posedge clk) begin
    if(rst) begin
        for(i = 0; i < 2**12; i = i + 1) begin
            mem[i] <= i * 412;
        end
    end
    else begin
        for(i = 0; i < 2**12; i = i + 1) begin
            mem[i] <= mem[i];
        end
    end
end

/**********************write address***************************/
always@(posedge clk) begin
    if(w_aw_active)
        r_awaddr <= S_AXI_AWADDR;
    else 
        r_awaddr <= r_awaddr;
end

always@(posedge clk) begin
    if(w_aw_active)
        r_awlen <= S_AXI_AWLEN;
    // else if()
    else 
        r_awlen <= r_awlen;
end
/*--------------------------write-------------------------------*/

always@(posedge clk) begin
    if(rst || S_AXI_WLAST) begin
        r_awready <= 'd1;
        r_write_cnt <= 0;
    end
    else if(w_w_active)   begin
        r_awready <= 'd0;
        r_write_cnt <= r_write_cnt + 1;
    end
    else begin    
        r_awready <= r_awready;
        r_write_cnt <= r_write_cnt;
    end
end

always@(posedge clk) begin
    if(w_aw_active)
        r_wready <= 'd1;
    else if(S_AXI_WLAST)
        r_wready <= 'd0;
    else 
        r_wready <= r_wready;
end
// delay 1 cycle for store
always@(posedge clk) begin
    if(rst || S_AXI_WLAST)
        r_w_active_1 <= 0;
    else 
        r_w_active_1 <= w_w_active;
end

// always@(posedge clk) begin
//     if(rst || w_trans_num == TRANS_PER_DATA) begin
//         w_trans_num <= 0;
//         if((S_AXI_AWBURST == 2'b0)
//             mem[w_awaddr_word] <= 0;
//     end
//     else if(S_AXI_WREADY && S_AXI_WVALID)
//         w_trans_num <= w_trans_num + 1;
//     else
//         w_trans_num <= w_trans_num;
// end

always@ * begin
    for(integer j = 0; j < STRB_WD; j = j + 1) begin
        WSTRB_word[j*8 +:8] = {8{S_AXI_WSTRB[j]}};
    end
end

always@(posedge clk) begin
    case(S_AXI_AWBURST)
    2'b0: begin         //FIXED mode
        if(w_w_active || r_w_active_1) begin
            if(r_write_cnt % TRANS_PER_DATA == 0)
            mem[w_awaddr_word] <= 0 + (S_AXI_WDATA & WSTRB_word);
            else
            mem[w_awaddr_word] <= mem[w_awaddr_word] + (S_AXI_WDATA & WSTRB_word);
        end
        else
            mem[w_awaddr_word] <= mem[w_awaddr_word]; 
    end
    2'b1: begin         //INCR mode
        if(w_w_active || r_w_active_1) begin
            if(TRANS_PER_DATA == 1)
            mem[w_awaddr_word + r_write_cnt - 1] <= S_AXI_WDATA & WSTRB_word;
            else if(r_write_cnt % TRANS_PER_DATA == 0)
            mem[w_awaddr_word + r_write_cnt/TRANS_PER_DATA - 1] <= 0;
            else 
            mem[w_awaddr_word + r_write_cnt/TRANS_PER_DATA - 1] <= mem[w_awaddr_word + r_write_cnt/TRANS_PER_DATA - 1] + (S_AXI_WDATA & WSTRB_word);
        end
        else
            mem[w_awaddr_word + r_write_cnt/TRANS_PER_DATA - 1] <= mem[w_awaddr_word + r_write_cnt/TRANS_PER_DATA - 1]; 
    end
    default: begin      //WRAP mode
        if(r_w_active_1)
            mem[w_awaddr_word] <= S_AXI_WDATA & WSTRB_word;
        else
            mem[w_awaddr_word] <= mem[w_awaddr_word]; 
    end
    endcase
end

// //ram核心�?
// always@(posedge clk) begin
//     if(!r_ram_rh_wl) 
//         r_ram[r_ram_addr_1b] <= r_ram_en ? r_ram_write_data : r_ram[r_ram_addr];
//     else 
//         r_ram[r_ram_addr_1b] <= r_ram[r_ram_addr_1b];
//         end

// //ram核心�?
// always@(posedge clk) begin
//     if(r_ram_rh_wl)
//         r_ram_read_data <= r_ram[r_ram_addr_1b] ;  
//     else 
//         r_ram_read_data <= r_ram_read_data   ;
//         end

// //ram地址
// always@(posedge clk) begin
//     if(w_rst || S_AXI_WLAST || S_AXI_RLAST)
//         r_ram_addr <= 'd0;
//     else if(w_aw_active)
//         r_ram_addr <= S_AXI_AWADDR[7:0];
//     else if(w_ar_active)
//         r_ram_addr <= S_AXI_ARADDR[7:0];
//     else if(w_w_active || (r_rvalid & S_AXI_RREADY))
//         r_ram_addr <= r_ram_addr + 1;
//     else 
//         r_ram_addr <= r_ram_addr;
//         end

// //ram地址打一�?
// always@(posedge clk) begin
//     r_ram_addr_1b <= r_ram_addr;
//     end

//ram写端�?
// always@(posedge clk) begin
//     if(w_w_active)
//         r_ram_write_data <= S_AXI_WDATA         ;
//     else    
//         r_ram_write_data <= r_ram_write_data    ;
//         end

// //ram读写控制
// always@(posedge clk) begin
//     if(w_ar_active)
//         r_ram_rh_wl <= 'd1;
//     else if(w_aw_active)
//         r_ram_rh_wl <= 'd0;
//     else 
//         r_ram_rh_wl <= r_ram_rh_wl;
//         end

// //ram写使�?
// always@(posedge clk) begin
//     if(w_w_active)
//         r_ram_en <= 'd1;
//     else
//         r_ram_en <= 'd0;
//         end


/**********************read address***************************/
always@(posedge clk) begin
    if(rst || S_AXI_RLAST)
        r_arready <= 'd1;
    else if(w_ar_active)
        r_arready <= 'd0;
    else 
        r_arready <= r_arready;
        end

 
always@(posedge clk) begin
    if(w_ar_active)
        r_araddr <= S_AXI_ARADDR;
    else 
        r_araddr <= r_araddr;
        end

always@(posedge clk) begin
    if(w_ar_active)
        r_arlen <= S_AXI_ARLEN; 
    else 
        r_arlen <= r_arlen;
        end
/********************** read ***************************/
//delay 1 cycle
always@(posedge clk) begin
    r_r_strobe_1 <= r_r_strobe;
end

always@(posedge clk) begin
    if(rst || r_trans_num == TRANS_PER_DATA)
        r_trans_num <= 1;
    else if(w_r_active)
        r_trans_num <= r_trans_num + 1;
    else
        r_trans_num <= r_trans_num;
end

always@(posedge clk) begin
    // if(rst)
    //     r_r_strobe <= 0
    // else if(w_r_active && r_trans_num == 0)
    //     r_r_strobe <= 
    // else
    if(rst || S_AXI_RLAST || w_ar_active) 
    case(TRANS_PER_DATA)
        2: r_r_strobe <= {{(STRB_WD/2){1'b0}},{(STRB_WD/2){1'b1}}};
        4: r_r_strobe <= {{(3*STRB_WD/4){1'b0}},{(STRB_WD/4){1'b1}}};
        8: r_r_strobe <= {{(7*STRB_WD/8){1'b0}},{(STRB_WD/8){1'b1}}};
        16: r_r_strobe <= {{(15*STRB_WD/16){1'b0}},{(STRB_WD/16){1'b1}}};
        default: r_r_strobe <= {STRB_WD{1'b1}};
    endcase
    else if(w_r_active) begin
        case(TRANS_PER_DATA)
            2: begin
                case(r_trans_num)
                    0: r_r_strobe <= {{(STRB_WD/2){1'b0}},{(STRB_WD/2){1'b1}}};
                    TRANS_PER_DATA: r_r_strobe <= {{(STRB_WD/2){1'b0}},{(STRB_WD/2){1'b1}}};
                default: r_r_strobe <= r_r_strobe << STRB_WD/2;
                endcase
            end
            4: begin
                case(r_trans_num)
                0: r_r_strobe <= {{(3*STRB_WD/4){1'b0}},{(STRB_WD/4){1'b1}}};
                TRANS_PER_DATA: r_r_strobe <= {{(3*STRB_WD/4){1'b0}},{(STRB_WD/4){1'b1}}};
                default: r_r_strobe <= r_r_strobe << STRB_WD/4;
                endcase
            end
            8: begin
                case(r_trans_num)
                0: r_r_strobe <= {{(7*STRB_WD/8){1'b0}},{(STRB_WD/8){1'b1}}};
                TRANS_PER_DATA: r_r_strobe <= {{(7*STRB_WD/8){1'b0}},{(STRB_WD/8){1'b1}}};
                default: r_r_strobe <= r_r_strobe << STRB_WD/8;
                endcase
            end
            16: begin
                case(r_trans_num)
                0: r_r_strobe <= {{(15*STRB_WD/16){1'b0}},{(STRB_WD/16){1'b1}}};
                TRANS_PER_DATA: r_r_strobe <= {{(15*STRB_WD/16){1'b0}},{(STRB_WD/16){1'b1}}};
                default: r_r_strobe <= r_r_strobe << STRB_WD/16;
                endcase
            end
            default: r_r_strobe <= {STRB_WD{1'b1}};
        endcase
    end
    else
        r_r_strobe <= r_r_strobe;
end

always@(posedge clk) begin
    if(rst || S_AXI_RLAST)
        r_read_cnt <= 'd0;
    else if(w_r_active)
        r_read_cnt <= r_read_cnt + 1;
    else
        r_read_cnt <= r_read_cnt;
end

always@(posedge clk) begin
    case(S_AXI_ARBURST)
    2'd0: begin     //FIXED mode
        if(rst || S_AXI_RLAST)
            r_rdata <= 'd0;
        else if(w_r_active)
            r_rdata <= mem[w_araddr_word];
        else 
            r_rdata <= r_rdata;
    end
    2'd1: begin     //INCR mode
        if(rst || S_AXI_RLAST)
            r_rdata <= 'd0;
        else if(w_r_active)
            r_rdata <= mem[r_read_cnt/TRANS_PER_DATA + w_araddr_word];
        else 
            r_rdata <= r_rdata;
    end
    default: begin   //WRAP mode
        if(rst || S_AXI_RLAST)
            r_rdata <= 'd0;
        else if(w_r_active)
            r_rdata <= mem[w_araddr_word];
        else 
            r_rdata <= r_rdata;
    end
    endcase
end

always@(posedge clk) begin
    if(rst || S_AXI_RLAST)
        r_rvalid <= 'd0;
    else if(w_ar_active)
        r_rvalid <= 'd1;
    else 
        r_rvalid <= r_rvalid;
        end

always@(posedge clk) begin
    if(S_AXI_WLAST)
        r_bvalid <= 'd1;
    else if(w_b_active)
        r_bvalid <= 'd0;
    else 
        r_bvalid <= r_bvalid;
end

endmodule

