`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:55:12 11/14/2024 
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
    input [31:0] PC,
    output [31:0] RD
    );
	
	wire [31:0] addr;
	reg [31:0] im[0:4095];
	
	initial begin
		$readmemh("code.txt", im);
	end
	
	assign addr = PC - 32'h0000_3000;
	assign RD = im[(addr >> 2)];

endmodule
