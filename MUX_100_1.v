module mux_100_to_1 #( parameter DATA_WIDTH = 16) (
    in, 
		sel,
    out       
);
    input wire [DATA_WIDTH-1:0] in [0:99]; 
    input wire [6:0] sel;                  
    output reg [DATA_WIDTH-1:0] out;

    always @(*) begin
        case (sel)
            7'd0: out = in[0];
            7'd1: out = in[1];
            7'd2: out = in[2];
            7'd3: out = in[3];
            7'd4: out = in[4];
            7'd5: out = in[5];
            7'd6: out = in[6];
            7'd7: out = in[7];
            7'd8: out = in[8];
            7'd9: out = in[9];
            7'd10: out = in[10];
            7'd11: out = in[11];
            7'd12: out = in[12];
            7'd13: out = in[13];
            7'd14: out = in[14];
            7'd15: out = in[15];
            7'd16: out = in[16];
            7'd17: out = in[17];
            7'd18: out = in[18];
            7'd19: out = in[19];
            7'd20: out = in[20];
            7'd21: out = in[21];
            7'd22: out = in[22];
            7'd23: out = in[23];
            7'd24: out = in[24];
            7'd25: out = in[25];
            7'd26: out = in[26];
            7'd27: out = in[27];
            7'd28: out = in[28];
            7'd29: out = in[29];
            7'd30: out = in[30];
            7'd31: out = in[31];
            7'd32: out = in[32];
            7'd33: out = in[33];
            7'd34: out = in[34];
            7'd35: out = in[35];
            7'd36: out = in[36];
            7'd37: out = in[37];
            7'd38: out = in[38];
            7'd39: out = in[39];
            7'd40: out = in[40];
            7'd41: out = in[41];
            7'd42: out = in[42];
            7'd43: out = in[43];
            7'd44: out = in[44];
            7'd45: out = in[45];
            7'd46: out = in[46];
            7'd47: out = in[47];
            7'd48: out = in[48];
            7'd49: out = in[49];
            7'd50: out = in[50];
            7'd51: out = in[51];
            7'd52: out = in[52];
            7'd53: out = in[53];
            7'd54: out = in[54];
            7'd55: out = in[55];
            7'd56: out = in[56];
            7'd57: out = in[57];
            7'd58: out = in[58];
            7'd59: out = in[59];
            7'd60: out = in[60];
            7'd61: out = in[61];
            7'd62: out = in[62];
            7'd63: out = in[63];
            7'd64: out = in[64];
            7'd65: out = in[65];
            7'd66: out = in[66];
            7'd67: out = in[67];
            7'd68: out = in[68];
            7'd69: out = in[69];
            7'd70: out = in[70];
            7'd71: out = in[71];
            7'd72: out = in[72];
            7'd73: out = in[73];
            7'd74: out = in[74];
            7'd75: out = in[75];
            7'd76: out = in[76];
            7'd77: out = in[77];
            7'd78: out = in[78];
            7'd79: out = in[79];
            7'd80: out = in[80];
            7'd81: out = in[81];
            7'd82: out = in[82];
            7'd83: out = in[83];
            7'd84: out = in[84];
            7'd85: out = in[85];
            7'd86: out = in[86];
            7'd87: out = in[87];
            7'd88: out = in[88];
            7'd89: out = in[89];
            7'd90: out = in[90];
            7'd91: out = in[91];
            7'd92: out = in[92];
            7'd93: out = in[93];
            7'd94: out = in[94];
            7'd95: out = in[95];
            7'd96: out = in[96];
            7'd97: out = in[97];
            7'd98: out = in[98];
            7'd99: out = in[99];
            default: out = {DATA_WIDTH{1'b0}};  // Default case
        endcase
    end

endmodule

