module condlogic (
    input  logic       clk, reset,
    input  logic [3:0] Cond,
    input  logic [3:0] ALUFlags,
    input  logic [1:0] FlagW,
    input  logic       PCS, RegW, MemW,
    output logic       PCSrc, RegWrite, MemWrite
);
    logic [1:0] FlagZ, FlagN;
    logic       condex;

    // Flag registers (NZCV: Negative, Zero, Carry, Overflow)
    flopenr #(2) flagregZ (.clk(clk), .reset(reset), .en(FlagW[1]), .d(ALUFlags[1:0]), .q(FlagZ));
    flopenr #(2) flagregN (.clk(clk), .reset(reset), .en(FlagW[0]), .d(ALUFlags[3:2]), .q(FlagN));

    // Condition check
    always_comb begin
        case (Cond)
            4'b0000: condex = FlagZ[1];        // EQ (Z=1)
            4'b0001: condex = ~FlagZ[1];       // NE (Z=0)
            4'b1010: condex = FlagN[0];        // GE (N=V)
            4'b1100: condex = FlagN[0] ^ FlagZ[0]; // GT (N=V and Z=0)
            4'b1110: condex = 1'b1;           // AL (Always)
            default: condex = 1'b0;
        endcase
    end

    // Conditional execution
    assign PCSrc = PCS & condex;
    assign RegWrite = RegW & condex;
    assign MemWrite = MemW & condex;

endmodule
