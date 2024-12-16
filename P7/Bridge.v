`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:41:12 12/14/2024 
// Design Name: 
// Module Name:    Bridge 
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
module Bridge(
	 output [31:0] m_data_addr,
	 output [31:0] m_data_wdata,
	 output [3:0] m_data_byteen,
	 input [31:0] m_data_rdata,
	 
	 input [31:0] tmp_m_data_addr,
	 input [31:0] tmp_m_data_wdata,
	 input [3:0] tmp_m_data_byteen,
	 output [31:0] tmp_m_data_rdata,
	 
	 output [31:0] TC0_Addr,
	 output TC0_WE,
	 output [31:0] TC0_Din,
	 input [31:0] TC0_Dout,
	 
	 output [31:0] TC1_Addr,
	 output TC1_WE,
	 output [31:0] TC1_Din,
	 input [31:0] TC1_Dout
    );

	assign m_data_addr = tmp_m_data_addr;
	assign m_data_wdata = tmp_m_data_wdata;
	assign m_data_byteen = tmp_m_data_byteen;
	assign tmp_m_data_rdata = m_data_rdata;

endmodule
