module Decoder_type (
    input  logic [31:0] Instr,
    output logic [3:0]  op,
    output logic [20:0] debug_bx_check,
    output logic [3:0]  debug_alu_op,
    output logic        debug_s_bit,
    output logic        debug_bx_match
);
    logic [1:0] opcode;
    logic [3:0] alu_op;
    logic [5:0] funct;
    
    assign opcode = Instr[27:26];
    assign funct = Instr[25:20];
    assign alu_op = Instr[24:21];
    assign debug_bx_check = Instr[24:4];
    assign debug_alu_op = alu_op;
    assign debug_s_bit = Instr[20];
    assign debug_bx_match = (Instr[24:4] == 21'b00010010111111111111 && Instr[3:0] == 4'b1110);
    
    always_comb begin
        op = 4'b1111;
        case (opcode)
            2'b00: begin
                if (debug_bx_match) begin
                    op = 4'b1010; // BX
                end else begin
                    case (alu_op)
                        4'b1101: op = 4'b0000; // MOV
                        4'b0100: op = 4'b0001; // ADD
                        4'b0010: op = 4'b0010; // SUB
                        4'b0000: op = 4'b0011; // AND
                        4'b1100: op = 4'b0100; // ORR
                        4'b0101: if (Instr[20] == 1) op = 4'b0101; // CMP
                        4'b1111: op = 4'b0110; // MVN
                    endcase
                end
            end
            2'b01: op = funct[0] ? 4'b0111 : 4'b1000; // LDR/STR
            2'b10: op = 4'b1001; // Branch
        endcase
    end
endmodule