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
    output reg [3:0] ALUCtrl,
    output reg ALUSrc,
    output reg [1:0] RegDst,
	 output reg [3:0] HILOCtrl,
	 output reg AOSel,
	 output reg Start
    );
	
	always @(*) begin
		if (`OpCode == `special) begin
			if (`Func == `add || `Func == `sub || `Func == `and_ ||
				`Func == `or_ || `Func == `slt || `Func == `sltu) begin
				WDSel = `wdAO;
				RegWrite = 1;
				MemWrite = 0;
				PCSel = `pc4;
				case (`Func)
					`add: ALUCtrl = `aluAdd;
					`sub: ALUCtrl = `aluSub;
					`and_: ALUCtrl = `aluAnd;
					`or_: ALUCtrl = `aluOr;
					`slt: ALUCtrl = `aluSlt;
					`sltu: ALUCtrl = `aluSltu;
				endcase
				ALUSrc = 0;
				RegDst = `a3rd;
				HILOCtrl = 0;
				AOSel = `aoALU;
				Start = 0;
			end
			else if (`Func == `mult || `Func == `multu || `Func == `div || 
			`Func == `divu || `Func == `mthi || `Func == `mtlo) begin
				WDSel = 0;
				RegWrite = 0;
				MemWrite = 0;
				PCSel = `pc4;
				ALUCtrl = 0;
				ALUSrc = 0;
				RegDst = 0;
				case (`Func)
					`mult: HILOCtrl = `mduMult;
					`multu: HILOCtrl = `mduMultu;
					`div: HILOCtrl = `mduDiv;
					`divu: HILOCtrl = `mduDivu;
					`mthi: HILOCtrl = `mduMthi;
					`mtlo: HILOCtrl = `mduMtlo;
				endcase
				AOSel = `aoMDU;
				if (`Func == `mult || `Func == `multu || `Func == `div || `Func == `divu) begin
					Start = 1;
				end
				else Start = 0;
			end
			else if (`Func == `mfhi || `Func == `mflo) begin
				WDSel = `wdAO;
				RegWrite = 1;
				MemWrite = 0;
				PCSel = `pc4;
				ALUCtrl = 0;
				ALUSrc = 0;
				RegDst = `a3rd;
				case (`Func)
					`mfhi: HILOCtrl = `mduMfhi;
					`mflo: HILOCtrl = `mduMflo;
				endcase
				AOSel = `aoMDU;
				Start = 0;
			end
			else if (`Func == `jr) begin
				WDSel = 0;
				RegWrite = 0;
				MemWrite = 0;
				PCSel = `pcJr;
				ALUCtrl = 0;
				ALUSrc = 0;
				RegDst = 0;
				HILOCtrl = 0;
				AOSel = 0;
				Start = 0;
			end
			else if (`Func == `nop) begin
				WDSel = 0;
				RegWrite = 0;
				MemWrite = 0;
				PCSel = `pc4;
				ALUCtrl = 0;
				ALUSrc = 0;
				RegDst = 0;
				HILOCtrl = 0;
				AOSel = 0;
				Start = 0;
			end
		end
		else if (`OpCode == `lui || `OpCode == `addi || `OpCode == `andi || `OpCode == `ori) begin
			WDSel = `wdAO;
			RegWrite = 1;
			MemWrite = 0;
			PCSel = `pc4;
			case (`OpCode)
				`lui: ALUCtrl = `aluLui;
				`addi: ALUCtrl = `aluAddi;
				`andi: ALUCtrl = `aluAndi;
				`ori: ALUCtrl = `aluOri;
			endcase
			ALUSrc = 1;
			RegDst = `a3rt;
			HILOCtrl = 0;
			AOSel = `aoALU;
			Start = 0;
		end
		else if (`OpCode == `lb || `OpCode == `lh || `OpCode == `lw) begin
			WDSel = `wdDM;
			RegWrite = 1;
			MemWrite = 0;
			PCSel = `pc4;
			ALUCtrl = `aluAdd;
			ALUSrc = 1;
			RegDst = `a3rt;
			HILOCtrl = 0;
			AOSel = `aoALU;
			Start = 0;
		end
		else if (`OpCode == `sb || `OpCode == `sh || `OpCode == `sw) begin
			WDSel = 0;
			RegWrite = 0;
			MemWrite = 1;
			PCSel = `pc4;
			ALUCtrl = `aluAdd;
			ALUSrc = 1;
			RegDst = 0;
			HILOCtrl = 0;
			AOSel = `aoALU;
			Start = 0;
		end
		else if (`OpCode == `beq || `OpCode == `bne) begin
			WDSel = 0;
			RegWrite = 0;
			MemWrite = 0;
			if (`OpCode == `beq) PCSel = `pcBeq;
			else if (`OpCode == `bne) PCSel = `pcBne;
			else PCSel = 0;
			ALUCtrl = 0;
			ALUSrc = 0;
			RegDst = 0;
			HILOCtrl = 0;
			AOSel = 0;
			Start = 0;
		end
		else if (`OpCode == `jal) begin
			WDSel = `wdPC8;
			RegWrite = 1;
			MemWrite = 0;
			PCSel = `pcJump;
			ALUCtrl = 0;
			ALUSrc = 0;
			RegDst = `a3ra;
			HILOCtrl = 0;
			AOSel = 0;
			Start = 0;
		end
		else begin
			// add new
		end
	end

endmodule
