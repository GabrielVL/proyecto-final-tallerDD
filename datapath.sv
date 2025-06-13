module datapath (
    input  logic        clk, reset,
    input  logic [1:0]  RegSrc, ImmSrc,
    input  logic        RegWrite, ALUSrc,
    input  logic [1:0]  ALUControl,
    input  logic        MemtoReg, PCSrc,
    output logic [3:0]  ALUFlags,
    output logic [31:0] PC, ALUResult, WriteData,
    input  logic [31:0] Instr, // Changed to input
    input  logic [31:0] ReadData
);
    logic [31:0] PCNext, PCPlus4, PCPlus8;
    logic [31:0] ExtImm, SrcA, SrcB, Result;
    logic [3:0]  RA1, RA2;

    // PC Logic
    flopenr #(32) pcreg (.clk(clk), .reset(reset), .en(1'b1), .d(PCNext), .q(PC));
    adder #(32) pcadd1 (.a(PC), .b(32'd4), .y(PCPlus4));
    adder #(32) pcadd2 (.a(PCPlus4), .b(32'd4), .y(PCPlus8));
    mux2 #(32) pcmux (.d0(PCPlus4), .d1(ALUResult), .s(PCSrc), .y(PCNext));

    // Register File Logic
    mux2 #(4) ra1mux (.d0(Instr[19:16]), .d1(4'd15), .s(RegSrc[0]), .y(RA1));
    mux2 #(4) ra2mux (.d0(Instr[3:0]), .d1(Instr[15:12]), .s(RegSrc[1]), .y(RA2));
    regfile rf (
        .clk(clk),
        .we3(RegWrite),
        .ra1(RA1),
        .ra2(RA2),
        .wa3(Instr[15:12]),
        .wd3(Result),
        .rd1(SrcA),
        .rd2(WriteData)
    );

    // Immediate Extension
    extend ext (.Instr(Instr[23:0]), .ImmSrc(ImmSrc), .ExtImm(ExtImm));

    // ALU Logic
    mux2 #(32) srcbmux (.d0(WriteData), .d1(ExtImm), .s(ALUSrc), .y(SrcB));
    alu alu (
        .a(SrcA),
        .b(SrcB),
        .ALUControl(ALUControl),
        .Result(ALUResult),
        .ALUFlags(ALUFlags)
    );

    // Result Selection
    mux2 #(32) resmux (.d0(ALUResult), .d1(ReadData), .s(MemtoReg), .y(Result));

endmodule
