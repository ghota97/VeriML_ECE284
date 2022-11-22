module core(acc,relu,clk,reset,inst_w,mode,in_l0,rd_l0,wr_l0,cen,o_full,o_ready,out_l0,full_l0,ready_l0);
parameter num = 2048;	
parameter num_inp = 8;
parameter psum_bw = 16;
parameter bw = 4;
parameter row = 4;
parameter col=4;
 
input acc,relu;
input clk,reset;
input [1:0] inst_w;
input mode;  
input [row*bw-1:0]in_l0;
input rd_l0;
input wr_l0;
input cen;
output o_full;
output o_ready;
output [row*bw-1:0]out_l0;
output full_l0;
output ready_l0; 
wire psum_mem_rd;
wire psum_wr;
wire [col*psum_bw-1:0]psum_mem_dout;
wire [col*psum_bw-1:0]psum_mem_din;   
reg [10:0] psum_mem_addr; 
reg [10:0] psum_mem_addr_q; 

corelet #(.psum_bw(psum_bw),.bw(bw),.row(row),.col(col)) corelet_instance(
    	.clk(clk),
	.reset(reset), 
	.acc(acc),
	.relu(relu),
	.inst_w(inst_w),
	.mode(mode),
	.in_l0(in_l0),
	.rd_l0(rd_l0),
	.wr_l0(wr_l0),
	.o_full(o_full),
	.o_ready(o_ready),
	.out_l0(out_l0),
	.full_l0(full_l0),
	.ready_l0(ready_l0),
	.psum_mem_rd(psum_mem_rd),
	.psum_wr(psum_wr),
	.psum_mem_dout(psum_mem_dout),
	.psum_mem_din(psum_mem_din)
);
 
sram_128b_w2048 #(.num(num)) psum_sram_instance(
	.CLK(clk),
	.WEN(psum_wr),
	.REN(psum_mem_rd),
	.CEN(cen),
	.D(psum_mem_din),
	.RA(psum_mem_addr),
	.WA(psum_mem_addr_q),
	.Q(psum_mem_dout)
);

always @(posedge clk) begin
    if(reset)
	psum_mem_addr <= 0;
    else if(psum_mem_rd) 
    	if (psum_mem_addr >= num_inp-1)
		psum_mem_addr <= 0;
	else 
		psum_mem_addr <= psum_mem_addr + 1'b1;
    psum_mem_addr_q <= psum_mem_addr;
end

endmodule

