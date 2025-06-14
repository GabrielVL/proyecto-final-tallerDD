module controller (
    input  logic        clk, reset,
    output logic        Stall,
    input  logic [31:0] Instr,
    input  logic [3:0]  ALUFlags,
    output logic [1:0]  RegSrc,
    output logic        RegWrite,
    output logic [1:0]  ImmSrc,
    output logic        ALUSrc,
    output logic [2:0]  ALUControl,
    output logic        MemWrite, MemtoReg, PCSrc,
    output logic        PCS_ALU_SrcA // NUEVA SEÑAL: para pasar desde decoder a datapath
);
    logic [1:0] FlagW;
    logic       PCS_internal, RegW_internal, MemW_internal; // Renombradas para evitar conflictos con salidas del controlador

    // Instanciar decoder
    decoder dec (
        .Op(Instr[27:26]),
        .Funct(Instr[25:20]),
        .Rd(Instr[15:12]),
        .FullInstr(Instr),
        .FlagW(FlagW),
        .PCS(PCS_internal), // Conectar a señal interna
        .RegW(RegW_internal), // Conectar a señal interna
        .MemW(MemW_internal), // Conectar a señal interna
        .MemtoReg(MemtoReg),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .RegSrc(RegSrc),
        .ALUControl(ALUControl),
        .PCS_ALU_SrcA(PCS_ALU_SrcA) // Conectar la nueva señal del decoder
    );

    // Instanciar la lógica condicional
    condlogic cl (
        .clk(clk),
        .reset(reset),
        .Cond(Instr[31:28]),
        .ALUFlags(ALUFlags),
        .FlagW(FlagW),
        .PCS(PCS_internal), // Usar señal interna del decoder
        .RegW(RegW_internal), // Usar señal interna del decoder
        .MemW(MemW_internal), // Usar señal interna del decoder
        .PCSrc(PCSrc),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .Stall(Stall)
    );
endmodule
