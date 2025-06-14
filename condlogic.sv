module condlogic (
    input  logic       clk, reset,
    input  logic [3:0] Cond,
    input  logic [3:0] ALUFlags,
    input  logic [1:0] FlagW,
    input  logic       PCS_from_decoder, RegW_from_decoder, MemW_from_decoder,
    output logic       PCSrc, RegWrite, MemWrite,
    output logic       Stall
);
    logic [1:0] FlagWrite;
    logic [3:0] Flags;
    logic       CondEx;
    
    // Reset initialization
    always_ff @(posedge clk) begin
        if (reset) begin
            Stall <= 0;
            Flags <= 4'b0000;
        end else begin
            if (FlagW[1]) Flags[3:2] <= ALUFlags[3:2]; // N, Z
            if (FlagW[0]) Flags[1:0] <= ALUFlags[1:0]; // C, V
            Stall <= 0; // Simplified, adjust if needed
        end
    end
    
    // Condition check
    always_comb begin
        case (Cond)
            4'b0000: CondEx = Flags[2]; // EQ
            4'b0001: CondEx = ~Flags[2]; // NE
            4'b1110: CondEx = 1'b1; // AL
            default: CondEx = 1'b0;
        endcase
        PCSrc = PCS_from_decoder & CondEx;
        RegWrite = RegW_from_decoder & CondEx;
        MemWrite = MemW_from_decoder & CondEx;
    end
endmodule