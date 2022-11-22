module sfu (clk, reset, acc, relu, ofifo_valid, ofifo_rd, ofifo_dout, psum_mem_rd, psum_mem_dout, psum_mem_wr, psum_mem_din);
	parameter col = 8;
	parameter bw = 4;
	parameter bw_psum = 16;

	input clk, reset, acc, relu, ofifo_valid;
        output reg ofifo_rd, psum_mem_rd, psum_mem_wr;
	input [col*bw_psum-1:0] ofifo_dout, psum_mem_dout;
        output reg [col*bw_psum-1:0] psum_mem_din;

	genvar i;

	always @(posedge clk) begin
		psum_mem_wr <= psum_mem_rd;
		if (reset) begin
			ofifo_rd <= 1'b0;
			psum_mem_rd <= 1'b0;
		end else if(ofifo_valid) begin
			ofifo_rd <= 1'b1;
			psum_mem_rd <= 1'b1;
		end
	end

	for (i = 0; i < col; i=i+1) begin: acc_col
		always @(posedge clk) begin
			if(acc) psum_mem_din[(i+1)*bw_psum-1:i*bw_psum] = psum_mem_dout[(i+1)*bw_psum-1:i*bw_psum] + ofifo_dout[(i+1)*bw_psum-1:i*bw_psum];
		        if(relu) psum_mem_din[(i+1)*bw_psum-1:i*bw_psum] = (psum_mem_dout[(i+1)*bw_psum-1:i*bw_psum] > 0)?psum_mem_dout[(i+1)*bw_psum-1:i*bw_psum]:{(bw_psum){1'b0}};  	
		end
	
	end

endmodule
