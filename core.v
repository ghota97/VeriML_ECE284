module core(clk,reset, inst_w, mode, in_l0,rd_l0,wr_l0,psum_mem_bus,o_full,o_ready,o_valid,out_l0,full_l0,ready_l0);
    
    parameter psum_bw = 16;
    parameter bw = 4;
    parameter row = 8;
    parameter col=8;
    
    input clk,reset;
    input [1:0] inst_w;
    input mode;  
    input [row*bw-1:0]in_l0;
    input [row-1:0]rd_l0;
    input [row-1:0]wr_l0;
    input rd_ofifo;

    output [col*psum_bw-1:0] psum_mem_bus;
    output o_full;
    output o_ready;
    output o_valid;
    output [row*bw-1:0]out_l0;
    output full_l0;
    output ready_l0; 
    

    wire  [psum*col-1:0] mac_arr_psum_bus;
    wire [col-1:0] valid_bus;
     
    
    l0 #(.bw(bw),.row(row)) l0_instance(
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
        .out(psum_mem_bus), 
        .rd(rd_ofifo),
        .wr(valid_bus),
        .o_full(o_full),
        .o_ready(o_ready),
        .o_valid(o_valid)
    );

    
    mac_array #(.bw(bw), .psum_bw(psum_bw),.row(row),.col(col)) mac_array_instance (
        .clk(clk),
        .reset(reset),
        .in_w(out_l0), 
        .in_n(0), 
        .mode(mode),
        .inst_w(inst_w), 
        .out_s(mac_arr_psum_bus), 
        .valid(valid_bus)  
    );
    
endmodule
 