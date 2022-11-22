// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac (out, a, b, c);

parameter bw = 4;
parameter psum_bw = 16;
output [psum_bw-1:0] out;
input [bw-1:0] a;  // activation
input [bw-1:0] b;  // weight
input [psum_bw-1:0] c;


wire [2*bw:0] product;
wire [psum_bw-1:0] psum;
wire [bw:0]   a_pad;


//output signed [psum_bw-1:0] out;
//input signed  [bw-1:0] a;  // activation
//input signed  [bw-1:0] b;  // weight
//input signed  [psum_bw-1:0] c;
//
//
//wire signed [2*bw:0] product;
//wire signed [psum_bw-1:0] psum;
//wire signed [bw:0]   a_pad;

assign out = c + {{(psum_bw-bw){b[bw-1]}},b}*$signed({{(psum_bw-bw){1'b0}},a});

endmodule
