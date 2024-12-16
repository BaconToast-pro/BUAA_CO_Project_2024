`timescale 1ns / 1ps
`include "constants.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:34:04 11/14/2024 
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
module CPU(
    input clk,
    input reset,
	 input [31:0] i_inst_rdata,
	 input [31:0] m_data_rdata,
	 input [5:0] HWInt,
	 output [31:0] i_inst_addr,
	 output [31:0] m_data_addr,
	 output [31:0] m_data_wdata,
	 output [3:0] m_data_byteen,
	 output [31:0] m_inst_addr,
	 output w_grf_we,
	 output [4:0] w_grf_addr,
	 output [31:0] w_grf_wdata,
	 output [31:0] w_inst_addr,
	 output [31:0] MPC
    );

/******** Declarations *********/
// F
wire StallPC;
wire [31:0] Instr_F;
wire [31:0] PC_F;
wire [31:0] PC;
wire excAdEL_F;
wire [4:0] excCode_F;
// D
wire StallD;
reg [31:0] Instr_D = 32'd0;
reg [31:0] PC4_D = 32'd0;
wire [31:0] RD1_D, RD2_D;
wire [31:0] GPR_rs, GPR_rt;
wire [31:0] NPC_D;
wire [1:0] RD1_D_Sel, RD2_D_Sel;
wire [31:0] PC_D;
wire equ_D;
wire [2:0] PCSel_D;
wire excRI_D;
reg [4:0] tmp_excCode_D;
wire excSyscall_D;
wire [4:0] excCode_D;
// E
wire ClrE;
reg [31:0] Instr_E = 32'd0;
reg [31:0] PC4_E = 32'd0;
reg [31:0] RD1_E = 32'd0, RD2_E = 32'd0;
wire [3:0] ALUCtrl_E;
wire [3:0] HILOCtrl_E;
wire [1:0] RegDst_E;
wire RegWrite_E;
wire ALUSrc_E;
wire [1:0] RD1_E_Sel, RD2_E_Sel;
wire [31:0] Op1_E, Op2_E;
wire [31:0] AO_E;
wire [4:0] GPR_A3_E;
wire [31:0] RD2_to_M;
wire Start_E, Busy_E;
wire [31:0] MO_E, HI_E, LO_E;
reg [4:0] tmp_excCode_E;
wire [4:0] excCode_E;
wire aluAdEL_E, aluAdES_E, aluOv_E;
wire excAdEL_E, excAdES_E, excOv_E;
// M
reg [31:0] Instr_M = 32'd0;
reg [31:0] PC4_M = 32'd0;
reg [31:0] AO_M = 32'd0;
reg [31:0] MO_M = 32'd0;
wire [31:0] AO_M_AfterAOSel;
wire MemWrite_M;
wire RegWrite_M;
wire [1:0] RegDst_M;
wire [2:0] PCSel_M;
reg [31:0] RD2_M = 32'd0;
wire [31:0] DO_M;
wire [31:0] PC_M;
reg [4:0] GPR_A3_M;
wire [3:0] byteen_M;
wire ExtOp_M;
wire [31:0] DO_M_beforeEXT;
wire AOSel_M;
wire Req_M;
wire CP0Write_M;
wire [31:0] CO_M;
wire EXLClr_M;
reg [4:0] tmp_excCode_M;
wire [4:0] excCode_M;
wire [2:0] LStype_M;
wire excAdEL_M, excAdES_M;
wire isDelaySlot_M;
wire [31:0] EPC_M;
// W
reg [31:0] Instr_W = 32'd0;
reg [31:0] PC8_W = 32'd0;
reg [31:0] AO_W = 32'd0;
reg [31:0] DO_W = 32'd0;
wire [1:0] WDSel_W;
wire RegWrite_W;
wire [1:0] RegDst_W;
reg [4:0] GPR_A3_W;
wire [31:0] GPR_WD_W;
reg [31:0] CO_W;
/**********  Stage_F  **********/
PC F_PC(
    .clk(clk),
    .reset(reset),
    .EN(~StallPC),
    .NPC(PC),
	 .Req(Req_M),
    .PC(PC_F)
    );
	 
/*	 
IM F_IM(
    .PC(PC_F),
    .RD(Instr_F)
    );
*/	 

assign i_inst_addr = PC_F; // IM in
assign Instr_F = (excAdEL_F) ? 32'd0 : i_inst_rdata; // IM out

