// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module sram_128b_w2048 (CLK, D, Q, CEN, WEN, RA,WA,REN);

  input  CLK;
  input  WEN;
  input  REN;
  input  CEN;
  input  [127:0] D;
  input  [10:0] RA;
  input  [10:0] WA;
  output [127:0] Q;
  parameter num = 2048;

  reg [127:0] memory [num-1:0] ;
  reg [10:0] add_q;
  assign Q = memory[add_q];
genvar i;
  for(i = 0; i< num; i=i+1) begin
  always @(posedge CLK) begin
    if(CEN)
      memory[i] <=0;
  end
end

  always @ (posedge CLK) begin

   if (!CEN && REN) // read 
      add_q <= RA;
   if (!CEN && WEN) // write
      memory[WA] <= D; 

  end

endmodule
