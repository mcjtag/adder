`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Dmitry Matyunin (https://github.com/mcjtag)
// 
// Create Date: 09.07.2024 11:30:57
// Design Name: adder
// Module Name adder_rca
// Description: Ripple Carry Adder
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

module adder_rca #(
	parameter WIDTH = 16
)
(
	input wire [WIDTH-1:0]a,
	input wire [WIDTH-1:0]b,
	input wire ci,
	output wire [WIDTH:0]po
);

integer i;
reg [WIDTH:0]c;
reg [WIDTH-1:0]s;

assign po = {c[WIDTH], s};

always @(*) begin
	c[0] = ci;
	for (i = 0; i < WIDTH; i = i + 1) begin
		{c[i+1], s[i]} = {(a[i]&b[i])|((a[i]^b[i])&c[i]), (a[i]^b[i])^c[i]};
	end
end 

endmodule