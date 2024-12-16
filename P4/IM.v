`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:53:15 10/30/2024 
// Design Name: 
// Module Name:    IM 
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
module IM(
    input clk,
    input reset,
    input [31:0] NPC,
    output [31:0] Instr,
    output reg [31:0] PC
    );
	
	reg [31:0] im[0:4095];
	wire [31:0] addr;
	
	initial begin
		$readmemh("code.txt", im);
		PC = 32'h0000_3000;
	end
	
	always @(posedge clk) begin
		if (reset) begin
			PC <= 32'h0000_3000;
		end
		else begin
			PC <= NPC;
		end
	end
	
	assign addr = PC - 32'h0000_3000;
	assign Instr = im[(addr >> 2)];

endmodule
