`timescale 1ns / 1ps
`include "constants.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:34:01 11/15/2024 
// Design Name: 
// Module Name:    HazardCtrl 
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
module HazardCtrl(
    input [31:0] Instr_D,
    input [31:0] Instr_E,
    input [31:0] Instr_M,
    input [31:0] Instr_W,
	 input RegWrite_E,
	 input RegWrite_M,
	 input RegWrite_W,
	 input [1:0] RegDst_E,
	 input [1:0] RegDst_M,
	 input [1:0] RegDst_W,
	 input Busy,
	 input Start,
    output StallPC,
    output StallD,
    output [1:0] RD1_D_Sel,
    output [1:0] RD2_D_Sel,
    output ClrE,
    output [1:0] RD1_E_Sel,
    output [1:0] RD2_E_Sel
    );
	
	/********** Declarations  **********/
	reg [1:0] rs_Tuse, rt_Tuse, E_Tnew, M_Tnew, W_Tnew;
	wire [4:0] A1_D = Instr_D[25:21], A2_D = Instr_D[20:16];
	wire [4:0] A1_E = Instr_E[25:21], A2_E = Instr_E[20:16];
	wire [4:0] A1_M = Instr_M[25:21], A2_M = Instr_M[20:16];
	wire [4:0] A1_W = Instr_W[25:21], A2_W = Instr_W[20:16];
	wire [4:0] A3_E, A3_M, A3_W;
	assign A3_E = (RegDst_E == 2'd0) ? Instr_E[20:16] :
					  (RegDst_E == 2'd1) ? Instr_E[15:11] : 5'd31;
	assign A3_M = (RegDst_M == 2'd0) ? Instr_M[20:16] :
					  (RegDst_M == 2'd1) ? Instr_M[15:11] : 5'd31;
	assign A3_W = (RegDst_W == 2'd0) ? Instr_W[20:16] :
					  (RegDst_W == 2'd1) ? Instr_W[15:11] : 5'd31;
	
	// StallCtrl
	wire Stall_RS0_E2, Stall_RS0_E1, Stall_RS0_M1, Stall_RS1_E2;
	wire Stall_RT0_E2, Stall_RT0_E1, Stall_RT0_M1, Stall_RT1_E2;
	wire Stall_RS, Stall_RT, Stall;
	reg Stall_CP0_E, Stall_CP0_M;
	
	/**********  Stage_D  **********/
	always @(*) begin
		if (Instr_D[31:26] == `special) begin
			if (Instr_D[5:0] == `add || Instr_D[5:0] == `sub || Instr_D[5:0] == `and_ || 
				Instr_D[5:0] == `or_ || Instr_D[5:0] == `slt || Instr_D[5:0] == `sltu) begin
				rs_Tuse = `R_rs_Tuse;
				rt_Tuse = `R_rt_Tuse; 					
			end
			else if (Instr_D[5:0] == `mult || Instr_D[5:0] == `multu ||
					  Instr_D[5:0] == `div || Instr_D[5:0] == `divu) begin
				rs_Tuse = `Md_rs_Tuse;
				rt_Tuse = `Md_rt_Tuse;
			end
			else if (Instr_D[5:0] == `mthi || Instr_D[5:0] == `mtlo) begin
				rs_Tuse = `Mt_rs_Tuse;
				rt_Tuse = `Mt_rt_Tuse;
			end
			else if (Instr_D[5:0] == `mfhi || Instr_D[5:0] == `mflo) begin
				rs_Tuse = `Mf_rs_Tuse;
				rt_Tuse = `Mf_rt_Tuse;
			end
			else if (Instr_D[5:0] == `jr) begin
				rs_Tuse = `Jr_rs_Tuse;
				rt_Tuse = `Jr_rt_Tuse;
			end
			else if (Instr_D[5:0] == `nop) begin
				rs_Tuse = `Nop_rs_Tuse;
				rt_Tuse = `Nop_rt_Tuse;
			end
			else begin
				// add new
			end
		end
		else if (Instr_D[31:26] == `lui || Instr_D[31:26] == `addi ||
			Instr_D[31:26] == `andi || Instr_D[31:26] == `ori) begin
			rs_Tuse = `I_rs_Tuse;
			rt_Tuse = `I_rt_Tuse;
		end
		else if (Instr_D[31:26] == `lb || Instr_D[31:26] == `lh || Instr_D[31:26] == `lw) begin
			rs_Tuse = `Load_rs_Tuse;
			rt_Tuse = `Load_rt_Tuse;
		end
		else if (Instr_D[31:26] == `sb || Instr_D[31:26] == `sh || Instr_D[31:26] == `sw) begin
			rs_Tuse = `Store_rs_Tuse;
			rt_Tuse = `Store_rt_Tuse;
		end
		else if (Instr_D[31:26] == `beq || Instr_D[31:26] == `bne) begin
			rs_Tuse = `Branch_rs_Tuse;
			rt_Tuse = `Branch_rt_Tuse;
		end
		else if (Instr_D[31:26] == `jal) begin
			rs_Tuse = `Jump_rs_Tuse;
			rt_Tuse = `Jump_rt_Tuse;
		end
		else begin
			// add new
		end
	end
	
	/**********  Stage_E  **********/
	always @(*) begin
		Stall_CP0_E = 0;
		if (Instr_E[31:26] == `special) begin
			if (Instr_E[5:0] == `add || Instr_E[5:0] == `sub || Instr_E[5:0] == `and_ || 
				Instr_E[5:0] == `or_ || Instr_E[5:0] == `slt || Instr_E[5:0] == `sltu) begin
				E_Tnew = `R_E_Tnew;		
			end
			else if (Instr_E[5:0] == `mult || Instr_E[5:0] == `multu ||
					  Instr_E[5:0] == `div || Instr_E[5:0] == `divu) begin
				E_Tnew = `Md_E_Tnew;
			end
			else if (Instr_E[5:0] == `mthi || Instr_E[5:0] == `mtlo) begin
				E_Tnew = `Mt_E_Tnew;
			end
			else if (Instr_E[5:0] == `mfhi || Instr_E[5:0] == `mflo) begin
				E_Tnew = `Mf_E_Tnew;
			end
			else if (Instr_E[5:0] == `jr) begin
				E_Tnew = `Jr_E_Tnew;
			end
			else if (Instr_E[5:0] == `nop) begin
				E_Tnew = `Nop_E_Tnew;
			end
			else begin
				// add new
			end
		end
		else if (Instr_E[31:26] == `cop0) begin
			if (Instr_E[25:20] == `mfc0) begin
				Stall_CP0_E = 1;
			end
			else;
		end
		else if (Instr_E[31:26] == `lui || Instr_E[31:26] == `addi ||
			Instr_E[31:26] == `andi || Instr_E[31:26] == `ori) begin
			E_Tnew = `I_E_Tnew;
		end
		else if (Instr_E[31:26] == `lb || Instr_E[31:26] == `lh || Instr_E[31:26] == `lw) begin
			E_Tnew = `Load_E_Tnew;
		end
		else if (Instr_E[31:26] == `sb || Instr_E[31:26] == `sh || Instr_E[31:26] == `sw) begin
			E_Tnew = `Store_E_Tnew;
		end
		else if (Instr_E[31:26] == `beq || Instr_E[31:26] == `bne) begin
			E_Tnew = `Branch_E_Tnew;
		end
		else if (Instr_E[31:26] == `jal) begin
			E_Tnew = `Jump_E_Tnew;
		end
		else begin
			// add new
		end
	end
	
	/**********  Stage_M  **********/
	always @(*) begin
		Stall_CP0_M = 0;
		if (Instr_M[31:26] == `special) begin
			if (Instr_M[5:0] == `add || Instr_M[5:0] == `sub || Instr_M[5:0] == `and_ || 
				Instr_M[5:0] == `or_ || Instr_M[5:0] == `slt || Instr_M[5:0] == `sltu) begin
				M_Tnew = `R_M_Tnew;		
			end
			else if (Instr_M[5:0] == `mult || Instr_M[5:0] == `multu ||
					  Instr_M[5:0] == `div || Instr_M[5:0] == `divu) begin
				M_Tnew = `Md_M_Tnew;
			end
			else if (Instr_M[5:0] == `mthi || Instr_M[5:0] == `mtlo) begin
				M_Tnew = `Mt_M_Tnew;
			end
			else if (Instr_M[5:0] == `mfhi || Instr_M[5:0] == `mflo) begin
				M_Tnew = `Mf_M_Tnew;
			end
			else if (Instr_M[5:0] == `jr) begin
				M_Tnew = `Jr_M_Tnew;
			end
			else if (Instr_M[5:0] == `nop) begin
				M_Tnew = `Nop_M_Tnew;
			end
			else begin
				// add new
			end
		end
		else if (Instr_M[31:26] == `cop0) begin
			if (Instr_M[25:21] == `mfc0) begin
				Stall_CP0_M = 1;
			end
			else;
		end
		else if (Instr_M[31:26] == `lui || Instr_M[31:26] == `addi ||
			Instr_M[31:26] == `andi || Instr_M[31:26] == `ori) begin
			M_Tnew = `I_M_Tnew;
		end
		else if (Instr_M[31:26] == `lb || Instr_M[31:26] == `lh || Instr_M[31:26] == `lw) begin
			M_Tnew = `Load_M_Tnew;
		end
		else if (Instr_M[31:26] == `sb || Instr_M[31:26] == `sh || Instr_M[31:26] == `sw) begin
			M_Tnew = `Store_M_Tnew;
		end
		else if (Instr_M[31:26] == `beq || Instr_M[31:26] == `bne) begin
			M_Tnew = `Branch_M_Tnew;
		end
		else if (Instr_M[31:26] == `jal) begin
			M_Tnew = `Jump_M_Tnew;
		end
		else begin
			// add new
		end
	end

	/**********  Stage_W  **********/
	always @(*) begin
		if (Instr_W[31:26] == `special) begin
			if (Instr_W[5:0] == `add || Instr_W[5:0] == `sub || Instr_W[5:0] == `and_ || 
				Instr_W[5:0] == `or_ || Instr_W[5:0] == `slt || Instr_W[5:0] == `sltu) begin
				W_Tnew = `R_W_Tnew;		
			end
			else if (Instr_W[5:0] == `mult || Instr_W[5:0] == `multu ||
					  Instr_W[5:0] == `div || Instr_W[5:0] == `divu) begin
				W_Tnew = `Md_W_Tnew;
			end
			else if (Instr_W[5:0] == `mthi || Instr_W[5:0] == `mtlo) begin
				W_Tnew = `Mt_W_Tnew;
			end
			else if (Instr_W[5:0] == `mfhi || Instr_W[5:0] == `mflo) begin
				W_Tnew = `Mf_W_Tnew;
			end
			else if (Instr_W[5:0] == `jr) begin
				W_Tnew = `Jr_W_Tnew;
			end
			else if (Instr_W[5:0] == `nop) begin
				W_Tnew = `Nop_W_Tnew;
			end
			else begin
				// add new
			end
		end
		else if (Instr_W[31:26] == `lui || Instr_W[31:26] == `addi ||
			Instr_W[31:26] == `andi || Instr_W[31:26] == `ori) begin
			W_Tnew = `I_W_Tnew;
		end
		else if (Instr_W[31:26] == `lb || Instr_W[31:26] == `lh || Instr_W[31:26] == `lw) begin
			W_Tnew = `Load_W_Tnew;
		end
		else if (Instr_W[31:26] == `sb || Instr_W[31:26] == `sh || Instr_W[31:26] == `sw) begin
			W_Tnew = `Store_W_Tnew;
		end
		else if (Instr_W[31:26] == `beq || Instr_W[31:26] == `bne) begin
			W_Tnew = `Branch_W_Tnew;
		end
		else if (Instr_W[31:26] == `jal) begin
			W_Tnew = `Jump_W_Tnew;
		end
		else begin
			// add new
		end
	end

	/**********  HazardCtrl  **********/
	// StallCtrl
	assign Stall_RS0_E2 = (rs_Tuse == 2'd0) & (E_Tnew == 2'd2) & (A1_D == A3_E) & (A1_D != 5'd0) & RegWrite_E;
	assign Stall_RS0_E1 = (rs_Tuse == 2'd0) & (E_Tnew == 2'd1) & (A1_D == A3_E) & (A1_D != 5'd0) & RegWrite_E;
	assign Stall_RS0_M1 = (rs_Tuse == 2'd0) & (M_Tnew == 2'd1) & (A1_D == A3_M) & (A1_D != 5'd0) & RegWrite_M;
	assign Stall_RS1_E2 = (rs_Tuse == 2'd1) & (E_Tnew == 2'd2) & (A1_D == A3_E) & (A1_D != 5'd0) & RegWrite_E;
	assign Stall_RS = Stall_RS0_E2 | Stall_RS0_E1 | Stall_RS0_M1 | Stall_RS1_E2;
	
	assign Stall_RT0_E2 = (rt_Tuse == 2'd0) & (E_Tnew == 2'd2) & (A2_D == A3_E) & (A2_D != 5'd0) & RegWrite_E;
	assign Stall_RT0_E1 = (rt_Tuse == 2'd0) & (E_Tnew == 2'd1) & (A2_D == A3_E) & (A2_D != 5'd0) & RegWrite_E;
	assign Stall_RT0_M1 = (rt_Tuse == 2'd0) & (M_Tnew == 2'd1) & (A2_D == A3_M) & (A2_D != 5'd0) & RegWrite_M;
	assign Stall_RT1_E2 = (rt_Tuse == 2'd1) & (E_Tnew == 2'd2) & (A2_D == A3_E) & (A2_D != 5'd0) & RegWrite_E;
	assign Stall_RT = Stall_RT0_E2 | Stall_RT0_E1 | Stall_RT0_M1 | Stall_RT1_E2;
	
	assign Stall = Stall_RS | Stall_RT | Busy | Start; //| Stall_CP0_E | Stall_CP0_M;
	assign StallPC = Stall;
	assign StallD = Stall;
	assign ClrE = Stall;
	
	// ForwardCtrl
	assign RD1_D_Sel = (A1_D == A3_M && A1_D != 5'd0 && M_Tnew == 2'd0 && RegWrite_M == 1'b1) ? 2'd2 :
							 (A1_D == A3_W && A1_D != 5'd0 && W_Tnew == 2'd0 && RegWrite_W == 1'b1) ? 2'd1 : 2'd0;
	assign RD2_D_Sel = (A2_D == A3_M && A2_D != 5'd0 && M_Tnew == 2'd0 && RegWrite_M == 1'b1) ? 2'd2 :
							 (A2_D == A3_W && A2_D != 5'd0 && W_Tnew == 2'd0 && RegWrite_W == 1'b1) ? 2'd1 : 2'd0;
	assign RD1_E_Sel = (A1_E == A3_M && A1_E != 5'd0 && Stall_CP0_M == 1 && RegWrite_M == 1'b1) ? 2'd3 :
							 (A1_E == A3_M && A1_E != 5'd0 && M_Tnew == 2'd0 && RegWrite_M == 1'b1) ? 2'd2 :
							 (A1_E == A3_W && A1_E != 5'd0 && W_Tnew == 2'd0 && RegWrite_W == 1'b1) ? 2'd1 : 2'd0;
	assign RD2_E_Sel = (A1_E == A3_M && A1_E != 5'd0 && Stall_CP0_M == 1 && RegWrite_M == 1'b1) ? 2'd3 : 
						    (A2_E == A3_M && A2_E != 5'd0 && M_Tnew == 2'd0 && RegWrite_M == 1'b1) ? 2'd2 :
							 (A2_E == A3_W && A2_E != 5'd0 && W_Tnew == 2'd0 && RegWrite_W == 1'b1) ? 2'd1 : 2'd0;	
endmodule
