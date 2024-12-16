`timescale 1ns / 1ps
`include "constants.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:50:27 12/13/2024 
// Design Name: 
// Module Name:    CP0 
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
module CP0(
    input clk,
    input reset,
    input en,
    input [4:0] CP0Add,
    input [31:0] CP0In,
    output [31:0] CP0Out,
    input [31:0] VPC,
    input BDIn,
    input [4:0] ExcCodeIn,
    input [5:0] HWInt,
    input EXLClr,
    output [31:0] EPCOut,
    output Req
    );
	
	wire int_req, exc_req;
	reg [31:0] SR, Cause, EPC;
	
	initial begin
		SR <= 32'd0;
		Cause <= 32'd0;
		EPC <= 32'd0;
	end
	
	always @(posedge clk) begin
		if (reset) begin
			SR <= 0;
			Cause <= 0;
			EPC <= 0;
		end
		else begin
			if (en) begin
				if (CP0Add == `SR) begin
					SR <= CP0In;
				end
				else if (CP0Add == `Cause) begin
					Cause <= CP0In;
				end
				else if (CP0Add == `EPC) begin
					EPC <= CP0In;
				end
				else begin
					// nop
				end
			end
		end
	end
	
	always @(posedge clk) begin
		if (reset) begin
			SR <= 0;
			Cause <= 0;
			EPC <= 0;
		end
		else begin
			`IP <= HWInt;
			if (Req) begin
				`EXL <= 1'b1;
				EPC <= BDIn ? (VPC - 32'd4) : VPC;
				`ExcCode <= int_req ? 5'd0 : ExcCodeIn;
				`BD <= BDIn;
			end
			if (EXLClr) begin
				`EXL <= 1'b0;
			end
		end
	end
	
	assign CP0Out = (CP0Add == `SR) ? SR :
						 (CP0Add == `Cause) ? Cause :
						 (CP0Add == `EPC) ? EPC : 0;
	assign int_req = (|(HWInt & `IM)) & `IE & (!`EXL);
	assign exc_req = (ExcCodeIn != 0) & (!`EXL);
	assign Req = int_req | exc_req;
	assign EPCOut = EPC;
	
endmodule
