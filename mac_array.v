// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_array (clk, reset, out_s, in_w, in_n, mode, inst_w, valid);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 4;
  parameter row = 4;

  input  clk, reset;
  input  [row*bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [1:0] inst_w;
  input  [psum_bw*col-1:0] in_n;
  input mode;
    
  output [psum_bw*col-1:0] out_s;
  output [col-1:0] valid;

  reg    [2*row-1:0] inst_w_bus;
  wire   [psum_bw*col*(row+1)-1:0] in_n_bus;
  wire   [row*col-1:0] valid_bus;


  assign out_s = in_n_bus[psum_bw*col*(row+1)-1:psum_bw*col*row];
  assign in_n_bus[psum_bw*col-1:0] = in_n;
  assign valid = valid_bus[row*col-1:(row-1)*col];
    
  genvar i;
  for (i=1; i < row+1 ; i=i+1) begin : row_num
      mac_row #(.bw(bw), .psum_bw(psum_bw),.col(col)) mac_row_instance (
         .clk(clk),
         .reset(reset),
         .in_w(in_w[bw*i-1:bw*(i-1)]),
         .inst_w(inst_w_bus[2*i-1:2*(i-1)]),
         .in_n(in_n_bus[psum_bw*col*i-1:psum_bw*col*(i-1)]),
         .valid(valid_bus[col*i-1:col*(i-1)]),
         .out_s(in_n_bus[psum_bw*col*(i+1)-1:psum_bw*col*(i)]));
  end
  generate
      for (i = 0; i < 2*row; i = i + 2) begin 
        always @(posedge clk) begin
	    if(i == 0) 
		inst_w_bus[1:0] <= inst_w;
	    else begin
            	if(mode == 1)
              	    inst_w_bus[i+1:i] <= inst_w_bus[i-1:i-2];
		else
		    inst_w_bus[i+1:i] <= inst_w;
	    end
        end
    end
  endgenerate
endmodule
