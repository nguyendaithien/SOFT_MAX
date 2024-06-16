module SOFTMAX_TOP #(parameter DATA_WIDTH_IN = 16, NUM_SUBTRACT = 1000,  IFM_SIZE = 1000, LUT_SIZE = 100, DATA_WIDTH_OUT = 26, NUM_REG_IFM = 1000)  (
		clk1        ,
		clk2        ,
		rst_n       ,
		valid_ifm   ,
		ifm         ,
		softmax_out_final ,
		valid_data,
		ifm_read

);
  input clk1                                   ;
  input clk2                                   ;
  input rst_n                                  ;
  input valid_ifm                              ;
  input  [DATA_WIDTH_IN -1:0 ] ifm             ;
  output wire [DATA_WIDTH_OUT- 1:0] softmax_out_final ;
  output wire valid_data                       ;
	output wire ifm_read;

	assign ifm_read = valid_data;
	wire wr_ifm;
	wire rd_ifm;
	wire wr_clr;
	wire rd_clr;
	wire [0:0] reg_write [999:0]                        ;
	wire reg_write_psum                           ;
	wire reg_write_output                         ;
	wire set_output                               ;
	wire [99:0] sel_mux_lut                       ;
	wire [DATA_WIDTH_IN-1:0] data_out_reg [999:0] ;

	wire [DATA_WIDTH_IN-1:0] data_out_fifo        ;
	wire [15:0] counter_ifm;
	wire [6:0] counter_lut;
	wire [DATA_WIDTH_OUT-1:0] softmax_out_1;
	wire [DATA_WIDTH_OUT-1:0] softmax_out_2;
	wire [DATA_WIDTH_OUT-1:0] softmax_out_3;
	wire [DATA_WIDTH_OUT-1:0] softmax_out_4;
	wire [DATA_WIDTH_OUT-1:0] softmax_out_5;
	wire [DATA_WIDTH_OUT-1:0] softmax_out_6;
	wire [DATA_WIDTH_OUT-1:0] softmax_out_7;
	wire [DATA_WIDTH_OUT-1:0] softmax_out_8;
	wire [DATA_WIDTH_OUT-1:0] softmax_out_9;
	wire [DATA_WIDTH_OUT-1:0] softmax_out_10;
	
	wire [3:0] sel_mux_output;
	wire [DATA_WIDTH_IN-1:0] data_out_mux [9:0];
  wire flag;
	wire flag_w;
	assign flag_w = (counter_ifm == 0);
	wire set_reg;


wire [DATA_WIDTH_OUT-1:0] data_out_lut_1;
wire [DATA_WIDTH_OUT-1:0] data_out_lut_2;
wire [DATA_WIDTH_OUT-1:0] data_out_lut_3;
wire [DATA_WIDTH_OUT-1:0] data_out_lut_4;
wire [DATA_WIDTH_OUT-1:0] data_out_lut_5;
wire [DATA_WIDTH_OUT-1:0] data_out_lut_6;
wire [DATA_WIDTH_OUT-1:0] data_out_lut_7;
wire [DATA_WIDTH_OUT-1:0] data_out_lut_8;
wire [DATA_WIDTH_OUT-1:0] data_out_lut_9;
wire [DATA_WIDTH_OUT-1:0] data_out_lut_10;
reg [DATA_WIDTH_OUT-1:0] reg_out_1  ;
reg [DATA_WIDTH_OUT-1:0] reg_out_2  ;
reg [DATA_WIDTH_OUT-1:0] reg_out_3  ;
reg [DATA_WIDTH_OUT-1:0] reg_out_4  ;
reg [DATA_WIDTH_OUT-1:0] reg_out_5  ;
reg [DATA_WIDTH_OUT-1:0] reg_out_6  ;
reg [DATA_WIDTH_OUT-1:0] reg_out_7  ;
reg [DATA_WIDTH_OUT-1:0] reg_out_8  ;
reg [DATA_WIDTH_OUT-1:0] reg_out_9  ;
reg [DATA_WIDTH_OUT-1:0] reg_out_10 ;

wire [3:0] current_state;
wire [7:0] counter_compute;

CONTROLLER #(.DATA_WIDTH(DATA_WIDTH_IN), .IFM_SIZE(IFM_SIZE), .LUT_SIZE(IFM_SIZE)) controller (
		 .clk            ( clk1             )
		,.rst_n          ( rst_n            )
		,.valid_ifm      ( valid_ifm        )
		,.ifm            ( ifm              )
		,.wr_ifm         ( wr_ifm           )
		,.rd_ifm         ( rd_ifm           )
		,.wr_clr         ( wr_clr           )
		,.rd_clr         ( rd_clr           )
		,.set_output     ( reg_write_output )
		,.counter_ifm    ( counter_ifm      )
		,.sel_mux_lut    ( sel_mux_lut      )
		,.counter_lut    ( counter_lut      )
		,.reg_write_psum ( reg_write_psum   )
		,.current_state  ( current_state    )
		,.flag           ( flag             )
		,.set_reg        ( set_reg          )
		,.counter_compute( counter_compute  )
	);

FIFO_ASYNCH #(.DATA_WIDTH(DATA_WIDTH_IN), .FIFO_SIZE(IFM_SIZE), .ADD_WIDTH(10)) ifm_buffer (
		 .clk1          ( clk1          )
		,.clk2          ( clk1          )
		,.rd_clr        ( rd_clr        )
		,.wr_clr        ( wr_clr        )
		,.rd_inc        ( 1'b1          )
		,.wr_inc        ( 1'b1          )
		,.wr_en         ( wr_ifm        )
		,.rd_en         ( rd_ifm        )
		,.data_in_fifo  ( ifm           )
		,.data_out_fifo ( data_out_fifo )
		);

WRITE_DATA #(.DATA_WIDTH(DATA_WIDTH_OUT), .OUTPUT_SIZE(10)) write_data (
	   .clk(clk1)
		,.rst_n(rst_n)
		,.state(current_state)
		,.valid_data(valid_data)
		,.sel_data(sel_mux_output)
		,.counter_compute(counter_compute)
		,.counter_ifm(counter_ifm)
);
//=======================================================================================
//=======================================================================================
 genvar i;
   generate
     for (i = 0; i < NUM_REG_IFM ; i = i + 1) begin : REGISTER_INST
       REGISTER #(DATA_WIDTH_IN) reg_inst (
          .clk       ( clk1            )
         ,.rst_n     ( rst_n           )
         ,.reg_write ( reg_write[i]    )
         ,.data_in   ( data_out_fifo   )
         ,.data_out  ( data_out_reg[i] )
       );
     end
   endgenerate

//=======================================================================================
//----------------------------SUBTRACT----------------------------------------------
//=======================================================================================
	 genvar j;
 generate
     for (j = 0; j < NUM_SUBTRACT; j = j + 1) begin : SUBTRACT_INST
         SUBTRACT #(DATA_WIDTH_IN) subtract_inst (
             .op_a(data_out_reg[j]),
             .op_b(data_out_fifo),
             .result(result[j])
         );
     end
 endgenerate

 wire [ DATA_WIDTH_IN-1:0] result [ 999:0];
 wire [ DATA_WIDTH_OUT-1:0] psum_out_1;
 wire [ DATA_WIDTH_OUT-1:0] psum_out_2;
 wire [ DATA_WIDTH_OUT-1:0] psum_out_3;
 wire [ DATA_WIDTH_OUT-1:0] psum_out_4;
 wire [ DATA_WIDTH_OUT-1:0] psum_out_5;
 wire [ DATA_WIDTH_OUT-1:0] psum_out_6;
 wire [ DATA_WIDTH_OUT-1:0] psum_out_7;
 wire [ DATA_WIDTH_OUT-1:0] psum_out_8;
 wire [ DATA_WIDTH_OUT-1:0] psum_out_9;
 wire [ DATA_WIDTH_OUT-1:0] psum_out_10;

 wire [ DATA_WIDTH_OUT-1:0] psum_in_1;
 wire [ DATA_WIDTH_OUT-1:0] psum_in_2;
 wire [ DATA_WIDTH_OUT-1:0] psum_in_3;
 wire [ DATA_WIDTH_OUT-1:0] psum_in_4;
 wire [ DATA_WIDTH_OUT-1:0] psum_in_5;
 wire [ DATA_WIDTH_OUT-1:0] psum_in_6;
 wire [ DATA_WIDTH_OUT-1:0] psum_in_7;
 wire [ DATA_WIDTH_OUT-1:0] psum_in_8;
 wire [ DATA_WIDTH_OUT-1:0] psum_in_9;
 wire [ DATA_WIDTH_OUT-1:0] psum_in_10;

 assign psum_in_1  = (flag_w) ? 0 : psum_out_1 ;
 assign psum_in_2  = (flag_w) ? 0 : psum_out_2 ;
 assign psum_in_3  = (flag_w) ? 0 : psum_out_3 ;
 assign psum_in_4  = (flag_w) ? 0 : psum_out_4 ;
 assign psum_in_5  = (flag_w) ? 0 : psum_out_5 ;
 assign psum_in_6  = (flag_w) ? 0 : psum_out_6 ;
 assign psum_in_7  = (flag_w) ? 0 : psum_out_7 ;
 assign psum_in_8  = (flag_w) ? 0 : psum_out_8 ;
 assign psum_in_9  = (flag_w) ? 0 : psum_out_9 ;
 assign psum_in_10 = (flag_w) ? 0 : psum_out_10;

// assign flag = ((counter_ifm == 0) || (counter_ifm == 1)); 
 
//=======================================================================================
//----------------------------REGISTER TO LUT----------------------------------------------
//=======================================================================================
//	genvar l;
//    generate
//        for (l = 0; l < NUM_REG_IFM; l = l + 1) begin : ASSIGN_PSUM
//            assign psum_in[l] = psum_out[l];
//        end
//    endgenerate
// genvar m;
//   generate
//     for (m = 0; m < NUM_REG_IFM ; m = m + 1) begin : REGISTER_INST_SET_OUTPUT
//       REGISTER #(DATA_WIDTH_IN) reg_inst (
//          .clk       ( clk1               )
//         ,.rst_n     ( rst_n              )
//         ,.reg_write ( reg_write_psum     )
//         ,.data_in   ( result[m]          )
//         ,.data_out  ( result[m] )
//       );
//     end
//   endgenerate
//=======================================================================================
//----------------------------MUX 100 TO 1----------------------------------------------
//=======================================================================================

MUX_100_TO_1 #(.DATA_WIDTH(DATA_WIDTH_IN)) mux_1 (
		    .sel (counter_lut),
				.out (data_out_mux[0]    ),
       .in_1 (result[0] ),      
       .in_2 (result[10]), 
       .in_3 (result[20]), 
       .in_4 (result[30]), 
       .in_5 (result[40]), 
       .in_6 (result[50]), 
       .in_7 (result[60]), 
       .in_8 (result[70]), 
       .in_9 (result[80]), 
      .in_10 (result[90]), 
      .in_11 (result[100]), 
      .in_12 (result[110]), 
      .in_13 (result[120]), 
      .in_14 (result[130]), 
      .in_15 (result[140]), 
      .in_16 (result[150]), 
      .in_17 (result[160]), 
      .in_18 (result[170]), 
      .in_19 (result[180]), 
      .in_20 (result[190]), 
      .in_21 (result[200]), 
      .in_22 (result[210]), 
      .in_23 (result[220]), 
      .in_24 (result[230]), 
      .in_25 (result[240]), 
      .in_26 (result[250]), 
      .in_27 (result[260]), 
      .in_28 (result[270]), 
      .in_29 (result[280]), 
      .in_30 (result[290]), 
      .in_31 (result[300]), 
      .in_32 (result[310]), 
      .in_33 (result[320]), 
      .in_34 (result[330]), 
      .in_35 (result[340]), 
      .in_36 (result[350]), 
      .in_37 (result[360]), 
      .in_38 (result[370]), 
      .in_39 (result[380]), 
      .in_40 (result[390]), 
      .in_41 (result[400]), 
      .in_42 (result[410]), 
      .in_43 (result[420]), 
      .in_44 (result[430]), 
      .in_45 (result[440]), 
      .in_46 (result[450]), 
      .in_47 (result[460]), 
      .in_48 (result[470]), 
      .in_49 (result[480]), 
      .in_50 (result[490]), 
      .in_51 (result[500]), 
      .in_52 (result[510]), 
      .in_53 (result[520]), 
      .in_54 (result[530]), 
      .in_55 (result[540]), 
      .in_56 (result[550]), 
      .in_57 (result[560]), 
      .in_58 (result[570]), 
      .in_59 (result[580]), 
      .in_60 (result[590]), 
      .in_61 (result[600]), 
      .in_62 (result[610]), 
      .in_63 (result[620]), 
      .in_64 (result[630]), 
      .in_65 (result[640]), 
      .in_66 (result[650]), 
      .in_67 (result[660]), 
      .in_68 (result[670]), 
      .in_69 (result[680]), 
      .in_70 (result[690]), 
      .in_71 (result[700]), 
      .in_72 (result[710]), 
      .in_73 (result[720]), 
      .in_74 (result[730]), 
      .in_75 (result[740]), 
      .in_76 (result[750]), 
      .in_77 (result[760]), 
      .in_78 (result[770]), 
      .in_79 (result[780]), 
      .in_80 (result[790]), 
      .in_81 (result[800]), 
      .in_82 (result[810]), 
      .in_83 (result[820]), 
      .in_84 (result[830]), 
      .in_85 (result[840]), 
      .in_86 (result[850]), 
      .in_87 (result[860]), 
      .in_88 (result[870]), 
      .in_89 (result[880]), 
      .in_90 (result[890]), 
      .in_91 (result[900]), 
      .in_92 (result[910]), 
      .in_93 (result[920]), 
      .in_94 (result[930]), 
      .in_95 (result[940]), 
      .in_96 (result[950]), 
      .in_97 (result[960]), 
      .in_98 (result[970]), 
      .in_99 (result[980]), 
			.in_100(result[990])           
);

