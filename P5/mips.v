`timescale 1ns / 1ps
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
module mips(
    input clk,
    input reset
    );

/******** Declarations *********/
// F
wire StallPC;
wire [31:0] Instr_F;
wire [31:0] PC_F;
wire [31:0] PC;
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
// E
wire ClrE;
reg [31:0] Instr_E = 32'd0;
reg [31:0] PC4_E = 32'd0;
reg [31:0] RD1_E = 32'd0, RD2_E = 32'd0;
wire [2:0] ALUCtrl_E;
wire [1:0] RegDst_E;
wire RegWrite_E;
wire ALUSrc_E;
wire [1:0] RD1_E_Sel, RD2_E_Sel;
wire [31:0] Op1_E, Op2_E;
wire [31:0] AO_E;
wire [4:0] GPR_A3_E;
wire [31:0] RD2_to_M;
// M
reg [31:0] Instr_M = 32'd0;
reg [31:0] PC4_M = 32'd0;
reg [31:0] AO_M = 32'd0;
wire MemWrite_M;
wire RegWrite_M;
wire [1:0] RegDst_M;
wire [2:0] PCSel_M;
reg [31:0] RD2_M = 32'd0;
wire [31:0] DO_M;
wire [31:0] PC_M;
reg [4:0] GPR_A3_M;
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
/**********  Stage_F  **********/
PC F_PC(
    .clk(clk),
    .reset(reset),
    .EN(~StallPC),
    .NPC(PC),
    .PC(PC_F)
    );
	 
IM F_IM(
    .PC(PC_F),
    .RD(Instr_F)
    );

assign PC = (PCSel_D == 3'd0) ? PC_F + 32'd4 :
				(PCSel_D == 3'd1 || PCSel_D == 3'd2) ? NPC_D :
				(PCSel_D == 3'd3) ? RD1_D : 0;
				
/**********  Stage_D  **********/
always @(posedge clk) begin
	if (reset) begin
		Instr_D <= 32'd0;
		PC4_D <= 32'd0;
	end
	else if (StallD) begin
		Instr_D <= Instr_D;
		PC4_D <= PC4_D;
	end
	else begin
		Instr_D <= Instr_F;
		PC4_D <= PC_F + 32'd4;
	end
end

Controller D_Controller(
    .Instr(Instr_D),
    .PCSel(PCSel_D)
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
					(RD1_D_Sel == 2'd2) ? AO_M : 0;
assign RD2_D = (RD2_D_Sel == 2'd0) ? GPR_rt :
					(RD2_D_Sel == 2'd1) ? GPR_WD_W :
					(RD2_D_Sel == 2'd2) ? AO_M : 0;
assign equ_D = (RD1_D == RD2_D);
assign PC_D = PC8_W - 32'd8;

/**********  Stage_E  **********/
always @(posedge clk) begin
	if (reset) begin
		Instr_E <= 32'd0;
		PC4_E <= 32'd0;
		RD1_E <= 32'd0;
		RD2_E <= 32'd0;
	end
	else if (ClrE) begin
		Instr_E <= 32'd0;
	end
	else begin
		Instr_E <= Instr_D;
		PC4_E <= PC4_D;
		RD1_E <= RD1_D;
		RD2_E <= RD2_D;
	end
end

Controller E_Controller(
    .Instr(Instr_E),
	 .RegWrite(RegWrite_E),
    .ALUCtrl(ALUCtrl_E),
    .ALUSrc(ALUSrc_E),
    .RegDst(RegDst_E)
    );

assign Op1_E = (RD1_E_Sel == 2'd0) ? RD1_E :
					(RD1_E_Sel == 2'd1) ? GPR_WD_W :
					(RD1_E_Sel == 2'd2) ? AO_M : 0;
assign Op2_E = (ALUSrc_E == 1'd1) ? {{20{Instr_E[15]}}, Instr_E[15:0]} :
					(RD2_E_Sel == 2'd0) ? RD2_E :
					(RD2_E_Sel == 2'd1) ? GPR_WD_W :
					(RD2_E_Sel == 2'd2) ? AO_M : 0;
assign RD2_to_M = (RD2_E_Sel == 2'd0) ? RD2_E :
					   (RD2_E_Sel == 2'd1) ? GPR_WD_W :
					   (RD2_E_Sel == 2'd2) ? AO_M : 0;
ALU E_ALU(
    .alu_A(Op1_E),
    .alu_B(Op2_E),
    .ALUCtrl(ALUCtrl_E),
    .alu_out(AO_E)
    );
	 
assign GPR_A3_E = (RegDst_E == 2'd0) ? Instr_E[20:16] :
						(RegDst_E == 2'd1) ? Instr_E[15:11] :
						(RegDst_E == 2'd2) ? 5'd31 : 0;
		
/**********  Stage_M  **********/
always @(posedge clk) begin
	if (reset) begin
		Instr_M <= 32'd0;
		PC4_M <= 32'd0;
		AO_M <= 32'd0;
		RD2_M <= 32'd0;
		GPR_A3_M <= 5'd0;
	end
	else begin
		Instr_M <= Instr_E;
		PC4_M <= PC4_E;
		AO_M <= AO_E;
		RD2_M <= RD2_to_M;
		GPR_A3_M <= GPR_A3_E;
	end
end

Controller M_Controller(
    .Instr(Instr_M),
	 .RegWrite(RegWrite_M),
    .MemWrite(MemWrite_M),
    .PCSel(PCSel_M),
	 .RegDst(RegDst_M)
    );
	
DM M_DM(
    .clk(clk),
    .reset(reset),
    .WE(MemWrite_M),
    .A(AO_M),
    .WD(RD2_M),
    .PC(PC_M),
    .RD(DO_M)
    );
assign PC_M = PC4_M - 32'd4;

/**********  Stage_W  **********/
always @(posedge clk) begin
	if (reset) begin
		Instr_W <= 32'd0;
		PC8_W <= 32'd0;
		AO_W <= 32'd0;
		DO_W <= 32'd0;
		GPR_A3_W <= 5'd0;
	end
	else begin
		Instr_W <= Instr_M;
		PC8_W <= PC4_M + 32'd4;
		AO_W <= AO_M;
		DO_W <= DO_M;
		GPR_A3_W <= GPR_A3_M;
	end
end

Controller W_Controller(
    .Instr(Instr_W),
    .WDSel(WDSel_W),
    .RegWrite(RegWrite_W),
	 .RegDst(RegDst_W)
    );
assign GPR_WD_W = (WDSel_W == 2'd0) ? DO_W :
						(WDSel_W == 2'd1) ? AO_W :
						(WDSel_W == 2'd2) ? PC8_W : 0;
						
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
    .StallPC(StallPC),
    .StallD(StallD),
    .RD1_D_Sel(RD1_D_Sel),
    .RD2_D_Sel(RD2_D_Sel),
    .ClrE(ClrE),
    .RD1_E_Sel(RD1_E_Sel),
    .RD2_E_Sel(RD2_E_Sel)
    );
	 
endmodule
