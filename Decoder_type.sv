module Decoder_type (
    input logic [31:0] Instr, // Instruction input
    input logic [31:0] PC,    // Program Counter for HEX0, HEX1
    output logic [3:0] instr_type, // Instruction type
    output logic [6:0] hex0,   // HEX0 (PC[3:0])
    output logic [6:0] hex1,   // HEX1 (PC[7:4])
    output logic [6:0] hex4,   // HEX4 
    output logic [6:0] hex5    // HEX5
);

    // Instruction type classification
    always_comb begin
        casez (Instr[31:20])
            12'b111000111010: instr_type = 4'd1;  // MOV 
            12'b111001011000: instr_type = 4'd2;  // STR 
            12'b111001011001: instr_type = 4'd3;  // LDR 
            12'b???000001000: instr_type = 4'd4;  // ADD 
            12'b???000000100: instr_type = 4'd5;  // SUB 
            12'b111000000000: instr_type = 4'd6;  // AND 
            12'b???0101?????: instr_type = 4'd7;  // B/BL 
            12'b???00001?101: instr_type = 4'd8;  // CMP 
            12'b111000000000: instr_type = (Instr[7:4] == 4'b1001) ? 4'd9 : 4'd6; 
            12'b111000011000: instr_type = 4'd10; // ORR 
            12'b???00001?001: instr_type = 4'd11; // EOR 
            12'b???000111110: instr_type = 4'd12; // MVN 
            12'b111001?01100: instr_type = 4'd13; // STRB 
            12'b111001?01101: instr_type = 4'd14; // LDRB 
            12'b111000010010: instr_type = 4'd15; // BX
            default:          instr_type = 4'd0;  // Other
        endcase
    end

    // 7-segmento PC
    seg7 u_hex0 (.data(PC[3:0]), .seg(hex0)); // PC[3:0]
    seg7 u_hex1 (.data(PC[7:4]), .seg(hex1)); // PC[7:4]

    // HEX4 HEX5
    always_comb begin
        case (instr_type)
            4'd1: begin // MOV: 'MO'
                hex4 = 7'b1000000; // 'O'
                hex5 = 7'b0001001; // 'M'
            end
            4'd2: begin // STR: 'ST'
                hex4 = 7'b1001110; // 'T'
                hex5 = 7'b0010010; // 'S'
            end
            4'd3: begin // LDR: 'LD'
                hex4 = 7'b0100001; // 'D'
                hex5 = 7'b1000111; // 'L'
            end
            4'd4: begin // ADD: 'AD'
                hex4 = 7'b0100001; // 'D'
                hex5 = 7'b0001000; // 'A'
            end
            4'd5: begin // SUB: 'SU'
                hex4 = 7'b1000001; // 'U'
                hex5 = 7'b0010010; // 'S'
            end
            4'd6: begin // AND: 'AN'
                hex4 = 7'b0101011; // 'n'
                hex5 = 7'b0001000; // 'A'
            end
            4'd7: begin // B/BL: 'BR'
                hex4 = 7'b0101111; // 'r'
                hex5 = 7'b0000011; // 'b'
            end
            4'd8: begin // CMP: 'CP'
                hex4 = 7'b0001100; // 'P'
                hex5 = 7'b1000110; // 'C'
            end
            4'd9: begin // MUL: 'ML'
                hex4 = 7'b1000111; // 'L'
                hex5 = 7'b0001001; // 'M'
            end
            4'd10: begin // ORR: 'OR'
                hex4 = 7'b0101111; // 'r'
                hex5 = 7'b1000000; // 'O'
            end
            4'd11: begin // EOR: 'EO'
                hex4 = 7'b1000000; // 'O'
                hex5 = 7'b0000110; // 'E'
            end
            4'd12: begin // MVN: 'MN'
                hex4 = 7'b0101011; // 'n'
                hex5 = 7'b0001001; // 'M'
            end
            4'd13: begin // STRB: 'SB'
                hex4 = 7'b0000011; // 'b'
                hex5 = 7'b0010010; // 'S'
            end
            4'd14: begin // LDRB: 'LB'
                hex4 = 7'b0000011; // 'b'
                hex5 = 7'b1000111; // 'L'
            end
            4'd15: begin // BX: 'BX'
                hex4 = 7'b0000010; // 'X'
                hex5 = 7'b0000011; // 'b'
            end
            default: begin // Other: Off
                hex4 = 7'b1111111;
                hex5 = 7'b1111111;
            end
        endcase
    end

endmodule