MUX_100_TO_1 #(.DATA_WIDTH(DATA_WIDTH_IN)) mux_2 (
		    .sel (counter_lut),
				.out (data_out_mux[1]   ),
       .in_1 (result[1]),      
       .in_2 (result[11]), 
       .in_3 (result[21]), 
       .in_4 (result[31]), 
       .in_5 (result[41]), 
       .in_6 (result[51]), 
       .in_7 (result[61]), 
       .in_8 (result[71]), 
       .in_9 (result[81]), 
      .in_10 (result[91]), 
      .in_11 (result[101]), 
      .in_12 (result[111]), 
      .in_13 (result[121]), 
      .in_14 (result[131]), 
      .in_15 (result[141]), 
      .in_16 (result[151]), 
      .in_17 (result[161]), 
      .in_18 (result[171]), 
      .in_19 (result[181]), 
      .in_20 (result[191]), 
      .in_21 (result[201]), 
      .in_22 (result[211]), 
      .in_23 (result[221]), 
      .in_24 (result[231]), 
      .in_25 (result[241]), 
      .in_26 (result[251]), 
      .in_27 (result[261]), 
      .in_28 (result[271]), 
      .in_29 (result[281]), 
      .in_30 (result[291]), 
      .in_31 (result[301]), 
      .in_32 (result[311]), 
      .in_33 (result[321]), 
      .in_34 (result[331]), 
      .in_35 (result[341]), 
      .in_36 (result[351]), 
      .in_37 (result[361]), 
      .in_38 (result[371]), 
      .in_39 (result[381]), 
      .in_40 (result[391]), 
      .in_41 (result[401]), 
      .in_42 (result[411]), 
      .in_43 (result[421]), 
      .in_44 (result[431]), 
      .in_45 (result[441]), 
      .in_46 (result[451]), 
      .in_47 (result[461]), 
      .in_48 (result[471]), 
      .in_49 (result[481]), 
      .in_50 (result[491]), 
      .in_51 (result[501]), 
      .in_52 (result[511]), 
      .in_53 (result[521]), 
      .in_54 (result[531]), 
      .in_55 (result[541]), 
      .in_56 (result[551]), 
      .in_57 (result[561]), 
      .in_58 (result[571]), 
      .in_59 (result[581]), 
      .in_60 (result[591]), 
      .in_61 (result[601]), 
      .in_62 (result[611]), 
      .in_63 (result[621]), 
      .in_64 (result[631]), 
      .in_65 (result[641]), 
      .in_66 (result[651]), 
      .in_67 (result[661]), 
      .in_68 (result[671]), 
      .in_69 (result[681]), 
      .in_70 (result[691]), 
      .in_71 (result[701]), 
      .in_72 (result[711]), 
      .in_73 (result[721]), 
      .in_74 (result[731]), 
      .in_75 (result[741]), 
      .in_76 (result[751]), 
      .in_77 (result[761]), 
      .in_78 (result[771]), 
      .in_79 (result[781]), 
      .in_80 (result[791]), 
      .in_81 (result[801]), 
      .in_82 (result[811]), 
      .in_83 (result[821]), 
      .in_84 (result[831]), 
      .in_85 (result[841]), 
      .in_86 (result[851]), 
      .in_87 (result[861]), 
      .in_88 (result[871]), 
      .in_89 (result[881]), 
      .in_90 (result[891]), 
      .in_91 (result[901]), 
      .in_92 (result[911]), 
      .in_93 (result[921]), 
      .in_94 (result[931]), 
      .in_95 (result[941]), 
      .in_96 (result[951]), 
      .in_97 (result[961]), 
      .in_98 (result[971]), 
      .in_99 (result[981]), 
			.in_100(result[991])           
);

MUX_100_TO_1 #(.DATA_WIDTH(DATA_WIDTH_IN)) mux_3 (
		    .sel (counter_lut),
				.out (data_out_mux[2]   ),
       .in_1 (result[2]),      
       .in_2 (result[12]), 
       .in_3 (result[22]), 
       .in_4 (result[32]), 
       .in_5 (result[42]), 
       .in_6 (result[52]), 
       .in_7 (result[62]), 
       .in_8 (result[72]), 
       .in_9 (result[82]), 
      .in_10 (result[92]), 
      .in_11 (result[102]), 
      .in_12 (result[112]), 
      .in_13 (result[122]), 
      .in_14 (result[132]), 
      .in_15 (result[142]), 
      .in_16 (result[152]), 
      .in_17 (result[162]), 
      .in_18 (result[172]), 
      .in_19 (result[182]), 
      .in_20 (result[192]), 
      .in_21 (result[202]), 
      .in_22 (result[212]), 
      .in_23 (result[222]), 
      .in_24 (result[232]), 
      .in_25 (result[242]), 
      .in_26 (result[252]), 
      .in_27 (result[262]), 
      .in_28 (result[272]), 
      .in_29 (result[282]), 
      .in_30 (result[292]), 
      .in_31 (result[302]), 
      .in_32 (result[312]), 
      .in_33 (result[322]), 
      .in_34 (result[332]), 
      .in_35 (result[342]), 
      .in_36 (result[352]), 
      .in_37 (result[362]), 
      .in_38 (result[372]), 
      .in_39 (result[382]), 
      .in_40 (result[392]), 
      .in_41 (result[402]), 
      .in_42 (result[412]), 
      .in_43 (result[422]), 
      .in_44 (result[432]), 
      .in_45 (result[442]), 
      .in_46 (result[452]), 
      .in_47 (result[462]), 
      .in_48 (result[472]), 
      .in_49 (result[482]), 
      .in_50 (result[492]), 
      .in_51 (result[502]), 
      .in_52 (result[512]), 
      .in_53 (result[522]), 
      .in_54 (result[532]), 
      .in_55 (result[542]), 
      .in_56 (result[552]), 
      .in_57 (result[562]), 
      .in_58 (result[572]), 
      .in_59 (result[582]), 
      .in_60 (result[592]), 
      .in_61 (result[602]), 
      .in_62 (result[612]), 
      .in_63 (result[622]), 
      .in_64 (result[632]), 
      .in_65 (result[642]), 
      .in_66 (result[652]), 
      .in_67 (result[662]), 
      .in_68 (result[672]), 
      .in_69 (result[682]), 
      .in_70 (result[692]), 
      .in_71 (result[702]), 
      .in_72 (result[712]), 
      .in_73 (result[722]), 
      .in_74 (result[732]), 
      .in_75 (result[742]), 
      .in_76 (result[752]), 
      .in_77 (result[762]), 
      .in_78 (result[772]), 
      .in_79 (result[782]), 
      .in_80 (result[792]), 
      .in_81 (result[802]), 
      .in_82 (result[812]), 
      .in_83 (result[822]), 
      .in_84 (result[832]), 
      .in_85 (result[842]), 
      .in_86 (result[852]), 
      .in_87 (result[862]), 
      .in_88 (result[872]), 
      .in_89 (result[882]), 
      .in_90 (result[892]), 
      .in_91 (result[902]), 
      .in_92 (result[912]), 
      .in_93 (result[922]), 
      .in_94 (result[932]), 
      .in_95 (result[942]), 
      .in_96 (result[952]), 
      .in_97 (result[962]), 
      .in_98 (result[972]), 
      .in_99 (result[982]), 
			.in_100(result[992])           
);

MUX_100_TO_1 #(.DATA_WIDTH(DATA_WIDTH_IN)) mux_4 (
		    .sel (counter_lut),
				.out (data_out_mux[3]   ),
       .in_1 (result[3]),      
       .in_2 (result[13]), 
       .in_3 (result[23]), 
       .in_4 (result[33]), 
       .in_5 (result[43]), 
       .in_6 (result[53]), 
       .in_7 (result[63]), 
       .in_8 (result[73]), 
       .in_9 (result[83]), 
      .in_10 (result[93]), 
      .in_11 (result[103]), 
      .in_12 (result[113]), 
      .in_13 (result[123]), 
      .in_14 (result[133]), 
      .in_15 (result[143]), 
      .in_16 (result[153]), 
      .in_17 (result[163]), 
      .in_18 (result[173]), 
      .in_19 (result[183]), 
      .in_20 (result[193]), 
      .in_21 (result[203]), 
      .in_22 (result[213]), 
      .in_23 (result[223]), 
      .in_24 (result[233]), 
      .in_25 (result[243]), 
      .in_26 (result[253]), 
      .in_27 (result[263]), 
      .in_28 (result[273]), 
      .in_29 (result[283]), 
      .in_30 (result[293]), 
      .in_31 (result[303]), 
      .in_32 (result[313]), 
      .in_33 (result[323]), 
      .in_34 (result[333]), 
      .in_35 (result[343]), 
      .in_36 (result[353]), 
      .in_37 (result[363]), 
      .in_38 (result[373]), 
      .in_39 (result[383]), 
      .in_40 (result[393]), 
      .in_41 (result[403]), 
      .in_42 (result[413]), 
      .in_43 (result[423]), 
      .in_44 (result[433]), 
      .in_45 (result[443]), 
      .in_46 (result[453]), 
      .in_47 (result[463]), 
      .in_48 (result[473]), 
      .in_49 (result[483]), 
      .in_50 (result[493]), 
      .in_51 (result[503]), 
      .in_52 (result[513]), 
      .in_53 (result[523]), 
      .in_54 (result[533]), 
      .in_55 (result[543]), 
      .in_56 (result[553]), 
      .in_57 (result[563]), 
      .in_58 (result[573]), 
      .in_59 (result[583]), 
      .in_60 (result[593]), 
      .in_61 (result[603]), 
      .in_62 (result[613]), 
      .in_63 (result[623]), 
      .in_64 (result[633]), 
      .in_65 (result[643]), 
      .in_66 (result[653]), 
      .in_67 (result[663]), 
      .in_68 (result[673]), 
      .in_69 (result[683]), 
      .in_70 (result[693]), 
      .in_71 (result[703]), 
      .in_72 (result[713]), 
      .in_73 (result[723]), 
      .in_74 (result[733]), 
      .in_75 (result[743]), 
      .in_76 (result[753]), 
      .in_77 (result[763]), 
      .in_78 (result[773]), 
      .in_79 (result[783]), 
      .in_80 (result[793]), 
      .in_81 (result[803]), 
      .in_82 (result[813]), 
      .in_83 (result[823]), 
      .in_84 (result[833]), 
      .in_85 (result[843]), 
      .in_86 (result[853]), 
      .in_87 (result[863]), 
      .in_88 (result[873]), 
      .in_89 (result[883]), 
      .in_90 (result[893]), 
      .in_91 (result[903]), 
      .in_92 (result[913]), 
      .in_93 (result[923]), 
      .in_94 (result[933]), 
      .in_95 (result[943]), 
      .in_96 (result[953]), 
      .in_97 (result[963]), 
      .in_98 (result[973]), 
      .in_99 (result[983]), 
			.in_100(result[993])           
);

