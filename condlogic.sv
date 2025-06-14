module condlogic (
    input  logic        clk, reset,
    input  logic [3:0]  Cond,
    input  logic [3:0]  ALUFlags,
    input  logic [1:0]  FlagW,
    input  logic        PCS_from_decoder, // Renamed input from decoder
    input  logic        RegW_from_decoder, // New input from decoder's RegWrite
    input  logic        MemW_from_decoder, // New input from decoder's MemWrite
    output logic        PCSrc,
    output logic        RegWrite,      // Final RegWrite output
    output logic        MemWrite,      // Final MemWrite output
    output logic        Stall
);

    logic [3:0] Flags; // Internal register to hold flags
    logic       condex;
    logic       cond_check_result; // Result of the condition code check
    integer     cycle_count; // For debugging purposes

    // Flag Register
    flopenr #(4) flag_reg (.clk(clk), .reset(reset), .en(FlagW[0]), .d(ALUFlags), .q(Flags));

    // Conditional Execution Logic
    always_comb begin
        cond_check_result = 1'b0; // Default to false
        case (Cond)
            4'b0000: cond_check_result = Flags[1];           // EQ (Z=1)
            4'b0001: cond_check_result = ~Flags[1];          // NE (Z=0)
            4'b0010: cond_check_result = Flags[2];           // CS/HS (C=1)
            4'b0011: cond_check_result = ~Flags[2];          // CC/LO (C=0)
            4'b0100: cond_check_result = Flags[0];           // MI (N=1)
            4'b0101: cond_check_result = ~Flags[0];          // PL (N=0)
            4'b0110: cond_check_result = Flags[3];           // VS (V=1)
            4'b0111: cond_check_result = ~Flags[3];          // VC (V=0)
            4'b1000: cond_check_result = Flags[2] & ~Flags[1]; // HI (C=1 & Z=0)
            4'b1001: cond_check_result = ~Flags[2] | Flags[1]; // LS (C=0 or Z=1)
            4'b1010: cond_check_result = Flags[0] == Flags[3]; // GE (N=V)
            4'b1011: cond_check_result = Flags[0] != Flags[3]; // LT (N!=V)
            4'b1100: cond_check_result = ~Flags[1] & (Flags[0] == Flags[3]); // GT (Z=0 & N=V)
            4'b1101: cond_check_result = Flags[1] | (Flags[0] != Flags[3]); // LE (Z=1 or N!=V)
            4'b1110: cond_check_result = 1'b1;                // AL (Always)
            4'b1111: cond_check_result = 1'b0;                // Special (e.g., for SWI or undefined)
            default: cond_check_result = 1'bX;
        endcase

        condex = cond_check_result; // Condition for execution based on flags

        // Control signal outputs
        PCSrc    = PCS_from_decoder & condex;
        RegWrite = RegW_from_decoder & condex;
        MemWrite = MemW_from_decoder & condex;
        Stall    = 1'b0; // Default to no stall, modify if pipeline introduces hazards
    end

    // Cycle Counter for Debugging - Now completely within the always_ff block
    always_ff @(posedge clk) begin
        if (reset) begin
            cycle_count <= 0; // Reset on asynchronous reset
        end else if (~Stall) begin // Only increment if not stalled
            cycle_count <= cycle_count + 1;
        end
        // Display inside always_ff to see state after clock edge
        $display("Time %0t: condlogic - cycle_count = %10d", $time, cycle_count);
        $display("Time %0t: condlogic - Cond = %b, ALUFlags = %b, FlagW = %b", $time, Cond, ALUFlags, FlagW);
        $display("Time %0t: condlogic - PCS = %b, RegW = %b, MemW = %b", $time, PCSrc, RegWrite, MemWrite);
        $display("Time %0t: condlogic - condex = %b, Stall = %b", $time, condex, Stall);
        $display("Time %0t: condlogic - PCSrc = %b, RegWrite = %b, MemWrite = %b", $time, PCSrc, RegWrite, MemWrite);
    end

endmodule
