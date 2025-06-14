module arm (
    input  logic        clk, reset,
    input  logic [31:0] Instr,
    input  logic [31:0] ReadData,
    output logic [31:0] PC,
    output logic [31:0] ALUResult,
    output logic [31:0] WriteData,
    output logic        MemWrite
);
    logic [3:0] ALUFlags;
    logic [1:0] RegSrc, ImmSrc, FlagW;
    logic       RegWrite, ALUSrc, MemtoReg, PCSrc, PCS_ALU_SrcA, Stall;
    logic [2:0] ALUControl;
    // Separate decoder outputs
    logic       MemWrite_dec, RegWrite_dec, PCS_dec;

    datapath dp (
        .clk(clk),
        .reset(reset),
        .Stall(Stall),
        .RegSrc(RegSrc),
        .ImmSrc(ImmSrc),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .ALUControl(ALUControl),
        .MemtoReg(MemtoReg),
        .PCSrc(PCSrc),
        .PCS_ALU_SrcA(PCS_ALU_SrcA),
        .ALUFlags(ALUFlags),
        .PC(PC),
        .ALUResult(ALUResult),
        .WriteData(WriteData),
        .Instr(Instr),
        .ReadData(ReadData)
    );

    decoder dec (
        .FullInstr(Instr),
        .RegSrc(RegSrc),
        .ImmSrc(ImmSrc),
        .MemtoReg(MemtoReg),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite_dec), // Decoder output
        .MemWrite(MemWrite_dec), // Decoder output
        .ALUControl(ALUControl),
        .PCS(PCS_dec),           // Decoder output
        .PCS_ALU_SrcA(PCS_ALU_SrcA),
        .FlagW(FlagW)
    );

    condlogic cl (
        .clk(clk),
        .reset(reset),
        .Cond(Instr[31:28]),
        .ALUFlags(ALUFlags),
        .FlagW(FlagW),
        .PCS_from_decoder(PCS_dec),
        .RegW_from_decoder(RegWrite_dec),
        .MemW_from_decoder(MemWrite_dec),
        .PCSrc(PCSrc),           // Final output
        .RegWrite(RegWrite),     // Final output
        .MemWrite(MemWrite),     // Final output
        .Stall(Stall)
    );
endmodule