MUX_100_TO_1 #(.DATA_WIDTH(DATA_WIDTH_IN)) mux_5 (
		    .sel (counter_lut),
				.out (data_out_mux[4]   ),
       .in_1 (result[4]),      
       .in_2 (result[14]), 
       .in_3 (result[24]), 
       .in_4 (result[34]), 
       .in_5 (result[44]), 
       .in_6 (result[54]), 
       .in_7 (result[64]), 
       .in_8 (result[74]), 
       .in_9 (result[84]), 
      .in_10 (result[94]), 
      .in_11 (result[104]), 
      .in_12 (result[114]), 
      .in_13 (result[124]), 
      .in_14 (result[134]), 
      .in_15 (result[144]), 
      .in_16 (result[154]), 
      .in_17 (result[164]), 
      .in_18 (result[174]), 
      .in_19 (result[184]), 
      .in_20 (result[194]), 
      .in_21 (result[204]), 
      .in_22 (result[214]), 
      .in_23 (result[224]), 
      .in_24 (result[234]), 
      .in_25 (result[244]), 
      .in_26 (result[254]), 
      .in_27 (result[264]), 
      .in_28 (result[274]), 
      .in_29 (result[284]), 
      .in_30 (result[294]), 
      .in_31 (result[304]), 
      .in_32 (result[314]), 
      .in_33 (result[324]), 
      .in_34 (result[334]), 
      .in_35 (result[344]), 
      .in_36 (result[354]), 
      .in_37 (result[364]), 
      .in_38 (result[374]), 
      .in_39 (result[384]), 
      .in_40 (result[394]), 
      .in_41 (result[404]), 
      .in_42 (result[414]), 
      .in_43 (result[424]), 
      .in_44 (result[434]), 
      .in_45 (result[444]), 
      .in_46 (result[454]), 
      .in_47 (result[464]), 
      .in_48 (result[474]), 
      .in_49 (result[484]), 
      .in_50 (result[494]), 
      .in_51 (result[504]), 
      .in_52 (result[514]), 
      .in_53 (result[524]), 
      .in_54 (result[534]), 
      .in_55 (result[544]), 
      .in_56 (result[554]), 
      .in_57 (result[564]), 
      .in_58 (result[574]), 
      .in_59 (result[584]), 
      .in_60 (result[594]), 
      .in_61 (result[604]), 
      .in_62 (result[614]), 
      .in_63 (result[624]), 
      .in_64 (result[634]), 
      .in_65 (result[644]), 
      .in_66 (result[654]), 
      .in_67 (result[664]), 
      .in_68 (result[674]), 
      .in_69 (result[684]), 
      .in_70 (result[694]), 
      .in_71 (result[704]), 
      .in_72 (result[714]), 
      .in_73 (result[724]), 
      .in_74 (result[734]), 
      .in_75 (result[744]), 
      .in_76 (result[754]), 
      .in_77 (result[764]), 
      .in_78 (result[774]), 
      .in_79 (result[784]), 
      .in_80 (result[794]), 
      .in_81 (result[804]), 
      .in_82 (result[814]), 
      .in_83 (result[824]), 
      .in_84 (result[834]), 
      .in_85 (result[844]), 
      .in_86 (result[854]), 
      .in_87 (result[864]), 
      .in_88 (result[874]), 
      .in_89 (result[884]), 
      .in_90 (result[894]), 
      .in_91 (result[904]), 
      .in_92 (result[914]), 
      .in_93 (result[924]), 
      .in_94 (result[934]), 
      .in_95 (result[944]), 
      .in_96 (result[954]), 
      .in_97 (result[964]), 
      .in_98 (result[974]), 
      .in_99 (result[984]), 
			.in_100(result[994])           
);

MUX_100_TO_1 #(.DATA_WIDTH(DATA_WIDTH_IN)) mux_6 (
		    .sel (counter_lut),
				.out (data_out_mux[5]   ),
       .in_1 (result[5]),      
       .in_2 (result[15]), 
       .in_3 (result[25]), 
       .in_4 (result[35]), 
       .in_5 (result[45]), 
       .in_6 (result[55]), 
       .in_7 (result[65]), 
       .in_8 (result[75]), 
       .in_9 (result[85]), 
      .in_10 (result[95]), 
      .in_11 (result[105]), 
      .in_12 (result[115]), 
      .in_13 (result[125]), 
      .in_14 (result[135]), 
      .in_15 (result[145]), 
      .in_16 (result[155]), 
      .in_17 (result[165]), 
      .in_18 (result[175]), 
      .in_19 (result[185]), 
      .in_20 (result[195]), 
      .in_21 (result[205]), 
      .in_22 (result[215]), 
      .in_23 (result[225]), 
      .in_24 (result[235]), 
      .in_25 (result[245]), 
      .in_26 (result[255]), 
      .in_27 (result[265]), 
      .in_28 (result[275]), 
      .in_29 (result[285]), 
      .in_30 (result[295]), 
      .in_31 (result[305]), 
      .in_32 (result[315]), 
      .in_33 (result[325]), 
      .in_34 (result[335]), 
      .in_35 (result[345]), 
      .in_36 (result[355]), 
      .in_37 (result[365]), 
      .in_38 (result[375]), 
      .in_39 (result[385]), 
      .in_40 (result[395]), 
      .in_41 (result[405]), 
      .in_42 (result[415]), 
      .in_43 (result[425]), 
      .in_44 (result[435]), 
      .in_45 (result[445]), 
      .in_46 (result[455]), 
      .in_47 (result[465]), 
      .in_48 (result[475]), 
      .in_49 (result[485]), 
      .in_50 (result[495]), 
      .in_51 (result[505]), 
      .in_52 (result[515]), 
      .in_53 (result[525]), 
      .in_54 (result[535]), 
      .in_55 (result[545]), 
      .in_56 (result[555]), 
      .in_57 (result[565]), 
      .in_58 (result[575]), 
      .in_59 (result[585]), 
      .in_60 (result[595]), 
      .in_61 (result[605]), 
      .in_62 (result[615]), 
      .in_63 (result[625]), 
      .in_64 (result[635]), 
      .in_65 (result[645]), 
      .in_66 (result[655]), 
      .in_67 (result[665]), 
      .in_68 (result[675]), 
      .in_69 (result[685]), 
      .in_70 (result[695]), 
      .in_71 (result[705]), 
      .in_72 (result[715]), 
      .in_73 (result[725]), 
      .in_74 (result[735]), 
      .in_75 (result[745]), 
      .in_76 (result[755]), 
      .in_77 (result[765]), 
      .in_78 (result[775]), 
      .in_79 (result[785]), 
      .in_80 (result[795]), 
      .in_81 (result[805]), 
      .in_82 (result[815]), 
      .in_83 (result[825]), 
      .in_84 (result[835]), 
      .in_85 (result[845]), 
      .in_86 (result[855]), 
      .in_87 (result[865]), 
      .in_88 (result[875]), 
      .in_89 (result[885]), 
      .in_90 (result[895]), 
      .in_91 (result[905]), 
      .in_92 (result[915]), 
      .in_93 (result[925]), 
      .in_94 (result[935]), 
      .in_95 (result[945]), 
      .in_96 (result[955]), 
      .in_97 (result[965]), 
      .in_98 (result[975]), 
      .in_99 (result[985]), 
			.in_100(result[995])           
);

MUX_100_TO_1 #(.DATA_WIDTH(DATA_WIDTH_IN)) mux_7 (
		    .sel (counter_lut),
				.out (data_out_mux[6]   ),
       .in_1 (result[6]),      
       .in_2 (result[16]), 
       .in_3 (result[26]), 
       .in_4 (result[36]), 
       .in_5 (result[46]), 
       .in_6 (result[56]), 
       .in_7 (result[66]), 
       .in_8 (result[76]), 
       .in_9 (result[86]), 
      .in_10 (result[96]), 
      .in_11 (result[106]), 
      .in_12 (result[116]), 
      .in_13 (result[126]), 
      .in_14 (result[136]), 
      .in_15 (result[146]), 
      .in_16 (result[156]), 
      .in_17 (result[166]), 
      .in_18 (result[176]), 
      .in_19 (result[186]), 
      .in_20 (result[196]), 
      .in_21 (result[206]), 
      .in_22 (result[216]), 
      .in_23 (result[226]), 
      .in_24 (result[236]), 
      .in_25 (result[246]), 
      .in_26 (result[256]), 
      .in_27 (result[266]), 
      .in_28 (result[276]), 
      .in_29 (result[286]), 
      .in_30 (result[296]), 
      .in_31 (result[306]), 
      .in_32 (result[316]), 
      .in_33 (result[326]), 
      .in_34 (result[336]), 
      .in_35 (result[346]), 
      .in_36 (result[356]), 
      .in_37 (result[366]), 
      .in_38 (result[376]), 
      .in_39 (result[386]), 
      .in_40 (result[396]), 
      .in_41 (result[406]), 
      .in_42 (result[416]), 
      .in_43 (result[426]), 
      .in_44 (result[436]), 
      .in_45 (result[446]), 
      .in_46 (result[456]), 
      .in_47 (result[466]), 
      .in_48 (result[476]), 
      .in_49 (result[486]), 
      .in_50 (result[496]), 
      .in_51 (result[506]), 
      .in_52 (result[516]), 
      .in_53 (result[526]), 
      .in_54 (result[536]), 
      .in_55 (result[546]), 
      .in_56 (result[556]), 
      .in_57 (result[566]), 
      .in_58 (result[576]), 
      .in_59 (result[586]), 
      .in_60 (result[596]), 
      .in_61 (result[606]), 
      .in_62 (result[616]), 
      .in_63 (result[626]), 
      .in_64 (result[636]), 
      .in_65 (result[646]), 
      .in_66 (result[656]), 
      .in_67 (result[666]), 
      .in_68 (result[676]), 
      .in_69 (result[686]), 
      .in_70 (result[696]), 
      .in_71 (result[706]), 
      .in_72 (result[716]), 
      .in_73 (result[726]), 
      .in_74 (result[736]), 
      .in_75 (result[746]), 
      .in_76 (result[756]), 
      .in_77 (result[766]), 
      .in_78 (result[776]), 
      .in_79 (result[786]), 
      .in_80 (result[796]), 
      .in_81 (result[806]), 
      .in_82 (result[816]), 
      .in_83 (result[826]), 
      .in_84 (result[836]), 
      .in_85 (result[846]), 
      .in_86 (result[856]), 
      .in_87 (result[866]), 
      .in_88 (result[876]), 
      .in_89 (result[886]), 
      .in_90 (result[896]), 
      .in_91 (result[906]), 
      .in_92 (result[916]), 
      .in_93 (result[926]), 
      .in_94 (result[936]), 
      .in_95 (result[946]), 
      .in_96 (result[956]), 
      .in_97 (result[966]), 
      .in_98 (result[976]), 
      .in_99 (result[986]), 
			.in_100(result[996])           
);

MUX_100_TO_1 #(.DATA_WIDTH(DATA_WIDTH_IN)) mux_8 (
		    .sel (counter_lut),
				.out (data_out_mux[7]   ),
       .in_1 (result[7]),      
       .in_2 (result[17]), 
       .in_3 (result[27]), 
       .in_4 (result[37]), 
       .in_5 (result[47]), 
       .in_6 (result[57]), 
       .in_7 (result[67]), 
       .in_8 (result[77]), 
       .in_9 (result[87]), 
      .in_10 (result[97]), 
      .in_11 (result[107]), 
      .in_12 (result[117]), 
      .in_13 (result[127]), 
      .in_14 (result[137]), 
      .in_15 (result[147]), 
      .in_16 (result[157]), 
      .in_17 (result[167]), 
      .in_18 (result[177]), 
      .in_19 (result[187]), 
      .in_20 (result[197]), 
      .in_21 (result[207]), 
      .in_22 (result[217]), 
      .in_23 (result[227]), 
      .in_24 (result[237]), 
      .in_25 (result[247]), 
      .in_26 (result[257]), 
      .in_27 (result[267]), 
      .in_28 (result[277]), 
      .in_29 (result[287]), 
      .in_30 (result[297]), 
      .in_31 (result[307]), 
      .in_32 (result[317]), 
      .in_33 (result[327]), 
      .in_34 (result[337]), 
      .in_35 (result[347]), 
      .in_36 (result[357]), 
      .in_37 (result[367]), 
      .in_38 (result[377]), 
      .in_39 (result[387]), 
      .in_40 (result[397]), 
      .in_41 (result[407]), 
      .in_42 (result[417]), 
      .in_43 (result[427]), 
      .in_44 (result[437]), 
      .in_45 (result[447]), 
      .in_46 (result[457]), 
      .in_47 (result[467]), 
      .in_48 (result[477]), 
      .in_49 (result[487]), 
      .in_50 (result[497]), 
      .in_51 (result[507]), 
      .in_52 (result[517]), 
      .in_53 (result[527]), 
      .in_54 (result[537]), 
      .in_55 (result[547]), 
      .in_56 (result[557]), 
      .in_57 (result[567]), 
      .in_58 (result[577]), 
      .in_59 (result[587]), 
      .in_60 (result[597]), 
      .in_61 (result[607]), 
      .in_62 (result[617]), 
      .in_63 (result[627]), 
      .in_64 (result[637]), 
      .in_65 (result[647]), 
      .in_66 (result[657]), 
      .in_67 (result[667]), 
      .in_68 (result[677]), 
      .in_69 (result[687]), 
      .in_70 (result[697]), 
      .in_71 (result[707]), 
      .in_72 (result[717]), 
      .in_73 (result[727]), 
      .in_74 (result[737]), 
      .in_75 (result[747]), 
      .in_76 (result[757]), 
      .in_77 (result[767]), 
      .in_78 (result[777]), 
      .in_79 (result[787]), 
      .in_80 (result[797]), 
      .in_81 (result[807]), 
      .in_82 (result[817]), 
      .in_83 (result[827]), 
      .in_84 (result[837]), 
      .in_85 (result[847]), 
      .in_86 (result[857]), 
      .in_87 (result[867]), 
      .in_88 (result[877]), 
      .in_89 (result[887]), 
      .in_90 (result[897]), 
      .in_91 (result[907]), 
      .in_92 (result[917]), 
      .in_93 (result[927]), 
      .in_94 (result[937]), 
      .in_95 (result[947]), 
      .in_96 (result[957]), 
      .in_97 (result[967]), 
      .in_98 (result[977]), 
      .in_99 (result[987]), 
			.in_100(result[997])           
);

