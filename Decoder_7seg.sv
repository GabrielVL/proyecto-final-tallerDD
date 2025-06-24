module Decoder_7seg (
    input  logic [3:0] op,       // Cambiar a 4 bits
    output logic [6:0] op7seg    // 7-segment display output
);
    always_comb
        case (op)
            4'b0000: op7seg = 7'b1101101; // "d" para MOV
            4'b0001: op7seg = 7'b1110111; // "A" para ADD
            4'b0010: op7seg = 7'b1011011; // "S" para SUB
            4'b0011: op7seg = 7'b1111110; // "n" para AND
            4'b0100: op7seg = 7'b0011101; // "o" para ORR
            4'b0101: op7seg = 7'b1001110; // "C" para CMP
            4'b0110: op7seg = 7'b1101011; // "n" para MVN
            4'b0111: op7seg = 7'b0011100; // "L" para LDR
            4'b1000: op7seg = 7'b1011011; // "S" para STR
            4'b1001: op7seg = 7'b0111101; // "b" para Branch
            4'b1010: op7seg = 7'b0110111; // "B" para BX
            default: op7seg = 7'b0000001; // "-" para indefinido
        endcase
endmodule