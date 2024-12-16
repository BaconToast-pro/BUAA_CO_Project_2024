`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:59:05 11/24/2024 
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
    input [31:0] data_in,
    input [3:0] byteen,
    input ExtOp,
    output reg [31:0] data_out
    );
	
	always @(*) begin
		case (byteen)
			4'b0000: data_out = 32'd0;
			4'b0001: begin
				if (ExtOp == 1'b0) data_out = {24'd0, data_in[7:0]};
				else data_out = {{24{data_in[7]}}, data_in[7:0]};
			end
			4'b0010: begin
				if (ExtOp == 1'b0) data_out = {16'd0, data_in[7:0], 8'd0};
				else data_out = {{24{data_in[15]}}, data_in[15:8]};
			end
			4'b0100: begin
				if (ExtOp == 1'b0) data_out = {8'd0, data_in[7:0], 16'd0};
				else data_out = {{24{data_in[23]}}, data_in[23:16]};
			end
			4'b1000: begin
				if (ExtOp == 1'b0) data_out = {data_in[7:0], 24'd0};
				else data_out = {{24{data_in[31]}}, data_in[31:24]};
			end
			4'b0011: begin
				if (ExtOp == 1'b0) data_out = {16'd0, data_in[15:0]};
				else data_out = {{16{data_in[15]}}, data_in[15:0]};
			end
			4'b1100: begin
				if (ExtOp == 1'b0) data_out = {data_in[15:0], 16'd0};
				else data_out = {{16{data_in[31]}}, data_in[31:16]};
			end
			4'b1111: data_out = data_in;
		endcase
	end

endmodule