MUX_100_TO_1 #(.DATA_WIDTH(DATA_WIDTH_IN)) mux_9 (
		    .sel (counter_lut),
				.out (data_out_mux[8]   ),
       .in_1 (result[8]),      
       .in_2 (result[18]), 
       .in_3 (result[28]), 
       .in_4 (result[38]), 
       .in_5 (result[48]), 
       .in_6 (result[58]), 
       .in_7 (result[68]), 
       .in_8 (result[78]), 
       .in_9 (result[88]), 
      .in_10 (result[98]), 
      .in_11 (result[108]), 
      .in_12 (result[118]), 
      .in_13 (result[128]), 
      .in_14 (result[138]), 
      .in_15 (result[148]), 
      .in_16 (result[158]), 
      .in_17 (result[168]), 
      .in_18 (result[178]), 
      .in_19 (result[188]), 
      .in_20 (result[198]), 
      .in_21 (result[208]), 
      .in_22 (result[218]), 
      .in_23 (result[228]), 
      .in_24 (result[238]), 
      .in_25 (result[248]), 
      .in_26 (result[258]), 
      .in_27 (result[268]), 
      .in_28 (result[278]), 
      .in_29 (result[288]), 
      .in_30 (result[298]), 
      .in_31 (result[308]), 
      .in_32 (result[318]), 
      .in_33 (result[328]), 
      .in_34 (result[338]), 
      .in_35 (result[348]), 
      .in_36 (result[358]), 
      .in_37 (result[368]), 
      .in_38 (result[378]), 
      .in_39 (result[388]), 
      .in_40 (result[398]), 
      .in_41 (result[408]), 
      .in_42 (result[418]), 
      .in_43 (result[428]), 
      .in_44 (result[438]), 
      .in_45 (result[448]), 
      .in_46 (result[458]), 
      .in_47 (result[468]), 
      .in_48 (result[478]), 
      .in_49 (result[488]), 
      .in_50 (result[498]), 
      .in_51 (result[508]), 
      .in_52 (result[518]), 
      .in_53 (result[528]), 
      .in_54 (result[538]), 
      .in_55 (result[548]), 
      .in_56 (result[558]), 
      .in_57 (result[568]), 
      .in_58 (result[578]), 
      .in_59 (result[588]), 
      .in_60 (result[598]), 
      .in_61 (result[608]), 
      .in_62 (result[618]), 
      .in_63 (result[628]), 
      .in_64 (result[638]), 
      .in_65 (result[648]), 
      .in_66 (result[658]), 
      .in_67 (result[668]), 
      .in_68 (result[678]), 
      .in_69 (result[688]), 
      .in_70 (result[698]), 
      .in_71 (result[708]), 
      .in_72 (result[718]), 
      .in_73 (result[728]), 
      .in_74 (result[738]), 
      .in_75 (result[748]), 
      .in_76 (result[758]), 
      .in_77 (result[768]), 
      .in_78 (result[778]), 
      .in_79 (result[788]), 
      .in_80 (result[798]), 
      .in_81 (result[808]), 
      .in_82 (result[818]), 
      .in_83 (result[828]), 
      .in_84 (result[838]), 
      .in_85 (result[848]), 
      .in_86 (result[858]), 
      .in_87 (result[868]), 
      .in_88 (result[878]), 
      .in_89 (result[888]), 
      .in_90 (result[898]), 
      .in_91 (result[908]), 
      .in_92 (result[918]), 
      .in_93 (result[928]), 
      .in_94 (result[938]), 
      .in_95 (result[948]), 
      .in_96 (result[958]), 
      .in_97 (result[968]), 
      .in_98 (result[978]), 
      .in_99 (result[988]), 
			.in_100(result[998])           
);

MUX_100_TO_1 #(.DATA_WIDTH(DATA_WIDTH_IN)) mux_10 (
		    .sel (counter_lut),
				.out (data_out_mux[9]   ),
       .in_1 (result[9]),      
       .in_2 (result[19]), 
       .in_3 (result[29]), 
       .in_4 (result[39]), 
       .in_5 (result[49]), 
       .in_6 (result[59]), 
       .in_7 (result[69]), 
       .in_8 (result[79]), 
       .in_9 (result[89]), 
      .in_10 (result[99]), 
      .in_11 (result[109]), 
      .in_12 (result[119]), 
      .in_13 (result[129]), 
      .in_14 (result[139]), 
      .in_15 (result[149]), 
      .in_16 (result[159]), 
      .in_17 (result[169]), 
      .in_18 (result[179]), 
      .in_19 (result[189]), 
      .in_20 (result[199]), 
      .in_21 (result[209]), 
      .in_22 (result[219]), 
      .in_23 (result[229]), 
      .in_24 (result[239]), 
      .in_25 (result[249]), 
      .in_26 (result[259]), 
      .in_27 (result[269]), 
      .in_28 (result[279]), 
      .in_29 (result[289]), 
      .in_30 (result[299]), 
      .in_31 (result[309]), 
      .in_32 (result[319]), 
      .in_33 (result[329]), 
      .in_34 (result[339]), 
      .in_35 (result[349]), 
      .in_36 (result[359]), 
      .in_37 (result[369]), 
      .in_38 (result[379]), 
      .in_39 (result[389]), 
      .in_40 (result[399]), 
      .in_41 (result[409]), 
      .in_42 (result[419]), 
      .in_43 (result[429]), 
      .in_44 (result[439]), 
      .in_45 (result[449]), 
      .in_46 (result[459]), 
      .in_47 (result[469]), 
      .in_48 (result[479]), 
      .in_49 (result[489]), 
      .in_50 (result[499]), 
      .in_51 (result[509]), 
      .in_52 (result[519]), 
      .in_53 (result[529]), 
      .in_54 (result[539]), 
      .in_55 (result[549]), 
      .in_56 (result[559]), 
      .in_57 (result[569]), 
      .in_58 (result[579]), 
      .in_59 (result[589]), 
      .in_60 (result[599]), 
      .in_61 (result[609]), 
      .in_62 (result[619]), 
      .in_63 (result[629]), 
      .in_64 (result[639]), 
      .in_65 (result[649]), 
      .in_66 (result[659]), 
      .in_67 (result[669]), 
      .in_68 (result[679]), 
      .in_69 (result[689]), 
      .in_70 (result[699]), 
      .in_71 (result[709]), 
      .in_72 (result[719]), 
      .in_73 (result[729]), 
      .in_74 (result[739]), 
      .in_75 (result[749]), 
      .in_76 (result[759]), 
      .in_77 (result[769]), 
      .in_78 (result[779]), 
      .in_79 (result[789]), 
      .in_80 (result[799]), 
      .in_81 (result[809]), 
      .in_82 (result[819]), 
      .in_83 (result[829]), 
      .in_84 (result[839]), 
      .in_85 (result[849]), 
      .in_86 (result[859]), 
      .in_87 (result[869]), 
      .in_88 (result[879]), 
      .in_89 (result[889]), 
      .in_90 (result[899]), 
      .in_91 (result[909]), 
      .in_92 (result[919]), 
      .in_93 (result[929]), 
      .in_94 (result[939]), 
      .in_95 (result[949]), 
      .in_96 (result[959]), 
      .in_97 (result[969]), 
      .in_98 (result[979]), 
      .in_99 (result[989]), 
			.in_100(result[999])           
);

//=======================================================================================
//----------------------------LUT----------------------------------------------
//=======================================================================================

LUT #(.DATA_WIDTH(DATA_WIDTH_IN) , .DATA_WIDTH_OUT(DATA_WIDTH_OUT)) lut1 (
		.data_in(data_out_mux[0])
	 ,.data_out(data_out_lut_1)
);
LUT #(.DATA_WIDTH(DATA_WIDTH_IN) , .DATA_WIDTH_OUT(DATA_WIDTH_OUT)) lut2 (
		.data_in(data_out_mux[1])
	 ,.data_out(data_out_lut_2)
);
LUT #(.DATA_WIDTH(DATA_WIDTH_IN) , .DATA_WIDTH_OUT(DATA_WIDTH_OUT)) lut3 (
		.data_in(data_out_mux[2])
	 ,.data_out(data_out_lut_3)
);
LUT #(.DATA_WIDTH(DATA_WIDTH_IN) , .DATA_WIDTH_OUT(DATA_WIDTH_OUT)) lut4 (
		.data_in(data_out_mux[3])
	 ,.data_out(data_out_lut_4)
);
LUT #(.DATA_WIDTH(DATA_WIDTH_IN) , .DATA_WIDTH_OUT(DATA_WIDTH_OUT)) lut5 (
		.data_in(data_out_mux[4])
	 ,.data_out(data_out_lut_5)
);
LUT #(.DATA_WIDTH(DATA_WIDTH_IN) , .DATA_WIDTH_OUT(DATA_WIDTH_OUT)) lut6 (
		.data_in(data_out_mux[5])
	 ,.data_out(data_out_lut_6)
);
LUT #(.DATA_WIDTH(DATA_WIDTH_IN) , .DATA_WIDTH_OUT(DATA_WIDTH_OUT)) lut7 (
		.data_in(data_out_mux[6])
	 ,.data_out(data_out_lut_7)
);
LUT #(.DATA_WIDTH(DATA_WIDTH_IN) , .DATA_WIDTH_OUT(DATA_WIDTH_OUT)) lut8 (
		.data_in(data_out_mux[7])
	 ,.data_out(data_out_lut_8)
);
LUT #(.DATA_WIDTH(DATA_WIDTH_IN) , .DATA_WIDTH_OUT(DATA_WIDTH_OUT)) lut9 (
		.data_in(data_out_mux[8])
	 ,.data_out(data_out_lut_9)
);
LUT #(.DATA_WIDTH(DATA_WIDTH_IN) , .DATA_WIDTH_OUT(DATA_WIDTH_OUT)) lut10 (
		.data_in(data_out_mux[9])
	 ,.data_out(data_out_lut_10)
);

//=======================================================================================
//----------------------------ADDER ----------------------------------------------
//=======================================================================================
PE #(.DATA_WIDTH(DATA_WIDTH_OUT)) pe1 (
     .clk      ( clk1           )
    ,.rst_n    ( rst_n          )
    ,.set_reg  ( set_reg        )
    ,.in1      ( psum_in_1      )
    ,.in2      ( data_out_lut_1 )
    ,.psum_out ( psum_out_1     )
	);
PE #(.DATA_WIDTH(DATA_WIDTH_OUT)) pe2 (
     .clk      ( clk1           )
    ,.rst_n    ( rst_n          )
    ,.set_reg  ( set_reg        )
    ,.in1      ( psum_in_1      )
    ,.in2      ( data_out_lut_2 )
    ,.psum_out ( psum_out_1     )
	);
PE #(.DATA_WIDTH(DATA_WIDTH_OUT)) pe3 (
     .clk      ( clk1           )
    ,.rst_n    ( rst_n          )
    ,.set_reg  ( set_reg        )
    ,.in1      ( psum_in_3      )
    ,.in2      ( data_out_lut_3 )
    ,.psum_out ( psum_out_3     )
	);
PE #(.DATA_WIDTH(DATA_WIDTH_OUT)) pe4 (
     .clk      ( clk1           )
    ,.rst_n    ( rst_n          )
    ,.set_reg  ( set_reg        )
    ,.in1      ( psum_in_4      )
    ,.in2      ( data_out_lut_4 )
    ,.psum_out ( psum_out_4     )
	);
