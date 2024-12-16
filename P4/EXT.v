`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:08:44 10/30/2024 
// Design Name: 
// Module Name:    EXT 
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
module EXT(
    input [15:0] Imm,
    input ExtOp,
    output [31:0] Imm32
    );

	assign Imm32 = (ExtOp == 1'b0) ? {{16{1'b0}}, Imm} : {{16{Imm[15]}}, Imm};

endmodule
