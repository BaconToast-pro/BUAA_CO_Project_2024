`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:12:11 11/14/2024 
// Design Name: 
// Module Name:    DM 
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
module DM(
    input clk,
    input reset,
    input WE,
    input [31:0] A,
    input [31:0] WD,
    input [31:0] PC,
    output [31:0] RD
    );
	 
	reg [31:0] dm[0:3071];
	wire [11:0] MemAddr;
	wire [31:0] Addr;
	integer i;
	
	always @(posedge clk) begin
		if (reset) begin
			for (i = 0; i < 3072; i = i + 1) begin
				dm[i] <= 32'h0000_0000;
			end
		end
		else begin
			if (WE) begin
				dm[MemAddr] <= WD;
				$display("%d@%h: *%h <= %h", $time, PC, A, WD);
			end
		end
	end

	assign MemAddr = A >> 2;
	assign RD = dm[MemAddr];
	
endmodule

