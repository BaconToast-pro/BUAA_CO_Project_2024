`timescale 1ns / 1ps
`include "constants.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:00:05 11/14/2024 
// Design Name: 
// Module Name:    ALU 
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
module ALU(
    input [31:0] alu_A,
    input [31:0] alu_B,
    input [3:0] ALUCtrl,
	 input aluAdEL,
	 input aluAdES,
	 input aluOv,
    output reg [31:0] alu_out,
	 output excAdEL,
	 output excAdES,
	 output excOv
    );
	 
	wire [32:0] ext_A = {alu_A[31], alu_A}, ext_B = {alu_B[31], alu_B};
	wire [32:0] ext_add = ext_A + ext_B;
	wire [32:0] ext_sub = ext_A - ext_B;
	assign excAdEL = (aluAdEL) && 
						  ((ALUCtrl == `aluAdd && ext_add[32] != ext_add[31]) ||
						  (ALUCtrl == `aluSub && ext_sub[32] != ext_sub[31]));
	assign excAdES = (aluAdES) && 
						  ((ALUCtrl == `aluAdd && ext_add[32] != ext_add[31]) ||
						  (ALUCtrl == `aluSub && ext_sub[32] != ext_sub[31]));
	assign excOv = (aluOv) && 
						((ALUCtrl == `aluAdd && ext_add[32] != ext_add[31]) ||
					   (ALUCtrl == `aluSub && ext_sub[32] != ext_sub[31]) || 
						(ALUCtrl == `aluAddi && ext_add[32] != ext_add[31]));
						  
	always @(*) begin
		case (ALUCtrl)
			`aluAdd: alu_out = alu_A + alu_B;
			`aluSub: alu_out = alu_A - alu_B;
			`aluAnd: alu_out = alu_A & alu_B;
			`aluOr: alu_out = alu_A | alu_B;
			`aluSlt: alu_out = $signed(alu_A) < $signed(alu_B);
			`aluSltu: alu_out = $unsigned(alu_A) < $unsigned(alu_B);
			`aluLui: alu_out = alu_B << 16;
			`aluOri: alu_out = alu_A | {16'd0, alu_B[15:0]};
			`aluAddi: alu_out = alu_A + alu_B;
			`aluAndi: alu_out = alu_A & {16'd0, alu_B[15:0]};
		endcase
	end

endmodule
