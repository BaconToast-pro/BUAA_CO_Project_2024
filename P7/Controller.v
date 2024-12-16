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
	 output reg Start,
	 output reg CP0Write,
	 output reg EXLClr,
	 output reg excRI,
	 output reg aluAdEL,
	 output reg aluAdES,
	 output reg aluOv,
	 output reg excSyscall,
	 output reg [2:0] LStype,
	 // 0 - not LS; 1 - lb; 2 - lh; 3 - lw; 4 - sb; 5 - sh; 6 - sw
	 output reg isDelaySlot
    );
	
	always @(*) begin
		excRI = 0;
		CP0Write = 0;
		EXLClr = 0;
		aluAdEL = 0;
		aluAdES = 0;
		aluOv = 0;
		excSyscall = 0;
		LStype = 0;
		isDelaySlot = 0;
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
				if (`Func == `add || `Func == `sub) begin
					aluOv = 1;
				end
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
				isDelaySlot = 1;
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
			else if (`Func == `syscall) begin
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
				excSyscall = 1;
			end
			else begin
				excRI = 1;
			end
		end
		else if (`OpCode == `cop0) begin
			if (`Func == `eret) begin
				WDSel = 0;
				RegWrite = 0;
				MemWrite = 0;
				PCSel = `pcEret;
				ALUCtrl = 0;
				ALUSrc = 0;
				RegDst = 0;
				HILOCtrl = 0;
				AOSel = 0;
				Start = 0;	
				EXLClr = 1;
			end
			else if (`Func == `nop) begin
				if (`Rs == `mfc0) begin
					WDSel = `wdCP0;
					RegWrite = 1;
					MemWrite = 0;
					PCSel = `pc4;
					ALUCtrl = 0;
					ALUSrc = 0;
					RegDst = `a3rt;
					HILOCtrl = 0;
					AOSel = 0;
					Start = 0;
				end
				else if (`Rs == `mtc0) begin
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
					CP0Write = 1;
				end
				else begin
					excRI = 1;
				end
			end
			else begin
				excRI = 1;
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
			if (`OpCode == `addi) begin
				aluOv = 1;
			end
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
			aluAdEL = 1;
			if (`OpCode == `lb) LStype = 3'd1;
			else if (`OpCode == `lh) LStype = 3'd2;
			else if (`OpCode == `lw) LStype = 3'd3;
			else;
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
			aluAdES = 1;
			if (`OpCode == `sb) LStype = 3'd4;
			else if (`OpCode == `sh) LStype = 3'd5;
			else if (`OpCode == `sw) LStype = 3'd6;
			else;
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
			isDelaySlot = 1;
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
			isDelaySlot = 1;
		end
		else begin
			excRI = 1;
		end
	end

endmodule
