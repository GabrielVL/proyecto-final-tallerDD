module extend (
    input  logic [23:0] Instr, // Bits 23:0 for immediate
    input  logic [1:0]  ImmSrc,
    output logic [31:0] ExtImm
);

    always_comb begin
        case (ImmSrc)
            2'b00: begin // Data Processing Immediate (8-bit rotated immediate)
                // Assuming Instr[7:0] is the 8-bit immediate and Instr[11:8] is the rotate amount.
                // This is a common ARM immediate format, but verify against your ARM spec.
                // For simplicity here, assuming direct use if not rotated.
                // If rotated: {8'b0, Instr[7:0]} rotated right by (Instr[11:8] * 2)
                ExtImm = {{24{1'b0}}, Instr[7:0]}; // Basic 8-bit, no rotation for now.
                                                  // IMPORTANT: If you use rotated immediates, this needs more logic.
            end
            2'b01: begin // Load/Store Immediate (12-bit unsigned immediate)
                ExtImm = {{20{1'b0}}, Instr[11:0]}; // Zero-extend 12-bit immediate
            end
            2'b10: begin // Branch Immediate (24-bit signed immediate, left-shifted by 2)
                // Use direct Verilog sign extension syntax for robustness
                ExtImm = {{8{Instr[23]}}, Instr[23:0]} << 2; // Sign-extend bit 23, then shift left by 2.
            end
            default: ExtImm = 32'hX; // Undefined ImmSrc
        endcase
    end

    // Debugging display for the extend module
    always_comb begin
        $display("Time %0t: extend - Instr[23:0]=%h, ImmSrc=%b", $time, Instr[23:0], ImmSrc);
        $display("Time %0t: extend - Instr[23]=%b (MSB of 24-bit immediate)", $time, Instr[23]);
        $display("Time %0t: extend - ExtImm=%h (Result of extension)", $time, ExtImm);
    end

endmodule
