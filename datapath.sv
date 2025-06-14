module datapath (
    input  logic        clk, reset,
    input  logic        Stall,
    input  logic [1:0]  RegSrc,
    input  logic [1:0]  ImmSrc,
    input  logic        RegWrite,
    input  logic        ALUSrc,
    input  logic [2:0]  ALUControl,
    input  logic        MemtoReg,
    input  logic        PCSrc,
    input  logic        PCS_ALU_SrcA,
    output logic [3:0]  ALUFlags,
    output logic [31:0] PC,
    output logic [31:0] ALUResult,
    output logic [31:0] WriteData,
    input  logic [31:0] Instr,
    input  logic [31:0] ReadData
);
    // Signal declarations
    logic [31:0] PCNext, PCPlus4, PCPlus8;
    logic [31:0] ExtImm, SrcA, SrcB, Result;
    logic [31:0] RD1, RD2;
    logic [3:0]  RA1, RA2, Rd;
    
    // Debug outputs
    always_comb begin
        $display("Time %0t: datapath - RD1 = %h, RD2 = %h, WriteData = %h, ALUResult = %h", $time, RD1, RD2, WriteData, ALUResult);
    end

    // PC Logic
    flopenr #(32) PCReg (
        .clk(clk),
        .reset(reset),
        .en(~Stall),
        .d(PCNext),
        .q(PC)
    );

    adder #(32) PCAdd4 (
        .a(PC),
        .b(32'h4),
        .y(PCPlus4)
    );

    adder #(32) PCAdd8 (
        .a(PCPlus4),
        .b(32'h4),
        .y(PCPlus8)
    );

    mux2 #(32) PCMux (
        .d0(PCPlus4),
        .d1(ALUResult),
        .s(PCSrc),
        .y(PCNext)
    );

    // Register File Address Selection
    assign RA1 = RegSrc[0] ? 4'hF : Instr[19:16]; // Rn or PC
    assign RA2 = RegSrc[1] ? Instr[15:12] : Instr[3:0]; // Rd or Rm
    assign Rd = Instr[15:12]; // Write address

    // Register File
    regfile rf (
        .clk(clk),
        .reset(reset),
        .we3(RegWrite),
        .ra1(RA1),      // 4 bits
        .ra2(RA2),      // 4 bits
        .wa3(Rd),       // 4 bits
        .wd3(Result),   // 32 bits
        .r15(PCPlus8),  // 32 bits
        .rd1(RD1),      // 32 bits
        .rd2(RD2)       // 32 bits
    );

    // Immediate Extension
    extend ext (
        .Instr(Instr[23:0]),
        .ImmSrc(ImmSrc),
        .ExtImm(ExtImm)
    );

    // ALU Source Selection
    mux2 #(32) SrcAMux (
        .d0(RD1),
        .d1(PC),
        .s(PCS_ALU_SrcA),
        .y(SrcA)
    );

    mux2 #(32) SrcBMux (
        .d0(RD2),
        .d1(ExtImm),
        .s(ALUSrc),
        .y(SrcB)
    );

    // ALU
    alu alu_inst (
        .a(SrcA),
        .b(SrcB),
        .ALUControl(ALUControl),
        .Result(ALUResult),
        .ALUFlags(ALUFlags)
    );

    // Write Data
    assign WriteData = RD2;

    // Result Selection
    mux2 #(32) ResMux (
        .d0(ALUResult),
        .d1(ReadData),
        .s(MemtoReg),
        .y(Result)
    );
endmodule