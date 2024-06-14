module CONTROLLER #(parameter DATA_WIDTH = 16, IFM_SIZE = 1000 , LUT_SIZE = 100) (
		clk,
		rst_n,
		valid_ifm,
		ifm,
		wr_ifm,
		rd_ifm,
		wr_clr,
		rd_clr,
		reg_write,
		set_output,
		counter_ifm,
		sel_mux_lut,
		valid_data
	);

  input              clk         ;
  input              rst_n       ;
  input              valid_ifm   ;
  input   [DATA_WIDTH-1:0] ifm   ;
  output wire        wr_ifm      ;
  output reg         rd_ifm      ;
  output reg         wr_clr      ;
  output reg         rd_clr      ;
  output reg [999:0]   reg_write   ;
  output reg         set_output  ;
  output reg [15:0]  counter_ifm ;
  output reg [99:0]   sel_mux_lut ;
	output reg         valid_data  ;

	parameter IDLE       = 4'd0;
	parameter WRITE_IFM  = 4'd1;
	parameter STORE_IFM  = 4'd2;
	parameter COMPUTE    = 4'd3;
	parameter WAIT       = 4'd4;
	parameter CAP_DATA   = 4'd5;
	parameter LUT        = 4'd6;
	parameter END        = 4'd7;

	assign wr_ifm = valid_ifm  ;

	reg [3:0 ]  current_state  ;
	reg [3:0 ]  next_state     ;
	reg [7:0 ]  counter_lut    ; 
  
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
  		current_state <= 0;
  	end
  	else begin
  		current_state <=  next_state;
  	end
	end
  
	always @(valid_ifm or counter_ifm or current_state) begin
		case(current_state)
			IDLE:
				if(valid_ifm & (counter_ifm == 16'd0))
					next_state = WRITE_IFM;
				else 
					next_state = IDLE;
			WRITE_IFM:
				if(counter_ifm == IFM_SIZE)
					next_state = WAIT;
				else 
					next_state = WRITE_IFM;
			WAIT:
				next_state = current_state + 1;
			STORE_IFM:
				if(counter_ifm == IFM_SIZE) 
					next_state = WAIT;
				else 
					next_state = STORE_IFM;
			COMPUTE:
				if(counter_ifm == IFM_SIZE) 
					next_state = WAIT;
				else 
					next_state = COMPUTE;
			CAP_DATA:
				next_state = LUT;
			LUT:
				if(counter_lut == 7'd100)
					next_state = END;
			  else 
					next_state = LUT;
			END:
				next_state = END;
			default: next_state = IDLE;
		endcase
	end
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
       rd_ifm         <=  0;             			
       wr_clr         <=  1; 
       rd_clr         <=  1; 
       reg_write      <=  0; 
       set_output     <=  0; 
       counter_ifm    <=  0; 
       sel_mux_lut    <=  0; 
			 valid_data     <=  0;
		end
		else begin
			case(next_state)
				IDLE: begin
          rd_ifm         <=  0;             			
          wr_clr         <=  0; 
          rd_clr         <=  0; 
          reg_write      <=  0; 
          set_output     <=  0; 
          counter_ifm    <=  0; 
          sel_mux_lut    <=  0; 
			    valid_data     <=  0;
				end
				WRITE_IFM: begin
          rd_ifm         <=  0;             			
          wr_clr         <=  0; 
          rd_clr         <=  0; 
          reg_write      <=  0; 
          set_output     <=  0; 
          counter_ifm    <=  0; 
          sel_mux_lut    <=  0; 
			    valid_data     <=  0;
				end
				STORE_IFM: begin
          rd_ifm         <=  1;             			
          wr_clr         <=  0; 
          rd_clr         <=  0; 
          set_output     <=  0; 
          counter_ifm    <=  0; 
          sel_mux_lut    <=  0; 
          reg_write[counter_ifm]      <=  1; 
			    valid_data     <=  0;
				end
				WAIT: begin
          rd_ifm         <=  0;             			
          wr_clr         <=  1; 
          rd_clr         <=  1; 
          reg_write      <=  0; 
          set_output     <=  0; 
          counter_ifm    <=  0; 
          sel_mux_lut    <=  0; 
			    valid_data     <=  0;
				end
				COMPUTE: begin
          rd_ifm         <=  1;             			
          wr_clr         <=  0; 
          rd_clr         <=  0; 
          set_output     <=  0; 
          counter_ifm    <=  0; 
          sel_mux_lut    <=  0; 
          reg_write      <=  0; 
			    valid_data     <=  0;
				end
				CAP_DATA: begin
          rd_ifm         <=  1;             			
          wr_clr         <=  0; 
          rd_clr         <=  0; 
          set_output     <=  0; 
          counter_ifm    <=  0; 
          sel_mux_lut    <=  0; 
          reg_write      <=  0; 
			    valid_data     <=  0;
				end
				LUT: begin
          rd_ifm         <=  1;             			
          wr_clr         <=  0; 
          rd_clr         <=  0; 
          set_output     <=  0; 
          counter_ifm    <=  0; 
          reg_write      <=  0; 
          sel_mux_lut[counter_lut]    <=  1; 
			    valid_data     <=  1;
				end
				END: begin /* */ end
			endcase
		end
	end
	
		always @(posedge clk or negedge rst_n) begin
			if(!rst_n) begin
				counter_ifm <= 16'd0;
				counter_lut <= 8'd0;
			end
			else begin
				case(next_state)
					IDLE: begin
				    counter_ifm <= 16'd0;
				    counter_lut <= 8'd0;
				  end
					WRITE_IFM: begin
			 	    counter_ifm <= (wr_ifm) ? (counter_ifm == IFM_SIZE) ? 0 : counter_ifm : counter_ifm + 1;
			 	    counter_lut <= 0;
					end
					WAIT: begin
			 	    counter_ifm <= 0;
			 	    counter_lut <= 0;
					end
					STORE_IFM: begin
			 	    counter_ifm <= (wr_ifm) ? (counter_ifm == IFM_SIZE) ? 0 : counter_ifm : counter_ifm + 1;
			 	    counter_lut <= 0;
					end
					COMPUTE: begin
			 	    counter_ifm <= (wr_ifm) ? (counter_ifm == IFM_SIZE) ? 0 : counter_ifm : counter_ifm + 1;
			 	    counter_lut <= 0;
					end
					CAP_DATA: begin
			 	    counter_ifm <= 0;
			 	    counter_lut <= 0;
					end
					LUT: begin
			 	    counter_ifm <= 0;
			 	    counter_lut <= (counter_lut == LUT_SIZE) ? 0 : counter_lut + 1 ;
					end
					default: begin
			 	    counter_ifm <= 0;
			 	    counter_lut <= 0;
					end
				endcase
			end
		end

endmodule

						
						
						
						

					



























					
					

					

						
				
				























































































