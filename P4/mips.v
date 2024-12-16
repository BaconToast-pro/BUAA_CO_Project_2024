`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:34:05 10/30/2024 
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
    input clk,
    input reset
    );
	 
	wire [31:0] NPC, Instr, PC;
	IM u_IM (
		.clk(clk),
		.reset(reset),
		.NPC(NPC),
		.Instr(Instr),
		.PC(PC)
	);
	
	wire [15:0] imm16;
	wire [25:0] imm26;
	wire [2:0] BranchOp, BRCHOp;
	assign BRCHOp = (BranchOp != 3'b001) ? BranchOp :
						 (Zero == 1'b1) ? BranchOp : 3'b000;
	wire [31:0] jrreg;
	PC u_PC (
		.PC(PC),
		.imm16(imm16),
		.imm26(imm26),
		.BranchOp(BRCHOp),
		.jrreg(jrreg),
		.NPC(NPC)
	);
	
	wire RegDst, ALUSrc, MemtoReg, RegWrite, MemWrite, ExtOp;
	wire [2:0] ALUctr;
	wire [4:0] rs, rt, rd;
	Controller u_CTRL (
		.Instr(Instr),
		.RegDst(RegDst),
		.ALUSrc(ALUSrc),
		.MemtoReg(MemtoReg),
		.RegWrite(RegWrite),
		.MemWrite(MemWrite),
		.BranchOp(BranchOp),
		.ExtOp(ExtOp),
		.ALUctr(ALUctr),
		.imm16(imm16),
		.imm26(imm26),
		.rs(rs),
		.rt(rt),
		.rd(rd)
	);
	
	wire [31:0] immALU;
	EXT u_EXT_ALU (
		.Imm(imm16),
		.ExtOp(ExtOp),
		.Imm32(immALU)
	);
	
	wire [31:0] RD1, RD2, ALUResult;
	wire Zero;
	ALU u_ALU (
		.ALUctr(ALUctr),
		.Op1(RD1),
		.Op2(ALUSrc ? immALU : RD2),
		.Zero(Zero),
		.ALUResult(ALUResult)
	);
	
	wire [31:0] RD;
	GRF u_GRF (
		.clk(clk),
		.reset(reset),
		.WE(RegWrite),
		.A1(rs),
		.A2(rt),
		.A3(RegDst ? rd : 
		   (BranchOp == 3'b010) ? 5'd31 : rt),
		.WD(MemtoReg ? RD : 
		   (BranchOp == 3'b010) ? (PC + 3'd4) : ALUResult),
		.PC(PC),
		.RD1(RD1),
		.RD2(RD2)
	);
	assign jrreg = RD1;
	
	DM u_DM (
		.clk(clk),
		.reset(reset),
		.WE(MemWrite),
		.addr(ALUResult[15:0]),
		.WD(RD2),
		.PC(PC),
		.RD(RD)
	);

endmodule
