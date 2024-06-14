module FIFO_ASYNCH #(parameter DATA_WIDTH = 16, FIFO_SIZE = 7, ADD_WIDTH = 3) (
		clk1  ,
		clk2  ,
		rd_clr,
		wr_clr,
		rd_inc,
		wr_inc,
		wr_en ,
		rd_en ,
		data_in_fifo ,
		data_out_fifo,
		);

   input clk1  ;  
   input clk2  ; 
   input rd_clr;         
   input wr_clr;
   input rd_inc;
   input wr_inc;
   input wr_en ;
   input rd_en ;
   input  [DATA_WIDTH-1:0] data_in_fifo ;
   output [DATA_WIDTH-1:0] data_out_fifo;

//=======================================================
//      INTERNAL DECLARATIONS
//=======================================================

   reg [DATA_WIDTH-1:0] fifo_data [FIFO_SIZE-1:0];
   reg [12:0] rd_ptr                  ;
   reg [12:0] wr_ptr                  ;
   reg [DATA_WIDTH-1:0] data_read               ;
   reg reg_re;
   reg reg_we;

	 always @(*) begin
	 		reg_re = rd_en;
			reg_we = wr_en;
	 end

	 always @(posedge clk1 or posedge rd_clr) begin
	 	 if(rd_clr) begin
		 		rd_ptr <= 0;
		 end
		 else if(reg_re) begin
		 		data_read <= fifo_data[rd_ptr];
				rd_ptr    <= rd_ptr + rd_inc   ;
		end
		else begin 
				data_read <= 0;
		end
	end
	always @(posedge clk2 or posedge wr_clr) begin
			if(wr_clr) begin
			  wr_ptr <= 0;
			end
			else if(reg_we) begin
				fifo_data[wr_ptr] <= data_in_fifo   ;
				wr_ptr            <= wr_ptr + wr_inc;
			end
			else begin
				fifo_data[wr_ptr] <= fifo_data[wr_ptr];
			end
	end

	assign data_out_fifo = data_read;
endmodule