assign PC = (PCSel_D == 3'd0) ? PC_F + 32'd4 :
				(PCSel_D == 3'd1 || PCSel_D == 3'd2 || PCSel_D == 3'd4) ? NPC_D :
				(PCSel_D == 3'd3) ? RD1_D : 
				(PCSel_D == 3'd5) ? EPC_M : 0;
				
assign excAdEL_F = ((|PC_F[1:0]) || (PC_F < 32'h0000_3000 || PC_F > 32'h0000_6ffc));
assign excCode_F = (excAdEL_F) ? `AdEL : 0;

/**********  Stage_D  **********/
always @(posedge clk) begin
	if (reset || Req_M || PCSel_D == 3'd5) begin
		Instr_D <= 32'd0;
		PC4_D <= 32'd0;
		tmp_excCode_D <= 5'd0;
	end
	else if (StallD) begin
		Instr_D <= Instr_D;
		PC4_D <= PC4_D;
		tmp_excCode_D <= 5'd0;
	end
	else begin
		Instr_D <= Instr_F;
		PC4_D <= PC_F + 32'd4;
		tmp_excCode_D <= excCode_F;
	end
end

assign excCode_D = tmp_excCode_D ? tmp_excCode_D : 
						 excRI_D ? `RI :
						 excSyscall_D ? `Syscall : `Int;

Controller D_Controller(
    .Instr(Instr_D),
    .PCSel(PCSel_D),
	 .excRI(excRI_D),
	 .excSyscall(excSyscall_D)
    );

GRF D_GRF(
    .clk(clk),
    .reset(reset),
    .WE(RegWrite_W),
    .A1(Instr_D[25:21]),
    .A2(Instr_D[20:16]),
    .A3(GPR_A3_W),
    .WD(GPR_WD_W),
	 .PC(PC_D),
    .RD1(GPR_rs),
    .RD2(GPR_rt)
    );
NPC D_NPC(
    .PC(PC4_D),
    .IMM(Instr_D[25:0]),
    .PCSel(PCSel_D),
    .equ(equ_D),
    .NPC(NPC_D)
    );
assign RD1_D = (RD1_D_Sel == 2'd0) ? GPR_rs :
					(RD1_D_Sel == 2'd1) ? GPR_WD_W :
					(RD1_D_Sel == 2'd2) ? AO_M_AfterAOSel : 0;
assign RD2_D = (RD2_D_Sel == 2'd0) ? GPR_rt :
					(RD2_D_Sel == 2'd1) ? GPR_WD_W :
					(RD2_D_Sel == 2'd2) ? AO_M_AfterAOSel : 0;
assign equ_D = (RD1_D == RD2_D);
assign PC_D = PC8_W - 32'd8;

/**********  Stage_E  **********/
always @(posedge clk) begin
	if (reset || Req_M) begin
		Instr_E <= 32'd0;
		PC4_E <= 32'd0;
		RD1_E <= 32'd0;
		RD2_E <= 32'd0;
		tmp_excCode_E <= 5'd0;
	end
	else if (ClrE) begin
		Instr_E <= 32'd0;
		tmp_excCode_E <= 5'd0;
	end
	else begin
		Instr_E <= Instr_D;
		PC4_E <= PC4_D;
		RD1_E <= RD1_D;
		RD2_E <= RD2_D;
		tmp_excCode_E <= excCode_D;
	end
end

assign excCode_E = tmp_excCode_E ? tmp_excCode_E : 
						 excAdEL_E ? `AdEL :
						 excAdES_E ? `AdES : 
						 excOv_E ? `Ov : `Int;

Controller E_Controller(
    .Instr(Instr_E),
	 .RegWrite(RegWrite_E),
    .ALUCtrl(ALUCtrl_E),
    .ALUSrc(ALUSrc_E),
    .RegDst(RegDst_E),
	 .HILOCtrl(HILOCtrl_E),
	 .Start(Start_E),
	 .aluAdEL(aluAdEL_E),
	 .aluAdES(aluAdES_E),
	 .aluOv(aluOv_E)
    );

assign Op1_E = (RD1_E_Sel == 2'd0) ? RD1_E :
					(RD1_E_Sel == 2'd1) ? GPR_WD_W :
					(RD1_E_Sel == 2'd2) ? AO_M_AfterAOSel : 
					(RD1_E_Sel == 2'd3) ? CO_M : 0;
assign Op2_E = (ALUSrc_E == 1'd1) ? {{20{Instr_E[15]}}, Instr_E[15:0]} :
					(RD2_E_Sel == 2'd0) ? RD2_E :
					(RD2_E_Sel == 2'd1) ? GPR_WD_W :
					(RD2_E_Sel == 2'd2) ? AO_M_AfterAOSel : 
					(RD2_E_Sel == 2'd3) ? CO_M : 0;
assign RD2_to_M = (RD2_E_Sel == 2'd0) ? RD2_E :
					   (RD2_E_Sel == 2'd1) ? GPR_WD_W :
					   (RD2_E_Sel == 2'd2) ? AO_M_AfterAOSel : 0;
ALU E_ALU(
    .alu_A(Op1_E),
    .alu_B(Op2_E),
    .ALUCtrl(ALUCtrl_E),
	 .aluAdEL(aluAdEL_E),
	 .aluAdES(aluAdES_E),
	 .aluOv(aluOv_E),
    .alu_out(AO_E),
	 .excAdEL(excAdEL_E),
	 .excAdES(excAdES_E),
	 .excOv(excOv_E)
    );
	 
assign GPR_A3_E = (RegDst_E == 2'd0) ? Instr_E[20:16] :
						(RegDst_E == 2'd1) ? Instr_E[15:11] :
						(RegDst_E == 2'd2) ? 5'd31 : 0;
		
HILO E_HILO(
	 .clk(clk),
	 .reset(reset),
    .D1(Op1_E),
    .D2(Op2_E),
	 .HILOCtrl(HILOCtrl_E),
    .Start(Start_E),
    .Busy(Busy_E),
    .out(MO_E),
	 .HI(HI_E),
	 .LO(LO_E)
    );
	 
/**********  Stage_M  **********/
always @(posedge clk) begin
	if (reset || Req_M) begin
		Instr_M <= 32'd0;
		PC4_M <= 32'd0;
		AO_M <= 32'd0;
		RD2_M <= 32'd0;
		GPR_A3_M <= 5'd0;
		MO_M <= 32'd0;
		tmp_excCode_M <= 5'd0;
	end
	else begin
		Instr_M <= Instr_E;
		PC4_M <= PC4_E;
		AO_M <= AO_E;
		RD2_M <= RD2_to_M;
		GPR_A3_M <= GPR_A3_E;
		MO_M <= MO_E;
		tmp_excCode_M <= excCode_E;
	end
end

assign excCode_M = tmp_excCode_M ? tmp_excCode_M : 
						 excAdEL_M ? `AdEL :
						 excAdES_M ? `AdES : `Int;


Controller M_Controller(
    .Instr(Instr_M),
	 .RegWrite(RegWrite_M),
    .MemWrite(MemWrite_M),
    .PCSel(PCSel_M),
	 .RegDst(RegDst_M),
	 .AOSel(AOSel_M),
	 .CP0Write(CP0Write_M),
	 .EXLClr(EXLClr_M),
	 .LStype(LStype_M)
    );
/*	
DM M_DM(
    .clk(clk),
    .reset(reset),
    .WE(MemWrite_M),
    .A(AO_M),
    .WD(RD2_M),
    .PC(PC_M),
    .RD(DO_M)
    );
*/
BYTE M_BYTE(
    .Instr(Instr_M),
    .addr(AO_M),
	 .byteen(byteen_M),
    .ExtOp(ExtOp_M)
    );
	 
EXT M_EXT_1(
    .data_in(RD2_M),
    .byteen(byteen_M),
    .ExtOp(ExtOp_M),
    .data_out(m_data_wdata)
    );

EXT M_EXT_2(
    .data_in(DO_M_beforeEXT),
    .byteen(byteen_M),
    .ExtOp(ExtOp_M),
    .data_out(DO_M)
    );
	 
assign PC_M = PC4_M - 32'd4;
assign m_data_addr = (Req_M) ? 32'd0 : AO_M;
// assign m_data_wdata = RD2_M -> EXT -> out;
assign m_data_byteen = (MemWrite_M) ? byteen_M : 4'd0;
assign m_inst_addr = PC_M;
assign DO_M_beforeEXT = m_data_rdata; // DM out
assign AO_M_AfterAOSel = (AOSel_M) ? MO_M : AO_M;

CP0 M_CP0(
    .clk(clk),
    .reset(reset),
    .en(CP0Write_M),
    .CP0Add(Instr_M[15:11]),
    .CP0In(RD2_M),
    .CP0Out(CO_M),
    .VPC(PC_M),
    .BDIn(isDelaySlot_M),
    .ExcCodeIn(HWInt ? `Int : excCode_M),
    .HWInt(HWInt),
    .EXLClr(EXLClr_M),
    .EPCOut(EPC_M),
    .Req(Req_M)
    );
	 
wire errAlignL = ((LStype_M == 3'd3) && (|AO_M[1:0])) ||
					  ((LStype_M == 3'd2) && (AO_M[0]));
wire errOutOfRangeL = !(((AO_M >= 32'h0000_0000) && (AO_M <= 32'h0000_2FFF)) ||
								((AO_M >= 32'h0000_7F00) && (AO_M <= 32'h0000_7F0B)) ||
								((AO_M >= 32'h0000_7F10) && (AO_M <= 32'h0000_7F1B)) ||
								((AO_M >= 32'h0000_7F20) && (AO_M <= 32'h0000_7F23)));
wire errTimerL = (LStype_M == 3'd1 || LStype_M == 3'd2) && 
					  ((AO_M >= 32'h0000_7F00 && AO_M <= 32'h0000_7F0B) || 
					   (AO_M >= 32'h0000_7F10 && AO_M <= 32'h0000_7E1B));
assign excAdEL_M = (LStype_M == 3'd1 || LStype_M == 3'd2 || LStype_M == 3'd3) && 
						 (errAlignL || errOutOfRangeL || errTimerL);

wire errAlignS = ((LStype_M == 3'd6) && (|AO_M[1:0])) ||
					  ((LStype_M == 3'd5) && (AO_M[0]));
wire errOutOfRangeS = !(((AO_M >= 32'h0000_0000) && (AO_M <= 32'h0000_2FFF)) ||
								((AO_M >= 32'h0000_7F00) && (AO_M <= 32'h0000_7F0B)) ||
								((AO_M >= 32'h0000_7F10) && (AO_M <= 32'h0000_7F1B)) ||
								((AO_M >= 32'h0000_7F20) && (AO_M <= 32'h0000_7F23)));
wire errTimerS = (AO_M >= 32'h0000_7F08 && AO_M <= 32'h0000_7F0B) ||
					  (AO_M >= 32'h0000_7F18 && AO_M <= 32'h0000_7F1B) ||
					  (LStype_M != 3'd6 && AO_M >= 32'h0000_7F00);
assign excAdES_M = (LStype_M == 3'd4 || LStype_M == 3'd5 || LStype_M == 3'd6) && 
						 (errAlignS || errOutOfRangeS || errTimerS);
						 
assign MPC = PC_M;

/**********  Stage_W  **********/
always @(posedge clk) begin
	if (reset || Req_M) begin
		Instr_W <= 32'd0;
		PC8_W <= 32'd0;
		AO_W <= 32'd0;
		DO_W <= 32'd0;
		GPR_A3_W <= 5'd0;
		CO_W <= 5'd0;
	end
	else begin
		Instr_W <= Instr_M;
		PC8_W <= PC4_M + 32'd4;
		AO_W <= AO_M_AfterAOSel;
		DO_W <= DO_M;
		GPR_A3_W <= GPR_A3_M;
		CO_W <= CO_M;
	end
end

//always @(negedge clk) begin
//	if (Req_M) begin
//		Instr_W <= 32'd0;
//		PC8_W <= 32'd0;
// 	AO_W <= 32'd0;
//		DO_W <= 32'd0;
//		GPR_A3_W <= 5'd0;
//		CO_W <= 5'd0;
//	end
//end

Controller W_Controller(
    .Instr(Instr_W),
    .WDSel(WDSel_W),
    .RegWrite(RegWrite_W),
	 .RegDst(RegDst_W),
	 .isDelaySlot(isDelaySlot_M)
    );
assign GPR_WD_W = (WDSel_W == 2'd0) ? DO_W :
						(WDSel_W == 2'd1) ? AO_W :
						(WDSel_W == 2'd2) ? PC8_W : 
						(WDSel_W == 2'd3) ? CO_W : 0;

assign w_grf_we = RegWrite_W;
assign w_grf_addr = GPR_A3_W;
assign w_grf_wdata = GPR_WD_W;
assign w_inst_addr = PC8_W - 32'd8;
						
/********** HazardCtrl **********/
HazardCtrl HazardCtrl(
    .Instr_D(Instr_D),
    .Instr_E(Instr_E),
    .Instr_M(Instr_M),
    .Instr_W(Instr_W),
	 .RegWrite_E(RegWrite_E),
	 .RegWrite_M(RegWrite_M),
	 .RegWrite_W(RegWrite_W),
	 .RegDst_E(RegDst_E),
	 .RegDst_M(RegDst_M),
	 .RegDst_W(RegDst_W),
	 .Busy(Busy_E),
	 .Start(Start_E),
    .StallPC(StallPC),
    .StallD(StallD),
    .RD1_D_Sel(RD1_D_Sel),
    .RD2_D_Sel(RD2_D_Sel),
    .ClrE(ClrE),
    .RD1_E_Sel(RD1_E_Sel),
    .RD2_E_Sel(RD2_E_Sel)
    );
	 
endmodule
