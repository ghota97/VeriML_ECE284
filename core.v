module core(acc,relu,clk,reset,inst_w,mode,Di,Dw,rd_l0,wr_l0,cen,o_full,o_ready,out_l0,full_l0,ready_l0,Ai,Aw, inp_sram_cenw,inp_sram_wenw, inp_sram_ceni,inp_sram_weni,psum_rd,psum_mem_dout,w_x,clk_gating_enable,srami_gated_clk,sramw_gated_clk);
parameter num = 2048;	
parameter num_inp = 8;
parameter psum_bw = 16;
parameter bw = 4;
parameter row = 8;
parameter col=8;
 
input acc,relu;
input clk,reset;
input sramw_gated_clk;
input srami_gated_clk;
input clk_gating_enable;
input [1:0] inst_w;
input mode;  
input [row*bw-1:0] in_l0;
input rd_l0;
input wr_l0;
input cen;
input w_x;
input inp_sram_ceni;
input inp_sram_weni;
input inp_sram_cenw;
input inp_sram_wenw;
input [10:0] Ai;
input [31:0] Di;
input [10:0] Aw;
input [31:0] Dw;
input psum_rd;

output [31:0] Q;
wire [31:0] Qw;
wire [31:0] Qi;


output o_full;
output o_ready;
output [row*bw-1:0]out_l0;
output full_l0;
output ready_l0; 
wire psum_mem_rd;
wire psum_wr;
output [col*psum_bw-1:0]psum_mem_dout;
wire [col*psum_bw-1:0]psum_mem_din;   
reg [10:0] psum_mem_addr; 
reg [10:0] psum_mem_addr_q; 

reg psum_mem_rd_q;
reg psum_wr_q;
reg psum_rd_q;
wire psum_gated_clk;
reg clk_gating_flop_signal_psum;
sram_32b_w2048_single_port input_sram_instance(
    .CLK(srami_gated_clk),
    .CEN(inp_sram_ceni),
    .WEN(inp_sram_weni),
    .A(Ai),
    .D(Di),
    .Q(Qi));

sram_32b_w2048_single_port weight_sram_instance(
    .CLK(sramw_gated_clk),
    .CEN(inp_sram_cenw),
    .WEN(inp_sram_wenw),
    .A(Aw),
    .D(Dw),
    .Q(Qw));


corelet #(.psum_bw(psum_bw),.bw(bw),.row(row),.col(col)) corelet_instance(
    	.clk(clk),
	.reset(reset), 
	.acc(acc),
	.relu(relu),
	.inst_w(inst_w),
	.mode(mode),
	.in_l0(Q),
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
	.CLK(psum_gated_clk),
	.WEN(psum_wr),
	.REN(psum_mem_rd | psum_rd),
	.CEN(cen),
	.D(psum_mem_din),
	.RA(psum_mem_addr),
	.WA(psum_mem_addr_q),
	.Q(psum_mem_dout)
);

always @(posedge clk) begin
	psum_mem_rd_q <= psum_mem_rd;
	psum_rd_q <= psum_rd;
	psum_wr_q <= psum_wr;
    end

always @(posedge clk) begin
	clk_gating_flop_signal_psum <= ((psum_mem_rd |psum_rd) | psum_wr);
    end 
assign psum_gated_clk = clk_gating_enable ? (clk & clk_gating_flop_signal_psum) : clk ;


always @(posedge clk) begin
    if(reset)
	psum_mem_addr <= 0;
    else if(psum_mem_rd | psum_rd_q) 
    	if (psum_mem_addr >= num_inp-1)
		psum_mem_addr <= 0;
	else 
		psum_mem_addr <= psum_mem_addr + 1'b1;
    psum_mem_addr_q <= psum_mem_addr;
end
assign Q = w_x ? Qw: Qi;
endmodule

