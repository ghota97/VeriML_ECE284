// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_tile (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset);

parameter bw = 4;
parameter psum_bw = 16;

input  clk;
input  reset;

input  [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
input  [psum_bw-1:0] in_n;
    
input  [1:0] inst_w;

output reg [1:0] inst_e;
output reg [bw-1:0] out_e; //activation
output [psum_bw-1:0] out_s;
    
    
reg [bw-1:0] b_q;//weight
reg [psum_bw-1:0] c_q;//psum
    
reg load_ready_q;


mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
        .a(out_e), 
        .b(b_q),
        .c(c_q),
	.out(out_s)
); 

always@(posedge clk) begin
    if (reset) begin
        inst_e <= 2'b0;
        load_ready_q <= 1'b1;
    end

    else begin
        inst_e[1] <= inst_w[1];
        if (|inst_w)begin
            out_e <= in_w;
            c_q   <= in_n;
	end
        else if (inst_w[0] && load_ready_q) begin
            b_q <= in_w;
            load_ready_q <= 1'b0;
        end

        else if (~load_ready_q) begin
            inst_e[0] <= inst_w[0];
        end
    end
end

endmodule
