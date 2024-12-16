`timescale 1ns / 1ps
`include "constants.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:12:58 11/24/2024 
// Design Name: 
// Module Name:    BYTE 
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
module BYTE(
    input [31:0] Instr,
    input [31:0] addr,
	 output reg [3:0] byteen,
    output reg ExtOp
    );
	
	always @(*) begin
		if (Instr[31:26] == `sb || Instr[31:26] == `lb) begin
			if (addr[1:0] == 2'b00) byteen = 4'b0001;
			else if (addr[1:0] == 2'b01) byteen = 4'b0010;
			else if (addr[1:0] == 2'b10) byteen = 4'b0100;
			else byteen = 4'b1000;
		end
		else if (Instr[31:26] == `sh || Instr[31:26] == `lh) begin
			if (addr[1] == 1'b0) byteen = 4'b0011;
			else byteen = 4'b1100;
		end
		else if (Instr[31:26] == `sw || Instr[31:26] == `lw) begin
			byteen = 4'b1111;
		end
		else begin
			byteen = 4'd0;
		end
		
		if (Instr[31:26] == `sb || Instr[31:26] == `sh || Instr[31:26] == `sw) ExtOp = 1'd0;
		else if (Instr[31:26] == `lb || Instr[31:26] == `lh || Instr[31:26] == `lw) ExtOp = 1'd1;
		else begin
			byteen = 4'd0;
		end
	end

endmodule
