module CONTROLLER #(parameter DATA_WIDTH = 16, IFM_SIZE = 1000 , LUT_SIZE = 100) (
		clk,
		rst_n,
		valid_ifm,
		ifm,
		wr_ifm,
		rd_ifm,
		wr_clr,
		rd_clr,
		counter_ifm,
		sel_mux_lut,
		valid_data,
		counter_lut,
		set_output,
		reg_write_psum,
		current_state,
		flag,
		set_reg,
		counter_compute
	);

  input              clk            ;
  input              rst_n          ;
  input              valid_ifm      ;
  input   [DATA_WIDTH-1:0] ifm      ;
  output wire        wr_ifm         ;
  output reg         rd_ifm         ;
  output reg         wr_clr         ;
  output reg         rd_clr         ;
  output reg         set_output     ;
  output reg [15:0]  counter_ifm    ;
  output reg [6:0]  counter_lut     ;
  output reg [99:0]   sel_mux_lut   ;
	output reg         valid_data     ;
	output reg         reg_write_psum ;
	output reg [3:0]   current_state  ;
	output reg         flag           ;
	output reg         set_reg        ;
	output reg [7:0]   counter_compute;

	parameter IDLE       = 4'd0;
	parameter WRITE_IFM  = 4'd1;
	parameter WAIT_1     = 4'd2;
	parameter STORE_IFM  = 4'd3;
	parameter WAIT_2     = 4'd4;
	parameter COMPUTE    = 4'd5;
	parameter NOP        = 4'd6;
	parameter CAP_DATA   = 4'd7;
	parameter END        = 4'd8;
	parameter COMPUTE_NUM = 100;

	assign wr_ifm = valid_ifm  ;

	reg [3:0 ]  next_state     ;
  
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
					next_state = WAIT_1;
				else 
					next_state = WRITE_IFM;
			WAIT_1:
				next_state = current_state + 1;
			WAIT_2:
				next_state = current_state + 1;
			STORE_IFM:
				if(counter_ifm == IFM_SIZE) 
					next_state = WAIT_2;
				else 
					next_state = STORE_IFM;
			COMPUTE:
			  if(counter_ifm == IFM_SIZE)
					next_state = NOP;
				else 
					next_state = COMPUTE;
			NOP:
				if(counter_compute == COMPUTE_NUM) 
					next_state = CAP_DATA;
				else 
					next_state = COMPUTE;
			CAP_DATA:
				next_state = END;
			END:
				next_state = END;
			default: next_state = IDLE;
		endcase
	end
       integer i;
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
       rd_ifm          <=  0;             			
       wr_clr          <=  1; 
       rd_clr          <=  1; 
       set_output      <=  0; 
       counter_ifm     <=  0; 
       sel_mux_lut     <=  0; 
			 valid_data      <=  0;
			 reg_write_psum  <=  0;
			 flag            <=  0;
			 set_reg         <=  0;
		end
		else begin
			case(next_state)
				IDLE: begin
          rd_ifm         <=  0;             			
          wr_clr         <=  0; 
          rd_clr         <=  0; 
          set_output     <=  0; 
          sel_mux_lut    <=  0; 
			    valid_data     <=  0;
			    reg_write_psum <=  0;
				end
				WRITE_IFM: begin
          rd_ifm         <=  0;             			
          wr_clr         <=  0; 
          rd_clr         <=  0; 
          set_output     <=  0; 
          sel_mux_lut    <=  0; 
			    valid_data     <=  0;
			    reg_write_psum <=  0;
				end
				STORE_IFM: begin
          rd_ifm         <=  1;             			
          wr_clr         <=  0; 
          rd_clr         <=  0; 
          set_output     <=  0; 
          sel_mux_lut    <=  0; 
			    valid_data     <=  0;
			    reg_write_psum <=  0;
				end
				WAIT_1: begin
          rd_ifm         <=  0;             			
          wr_clr         <=  1; 
          rd_clr         <=  1; 
          set_output     <=  0; 
          sel_mux_lut    <=  0; 
			    valid_data     <=  0;
			    reg_write_psum <=  0;
				end
				WAIT_2: begin
          rd_ifm         <=  0;             			
          wr_clr         <=  1; 
          rd_clr         <=  1; 
          set_output     <=  0; 
          sel_mux_lut    <=  0; 
			    valid_data     <=  0;
			    reg_write_psum <=  0;
			    flag           <=  1;
				end
				COMPUTE: begin
          rd_ifm         <=  1;             			
          wr_clr         <=  0; 
          rd_clr         <=  0; 
          set_output     <=  0; 
          sel_mux_lut    <=  0; 
			    valid_data     <=  0;
			    reg_write_psum <=  0;
			    flag           <=  0;
			    set_reg        <=  1;
				end
				CAP_DATA: begin
          rd_ifm         <=  1;             			
          wr_clr         <=  0; 
          rd_clr         <=  0; 
          set_output     <=  0; 
          sel_mux_lut    <=  0; 
			    valid_data     <=  0;
			    reg_write_psum <=  1;
			    set_reg         <=  0;
				end
				NOP: begin
				  rd_clr <= 1;
			    flag           <=  1;
			    set_reg        <=  0;
          set_output     <=  1; 
				end
				END: begin /* */ end
			endcase
		end
	end
	
		always @(posedge clk or negedge rst_n) begin
			if(!rst_n) begin
				counter_ifm <= 16'd0;
				counter_lut <= 8'd0;
			  counter_compute <=  0;
			end
			else begin
				case(next_state)
					IDLE: begin
				    counter_ifm <= 16'd0;
				    counter_lut <= 8'd0;
			      counter_compute <=  0;
				  end
					WRITE_IFM: begin
			 	    counter_ifm <= (wr_ifm) ? (counter_ifm == IFM_SIZE) ? 0 : counter_ifm + 1: counter_ifm;
			 	    counter_lut <= 0;
					end
					WAIT_1: begin
			 	    counter_ifm <= 0;
			 	    counter_lut <= 0;
					end
					STORE_IFM: begin
			 	    counter_ifm <= (rd_ifm) ? (counter_ifm == IFM_SIZE) ? 0 : counter_ifm + 1: counter_ifm;
			 	    counter_lut <= 0;
					end
					COMPUTE: begin
			 	    counter_ifm <= (rd_ifm) ? (counter_ifm == IFM_SIZE) ? 0 : counter_ifm + 1 : counter_ifm;
			 	    counter_lut <= counter_compute + 1;
					end
					NOP: begin
			      counter_compute <=  (counter_compute == COMPUTE_NUM) ? 0 : counter_compute +1 ;
			 	    counter_lut <= 0;
					end
					CAP_DATA: begin
			 	    counter_ifm <= 0;
			 	    counter_lut <= 0;
			      counter_compute <=  0;
					end
					default: begin
			 	    counter_ifm <= 0;
			 	    counter_lut <= 0;
					end
				endcase
			end
		end

endmodule

