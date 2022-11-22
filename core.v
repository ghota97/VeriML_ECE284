module core(clk,reset, acc,relu,inst_w, mode, in_l0,rd_l0,wr_l0,o_full,o_ready,out_l0,full_l0,ready_l0,psum_rd,psum_wr,psum_mem_dout,psum_mem_din);
    
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

    output o_full;
    output o_ready;
    output [row*bw-1:0]out_l0;
    output full_l0;
    output ready_l0; 
    output psum_rd;
    output psum_wr;
    output [col*psum_bw-1:0]psum_mem_dout;
    output [col*psum_bw-1:0]psum_mem_din;   
 
    reg  [psum_bw*col-1:0] init_psum = 0;
    wire  [psum_bw*col-1:0] mac_arr_psum_bus;
    wire [col-1:0] valid_bus;
    wire rd_ofifo;
    wire o_valid;
    wire [col*psum_bw-1:0] ofifo_dout;
     
    
    l0 #(.bw(bw),.row(row),.col(col)) l0_instance(
        .clk(clk), 
        .reset(reset),
        .in(in_l0), 
        .out(out_l0), 
        .rd(rd_l0),
        .wr(wr_l0),
        .mode(mode),
        .o_full(full_l0),
        .o_ready(ready_l0)
    );
    

    
    ofifo #(.psum_bw(psum_bw),.col(col)) ofifo_instance(
        .clk(clk), 
        .reset(reset),
        .in(mac_arr_psum_bus), 
        .out(ofifo_dout), 
        .rd(rd_ofifo),
        .wr(valid_bus),
        .o_full(o_full),
        .o_ready(o_ready),
        .o_valid(o_valid)
    );

    sfu #(.bw(bw),.col(col),.psum_bw(psum_bw)) sfu_instance(
	
	.clk(clk), 
	.reset(reset), 
	.acc(acc), 
	.relu(relu), 
	.ofifo_valid(o_valid),
        .ofifo_rd(rd_ofifo), 
	.psum_mem_rd(psum_rd), 
	.psum_mem_wr(psum_wr),
	.ofifo_dout(ofifo_dout), 
	.psum_mem_dout(psum_mem_dout),
        .psum_mem_din(psum_mem_din)
    );    
    mac_array #(.bw(bw), .psum_bw(psum_bw),.row(row),.col(col)) mac_array_instance (
        .clk(clk),
        .reset(reset),
        .in_w(out_l0), 
        .in_n(init_psum), 
        .mode(mode),
        .inst_w(inst_w), 
        .out_s(mac_arr_psum_bus), 
        .valid(valid_bus)  
    );
    
endmodule
 
