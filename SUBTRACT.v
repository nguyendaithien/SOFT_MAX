module SUBTRACT #(parameter DATA_WIDTH = 16) (
		op_a,
		op_b,
		result
	);
	input  signed  [DATA_WIDTH-1:0] op_a;
	input  signed  [DATA_WIDTH-1:0] op_b;
	output signed [DATA_WIDTH-1:0] result;

	assign result = op_a - op_b;

endmodule

