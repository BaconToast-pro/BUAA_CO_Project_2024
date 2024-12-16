`timescale 1ns / 1ps
`include "constants.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:00:05 11/14/2024 
// Design Name: 
// Module Name:    ALU 
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
module ALU(
    input [31:0] alu_A,
    input [31:0] alu_B,
    input [2:0] ALUCtrl,
    output reg [31:0] alu_out
    );
	 
	always @(*) begin
		case (ALUCtrl)
			`aluAdd:
				alu_out = alu_A + alu_B;
			`aluSub:
				alu_out = alu_A - alu_B;
			`aluOri:
				alu_out = alu_A | {16'd0, alu_B[15:0]};
			`aluLui:
				alu_out = alu_B << 16;
		endcase
	end

endmodule
