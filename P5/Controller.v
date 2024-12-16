`timescale 1ns / 1ps
`include "constants.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:26:04 11/14/2024 
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
    output reg [1:0] WDSel,
    output reg RegWrite,
    output reg MemWrite,
    output reg [2:0] PCSel,
    output reg [2:0] ALUCtrl,
    output reg ALUSrc,
    output reg [1:0] RegDst
    );
	
	always @(*) begin
		case (`OpCode)
			`nop: begin // OpCode = 6'b000000;
				case (`Func) 
					`add: begin
						WDSel = `wdAO;
						RegWrite = 1;
						MemWrite = 0;
						PCSel = `pc4;
						ALUCtrl = `aluAdd;
						ALUSrc = 0;
						RegDst = `a3rd;
					end
					`sub: begin
						WDSel = `wdAO;
						RegWrite = 1;
						MemWrite = 0;
						PCSel = `pc4;
						ALUCtrl = `aluSub;
						ALUSrc = 0;
						RegDst = `a3rd;						
					end
					`nop: begin
						WDSel = 0;
						RegWrite = 0;
						MemWrite = 0;
						PCSel = `pc4;
						ALUCtrl = 0;
						ALUSrc = 0;
						RegDst = 0;
					end
					`jr: begin
						WDSel = 0;
						RegWrite = 0;
						MemWrite = 0;
						PCSel = `pcJr;
						ALUCtrl = 0;
						ALUSrc = 0;
						RegDst = 0;
					end
				endcase
			end
			`ori: begin
				WDSel = `wdAO;
				RegWrite = 1;
				MemWrite = 0;
				PCSel = `pc4;
				ALUCtrl = `aluOri;
				ALUSrc = 1;
				RegDst = `a3rt;
			end
			`lui: begin
				WDSel = `wdAO;
				RegWrite = 1;
				MemWrite = 0;
				PCSel = `pc4;
				ALUCtrl = `aluLui;
				ALUSrc = 1;
				RegDst = `a3rt;
			end
			`lw: begin
				WDSel = `wdDM;
				RegWrite = 1;
				MemWrite = 0;
				PCSel = `pc4;
				ALUCtrl = `aluAdd;
				ALUSrc = 1;
				RegDst = `a3rt;
			end
			`sw: begin
				WDSel = 0;
				RegWrite = 0;
				MemWrite = 1;
				PCSel = `pc4;
				ALUCtrl = `aluAdd;
				ALUSrc = 1;
				RegDst = 0;
			end
			`beq: begin
				WDSel = 0;
				RegWrite = 0;
				MemWrite = 0;
				PCSel = `pcBeq;
				ALUCtrl = `aluSub;
				ALUSrc = 0;
				RegDst = 0;
			end
			`jal: begin
				WDSel = `wdPC8;
				RegWrite = 1;
				MemWrite = 0;
				PCSel = `pcJal;
				ALUCtrl = 0;
				ALUSrc = 0;
				RegDst = `a3ra;
			end
			`jr: begin
				WDSel = 0;
				RegWrite = 0;
				MemWrite = 0;
				PCSel = `pcJr;
				ALUCtrl = 0;
				ALUSrc = 0;
				RegDst = 0;
			end
		endcase
	end

endmodule
