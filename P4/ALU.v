`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:20:50 10/30/2024 
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
    input [2:0] ALUctr,
    input [31:0] Op1,
    input [31:0] Op2,
    output Zero,
    output reg [31:0] ALUResult
    );

	always @(*) begin
		case (ALUctr)
			3'b000: ALUResult = Op1 + Op2;
			3'b001: ALUResult = Op1 - Op2;
			3'b010: ALUResult = Op1 | Op2;
			3'b011: ALUResult = Op2 << 16;
		endcase
	end
	
	assign Zero = (ALUResult == 0) ? 1'b1 : 1'b0;

endmodule
