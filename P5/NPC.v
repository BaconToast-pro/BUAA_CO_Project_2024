`timescale 1ns / 1ps
`include "constants.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:07:07 11/14/2024 
// Design Name: 
// Module Name:    NPC 
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
module NPC(
    input [31:0] PC,
    input [25:0] IMM,
    input [2:0] PCSel,
    input equ,
    output reg [31:0] NPC
    );
	
	always @(*) begin
		case (PCSel)
			`pcBeq: begin
				if (equ) begin
					NPC = PC + ({{16{IMM[15]}}, IMM[15:0]} << 2);
				end
				else begin
					NPC = PC + 32'd4;
				end
			end
			`pcJal: begin
				NPC = {PC[31:28], IMM, 2'd0};
			end
		endcase
	end

endmodule
