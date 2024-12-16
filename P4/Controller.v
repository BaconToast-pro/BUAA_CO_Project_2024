`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:57:19 10/30/2024 
// Design Name: 
// Module Name:    Controller 
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
module Controller(
    input [31:0] Instr,
    output RegDst,
    output ALUSrc,
    output MemtoReg,
    output RegWrite,
    output MemWrite,
    output [2:0] BranchOp,
    output ExtOp,
    output [2:0] ALUctr,
	 output [15:0] imm16,
	 output [25:0] imm26,
	 output [4:0] rs,
	 output [4:0] rt,
	 output [4:0] rd
    );
	 
	wire [5:0] op;
	wire [5:0] func;
	
	assign op = Instr[31:26];
	assign func = Instr[5:0];
	assign imm16 = Instr[15:0];
	assign imm26 = Instr[25:0];
	assign rs = Instr[25:21];
	assign rt = Instr[20:16];
	assign rd = Instr[15:11];
	
	wire add = (op == 6'b0 && func == 6'b100000);
	wire sub = (op == 6'b0 && func == 6'b100010);
	wire ori = (op == 6'b001101);
	wire lw = (op == 6'b100011);
	wire sw = (op == 6'b101011);
	wire beq = (op == 6'b000100);
	wire lui = (op == 6'b001111);
	wire jal = (op == 6'b000011);
	wire jr = (op == 6'b0 && func == 6'b001000);
	
	assign RegDst = add || sub;
	assign ALUSrc = ori || lw || sw || lui;
	assign MemtoReg = lw;
	assign RegWrite = add || sub || ori || lw || lui || jal;
	assign MemWrite = sw;
	assign BranchOp[0] = beq || jr;
	assign BranchOp[1] = jal || jr;
	assign BranchOp[2] = 0;
	assign ExtOp = lw || sw || beq;
	assign ALUctr[0] = sub || beq || lui;
	assign ALUctr[1] = ori || lui;
	assign ALUctr[2] = 0;
	
endmodule
