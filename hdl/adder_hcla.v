`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Dmitry Matyunin (https://github.com/mcjtag)
// 
// Create Date: 09.07.2024 11:30:57
// Design Name: adder
// Module Name adder_hcla
// Description: Hierarchical Carry Look-Ahead
// License: MIT
//  Copyright (c) 2024 Dmitry Matyunin
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
// 
//////////////////////////////////////////////////////////////////////////////////

module adder_hcla #(
	parameter WIDTH = 16,
	parameter SUBNUM = 4
)
(
	input wire [WIDTH-1:0]a,
	input wire [WIDTH-1:0]b,
	input wire ci,
	output wire [WIDTH:0]po
);

localparam GPW = WIDTH / SUBNUM;
localparam GP0_W = GPW;
localparam GP0_N = WIDTH / GPW;
localparam GP1_W = GP0_N;

reg [WIDTH-1:0]cin;
reg [WIDTH-1:0]g, p, s;

reg [GP0_W-1:0]g0[GP0_N-1:0];
reg [GP0_W-1:0]p0[GP0_N-1:0];
reg [GP0_W-1:0]c0[GP0_N-1:0];

reg [GP0_N-1:0]G0, P0;
reg [GP0_W-2:0]C0[GP0_N-1:0];

reg [GP1_W-1:0]c1;
reg [GP1_W-1:0]p1, g1;

reg G1, P1;
reg [GP1_W-2:0]C1;

integer i, j;

assign po = {(ci&P1)|G1, s};

// Carry Look-Ahead Sigma
always @(*) begin
	for (i = 0; i < WIDTH; i = i + 1) begin
		g[i] = a[i] & b[i];
		p[i] = a[i] ^ b[i];
		s[i] = p[i] ^ cin[i];
	end
end

// Carry
always @(*) begin
	for (i = 0; i < GP0_N; i = i + 1) begin
		cin[(i+1)*GP0_W-1-:GP0_W] = {C0[i], (i == 0) ? ci : C1[i-1]};
	end
end

// Carry Look-Ahead Generator (Stage 0)
always @(*) begin
	for (i = 0; i < GP0_N; i = i + 1) begin
		c0[i][0] = (i == 0) ? ci : C1[i-1];
		p0[i][0] = p[i*GP0_W];
		g0[i][0] = g[i*GP0_W];
		for (j = 1; j < GP0_W; j = j + 1) begin
			c0[i][j] = c0[i][j-1] & p[i*GP0_W+j-1] | g[i*GP0_W+j-1];
			g0[i][j] = g0[i][j-1] & p[i*GP0_W+j] | g[i*GP0_W+j];
			p0[i][j] = p0[i][j-1] & p[i*GP0_W+j];
		end
	end
	for (i = 0; i < GP0_N; i = i + 1) begin
		G0[i] = g0[i][GP0_W-1];
		P0[i] = p0[i][GP0_W-1];
		C0[i] = c0[i][GP0_W-1:1];
	end
end

// Carry Look-Ahead Generator (Stage 1)
always @(*) begin
	c1[0] = ci;
	p1[0] = P0[0];
	g1[0] = G0[0];
	for (i = 1; i < GP1_W; i = i + 1) begin
		c1[i] = c1[i-1] & P0[i-1] | G0[i-1];
		g1[i] = g1[i-1] & P0[i] | G0[i];
		p1[i] = g1[i-1] & P0[i];
	end
	G1 = g1[GP1_W-1];
	P1 = p1[GP1_W-1];
	C1 = c1[GP1_W-1:1];
end

endmodule