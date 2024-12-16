`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:07:23 11/14/2024 
// Design Name: 
// Module Name:    GRF 
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
module GRF(
    input clk,
    input reset,
    input WE,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD,
	 input [31:0] PC,
    output [31:0] RD1,
    output [31:0] RD2
    );

	integer i;
	reg [31:0] regs[0:31];
	
	initial begin
		for (i = 0; i < 32; i = i + 1) begin
			regs[i] <= 32'h0000_0000;
		end
	end
	
	always @(posedge clk) begin
		if (reset) begin
			for (i = 0; i < 32; i = i + 1) begin
				regs[i] <= 32'h0000_0000;
			end
		end
		else begin
			if (WE && A3 != 5'd0) begin
				$display("%d@%h: $%d <= %h", $time, PC, A3, WD);
				regs[A3] <= WD;
			end
		end
	end
	
	assign RD1 = regs[A1];
	assign RD2 = regs[A2];

endmodule
