module datapath (
    input  logic        clk, reset,
    input  logic        Stall,
    input  logic [1:0]  RegSrc, ImmSrc,
    input  logic        RegWrite, ALUSrc,
    input  logic [2:0]  ALUControl,
    input  logic        MemtoReg, PCSrc,
    input  logic        PCS_ALU_SrcA, // NUEVA SEÑAL: para controlar el mux de SrcA
    output logic [3:0]  ALUFlags,
    output logic [31:0] PC, ALUResult, WriteData,
    input  logic [31:0] Instr, // Instruction input to datapath
    input  logic [31:0] ReadData
);
    logic [31:0] PCNext, PCPlus4, PCPlus8;
    logic [31:0] ExtImm, SrcA_regfile, SrcB, Result; // Renombrado SrcA a SrcA_regfile para el output del regfile
    logic [3:0]  RA1, RA2;
    logic [31:0] SrcA; // Definición de SrcA para la conexión al ALU

    // PC Logic with Stall and CORRECTED PCSrc
    flopenr #(32) pcreg (.clk(clk), .reset(reset), .en(~Stall), .d(PCNext), .q(PC));
    adder #(32) pcadd1 (.a(PC), .b(32'd4), .y(PCPlus4));
    adder #(32) pcadd2 (.a(PCPlus4), .b(32'd4), .y(PCPlus8)); // PC+8 para direccionamiento de ramas
    mux2 #(32) pcmux (.d0(PCPlus4), .d1(ALUResult), .s(PCSrc), .y(PCNext)); // Usa PCSrc input

    // Register File Logic with Stall
    mux2 #(4) ra1mux (.d0(Instr[19:16]), .d1(4'd15), .s(RegSrc[0]), .y(RA1));
    mux2 #(4) ra2mux (.d0(Instr[3:0]), .d1(Instr[15:12]), .s(RegSrc[1]), .y(RA2));
    regfile rf (
        .clk(clk),
        .reset(reset),
        .we3(RegWrite & ~Stall),
        .ra1(RA1),
        .ra2(RA2),
        .wa3(Instr[15:12]),
        .wd3(Result),
        .rd1(SrcA_regfile), // Salida del regfile para SrcA
        .rd2(WriteData)
    );

    // Immediate Extension
    extend ext (
        .Instr(Instr[23:0]), // Pass only relevant bits to extend
        .ImmSrc(ImmSrc),
        .ExtImm(ExtImm)
    );

    // FIX: Mux para SrcA
    // Selecciona entre el valor del registro (SrcA_regfile) y PC+8 para ramas
    mux2 #(32) srcamux (.d0(SrcA_regfile), .d1(PCPlus8), .s(PCS_ALU_SrcA), .y(SrcA));

    // ALU Logic
    mux2 #(32) srcbmux (.d0(WriteData), .d1(ExtImm), .s(ALUSrc), .y(SrcB));
    alu alu (
        .a(SrcA), // Conectado a la salida del mux SrcA
        .b(SrcB),
        .ALUControl(ALUControl),
        .Result(ALUResult),
        .ALUFlags(ALUFlags)
    );

    // Result Selection
    mux2 #(32) resmux (.d0(ALUResult), .d1(ReadData), .s(MemtoReg), .y(Result));

    // New Debugging display for Instr and Instr[23] within datapath
    always_comb begin
        $display("Time %0t: datapath - Instr (full)=%h, Instr[23]=%b (before extend)", $time, Instr, Instr[23]);
    end
endmodule