PE #(.DATA_WIDTH(DATA_WIDTH_OUT)) pe5 (
     .clk(clk1)
    ,.rst_n(rst_n)
    ,.set_reg(set_reg)
    ,.in1(psum_in_5)
    ,.in2(data_out_lut_5)
    ,.psum_out(psum_out_5)
	);
PE #(.DATA_WIDTH(DATA_WIDTH_OUT)) pe6 (
     .clk(clk1)
    ,.rst_n(rst_n)
    ,.set_reg(set_reg)
    ,.in1(psum_in_6)
    ,.in2(data_out_lut_6)
    ,.psum_out(psum_out_6)
	);
PE #(.DATA_WIDTH(DATA_WIDTH_OUT)) pe7 (
     .clk(clk1)
    ,.rst_n(rst_n)
    ,.set_reg(set_reg)
    ,.in1(psum_in_7)
    ,.in2(data_out_lut_7)
    ,.psum_out(psum_out_7)
	);
PE #(.DATA_WIDTH(DATA_WIDTH_OUT)) pe8 (
     .clk(clk1)
    ,.rst_n(rst_n)
    ,.set_reg(set_reg)
    ,.in1(psum_in_8)
    ,.in2(data_out_lut_8)
    ,.psum_out(psum_out_8)
	);
PE #(.DATA_WIDTH(DATA_WIDTH_OUT)) pe9 (
     .clk(clk1)
    ,.rst_n(rst_n)
    ,.set_reg(set_reg)
    ,.in1(psum_in_9)
    ,.in2(data_out_lut_9)
    ,.psum_out(psum_out_9)
	);
PE #(.DATA_WIDTH(DATA_WIDTH_OUT)) pe10 (
     .clk(clk1)
    ,.rst_n(rst_n)
    ,.set_reg(set_reg)
    ,.in1(psum_in_10)
    ,.in2(data_out_lut_10)
    ,.psum_out(psum_out_10)
	);



always @(posedge clk1 or negedge rst_n) begin
	if(!rst_n) begin
     reg_out_1  <= 24'd0;   
     reg_out_2  <= 24'd0;
     reg_out_3  <= 24'd0;
     reg_out_4  <= 24'd0;
     reg_out_5  <= 24'd0;
     reg_out_6  <= 24'd0;
     reg_out_7  <= 24'd0;
     reg_out_8  <= 24'd0;
     reg_out_9  <= 24'd0;
     reg_out_10 <= 24'd0;
	end
	else begin
		reg_out_1  <= (reg_write_output) ? psum_out_1  :  reg_out_1 ;  
		reg_out_2  <= (reg_write_output) ? psum_out_2  :  reg_out_2 ;
		reg_out_3  <= (reg_write_output) ? psum_out_3  :  reg_out_3 ;
		reg_out_4  <= (reg_write_output) ? psum_out_4  :  reg_out_4 ;
		reg_out_5  <= (reg_write_output) ? psum_out_5  :  reg_out_5 ;
		reg_out_6  <= (reg_write_output) ? psum_out_6  :  reg_out_6 ;
		reg_out_7  <= (reg_write_output) ? psum_out_7  :  reg_out_7 ;
		reg_out_8  <= (reg_write_output) ? psum_out_8  :  reg_out_8 ;
		reg_out_9  <= (reg_write_output) ? psum_out_9  :  reg_out_9 ;
		reg_out_10 <= (reg_write_output) ? psum_out_10 :  reg_out_10;
	end
end


MUX_10_TO_1 #(.DATA_WIDTH(24)) mux_output (
		 .in0(reg_out_1 ) 
		,.in1(reg_out_2 )
		,.in2(reg_out_3 )
		,.in3(reg_out_4 )
		,.in4(reg_out_5 )
		,.in5(reg_out_6 )
		,.in6(reg_out_7 )
		,.in7(reg_out_8 )
		,.in8(reg_out_9 )
		,.in9(reg_out_10)
		,.sel(sel_mux_output)
		,.out(softmax_out_final)
);

