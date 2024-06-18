`timescale 1 ns/10 ps
module SOFTMAX_TB;
    // Parameters
    parameter DATA_WIDTH_IN = 16; 
    parameter NUM_SUBTRACT = 1000;
    parameter IFM_SIZE = 1000;
    parameter LUT_SIZE = 100;
    parameter DATA_WIDTH_OUT = 24; 
    parameter NUM_REG_IFM = 1000;
    parameter IFM_LEN = 10000;

    // Inputs
    reg clk1;
    reg clk2;
    reg rst_n;
    reg valid_ifm;

    // Outputs
    wire [DATA_WIDTH_OUT-1:0] softmax_out_final;
    wire valid_data;
    wire ifm_read;
    wire [DATA_WIDTH_IN-1:0] ifm;

    // Internal registers
    reg [15:0] ifm_in [0:IFM_LEN-1];
    reg [31:0] ifm_cnt;
    reg [DATA_WIDTH_IN-1:0] ifm_r;
    integer file;
		wire end_softmax;

    // Instantiate the DUT (Device Under Test)
    SOFTMAX_TOP #(
        .DATA_WIDTH_IN(DATA_WIDTH_IN), 
        .NUM_SUBTRACT(NUM_SUBTRACT), 
        .IFM_SIZE(IFM_SIZE), 
        .LUT_SIZE(LUT_SIZE), 
        .DATA_WIDTH_OUT(DATA_WIDTH_OUT), 
        .NUM_REG_IFM(NUM_REG_IFM)
    ) dut (
        .clk1(clk1),
        .clk2(clk2),
        .rst_n(rst_n),
        .valid_ifm(valid_ifm),
        .ifm(ifm),
        .softmax_out_final(softmax_out_final),
        .valid_data(valid_data),
        .ifm_read(ifm_read),
        .end_softmax(end_softmax)
    );

    // Initialize file for writing
    initial begin
        file = $fopen("output_final.txt", "w");
        if (file == 0) begin
            $display("Error: could not open file.");
            $finish;
        end
    end

    // Dumping waveforms
    initial begin
        $dumpfile("softmax.vcd");
        $dumpvars(0, SOFTMAX_TB);
    end

    // Read input values from file
    initial begin
        $readmemb("./test_input_values.txt", ifm_in);
    end

    // Handle input data and counters
    always @(*) begin
        if (!rst_n) begin
            ifm_r = 0;
        end else if (valid_ifm) begin
            ifm_r = ifm_in[ifm_cnt];
        end else begin
            ifm_r = 0;
        end
    end
    assign ifm = ifm_r;

    always @(posedge clk1 or negedge rst_n) begin
        if (!rst_n) begin
            ifm_cnt <= 0;
        end else if (ifm_cnt == IFM_LEN && !ifm_read) begin
            ifm_cnt <= 0;
        end else if (valid_ifm) begin
            ifm_cnt <= ifm_cnt + 1;
        end else begin
            ifm_cnt <= ifm_cnt;
        end
    end

    // Clock generation
    initial begin
        clk1 = 0;
        forever #5 clk1 = ~clk1;
    end

    always #5 clk2 = !clk1;

    // Reset and valid_ifm signal generation
    initial begin
        rst_n = 0;
        valid_ifm = 0;

        #20;
        rst_n = 1;
        #20;

        valid_ifm = 1;
        #20000;
    end

    initial begin
        #10045 valid_ifm = 0;
    end

    // Stop simulation after a certain time
    initial begin
        #1500000 $finish;
    end

always @(posedge end_softmax) begin
	$finish;
end
    // Write softmax_out_final to file when valid_data is high
    always @(posedge clk1) begin
        if (valid_data) begin
            $fwrite(file,"%b\n", softmax_out_final);
        end
    end

    always @(dut.counter_compute) begin
			$display( " counter_compute : %d ", dut.counter_compute);
    end
    // Close the file at the end of simulation
    initial begin
        #1500000 $fclose(file);
    end

endmodule

