module controller(clk,reset,start,wr,rd,mode,inst_w,compute_done,iter_done);
	parameter num_inp = 64;
	parameter col = 8;
	parameter row = 8;
	parameter kij_len = 9;

	input clk,reset,start;
	output reg wr,rd,mode;
	output reg [1:0]inst_w;
	output reg compute_done;
	
	reg [7:0] iter,counter;
	output reg iter_done;
	reg started;
	always@(posedge clk )
		started <= start;
	always@(posedge clk )begin
		if(start && ~started)begin
			iter<=0;
			iter_done<=0;
			compute_done <=0;
		end
		else if(iter_done)begin
		    if(iter == kij_len-1)begin
			iter<=0;
			compute_done<=1;
			iter_done <=0;
		    end
		    else begin
			iter_done<=0;
		    	iter <= iter+1;
		    end
		end
	end
	always@(posedge clk)begin
		if(reset) 
			counter <=0;
		else if(compute_done | ~start)
			counter <=0;
		else if(counter == 2*(num_inp+row+1))begin
			counter <=0;
			iter_done <=1;
		end
		else	begin
			counter <= counter +1'b1;
			end
	end

	always@ (posedge clk)begin
		if(reset)begin
			wr<=0;
			rd<=0;
			mode<=0;
			inst_w<=0;
		end	
		else if(start)begin
		     if((counter > 0) && (counter <= row)) begin
			rd<=1;
			inst_w <=2'b01;
			mode <= 0;
		     end	
		     else if(counter == row+1) begin
			rd<=0;
			inst_w <=2'b01;
			mode <= 0;
		     end	
		     else if((counter > row+1) && (counter <= 1+row+num_inp))begin
			rd<=1;
			inst_w <=2'b10;
			mode <= 1;
		     end
		     else begin
			rd<=0;
			inst_w <=2'b00;
		     end
			
		     if(counter < row+num_inp)
		 	wr<=1;
		     else 
			wr<=0;
	       end
      	end
endmodule			
			
						
			