REG_CONTROL #(.DATA_WIDTH(DATA_WIDTH_IN)) reg_control (
		 .current_state(current_state)
		,.counter_ifm(counter_ifm)
    ,.reg_write_1(reg_write[0])
    ,.reg_write_2(reg_write[1])
    ,.reg_write_3(reg_write[2])
    ,.reg_write_4(reg_write[3])
    ,.reg_write_5(reg_write[4])
    ,.reg_write_6(reg_write[5])
    ,.reg_write_7(reg_write[6])
    ,.reg_write_8(reg_write[7])
    ,.reg_write_9(reg_write[8])
    ,.reg_write_10(reg_write[9])
    ,.reg_write_11(reg_write[10])
    ,.reg_write_12(reg_write[11])
    ,.reg_write_13(reg_write[12])
    ,.reg_write_14(reg_write[13])
    ,.reg_write_15(reg_write[14])
    ,.reg_write_16(reg_write[15])
    ,.reg_write_17(reg_write[16])
    ,.reg_write_18(reg_write[17])
    ,.reg_write_19(reg_write[18])
    ,.reg_write_20(reg_write[19])
    ,.reg_write_21(reg_write[20])
    ,.reg_write_22(reg_write[21])
    ,.reg_write_23(reg_write[22])
    ,.reg_write_24(reg_write[23])
    ,.reg_write_25(reg_write[24])
    ,.reg_write_26(reg_write[25])
    ,.reg_write_27(reg_write[26])
    ,.reg_write_28(reg_write[27])
    ,.reg_write_29(reg_write[28])
    ,.reg_write_30(reg_write[29])
    ,.reg_write_31(reg_write[30])
    ,.reg_write_32(reg_write[31])
    ,.reg_write_33(reg_write[32])
    ,.reg_write_34(reg_write[33])
    ,.reg_write_35(reg_write[34])
    ,.reg_write_36(reg_write[35])
    ,.reg_write_37(reg_write[36])
    ,.reg_write_38(reg_write[37])
    ,.reg_write_39(reg_write[38])
    ,.reg_write_40(reg_write[39])
    ,.reg_write_41(reg_write[40])
    ,.reg_write_42(reg_write[41])
    ,.reg_write_43(reg_write[42])
    ,.reg_write_44(reg_write[43])
    ,.reg_write_45(reg_write[44])
    ,.reg_write_46(reg_write[45])
    ,.reg_write_47(reg_write[46])
    ,.reg_write_48(reg_write[47])
    ,.reg_write_49(reg_write[48])
    ,.reg_write_50(reg_write[49])
    ,.reg_write_51(reg_write[50])
    ,.reg_write_52(reg_write[51])
    ,.reg_write_53(reg_write[52])
    ,.reg_write_54(reg_write[53])
    ,.reg_write_55(reg_write[54])
    ,.reg_write_56(reg_write[55])
    ,.reg_write_57(reg_write[56])
    ,.reg_write_58(reg_write[57])
    ,.reg_write_59(reg_write[58])
    ,.reg_write_60(reg_write[59])
    ,.reg_write_61(reg_write[60])
    ,.reg_write_62(reg_write[61])
    ,.reg_write_63(reg_write[62])
    ,.reg_write_64(reg_write[63])
    ,.reg_write_65(reg_write[64])
    ,.reg_write_66(reg_write[65])
    ,.reg_write_67(reg_write[66])
    ,.reg_write_68(reg_write[67])
    ,.reg_write_69(reg_write[68])
    ,.reg_write_70(reg_write[69])
    ,.reg_write_71(reg_write[70])
    ,.reg_write_72(reg_write[71])
    ,.reg_write_73(reg_write[72])
    ,.reg_write_74(reg_write[73])
    ,.reg_write_75(reg_write[74])
    ,.reg_write_76(reg_write[75])
    ,.reg_write_77(reg_write[76])
    ,.reg_write_78(reg_write[77])
    ,.reg_write_79(reg_write[78])
    ,.reg_write_80(reg_write[79])
    ,.reg_write_81(reg_write[80])
    ,.reg_write_82(reg_write[81])
    ,.reg_write_83(reg_write[82])
    ,.reg_write_84(reg_write[83])
    ,.reg_write_85(reg_write[84])
    ,.reg_write_86(reg_write[85])
    ,.reg_write_87(reg_write[86])
    ,.reg_write_88(reg_write[87])
    ,.reg_write_89(reg_write[88])
    ,.reg_write_90(reg_write[89])
    ,.reg_write_91(reg_write[90])
    ,.reg_write_92(reg_write[91])
    ,.reg_write_93(reg_write[92])
    ,.reg_write_94(reg_write[93])
    ,.reg_write_95(reg_write[94])
    ,.reg_write_96(reg_write[95])
    ,.reg_write_97(reg_write[96])
    ,.reg_write_98(reg_write[97])
    ,.reg_write_99(reg_write[98])
    ,.reg_write_100(reg_write[99])
    ,.reg_write_101(reg_write[100])
    ,.reg_write_102(reg_write[101])
    ,.reg_write_103(reg_write[102])
    ,.reg_write_104(reg_write[103])
    ,.reg_write_105(reg_write[104])
    ,.reg_write_106(reg_write[105])
    ,.reg_write_107(reg_write[106])
    ,.reg_write_108(reg_write[107])
    ,.reg_write_109(reg_write[108])
    ,.reg_write_110(reg_write[109])
    ,.reg_write_111(reg_write[110])
    ,.reg_write_112(reg_write[111])
    ,.reg_write_113(reg_write[112])
    ,.reg_write_114(reg_write[113])
    ,.reg_write_115(reg_write[114])
    ,.reg_write_116(reg_write[115])
    ,.reg_write_117(reg_write[116])
    ,.reg_write_118(reg_write[117])
    ,.reg_write_119(reg_write[118])
    ,.reg_write_120(reg_write[119])
    ,.reg_write_121(reg_write[120])
    ,.reg_write_122(reg_write[121])
    ,.reg_write_123(reg_write[122])
    ,.reg_write_124(reg_write[123])
    ,.reg_write_125(reg_write[124])
    ,.reg_write_126(reg_write[125])
    ,.reg_write_127(reg_write[126])
    ,.reg_write_128(reg_write[127])
    ,.reg_write_129(reg_write[128])
    ,.reg_write_130(reg_write[129])
    ,.reg_write_131(reg_write[130])
    ,.reg_write_132(reg_write[131])
    ,.reg_write_133(reg_write[132])
    ,.reg_write_134(reg_write[133])
    ,.reg_write_135(reg_write[134])
    ,.reg_write_136(reg_write[135])
    ,.reg_write_137(reg_write[136])
    ,.reg_write_138(reg_write[137])
    ,.reg_write_139(reg_write[138])
    ,.reg_write_140(reg_write[139])
    ,.reg_write_141(reg_write[140])
    ,.reg_write_142(reg_write[141])
    ,.reg_write_143(reg_write[142])
    ,.reg_write_144(reg_write[143])
    ,.reg_write_145(reg_write[144])
    ,.reg_write_146(reg_write[145])
    ,.reg_write_147(reg_write[146])
    ,.reg_write_148(reg_write[147])
    ,.reg_write_149(reg_write[148])
    ,.reg_write_150(reg_write[149])
    ,.reg_write_151(reg_write[150])
    ,.reg_write_152(reg_write[151])
    ,.reg_write_153(reg_write[152])
    ,.reg_write_154(reg_write[153])
    ,.reg_write_155(reg_write[154])
    ,.reg_write_156(reg_write[155])
    ,.reg_write_157(reg_write[156])
    ,.reg_write_158(reg_write[157])
    ,.reg_write_159(reg_write[158])
    ,.reg_write_160(reg_write[159])
    ,.reg_write_161(reg_write[160])
    ,.reg_write_162(reg_write[161])
    ,.reg_write_163(reg_write[162])
    ,.reg_write_164(reg_write[163])
    ,.reg_write_165(reg_write[164])
    ,.reg_write_166(reg_write[165])
    ,.reg_write_167(reg_write[166])
    ,.reg_write_168(reg_write[167])
    ,.reg_write_169(reg_write[168])
    ,.reg_write_170(reg_write[169])
    ,.reg_write_171(reg_write[170])
    ,.reg_write_172(reg_write[171])
    ,.reg_write_173(reg_write[172])
    ,.reg_write_174(reg_write[173])
    ,.reg_write_175(reg_write[174])
    ,.reg_write_176(reg_write[175])
    ,.reg_write_177(reg_write[176])
    ,.reg_write_178(reg_write[177])
    ,.reg_write_179(reg_write[178])
    ,.reg_write_180(reg_write[179])
    ,.reg_write_181(reg_write[180])
    ,.reg_write_182(reg_write[181])
    ,.reg_write_183(reg_write[182])
    ,.reg_write_184(reg_write[183])
    ,.reg_write_185(reg_write[184])
    ,.reg_write_186(reg_write[185])
    ,.reg_write_187(reg_write[186])
    ,.reg_write_188(reg_write[187])
    ,.reg_write_189(reg_write[188])
    ,.reg_write_190(reg_write[189])
    ,.reg_write_191(reg_write[190])
    ,.reg_write_192(reg_write[191])
    ,.reg_write_193(reg_write[192])
    ,.reg_write_194(reg_write[193])
    ,.reg_write_195(reg_write[194])
    ,.reg_write_196(reg_write[195])
    ,.reg_write_197(reg_write[196])
    ,.reg_write_198(reg_write[197])
    ,.reg_write_199(reg_write[198])
    ,.reg_write_200(reg_write[199])
    ,.reg_write_201(reg_write[200])
    ,.reg_write_202(reg_write[201])
    ,.reg_write_203(reg_write[202])
    ,.reg_write_204(reg_write[203])
    ,.reg_write_205(reg_write[204])
    ,.reg_write_206(reg_write[205])
    ,.reg_write_207(reg_write[206])
    ,.reg_write_208(reg_write[207])
    ,.reg_write_209(reg_write[208])
    ,.reg_write_210(reg_write[209])
    ,.reg_write_211(reg_write[210])
    ,.reg_write_212(reg_write[211])
    ,.reg_write_213(reg_write[212])
    ,.reg_write_214(reg_write[213])
    ,.reg_write_215(reg_write[214])
    ,.reg_write_216(reg_write[215])
    ,.reg_write_217(reg_write[216])
    ,.reg_write_218(reg_write[217])
    ,.reg_write_219(reg_write[218])
    ,.reg_write_220(reg_write[219])
    ,.reg_write_221(reg_write[220])
    ,.reg_write_222(reg_write[221])
    ,.reg_write_223(reg_write[222])
    ,.reg_write_224(reg_write[223])
    ,.reg_write_225(reg_write[224])
    ,.reg_write_226(reg_write[225])
    ,.reg_write_227(reg_write[226])
    ,.reg_write_228(reg_write[227])
    ,.reg_write_229(reg_write[228])
    ,.reg_write_230(reg_write[229])
    ,.reg_write_231(reg_write[230])
    ,.reg_write_232(reg_write[231])
    ,.reg_write_233(reg_write[232])
    ,.reg_write_234(reg_write[233])
    ,.reg_write_235(reg_write[234])
    ,.reg_write_236(reg_write[235])
    ,.reg_write_237(reg_write[236])
    ,.reg_write_238(reg_write[237])
    ,.reg_write_239(reg_write[238])
    ,.reg_write_240(reg_write[239])
    ,.reg_write_241(reg_write[240])
    ,.reg_write_242(reg_write[241])
    ,.reg_write_243(reg_write[242])
    ,.reg_write_244(reg_write[243])
    ,.reg_write_245(reg_write[244])
    ,.reg_write_246(reg_write[245])
    ,.reg_write_247(reg_write[246])
    ,.reg_write_248(reg_write[247])
    ,.reg_write_249(reg_write[248])
    ,.reg_write_250(reg_write[249])
    ,.reg_write_251(reg_write[250])
    ,.reg_write_252(reg_write[251])
    ,.reg_write_253(reg_write[252])
    ,.reg_write_254(reg_write[253])
    ,.reg_write_255(reg_write[254])
    ,.reg_write_256(reg_write[255])
    ,.reg_write_257(reg_write[256])
    ,.reg_write_258(reg_write[257])
    ,.reg_write_259(reg_write[258])
    ,.reg_write_260(reg_write[259])
    ,.reg_write_261(reg_write[260])
    ,.reg_write_262(reg_write[261])
    ,.reg_write_263(reg_write[262])
    ,.reg_write_264(reg_write[263])
    ,.reg_write_265(reg_write[264])
    ,.reg_write_266(reg_write[265])
    ,.reg_write_267(reg_write[266])
    ,.reg_write_268(reg_write[267])
    ,.reg_write_269(reg_write[268])
    ,.reg_write_270(reg_write[269])
    ,.reg_write_271(reg_write[270])
    ,.reg_write_272(reg_write[271])
    ,.reg_write_273(reg_write[272])
    ,.reg_write_274(reg_write[273])
    ,.reg_write_275(reg_write[274])
    ,.reg_write_276(reg_write[275])
    ,.reg_write_277(reg_write[276])
    ,.reg_write_278(reg_write[277])
    ,.reg_write_279(reg_write[278])
    ,.reg_write_280(reg_write[279])
    ,.reg_write_281(reg_write[280])
    ,.reg_write_282(reg_write[281])
    ,.reg_write_283(reg_write[282])
    ,.reg_write_284(reg_write[283])
    ,.reg_write_285(reg_write[284])
    ,.reg_write_286(reg_write[285])
    ,.reg_write_287(reg_write[286])
    ,.reg_write_288(reg_write[287])
    ,.reg_write_289(reg_write[288])
    ,.reg_write_290(reg_write[289])
    ,.reg_write_291(reg_write[290])
    ,.reg_write_292(reg_write[291])
    ,.reg_write_293(reg_write[292])
    ,.reg_write_294(reg_write[293])
    ,.reg_write_295(reg_write[294])
    ,.reg_write_296(reg_write[295])
    ,.reg_write_297(reg_write[296])
    ,.reg_write_298(reg_write[297])
    ,.reg_write_299(reg_write[298])
    ,.reg_write_300(reg_write[299])
    ,.reg_write_301(reg_write[300])
    ,.reg_write_302(reg_write[301])
    ,.reg_write_303(reg_write[302])
    ,.reg_write_304(reg_write[303])
    ,.reg_write_305(reg_write[304])
    ,.reg_write_306(reg_write[305])
    ,.reg_write_307(reg_write[306])
    ,.reg_write_308(reg_write[307])
    ,.reg_write_309(reg_write[308])
    ,.reg_write_310(reg_write[309])
    ,.reg_write_311(reg_write[310])
    ,.reg_write_312(reg_write[311])
    ,.reg_write_313(reg_write[312])
    ,.reg_write_314(reg_write[313])
    ,.reg_write_315(reg_write[314])
    ,.reg_write_316(reg_write[315])
    ,.reg_write_317(reg_write[316])
    ,.reg_write_318(reg_write[317])
    ,.reg_write_319(reg_write[318])
    ,.reg_write_320(reg_write[319])
    ,.reg_write_321(reg_write[320])
    ,.reg_write_322(reg_write[321])
    ,.reg_write_323(reg_write[322])
    ,.reg_write_324(reg_write[323])
    ,.reg_write_325(reg_write[324])
    ,.reg_write_326(reg_write[325])
    ,.reg_write_327(reg_write[326])
    ,.reg_write_328(reg_write[327])
    ,.reg_write_329(reg_write[328])
    ,.reg_write_330(reg_write[329])
    ,.reg_write_331(reg_write[330])
    ,.reg_write_332(reg_write[331])
    ,.reg_write_333(reg_write[332])
    ,.reg_write_334(reg_write[333])
    ,.reg_write_335(reg_write[334])
    ,.reg_write_336(reg_write[335])
    ,.reg_write_337(reg_write[336])
    ,.reg_write_338(reg_write[337])
    ,.reg_write_339(reg_write[338])
    ,.reg_write_340(reg_write[339])
    ,.reg_write_341(reg_write[340])
    ,.reg_write_342(reg_write[341])
    ,.reg_write_343(reg_write[342])
    ,.reg_write_344(reg_write[343])
    ,.reg_write_345(reg_write[344])
    ,.reg_write_346(reg_write[345])
    ,.reg_write_347(reg_write[346])
    ,.reg_write_348(reg_write[347])
    ,.reg_write_349(reg_write[348])
    ,.reg_write_350(reg_write[349])
    ,.reg_write_351(reg_write[350])
    ,.reg_write_352(reg_write[351])
    ,.reg_write_353(reg_write[352])
    ,.reg_write_354(reg_write[353])
    ,.reg_write_355(reg_write[354])
    ,.reg_write_356(reg_write[355])
    ,.reg_write_357(reg_write[356])
    ,.reg_write_358(reg_write[357])
    ,.reg_write_359(reg_write[358])
    ,.reg_write_360(reg_write[359])
    ,.reg_write_361(reg_write[360])
    ,.reg_write_362(reg_write[361])
    ,.reg_write_363(reg_write[362])
    ,.reg_write_364(reg_write[363])
    ,.reg_write_365(reg_write[364])
    ,.reg_write_366(reg_write[365])
    ,.reg_write_367(reg_write[366])
    ,.reg_write_368(reg_write[367])
    ,.reg_write_369(reg_write[368])
    ,.reg_write_370(reg_write[369])
    ,.reg_write_371(reg_write[370])
    ,.reg_write_372(reg_write[371])
    ,.reg_write_373(reg_write[372])
    ,.reg_write_374(reg_write[373])
    ,.reg_write_375(reg_write[374])
    ,.reg_write_376(reg_write[375])
    ,.reg_write_377(reg_write[376])
    ,.reg_write_378(reg_write[377])
    ,.reg_write_379(reg_write[378])
    ,.reg_write_380(reg_write[379])
    ,.reg_write_381(reg_write[380])
    ,.reg_write_382(reg_write[381])
    ,.reg_write_383(reg_write[382])
    ,.reg_write_384(reg_write[383])
    ,.reg_write_385(reg_write[384])
    ,.reg_write_386(reg_write[385])
    ,.reg_write_387(reg_write[386])
    ,.reg_write_388(reg_write[387])
    ,.reg_write_389(reg_write[388])
    ,.reg_write_390(reg_write[389])
    ,.reg_write_391(reg_write[390])
    ,.reg_write_392(reg_write[391])
    ,.reg_write_393(reg_write[392])
    ,.reg_write_394(reg_write[393])
    ,.reg_write_395(reg_write[394])
    ,.reg_write_396(reg_write[395])
    ,.reg_write_397(reg_write[396])
    ,.reg_write_398(reg_write[397])
    ,.reg_write_399(reg_write[398])
    ,.reg_write_400(reg_write[399])
    ,.reg_write_401(reg_write[400])
    ,.reg_write_402(reg_write[401])
    ,.reg_write_403(reg_write[402])
    ,.reg_write_404(reg_write[403])
    ,.reg_write_405(reg_write[404])
    ,.reg_write_406(reg_write[405])
    ,.reg_write_407(reg_write[406])
    ,.reg_write_408(reg_write[407])
    ,.reg_write_409(reg_write[408])
    ,.reg_write_410(reg_write[409])
    ,.reg_write_411(reg_write[410])
    ,.reg_write_412(reg_write[411])
    ,.reg_write_413(reg_write[412])
    ,.reg_write_414(reg_write[413])
    ,.reg_write_415(reg_write[414])
    ,.reg_write_416(reg_write[415])
    ,.reg_write_417(reg_write[416])
    ,.reg_write_418(reg_write[417])
    ,.reg_write_419(reg_write[418])
    ,.reg_write_420(reg_write[419])
    ,.reg_write_421(reg_write[420])
    ,.reg_write_422(reg_write[421])
    ,.reg_write_423(reg_write[422])
    ,.reg_write_424(reg_write[423])
    ,.reg_write_425(reg_write[424])
    ,.reg_write_426(reg_write[425])
    ,.reg_write_427(reg_write[426])
    ,.reg_write_428(reg_write[427])
    ,.reg_write_429(reg_write[428])
    ,.reg_write_430(reg_write[429])
    ,.reg_write_431(reg_write[430])
    ,.reg_write_432(reg_write[431])
    ,.reg_write_433(reg_write[432])
    ,.reg_write_434(reg_write[433])
    ,.reg_write_435(reg_write[434])
    ,.reg_write_436(reg_write[435])
    ,.reg_write_437(reg_write[436])
    ,.reg_write_438(reg_write[437])
    ,.reg_write_439(reg_write[438])
    ,.reg_write_440(reg_write[439])
    ,.reg_write_441(reg_write[440])
    ,.reg_write_442(reg_write[441])
    ,.reg_write_443(reg_write[442])
    ,.reg_write_444(reg_write[443])
    ,.reg_write_445(reg_write[444])
    ,.reg_write_446(reg_write[445])
    ,.reg_write_447(reg_write[446])
    ,.reg_write_448(reg_write[447])
    ,.reg_write_449(reg_write[448])
    ,.reg_write_450(reg_write[449])
    ,.reg_write_451(reg_write[450])
    ,.reg_write_452(reg_write[451])
    ,.reg_write_453(reg_write[452])
    ,.reg_write_454(reg_write[453])
    ,.reg_write_455(reg_write[454])
    ,.reg_write_456(reg_write[455])
    ,.reg_write_457(reg_write[456])
    ,.reg_write_458(reg_write[457])
    ,.reg_write_459(reg_write[458])
    ,.reg_write_460(reg_write[459])
    ,.reg_write_461(reg_write[460])
    ,.reg_write_462(reg_write[461])
    ,.reg_write_463(reg_write[462])
    ,.reg_write_464(reg_write[463])
    ,.reg_write_465(reg_write[464])
    ,.reg_write_466(reg_write[465])
    ,.reg_write_467(reg_write[466])
    ,.reg_write_468(reg_write[467])
    ,.reg_write_469(reg_write[468])
    ,.reg_write_470(reg_write[469])
    ,.reg_write_471(reg_write[470])
    ,.reg_write_472(reg_write[471])
    ,.reg_write_473(reg_write[472])
    ,.reg_write_474(reg_write[473])
    ,.reg_write_475(reg_write[474])
    ,.reg_write_476(reg_write[475])
    ,.reg_write_477(reg_write[476])
    ,.reg_write_478(reg_write[477])
    ,.reg_write_479(reg_write[478])
    ,.reg_write_480(reg_write[479])
    ,.reg_write_481(reg_write[480])
    ,.reg_write_482(reg_write[481])
    ,.reg_write_483(reg_write[482])
    ,.reg_write_484(reg_write[483])
    ,.reg_write_485(reg_write[484])
    ,.reg_write_486(reg_write[485])
    ,.reg_write_487(reg_write[486])
    ,.reg_write_488(reg_write[487])
    ,.reg_write_489(reg_write[488])
    ,.reg_write_490(reg_write[489])
    ,.reg_write_491(reg_write[490])
    ,.reg_write_492(reg_write[491])
    ,.reg_write_493(reg_write[492])
    ,.reg_write_494(reg_write[493])
    ,.reg_write_495(reg_write[494])
    ,.reg_write_496(reg_write[495])
    ,.reg_write_497(reg_write[496])
    ,.reg_write_498(reg_write[497])
    ,.reg_write_499(reg_write[498])
    ,.reg_write_500(reg_write[499])
    ,.reg_write_501(reg_write[500])
    ,.reg_write_502(reg_write[501])
    ,.reg_write_503(reg_write[502])
    ,.reg_write_504(reg_write[503])
    ,.reg_write_505(reg_write[504])
    ,.reg_write_506(reg_write[505])
    ,.reg_write_507(reg_write[506])
    ,.reg_write_508(reg_write[507])
    ,.reg_write_509(reg_write[508])
    ,.reg_write_510(reg_write[509])
    ,.reg_write_511(reg_write[510])
    ,.reg_write_512(reg_write[511])
    ,.reg_write_513(reg_write[512])
    ,.reg_write_514(reg_write[513])
    ,.reg_write_515(reg_write[514])
    ,.reg_write_516(reg_write[515])
    ,.reg_write_517(reg_write[516])
    ,.reg_write_518(reg_write[517])
    ,.reg_write_519(reg_write[518])
    ,.reg_write_520(reg_write[519])
    ,.reg_write_521(reg_write[520])
    ,.reg_write_522(reg_write[521])
    ,.reg_write_523(reg_write[522])
    ,.reg_write_524(reg_write[523])
    ,.reg_write_525(reg_write[524])
    ,.reg_write_526(reg_write[525])
    ,.reg_write_527(reg_write[526])
    ,.reg_write_528(reg_write[527])
    ,.reg_write_529(reg_write[528])
    ,.reg_write_530(reg_write[529])
    ,.reg_write_531(reg_write[530])
    ,.reg_write_532(reg_write[531])
    ,.reg_write_533(reg_write[532])
    ,.reg_write_534(reg_write[533])
    ,.reg_write_535(reg_write[534])
    ,.reg_write_536(reg_write[535])
    ,.reg_write_537(reg_write[536])
    ,.reg_write_538(reg_write[537])
    ,.reg_write_539(reg_write[538])
    ,.reg_write_540(reg_write[539])
    ,.reg_write_541(reg_write[540])
    ,.reg_write_542(reg_write[541])
    ,.reg_write_543(reg_write[542])
    ,.reg_write_544(reg_write[543])
    ,.reg_write_545(reg_write[544])
    ,.reg_write_546(reg_write[545])
    ,.reg_write_547(reg_write[546])
    ,.reg_write_548(reg_write[547])
    ,.reg_write_549(reg_write[548])
    ,.reg_write_550(reg_write[549])
    ,.reg_write_551(reg_write[550])
    ,.reg_write_552(reg_write[551])
    ,.reg_write_553(reg_write[552])
    ,.reg_write_554(reg_write[553])
    ,.reg_write_555(reg_write[554])
    ,.reg_write_556(reg_write[555])
    ,.reg_write_557(reg_write[556])
    ,.reg_write_558(reg_write[557])
    ,.reg_write_559(reg_write[558])
    ,.reg_write_560(reg_write[559])
    ,.reg_write_561(reg_write[560])
    ,.reg_write_562(reg_write[561])
    ,.reg_write_563(reg_write[562])
    ,.reg_write_564(reg_write[563])
    ,.reg_write_565(reg_write[564])
    ,.reg_write_566(reg_write[565])
    ,.reg_write_567(reg_write[566])
    ,.reg_write_568(reg_write[567])
    ,.reg_write_569(reg_write[568])
    ,.reg_write_570(reg_write[569])
    ,.reg_write_571(reg_write[570])
    ,.reg_write_572(reg_write[571])
    ,.reg_write_573(reg_write[572])
    ,.reg_write_574(reg_write[573])
    ,.reg_write_575(reg_write[574])
    ,.reg_write_576(reg_write[575])
    ,.reg_write_577(reg_write[576])
    ,.reg_write_578(reg_write[577])
    ,.reg_write_579(reg_write[578])
    ,.reg_write_580(reg_write[579])
    ,.reg_write_581(reg_write[580])
    ,.reg_write_582(reg_write[581])
    ,.reg_write_583(reg_write[582])
    ,.reg_write_584(reg_write[583])
    ,.reg_write_585(reg_write[584])
    ,.reg_write_586(reg_write[585])
    ,.reg_write_587(reg_write[586])
    ,.reg_write_588(reg_write[587])
    ,.reg_write_589(reg_write[588])
    ,.reg_write_590(reg_write[589])
    ,.reg_write_591(reg_write[590])
    ,.reg_write_592(reg_write[591])
    ,.reg_write_593(reg_write[592])
    ,.reg_write_594(reg_write[593])
    ,.reg_write_595(reg_write[594])
    ,.reg_write_596(reg_write[595])
    ,.reg_write_597(reg_write[596])
    ,.reg_write_598(reg_write[597])
    ,.reg_write_599(reg_write[598])
    ,.reg_write_600(reg_write[599])
    ,.reg_write_601(reg_write[600])
    ,.reg_write_602(reg_write[601])
    ,.reg_write_603(reg_write[602])
    ,.reg_write_604(reg_write[603])
    ,.reg_write_605(reg_write[604])
    ,.reg_write_606(reg_write[605])
    ,.reg_write_607(reg_write[606])
    ,.reg_write_608(reg_write[607])
    ,.reg_write_609(reg_write[608])
    ,.reg_write_610(reg_write[609])
    ,.reg_write_611(reg_write[610])
    ,.reg_write_612(reg_write[611])
    ,.reg_write_613(reg_write[612])
    ,.reg_write_614(reg_write[613])
    ,.reg_write_615(reg_write[614])
    ,.reg_write_616(reg_write[615])
    ,.reg_write_617(reg_write[616])
    ,.reg_write_618(reg_write[617])
    ,.reg_write_619(reg_write[618])
    ,.reg_write_620(reg_write[619])
    ,.reg_write_621(reg_write[620])
    ,.reg_write_622(reg_write[621])
    ,.reg_write_623(reg_write[622])
    ,.reg_write_624(reg_write[623])
    ,.reg_write_625(reg_write[624])
    ,.reg_write_626(reg_write[625])
    ,.reg_write_627(reg_write[626])
    ,.reg_write_628(reg_write[627])
    ,.reg_write_629(reg_write[628])
    ,.reg_write_630(reg_write[629])
    ,.reg_write_631(reg_write[630])
    ,.reg_write_632(reg_write[631])
    ,.reg_write_633(reg_write[632])
    ,.reg_write_634(reg_write[633])
    ,.reg_write_635(reg_write[634])
    ,.reg_write_636(reg_write[635])
    ,.reg_write_637(reg_write[636])
    ,.reg_write_638(reg_write[637])
    ,.reg_write_639(reg_write[638])
    ,.reg_write_640(reg_write[639])
    ,.reg_write_641(reg_write[640])
    ,.reg_write_642(reg_write[641])
    ,.reg_write_643(reg_write[642])
    ,.reg_write_644(reg_write[643])
    ,.reg_write_645(reg_write[644])
    ,.reg_write_646(reg_write[645])
    ,.reg_write_647(reg_write[646])
    ,.reg_write_648(reg_write[647])
    ,.reg_write_649(reg_write[648])
    ,.reg_write_650(reg_write[649])
    ,.reg_write_651(reg_write[650])
    ,.reg_write_652(reg_write[651])
    ,.reg_write_653(reg_write[652])
    ,.reg_write_654(reg_write[653])
    ,.reg_write_655(reg_write[654])
    ,.reg_write_656(reg_write[655])
    ,.reg_write_657(reg_write[656])
    ,.reg_write_658(reg_write[657])
    ,.reg_write_659(reg_write[658])
    ,.reg_write_660(reg_write[659])
    ,.reg_write_661(reg_write[660])
    ,.reg_write_662(reg_write[661])
    ,.reg_write_663(reg_write[662])
    ,.reg_write_664(reg_write[663])
    ,.reg_write_665(reg_write[664])
    ,.reg_write_666(reg_write[665])
    ,.reg_write_667(reg_write[666])
    ,.reg_write_668(reg_write[667])
    ,.reg_write_669(reg_write[668])
    ,.reg_write_670(reg_write[669])
    ,.reg_write_671(reg_write[670])
    ,.reg_write_672(reg_write[671])
    ,.reg_write_673(reg_write[672])
    ,.reg_write_674(reg_write[673])
    ,.reg_write_675(reg_write[674])
    ,.reg_write_676(reg_write[675])
    ,.reg_write_677(reg_write[676])
    ,.reg_write_678(reg_write[677])
    ,.reg_write_679(reg_write[678])
    ,.reg_write_680(reg_write[679])
    ,.reg_write_681(reg_write[680])
    ,.reg_write_682(reg_write[681])
    ,.reg_write_683(reg_write[682])
    ,.reg_write_684(reg_write[683])
    ,.reg_write_685(reg_write[684])
    ,.reg_write_686(reg_write[685])
    ,.reg_write_687(reg_write[686])
    ,.reg_write_688(reg_write[687])
    ,.reg_write_689(reg_write[688])
    ,.reg_write_690(reg_write[689])
    ,.reg_write_691(reg_write[690])
    ,.reg_write_692(reg_write[691])
    ,.reg_write_693(reg_write[692])
    ,.reg_write_694(reg_write[693])
    ,.reg_write_695(reg_write[694])
    ,.reg_write_696(reg_write[695])
    ,.reg_write_697(reg_write[696])
    ,.reg_write_698(reg_write[697])
    ,.reg_write_699(reg_write[698])
    ,.reg_write_700(reg_write[699])
    ,.reg_write_701(reg_write[700])
    ,.reg_write_702(reg_write[701])
    ,.reg_write_703(reg_write[702])
    ,.reg_write_704(reg_write[703])
    ,.reg_write_705(reg_write[704])
    ,.reg_write_706(reg_write[705])
    ,.reg_write_707(reg_write[706])
    ,.reg_write_708(reg_write[707])
    ,.reg_write_709(reg_write[708])
    ,.reg_write_710(reg_write[709])
    ,.reg_write_711(reg_write[710])
    ,.reg_write_712(reg_write[711])
    ,.reg_write_713(reg_write[712])
    ,.reg_write_714(reg_write[713])
    ,.reg_write_715(reg_write[714])
    ,.reg_write_716(reg_write[715])
    ,.reg_write_717(reg_write[716])
    ,.reg_write_718(reg_write[717])
    ,.reg_write_719(reg_write[718])
    ,.reg_write_720(reg_write[719])
    ,.reg_write_721(reg_write[720])
    ,.reg_write_722(reg_write[721])
    ,.reg_write_723(reg_write[722])
    ,.reg_write_724(reg_write[723])
    ,.reg_write_725(reg_write[724])
    ,.reg_write_726(reg_write[725])
    ,.reg_write_727(reg_write[726])
    ,.reg_write_728(reg_write[727])
    ,.reg_write_729(reg_write[728])
    ,.reg_write_730(reg_write[729])
    ,.reg_write_731(reg_write[730])
    ,.reg_write_732(reg_write[731])
    ,.reg_write_733(reg_write[732])
    ,.reg_write_734(reg_write[733])
    ,.reg_write_735(reg_write[734])
    ,.reg_write_736(reg_write[735])
    ,.reg_write_737(reg_write[736])
    ,.reg_write_738(reg_write[737])
    ,.reg_write_739(reg_write[738])
    ,.reg_write_740(reg_write[739])
    ,.reg_write_741(reg_write[740])
    ,.reg_write_742(reg_write[741])
    ,.reg_write_743(reg_write[742])
    ,.reg_write_744(reg_write[743])
    ,.reg_write_745(reg_write[744])
    ,.reg_write_746(reg_write[745])
    ,.reg_write_747(reg_write[746])
    ,.reg_write_748(reg_write[747])
    ,.reg_write_749(reg_write[748])
    ,.reg_write_750(reg_write[749])
    ,.reg_write_751(reg_write[750])
    ,.reg_write_752(reg_write[751])
    ,.reg_write_753(reg_write[752])
    ,.reg_write_754(reg_write[753])
    ,.reg_write_755(reg_write[754])
    ,.reg_write_756(reg_write[755])
    ,.reg_write_757(reg_write[756])
    ,.reg_write_758(reg_write[757])
    ,.reg_write_759(reg_write[758])
    ,.reg_write_760(reg_write[759])
    ,.reg_write_761(reg_write[760])
    ,.reg_write_762(reg_write[761])
    ,.reg_write_763(reg_write[762])
    ,.reg_write_764(reg_write[763])
    ,.reg_write_765(reg_write[764])
    ,.reg_write_766(reg_write[765])
    ,.reg_write_767(reg_write[766])
    ,.reg_write_768(reg_write[767])
    ,.reg_write_769(reg_write[768])
    ,.reg_write_770(reg_write[769])
    ,.reg_write_771(reg_write[770])
    ,.reg_write_772(reg_write[771])
    ,.reg_write_773(reg_write[772])
    ,.reg_write_774(reg_write[773])
    ,.reg_write_775(reg_write[774])
    ,.reg_write_776(reg_write[775])
    ,.reg_write_777(reg_write[776])
    ,.reg_write_778(reg_write[777])
    ,.reg_write_779(reg_write[778])
    ,.reg_write_780(reg_write[779])
    ,.reg_write_781(reg_write[780])
    ,.reg_write_782(reg_write[781])
    ,.reg_write_783(reg_write[782])
    ,.reg_write_784(reg_write[783])
    ,.reg_write_785(reg_write[784])
    ,.reg_write_786(reg_write[785])
    ,.reg_write_787(reg_write[786])
    ,.reg_write_788(reg_write[787])
    ,.reg_write_789(reg_write[788])
    ,.reg_write_790(reg_write[789])
    ,.reg_write_791(reg_write[790])
    ,.reg_write_792(reg_write[791])
    ,.reg_write_793(reg_write[792])
    ,.reg_write_794(reg_write[793])
    ,.reg_write_795(reg_write[794])
    ,.reg_write_796(reg_write[795])
    ,.reg_write_797(reg_write[796])
    ,.reg_write_798(reg_write[797])
    ,.reg_write_799(reg_write[798])
    ,.reg_write_800(reg_write[799])
    ,.reg_write_801(reg_write[800])
    ,.reg_write_802(reg_write[801])
    ,.reg_write_803(reg_write[802])
    ,.reg_write_804(reg_write[803])
    ,.reg_write_805(reg_write[804])
    ,.reg_write_806(reg_write[805])
    ,.reg_write_807(reg_write[806])
    ,.reg_write_808(reg_write[807])
    ,.reg_write_809(reg_write[808])
    ,.reg_write_810(reg_write[809])
    ,.reg_write_811(reg_write[810])
    ,.reg_write_812(reg_write[811])
    ,.reg_write_813(reg_write[812])
    ,.reg_write_814(reg_write[813])
    ,.reg_write_815(reg_write[814])
    ,.reg_write_816(reg_write[815])
    ,.reg_write_817(reg_write[816])
    ,.reg_write_818(reg_write[817])
    ,.reg_write_819(reg_write[818])
    ,.reg_write_820(reg_write[819])
    ,.reg_write_821(reg_write[820])
    ,.reg_write_822(reg_write[821])
    ,.reg_write_823(reg_write[822])
    ,.reg_write_824(reg_write[823])
    ,.reg_write_825(reg_write[824])
    ,.reg_write_826(reg_write[825])
    ,.reg_write_827(reg_write[826])
    ,.reg_write_828(reg_write[827])
    ,.reg_write_829(reg_write[828])
    ,.reg_write_830(reg_write[829])
    ,.reg_write_831(reg_write[830])
    ,.reg_write_832(reg_write[831])
    ,.reg_write_833(reg_write[832])
    ,.reg_write_834(reg_write[833])
    ,.reg_write_835(reg_write[834])
    ,.reg_write_836(reg_write[835])
    ,.reg_write_837(reg_write[836])
    ,.reg_write_838(reg_write[837])
    ,.reg_write_839(reg_write[838])
    ,.reg_write_840(reg_write[839])
    ,.reg_write_841(reg_write[840])
    ,.reg_write_842(reg_write[841])
    ,.reg_write_843(reg_write[842])
    ,.reg_write_844(reg_write[843])
    ,.reg_write_845(reg_write[844])
    ,.reg_write_846(reg_write[845])
    ,.reg_write_847(reg_write[846])
    ,.reg_write_848(reg_write[847])
    ,.reg_write_849(reg_write[848])
    ,.reg_write_850(reg_write[849])
    ,.reg_write_851(reg_write[850])
    ,.reg_write_852(reg_write[851])
    ,.reg_write_853(reg_write[852])
    ,.reg_write_854(reg_write[853])
    ,.reg_write_855(reg_write[854])
    ,.reg_write_856(reg_write[855])
    ,.reg_write_857(reg_write[856])
    ,.reg_write_858(reg_write[857])
    ,.reg_write_859(reg_write[858])
    ,.reg_write_860(reg_write[859])
    ,.reg_write_861(reg_write[860])
    ,.reg_write_862(reg_write[861])
    ,.reg_write_863(reg_write[862])
    ,.reg_write_864(reg_write[863])
    ,.reg_write_865(reg_write[864])
    ,.reg_write_866(reg_write[865])
    ,.reg_write_867(reg_write[866])
    ,.reg_write_868(reg_write[867])
    ,.reg_write_869(reg_write[868])
    ,.reg_write_870(reg_write[869])
    ,.reg_write_871(reg_write[870])
    ,.reg_write_872(reg_write[871])
    ,.reg_write_873(reg_write[872])
    ,.reg_write_874(reg_write[873])
    ,.reg_write_875(reg_write[874])
    ,.reg_write_876(reg_write[875])
    ,.reg_write_877(reg_write[876])
    ,.reg_write_878(reg_write[877])
    ,.reg_write_879(reg_write[878])
    ,.reg_write_880(reg_write[879])
    ,.reg_write_881(reg_write[880])
    ,.reg_write_882(reg_write[881])
    ,.reg_write_883(reg_write[882])
    ,.reg_write_884(reg_write[883])
    ,.reg_write_885(reg_write[884])
    ,.reg_write_886(reg_write[885])
    ,.reg_write_887(reg_write[886])
    ,.reg_write_888(reg_write[887])
    ,.reg_write_889(reg_write[888])
    ,.reg_write_890(reg_write[889])
    ,.reg_write_891(reg_write[890])
    ,.reg_write_892(reg_write[891])
    ,.reg_write_893(reg_write[892])
    ,.reg_write_894(reg_write[893])
    ,.reg_write_895(reg_write[894])
    ,.reg_write_896(reg_write[895])
    ,.reg_write_897(reg_write[896])
    ,.reg_write_898(reg_write[897])
    ,.reg_write_899(reg_write[898])
    ,.reg_write_900(reg_write[899])
    ,.reg_write_901(reg_write[900])
    ,.reg_write_902(reg_write[901])
    ,.reg_write_903(reg_write[902])
    ,.reg_write_904(reg_write[903])
    ,.reg_write_905(reg_write[904])
    ,.reg_write_906(reg_write[905])
    ,.reg_write_907(reg_write[906])
    ,.reg_write_908(reg_write[907])
    ,.reg_write_909(reg_write[908])
    ,.reg_write_910(reg_write[909])
    ,.reg_write_911(reg_write[910])
    ,.reg_write_912(reg_write[911])
    ,.reg_write_913(reg_write[912])
    ,.reg_write_914(reg_write[913])
    ,.reg_write_915(reg_write[914])
    ,.reg_write_916(reg_write[915])
    ,.reg_write_917(reg_write[916])
    ,.reg_write_918(reg_write[917])
    ,.reg_write_919(reg_write[918])
    ,.reg_write_920(reg_write[919])
    ,.reg_write_921(reg_write[920])
    ,.reg_write_922(reg_write[921])
    ,.reg_write_923(reg_write[922])
    ,.reg_write_924(reg_write[923])
    ,.reg_write_925(reg_write[924])
    ,.reg_write_926(reg_write[925])
    ,.reg_write_927(reg_write[926])
    ,.reg_write_928(reg_write[927])
    ,.reg_write_929(reg_write[928])
    ,.reg_write_930(reg_write[929])
    ,.reg_write_931(reg_write[930])
    ,.reg_write_932(reg_write[931])
    ,.reg_write_933(reg_write[932])
    ,.reg_write_934(reg_write[933])
    ,.reg_write_935(reg_write[934])
    ,.reg_write_936(reg_write[935])
    ,.reg_write_937(reg_write[936])
    ,.reg_write_938(reg_write[937])
    ,.reg_write_939(reg_write[938])
    ,.reg_write_940(reg_write[939])
    ,.reg_write_941(reg_write[940])
    ,.reg_write_942(reg_write[941])
    ,.reg_write_943(reg_write[942])
    ,.reg_write_944(reg_write[943])
    ,.reg_write_945(reg_write[944])
    ,.reg_write_946(reg_write[945])
    ,.reg_write_947(reg_write[946])
    ,.reg_write_948(reg_write[947])
    ,.reg_write_949(reg_write[948])
    ,.reg_write_950(reg_write[949])
    ,.reg_write_951(reg_write[950])
    ,.reg_write_952(reg_write[951])
    ,.reg_write_953(reg_write[952])
    ,.reg_write_954(reg_write[953])
    ,.reg_write_955(reg_write[954])
    ,.reg_write_956(reg_write[955])
    ,.reg_write_957(reg_write[956])
    ,.reg_write_958(reg_write[957])
    ,.reg_write_959(reg_write[958])
    ,.reg_write_960(reg_write[959])
    ,.reg_write_961(reg_write[960])
    ,.reg_write_962(reg_write[961])
    ,.reg_write_963(reg_write[962])
    ,.reg_write_964(reg_write[963])
    ,.reg_write_965(reg_write[964])
    ,.reg_write_966(reg_write[965])
    ,.reg_write_967(reg_write[966])
    ,.reg_write_968(reg_write[967])
    ,.reg_write_969(reg_write[968])
    ,.reg_write_970(reg_write[969])
    ,.reg_write_971(reg_write[970])
    ,.reg_write_972(reg_write[971])
    ,.reg_write_973(reg_write[972])
    ,.reg_write_974(reg_write[973])
    ,.reg_write_975(reg_write[974])
    ,.reg_write_976(reg_write[975])
    ,.reg_write_977(reg_write[976])
    ,.reg_write_978(reg_write[977])
    ,.reg_write_979(reg_write[978])
    ,.reg_write_980(reg_write[979])
    ,.reg_write_981(reg_write[980])
    ,.reg_write_982(reg_write[981])
    ,.reg_write_983(reg_write[982])
    ,.reg_write_984(reg_write[983])
    ,.reg_write_985(reg_write[984])
    ,.reg_write_986(reg_write[985])
    ,.reg_write_987(reg_write[986])
    ,.reg_write_988(reg_write[987])
    ,.reg_write_989(reg_write[988])
    ,.reg_write_990(reg_write[989])
    ,.reg_write_991(reg_write[990])
    ,.reg_write_992(reg_write[991])
    ,.reg_write_993(reg_write[992])
    ,.reg_write_994(reg_write[993])
    ,.reg_write_995(reg_write[994])
    ,.reg_write_996(reg_write[995])
    ,.reg_write_997(reg_write[996])
    ,.reg_write_998(reg_write[997])
    ,.reg_write_999(reg_write[998])
    ,.reg_write_1000(reg_write[999])
	);

endmodule
