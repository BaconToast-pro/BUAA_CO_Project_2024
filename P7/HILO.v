`timescale 1ns / 1ps
`include "constants.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:59:51 11/24/2024 
// Design Name: 
// Module Name:    HILO 
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
module HILO(
	 input clk,
	 input reset,
    input [31:0] D1,
    input [31:0] D2,
	 input [3:0] HILOCtrl,
    input Start,
    output reg Busy,
    output [31:0] out,
	 output reg [31:0] HI,
	 output reg [31:0] LO
    );
	
	reg [31:0] HItmp = 32'd0;
	reg [31:0] LOtmp = 32'd0;
	reg [3:0] max = 4'd0, cnt = 4'd0;
	
	always @(posedge clk) begin
		if (reset) begin
			HI <= 0;
			LO <= 0;
			HItmp <= 0;
			LOtmp <= 0;
		end
		else if (Busy == 0) begin
			case (HILOCtrl)
				`mduMthi: HI <= D1;
				`mduMtlo: LO <= D1;
				`mduMult: begin
					{HItmp, LOtmp} <= $signed(D1) * $signed(D2);
					max <= 5;
				end
				`mduMultu: begin
					{HItmp, LOtmp} <= $unsigned(D1) * $unsigned(D2);
					max <= 5;
				end
				`mduDiv: begin
					{HItmp, LOtmp} <= {$signed(D1) % $signed(D2), $signed(D1) / $signed(D2)};
					max <= 10;
				end
				`mduDivu: begin
					{HItmp, LOtmp} <= {$unsigned(D1) % $unsigned(D2), $unsigned(D1) / $unsigned(D2)};
					max <= 10;
				end
			endcase
		end
		else begin
			if (cnt == max - 1) {HI, LO} <= {HItmp, LOtmp};
			else {HI, LO} <= {HI, LO};
		end
	end
	
	always @(posedge clk) begin
		if (reset) begin
			cnt <= 0;
			Busy <= 0;
		end
		else if (Start) begin
			Busy <= 1'b1;
		end
		else if (~Start && Busy) begin
			if (cnt == max - 1) begin
				cnt <= 0;
				Busy <= 0;
			end
			else begin
				cnt <= cnt + 1;
			end
		end
	end
	
	assign out = (HILOCtrl == `mduMfhi) ? HI :
					 (HILOCtrl == `mduMflo) ? LO : 0;

endmodule
