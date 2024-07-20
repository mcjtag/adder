`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Dmitry Matyunin (https://github.com/mcjtag)
// 
// Create Date: 09.07.2024 11:30:57
// Design Name: adder
// Module Name: adder_bka
// Description: Brent-Kung Adder
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

// Radix 2
module adder_bka_r2 #(
	parameter WIDTH = 16
)
(
	input wire [WIDTH-1:0]a,
	input wire [WIDTH-1:0]b,
	input wire [WIDTH-1:0]ci,
	output wire [WIDTH:0]po
);

localparam GP0 = $clog2(WIDTH);
localparam GP1 = GP0 - 1;
localparam GP = GP0+GP1;

reg [WIDTH-1:0]p[GP:0];
reg [WIDTH-1:0]g[GP:0];
reg [WIDTH-1:0]s;
reg c;

integer i, j;

assign po = {c, s};

always @(*) begin
	for (i = 0; i < WIDTH; i = i + 1) begin
		p[0][i] = a[i] ^ b[i];
		if (i == 0) begin
			g[0][i] = (a[i] & ci) | (b[i] & ci) | (a[i] & b[i]);
		end else begin
			g[0][i] = a[i] & b[i];
		end
	end
	
	for (i = 0; i < GP0; i = i + 1) begin
		for (j = 0; j < WIDTH; j = j + 1) begin
			g[i+1][j] = g[i][j];
			p[i+1][j] = p[i][j];
		end
		for (j = 2**(i+1)-1; j < WIDTH; j = j + 2**(i+1)) begin
			g[i+1][j] = g[i][j] | (p[i][j] & g[i][j-2**i]);
			p[i+1][j] = p[i][j];
			if (j != 2**(i+1)-1) begin
				p[i+1][j] = p[i][j] & p[i][j-2**i];
			end
		end
	end
	
	for (i = 0; i < GP1-1; i = i + 1) begin
		for (j = 0; j < WIDTH; j = j + 1) begin
			g[GP0+i+1][j] = g[GP0+i][j];
			p[GP0+i+1][j] = p[GP0+i][j];
		end
		for (j = 3*2**(GP1-1-i)-1; j < WIDTH; j = j + 2**(GP1-i)) begin
			g[GP0+i+1][j] = g[GP0+i][j] | (p[GP0+i][j] & g[GP0+i][j-2**(GP1-i-1)]);
			p[GP0+i+1][j] = p[GP0+i][j];
		end
	end
	
	for (i = 0; i < WIDTH; i = i + 1) begin
		g[GP][i] = g[GP-1][i];
		p[GP][i] = p[GP-1][i];
	end
	
	for (i = 2; i < WIDTH; i = i + 1) begin
		if ((i % 2) == 1'b0) begin
			g[GP][i] = g[GP-1][i] | (p[GP-1][i] & g[GP-1][i-1]);
			p[GP][i] = p[GP-1][i];
		end
	end
	
	c = g[GP][WIDTH-1];
	for (i = 0; i < WIDTH; i = i + 1) begin
		if (i == 0) begin
			s[i] = p[0][i] ^ ci;
		end else begin
			s[i] = p[0][i] ^ g[GP][i-1];
		end
	end 
end

endmodule