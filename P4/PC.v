`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:34:45 10/31/2024 
// Design Name: 
// Module Name:    PC 
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
module PC(
    input [31:0] PC,
    input [15:0] imm16,
    input [25:0] imm26,
    input [2:0] BranchOp,
    input [31:0] jrreg,
    output [31:0] NPC
    );
	 
	wire [31:0] imm;
	assign imm = (BranchOp == 3'b001) ? {{16{imm16[15]}}, imm16} :
			  		 (BranchOp == 3'b010) ? {{6{imm26[25]}}, imm26} : 0;
	 
	assign NPC = (BranchOp == 3'b000) ? (PC + 3'd4) :
					 (BranchOp == 3'b001) ? (PC + 3'd4 + (imm << 2)) : 
					 (BranchOp == 3'b010) ? ({PC[31:28], imm[25:0], 2'b00}) :
					 (BranchOp == 3'b011) ? (jrreg) : 0;
					 
endmodule