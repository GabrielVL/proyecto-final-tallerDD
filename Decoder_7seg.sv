module Decoder_7seg (
    input  logic [3:0] op,
    output logic [6:0] op7seg
);
    always_comb
        case (op)
            4'b0000: op7seg = 7'b1010110; // "M" for MOV
            4'b0001: op7seg = 7'b1110111; // "A" for ADD
            4'b0010: op7seg = 7'b0111110; // "U" for SUB
            4'b0011: op7seg = 7'b1010111; // "N" for AND
            4'b0100: op7seg = 7'b1111110; // "O" for ORR
            4'b0101: op7seg = 7'b1111001; // "C" for CMP
            4'b0110: op7seg = 7'b0111110; // "V" for MVN
            4'b0111: op7seg = 7'b0011100; // "L" for LDR
            4'b1000: op7seg = 7'b1011011; // "S" for STR
            4'b1001: op7seg = 7'b0111101; // "B" for Branch
            4'b1010: op7seg = 7'b0110110; // "X" for BX
            default: op7seg = 7'b0000001; // "-" for undefined
        endcase
endmodule