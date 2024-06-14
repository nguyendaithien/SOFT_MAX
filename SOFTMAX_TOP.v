module SOFTMAX_TOP #(parameter DATA_WIDTH_IN = 16, IFM_SIZE = 1000, LUT_SIZE = 100, DATA_WIDTH_OUT = 24, NUM_REG_IFM = 1000)  (
		clk1,
		clk2,
		rst_n,
		valid_ifm,
		ifm,
		softmax_out,
		valid_data
);
  input clk1;
  input clk2;
  input rst_n;
  input valid_ifm;
  input  [DATA_WIDTH_IN -1:0 ] ifm;
  output reg [DATA_WIDTH_OUT- 1:0] softmax_out;
  output wire valid_data;

	wire wr_ifm;
	wire rd_ifm;
	wire wr_clr;
	wire rd_clr;
	wire [999:0] reg_write;
	wire set_output;
	wire [99:0] sel_mux_lut;
	wire [DATA_WIDTH_IN-1:0] data_out_reg [999:0];

	wire [DATA_WIDTH_IN-1:0] data_out_fifo;
	wire [15:0] counter_ifm;
	

CONTROLLER #(.DATA_WIDTH(DATA_WIDTH_IN), .IFM_SIZE(IFM_SIZE), .LUT_SIZE(IFM_SIZE)) controller (
		 .clk(clk1)
		,.rst_n(rst_n)
		,.valid_ifm(valid_ifm)
		,.ifm(ifm)
		,.wr_ifm(wr_ifm)
		,.rd_ifm(rd_ifm)
		,.wr_clr(wr_clr)
		,.rd_clr(rd_clr)
		,.reg_write(reg_write)
		,.set_output(set_output)
		,.counter_ifm(counter_ifm)
		,.sel_mux_lut(sel_mux_lut)
		,.valid_data(valid_data)
	);

FIFO_ASYNCH #(.DATA_WIDTH(DATA_WIDTH_IN), .FIFO_SIZE(IFM_SIZE), .ADD_WIDTH(10)) ifm_buffer (
		 .clk1 (clk1) 
		,.clk2 (clk2) 
		,.rd_clr(rd_clr)
		,.wr_clr(wr_clr)
		,.rd_inc(1'b1) 
		,.wr_inc(1'b1)
		,.wr_en (wr_ifm)
		,.rd_en (rd_ifm)
		,.data_in_fifo(ifm)
		,.data_out_fifo(data_out_fifo)
		);

 genvar i;
   generate
     for (i = 0; i < NUM_REG_IFM ; i = i + 1) begin : REGISTER_INST
       REGISTER #(DATA_WIDTH_IN) reg_inst (
         .clk(clk1),
         .rst_n(rst_n),
         .reg_write(reg_write[i]),
         .data_in(data_out_fifo),
         .data_out(data_out_reg[i])
       );
     end
   endgenerate

endmodule
