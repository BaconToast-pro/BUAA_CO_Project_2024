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
	
	/**********  Stage_D  **********/
	always @(*) begin
		case (Instr_D[31:26])
			`nop: begin
				case (Instr_D[5:0])
					`add: begin
						rs_Tuse = `add_rs_Tuse;
						rt_Tuse = `add_rt_Tuse;
					end
					`sub: begin
						rs_Tuse = `sub_rs_Tuse;
						rt_Tuse = `sub_rt_Tuse;
					end
					`nop: begin
						rs_Tuse = `nop_rs_Tuse;
						rt_Tuse = `nop_rt_Tuse;
					end
					`jr: begin
						rs_Tuse = `jr_rs_Tuse;
						rt_Tuse = `jr_rt_Tuse;
					end
				endcase
			end
			`ori: begin
				rs_Tuse = `ori_rs_Tuse;
				rt_Tuse = `ori_rt_Tuse;
			end
			`lui: begin
				rs_Tuse = `lui_rs_Tuse;
				rt_Tuse = `lui_rt_Tuse;
			end
			`lw: begin
				rs_Tuse = `lw_rs_Tuse;
				rt_Tuse = `lw_rt_Tuse;
			end
			`sw: begin
				rs_Tuse = `sw_rs_Tuse;
				rt_Tuse = `sw_rt_Tuse;
			end
			`beq: begin
				rs_Tuse = `beq_rs_Tuse;
				rt_Tuse = `beq_rt_Tuse;
			end
			`jal: begin
				rs_Tuse = `jal_rs_Tuse;
				rt_Tuse = `jal_rt_Tuse;
			end
		endcase
	end
	
	/**********  Stage_E  **********/
	always @(*) begin
		case (Instr_E[31:26])
			`nop: begin
				case (Instr_E[5:0])
					`add: begin
						E_Tnew = `add_E_Tnew;
					end
					`sub: begin
						E_Tnew = `sub_E_Tnew;
					end
					`nop: begin
						E_Tnew = `nop_E_Tnew;
					end
					`jr: begin
						E_Tnew = `jr_E_Tnew;
					end
				endcase
			end
			`ori: begin
				E_Tnew = `ori_E_Tnew;
			end
			`lui: begin
				E_Tnew = `lui_E_Tnew;
			end
			`lw: begin
				E_Tnew = `lw_E_Tnew;
			end
			`sw: begin
				E_Tnew = `sw_E_Tnew;
			end
			`beq: begin
				E_Tnew = `beq_E_Tnew;
			end
			`jal: begin
				E_Tnew = `jal_E_Tnew;
			end
		endcase
	end

	/**********  Stage_M  **********/
	always @(*) begin
		case (Instr_M[31:26])
			`nop: begin
				case (Instr_M[5:0])
					`add: begin
						M_Tnew = `add_M_Tnew;
					end
					`sub: begin
						M_Tnew = `sub_M_Tnew;
					end
					`nop: begin
						M_Tnew = `nop_M_Tnew;
					end
					`jr: begin
						M_Tnew = `jr_M_Tnew;
					end
				endcase
			end
			`ori: begin
				M_Tnew = `ori_M_Tnew;
			end
			`lui: begin
				M_Tnew = `lui_M_Tnew;
			end
			`lw: begin
				M_Tnew = `lw_M_Tnew;
			end
			`sw: begin
				M_Tnew = `sw_M_Tnew;
			end
			`beq: begin
				M_Tnew = `beq_M_Tnew;
			end
			`jal: begin
				M_Tnew = `jal_M_Tnew;
			end
		endcase
	end

	/**********  Stage_W  **********/
	always @(*) begin
		case (Instr_W[31:26])
			`nop: begin
				case (Instr_W[5:0])
					`add: begin
						W_Tnew = `add_W_Tnew;
					end
					`sub: begin
						W_Tnew = `sub_W_Tnew;
					end
					`nop: begin
						W_Tnew = `nop_W_Tnew;
					end
					`jr: begin
						W_Tnew = `jr_W_Tnew;
					end
				endcase
			end
			`ori: begin
				W_Tnew = `ori_W_Tnew;
			end
			`lui: begin
				W_Tnew = `lui_W_Tnew;
			end
			`lw: begin
				W_Tnew = `lw_W_Tnew;
			end
			`sw: begin
				W_Tnew = `sw_W_Tnew;
			end
			`beq: begin
				W_Tnew = `beq_W_Tnew;
			end
			`jal: begin
				W_Tnew = `jal_W_Tnew;
			end
		endcase
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
	
	assign Stall = Stall_RS | Stall_RT;
	assign StallPC = Stall;
	assign StallD = Stall;
	assign ClrE = Stall;
	
	// ForwardCtrl
	assign RD1_D_Sel = (A1_D == A3_M && A1_D != 5'd0 && M_Tnew == 2'd0 && RegWrite_M == 1'b1) ? 2'd2 :
							 (A1_D == A3_W && A1_D != 5'd0 && W_Tnew == 2'd0 && RegWrite_W == 1'b1) ? 2'd1 : 2'd0;
	assign RD2_D_Sel = (A2_D == A3_M && A2_D != 5'd0 && M_Tnew == 2'd0 && RegWrite_M == 1'b1) ? 2'd2 :
							 (A2_D == A3_W && A2_D != 5'd0 && W_Tnew == 2'd0 && RegWrite_W == 1'b1) ? 2'd1 : 2'd0;
	assign RD1_E_Sel = (A1_E == A3_M && A1_E != 5'd0 && M_Tnew == 2'd0 && RegWrite_M == 1'b1) ? 2'd2 :
							 (A1_E == A3_W && A1_E != 5'd0 && W_Tnew == 2'd0 && RegWrite_W == 1'b1) ? 2'd1 : 2'd0;
	assign RD2_E_Sel = (A2_E == A3_M && A2_E != 5'd0 && M_Tnew == 2'd0 && RegWrite_M == 1'b1) ? 2'd2 :
							 (A2_E == A3_W && A2_E != 5'd0 && W_Tnew == 2'd0 && RegWrite_W == 1'b1) ? 2'd1 : 2'd0;	
endmodule
