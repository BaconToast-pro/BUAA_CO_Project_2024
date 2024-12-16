`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:23:05 12/14/2024 
// Design Name: 
// Module Name:    mips 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module mips(
    input clk,                    // 时钟信号
    input reset,                  // 同步复位信号
    input interrupt,              // 外部中断信号
    output [31:0] macroscopic_pc, // 宏观 PC

    output [31:0] i_inst_addr,    // IM 读取地址（取指 PC）
    input  [31:0] i_inst_rdata,   // IM 读取数据

    output [31:0] m_data_addr,    // DM 读写地址
    input  [31:0] m_data_rdata,   // DM 读取数据
    output [31:0] m_data_wdata,   // DM 待写入数据
    output [3 :0] m_data_byteen,  // DM 字节使能信号

    output [31:0] m_int_addr,     // 中断发生器待写入地址
    output [3 :0] m_int_byteen,   // 中断发生器字节使能信号

    output [31:0] m_inst_addr,    // M 级 PC

    output w_grf_we,              // GRF 写使能信号
    output [4 :0] w_grf_addr,     // GRF 待写入寄存器编号
    output [31:0] w_grf_wdata,    // GRF 待写入数据

    output [31:0] w_inst_addr     // W 级 PC
);

wire [31:0] m_data_addr_cpu;
assign m_data_addr = m_data_addr_cpu;

wire [3:0] m_data_byteen_cpu;
assign m_data_byteen = m_data_byteen_cpu;

wire [31:0] m_data_wdata_cpu;
assign m_data_wdata = m_data_wdata_cpu;

wire [31:0] m_data_rdata_cpu;

assign m_int_addr = (interrupt || IRQ0 || IRQ1) ? 32'h0000_7f20 : 0;
assign m_int_byteen = (interrupt || IRQ0 || IRQ1) ? 4'b1111 : 0;

CPU u_CPU(
    .clk(clk),
    .reset(reset),
	 .i_inst_rdata(i_inst_rdata),
	 .m_data_rdata(m_data_rdata_cpu),
	 .HWInt({3'b0, interrupt, IRQ0, IRQ1}),
	 .i_inst_addr(i_inst_addr),
	 .m_data_addr(m_data_addr_cpu),
	 .m_data_wdata(m_data_wdata_cpu),
	 .m_data_byteen(m_data_byteen_cpu),
	 .m_inst_addr(m_inst_addr),
	 .w_grf_we(w_grf_we),
	 .w_grf_addr(w_grf_addr),
	 .w_grf_wdata(w_grf_wdata),
	 .w_inst_addr(w_inst_addr),
	 .MPC(macroscopic_pc)
    );

wire selTC0 = (m_data_addr_cpu >= 32'h0000_7F00) && (m_data_addr_cpu <= 32'h0000_7F0B);
wire selTC1 = (m_data_addr_cpu >= 32'h0000_7F10) && (m_data_addr_cpu <= 32'h0000_7F1B);	 

TC u_TC0(
    .clk(clk),
    .reset(reset),
    .Addr(m_data_addr_cpu[31:2]),
    .WE(m_data_addr_byteen_cpu != 4'b0000 && selTC0 == 1'b1),
    .Din(m_data_wdata_cpu),
    .Dout(TCDout0),
    .IRQ(IRQ0)
    );
	 
TC u_TC1(
    .clk(clk),
    .reset(reset),
    .Addr(m_data_addr_cpu[31:2]),
    .WE(m_data_addr_byteen_cpu != 4'b0000 && selTC1 == 1'b1),
    .Din(m_data_wdata_cpu),
    .Dout(TCDout1),
    .IRQ(IRQ1)
    );
	 
Bridge u_Bridge(
	 .m_data_addr(m_data_addr),
	 .m_data_wdata(m_data_wdata),
	 .m_data_byteen(m_data_byteen),
	 .m_data_rdata(m_data_rdata),
	 
	 .tmp_m_data_addr(m_data_addr_cpu),
	 .tmp_m_data_wdata(m_data_wdata_cpu),
	 .tmp_m_data_byteen(m_data_byteen_cpu),
	 .tmp_m_data_rdata(m_data_rdata_cpu),
	 
	 .TC0_Addr(m_data_addr_cpu[31:2]),
	 .TC0_WE(),
	 .TC0_Din(),
	 .TC0_Dout(),
	 
	 .TC1_Addr(m_data_addr_cpu[31:2]),
	 .TC1_WE(),
	 .TC1_Din(),
	 .TC1_Dout()
    );

endmodule
