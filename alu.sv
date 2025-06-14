module alu (
    input  logic [31:0] a, b,
    input  logic [2:0]  ALUControl,
    output logic [31:0] Result,
    output logic [3:0]  ALUFlags // N, Z, C, V (Negative, Zero, Carry, Overflow)
);

    logic [31:0] alu_result_unsigned;
    logic        N, Z, C, V;

    // ALU operations
    always_comb begin
        alu_result_unsigned = 32'hX; // Default to unknown
        N = 1'bX; Z = 1'bX; C = 1'bX; V = 1'bX;

        case (ALUControl)
            3'b000: begin // AND
                alu_result_unsigned = a & b;
                // Flags based on result
                N = alu_result_unsigned[31];
                Z = (alu_result_unsigned == 32'h0);
                C = 1'bX; // AND doesn't typically affect carry (unless it's an ANDS, which would be handled by FlagW)
                V = 1'bX; // AND doesn't typically affect overflow
            end
            3'b001: begin // EOR (XOR)
                alu_result_unsigned = a ^ b;
                N = alu_result_unsigned[31];
                Z = (alu_result_unsigned == 32'h0);
                C = 1'bX;
                V = 1'bX;
            end
            3'b010: begin // SUB (Subtract)
                // a - b = a + (~b + 1)
                alu_result_unsigned = a - b;
                // Calculate flags for subtraction (signed and unsigned)
                N = alu_result_unsigned[31];
                Z = (alu_result_unsigned == 32'h0);
                C = (~(a[31] & ~b[31]) | (~b[31] & alu_result_unsigned[31]) | (alu_result_unsigned[31] & a[31])); // Unsigned Borrow (C for borrow/no borrow)
                // C is inverted for ARM sub: 1 if no borrow, 0 if borrow.
                C = ~(alu_result_unsigned > a); // Carry is set if no borrow occurred. (a >= b)
                // Overflow for a-b: (a_sign XOR b_sign_inverted) AND (a_sign XOR result_sign)
                V = (a[31] ^ ~b[31]) & (a[31] ^ alu_result_unsigned[31]);
            end
            3'b011: begin // ADD
                alu_result_unsigned = a + b;
                // Flags for addition
                N = alu_result_unsigned[31];
                Z = (alu_result_unsigned == 32'h0);
                C = (alu_result_unsigned < a); // Carry is set if unsigned overflow (result < a)
                // Overflow for a+b: (a_sign XOR b_sign) AND (a_sign XOR result_sign)
                V = (~(a[31] ^ b[31])) & (a[31] ^ alu_result_unsigned[31]);
            end
            3'b100: begin // ADC (Add with Carry) - not implemented fully, will act as ADD for now
                alu_result_unsigned = a + b; // + C_in if you have it
                N = alu_result_unsigned[31];
                Z = (alu_result_unsigned == 32'h0);
                C = (alu_result_unsigned < a);
                V = (~(a[31] ^ b[31])) & (a[31] ^ alu_result_unsigned[31]);
            end
            3'b101: begin // SBC (Subtract with Carry) - not implemented fully, will act as SUB for now
                alu_result_unsigned = a - b; // - C_in_inverted if you have it
                N = alu_result_unsigned[31];
                Z = (alu_result_unsigned == 32'h0);
                C = ~(alu_result_unsigned > a);
                V = (a[31] ^ ~b[31]) & (a[31] ^ alu_result_unsigned[31]);
            end
            3'b110: begin // RSC (Reverse Subtract with Carry) - not implemented, acts as SUB for now
                alu_result_unsigned = b - a; // b - a
                N = alu_result_unsigned[31];
                Z = (alu_result_unsigned == 32'h0);
                C = ~(alu_result_unsigned > b);
                V = (b[31] ^ ~a[31]) & (b[31] ^ alu_result_unsigned[31]);
            end
            3'b111: begin // Test / Compare operations (CMP, TST, TEQ, CMN) - Result is discarded, only flags are set
                // For CMP (a-b)
                alu_result_unsigned = a - b;
                N = alu_result_unsigned[31];
                Z = (alu_result_unsigned == 32'h0);
                C = ~(alu_result_unsigned > a);
                V = (a[31] ^ ~b[31]) & (a[31] ^ alu_result_unsigned[31]);
                // Result is usually ignored for these
            end
            default: begin // Undefined ALUControl
                alu_result_unsigned = 32'hX;
                N = 1'bX; Z = 1'bX; C = 1'bX; V = 1'bX;
            end
        endcase

        Result = alu_result_unsigned;
        ALUFlags = {N, Z, C, V}; // Order: N, Z, C, V
    end

    // Debugging displays for alu.sv
    always_comb begin
        $display("Time %0t: alu - a=%h, b=%h, ALUControl=%b", $time, a, b, ALUControl);
        $display("Time %0t: alu - Result=%h, neg=%b, zero=%b, carry=%b, overflow=%b", $time, Result, ALUFlags[3], ALUFlags[2], ALUFlags[1], ALUFlags[0]);
    end

endmodule
