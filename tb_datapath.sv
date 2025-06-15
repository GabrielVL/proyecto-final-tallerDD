// tb_datapath.sv
// Testbench para el Módulo Datapath

module tb_datapath;

    // Entradas al módulo datapath (controladas por el testbench)
    reg clk;
    reg rst;
    reg [1:0] RegSrc;
    reg RegWrite;     // Señal de RegWrite "bruta" del control del TB
    reg [1:0] ImmSrc;
    reg ALUSrc;
    reg [1:0] ALUControl;
    reg MemtoReg;     // Señal de MemtoReg "bruta" del control del TB
    reg PCSrc;        // Señal de PCSrc "bruta" del control del TB
    reg [31:0] ReadData; // Datos leídos de la memoria (simulados por TB)
    reg [31:0] Instr;    // Instrucción completa de 32 bits
    reg MemWrite;        // Declaración de MemWrite

    // Salidas del módulo datapath (observadas en el testbench)
    wire [3:0] ALUFlags;
    wire [31:0] PC;
    wire [31:0] ALUResult;
    wire [31:0] WriteData; // Datos a escribir en memoria o segundo operando de regfile

    // Señales internas para monitoreo detallado (extraídas del DUT)
    wire [31:0] PCNext_int, PCPlus4_int, PCPlus8_int;
    wire [31:0] ExtImm_int, SrcA_int, SrcB_int, Result_int;
    wire [3:0] RA1_int, RA2_int;
    wire CondEx_int; // Para monitorear la salida del condcheck (renombrado de CondPassed_int)
    // Nuevas wires para monitorear las señales gated
    wire RegWrite_gated_int;
    wire MemtoReg_gated_int;
    wire PCSrc_gated_int;
    wire [31:0] BranchTarget_int; // Para monitorear el BranchTarget

    // Instancia del Datapath bajo prueba (DUT - Device Under Test)
    datapath dut (
        .clk(clk),
        .rst(rst),
        .RegSrc(RegSrc),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .ALUControl(ALUControl),
        .MemtoReg(MemtoReg),
        .PCSrc(PCSrc),
        .ReadData(ReadData),
        .Instr(Instr),
        .ALUFlags(ALUFlags),
        .PC(PC),
        .ALUResult(ALUResult),
        .WriteData(WriteData)
    );

    // Conectar señales internas del DUT a wires internas del TB para monitoreo
    assign PCNext_int = dut.PCNext;
    assign PCPlus4_int = dut.PCPlus4;
    assign PCPlus8_int = dut.PCPlus8;
    assign ExtImm_int = dut.ExtImm;
    assign SrcA_int = dut.SrcA;
    assign SrcB_int = dut.SrcB;
    assign Result_int = dut.Result;
    assign RA1_int = dut.RA1;
    assign RA2_int = dut.RA2;
    assign CondEx_int = dut.CondEx_internal; // Conectar a la nueva señal CondEx_internal
    assign RegWrite_gated_int = dut.RegWrite_gated; // Conectar la señal gated
    assign MemtoReg_gated_int = dut.MemtoReg_gated; // Conectar la señal gated
    assign PCSrc_gated_int = dut.PCSrc_gated;     // Conectar la señal gated
    assign BranchTarget_int = dut.BranchTarget;   // Conectar el BranchTarget

    // Generador de reloj: Ciclo de 10 unidades de tiempo
    always #5 clk = ~clk;

    // Bloque inicial para estímulos
    initial begin
        // Inicialización de todas las entradas del TB
        clk = 0;
        rst = 0;
        RegSrc = 2'b00;
        RegWrite = 0;
        ImmSrc = 2'b00;
        ALUSrc = 0;
        ALUControl = 2'b00; // ADD
        MemtoReg = 0;
        PCSrc = 0;
        ReadData = 32'hFFFFFFFF; // Valor por defecto para ReadData
        Instr = 32'h00000000;
        MemWrite = 0; // Inicializar MemWrite

        // Configurar monitoreo de señales
        $monitor("Tiempo=%0t clk=%b rst=%b PC=%h | Instr=%h (Cond=%b Op=%b Funct=%b Rn=%h Rd=%h Imm/Rm=%h) | ReadData=%h | RegSrc=%b RegWrite=%b ImmSrc=%b ALUSrc=%b ALUControl=%b MemtoReg=%b PCSrc=%b MemWrite=%b | CondEx=%b RegWrite_g=%b MemtoReg_g=%b PCSrc_g=%b | PCNext=%h PCPlus4=%h PCPlus8=%h BranchTarget=%h | ExtImm=%h SrcA=%h SrcB=%h | ALUResult=%h ALUFlags=%b WriteData=%h | Result=%h",
                 $time, clk, rst, PC,
                 Instr, Instr[31:28], Instr[27:26], Instr[25:20], Instr[19:16], Instr[15:12], Instr[11:0], ReadData,
                 RegSrc, RegWrite, ImmSrc, ALUSrc, ALUControl, MemtoReg, PCSrc, MemWrite,
                 CondEx_int, RegWrite_gated_int, MemtoReg_gated_int, PCSrc_gated_int, // Añadido al monitor
                 PCNext_int, PCPlus4_int, PCPlus8_int, BranchTarget_int, // Añadido BranchTarget
                 ExtImm_int, SrcA_int, SrcB_int,
                 ALUResult, ALUFlags, WriteData, Result_int);

        #10; // Permite que los valores iniciales se propaguen (y el reset asíncrono del regfile)

        // --- Test 1: Reset Behavior ---
        $display("\n--- Test 1: Reset Behavior (PC should be 0, all registers to 0) ---");
        rst = 1;
        #10;
        rst = 0;
        #10; // PC should be 0 after reset, then 4 after first clock edge

        // --- Test 2: PC Incrementing (No Branch, No PC Write) ---
        $display("\n--- Test 2: PC Incrementing (PC + 4 each cycle) ---");
        PCSrc = 0; // No branch
        RegWrite = 0; // No reg write
        MemtoReg = 0; // Not relevant
        ALUControl = 2'b00; // Not relevant, but a default
        ImmSrc = 2'b00; // Not relevant
        #10; // PC=4
        #10; // PC=8
        #10; // PC=C (12)
        #10; // PC=10 (16)

        // --- Test 3: R-type ADD (R1 = R0 + R0_from_WriteData) ---
        $display("\n--- Test 3: R-type ADD (R1 = R0 + R0_from_WriteData) ---");
        // Instr: ADD R1, R0, R0 -> E0801000 (Cond=AL(1110), Op=DP(00), Funct=ADD_noS(001000), Rn=R0(0000), Rd=R1(0001), Rm=R0(0000))
        Instr = 32'hE0801000;
        RegSrc = 2'b00;     // RA1=Rn (R0), RA2=Rm (R0 for WriteData)
        ALUSrc = 0;         // SrcB = WriteData (R0)
        ALUControl = 2'b00; // ADD
        MemtoReg = 0;       // Result = ALUResult
        RegWrite = 1;       // Habilitar escritura en regfile (será gated por AL)
        PCSrc = 0;          // PC sigue incrementando
        MemWrite = 0;

        #10; // R1 gets 0 (ALUResult=0)
        RegWrite = 0; // Deshabilitar escritura
        $display("Expected R1 (read from RegFile output after write) = 0");
        Instr = 32'hE0810000; // Instr: ADD R0, R1, R0 (read R1, Rd=R0, Op/Funct doesn't matter much)
        RegSrc = 2'b00; // Rn selected by RA1mux is R1
        #1; // Short delay to allow combinational read to propagate
        $display("R1 value (SrcA, reading R1 directly): %h", SrcA_int); // Should be 0

        // --- Test 4: I-type ADDI (R2 = R1 + 0xA) ---
        $display("\n--- Test 4: I-type ADDI (R2 = R1 + 0xA) ---");
        // Instr: ADDI R2, R1, #10 -> E281200A (Cond=AL(1110), Op=DP(00), Funct=ADDI_noS(001000), Rn=R1(0001), Rd=R2(0010), Imm=0xA (0000_1010))
        Instr = 32'hE281200A;
        RegSrc = 2'b00;     // RA1=Rn (R1)
        ALUSrc = 1;         // SrcB = ExtImm
        ImmSrc = 2'b00;     // 8-bit unsigned immediate (Imm[7:0] for ADDI)
        ALUControl = 2'b00; // ADD
        MemtoReg = 0;
        RegWrite = 1;
        PCSrc = 0;
        MemWrite = 0;
        #10; // R2 gets (R1 + 10) = (0 + 10) = 10 (0xA)
        RegWrite = 0;
        $display("Expected R2 (read from RegFile output after write) = 0xA");
        Instr = 32'hE0820000; // Instr: ADD R0, R2, R0 (read R2, Rd=R0)
        RegSrc = 2'b00; // Rn selected by RA1mux is R2
        #1;
        $display("R2 value (SrcA, reading R2 directly): %h", SrcA_int); // Should be 0xA

        // --- Test 5: LDR (R3 = [R2 + 0xC]) ---
        $display("\n--- Test 5: LDR (R3 = [R2 + 0xC]) ---");
        // Instr: LDR R3, [R2, #12] -> E492300C (Cond=AL(1110), Op=LDR/STR(01), Funct=LDR(000001), Rn=R2(0010), Rd=R3(0011), Imm=0xC (0000_1100))
        Instr = 32'hE492300C;
        RegSrc = 2'b00;     // RA1=Rn (R2)
        ALUSrc = 1;         // SrcB = ExtImm
        ImmSrc = 2'b01;     // 12-bit unsigned immediate (Imm[11:0] for LDR)
        ALUControl = 2'b00; // ADD (for address calculation)
        MemtoReg = 1;       // Result = ReadData
        RegWrite = 1;       // Habilitar escritura en R3
        PCSrc = 0;
        ReadData = 32'hDEADBEEF; // Simulate memory read data
        MemWrite = 0;
        #10; // R3 should get DEADBEEF (ALUResult=0xA+0xC=0x16, then ReadData=0xDEADBEEF)
        RegWrite = 0;
        $display("Expected R3 (read from RegFile output after write) = DEADBEEF");
        Instr = 32'hE0830000; // Instr: ADD R0, R3, R0 (read R3, Rd=R0)
        RegSrc = 2'b00; // Rn selected by RA1mux is R3
        #1;
        $display("R3 value (SrcA, reading R3 directly): %h", SrcA_int); // Should be DEADBEEF

        // --- Test 6: STR (Store Word) ---
        $display("\n--- Test 6: STR ([R2 + 0x10] = R3) ---");
        // Instr: STR R3, [R2, #16] -> E5823010 (Cond=AL(1110), Op=LDR/STR(01), Funct=STR(000000), Rn=R2(0010), Rd=R3(0011), Imm=0x10 (0001_0000))
        Instr = 32'hE5823010;
        RegSrc = 2'b10;     // RA1=Rn (R2), RA2=Rd (R3 for WriteData to memory)
        ALUSrc = 1;         // SrcB = ExtImm
        ImmSrc = 2'b01;     // 12-bit unsigned immediate
        ALUControl = 2'b00; // ADD (for address calculation)
        MemtoReg = 0;       // Result = ALUResult (ignored for STR)
        RegWrite = 0;       // No escritura en regfile
        MemWrite = 1;       // Habilitar escritura en memoria (simulada aquí) (será gated por AL)
        PCSrc = 0;
        #10; // ALUSrc will use ExtImm (0x10). SrcA is R2 (0xA). ALUResult (address) = 0x1A.
        // WriteData (from rd2) will be R3 (0xDEADBEEF). MemWrite is active.
        $display("Expected MemWrite=1, WriteData=DEADBEEF (address 0x1A)");
        MemWrite = 0; // Deshabilitar escritura en memoria

        // --- Test 7: Branch (B) ---
        $display("\n--- Test 7: Branch (PC = current PC + 8 + offset) ---");
        // Instr: B +8 (e.g., branch to PC+8 + 8 = PC+16) -> EA000000 (Cond=AL(1110), Op=B(10), Imm=0 (offset for +8 from current PC+8))
        // Current PC at start of cycle for this test will be 0x00000024 (from previous increments)
        // PCPlus8 for current PC=0x24 will be 0x24 + 8 = 0x2C
        // ExtImm for Instr=EA000000 (offset 0) is 0x00000000
        // Expected BranchTarget = 0x2C + 0 = 0x2C
        Instr = 32'hEA000000; // Branch offset 0 (00000000 in Instr[23:0])
        RegSrc = 2'b00;     // Default (not relevant for branch)
        ALUSrc = 0;         // Default (not relevant for branch target calc in this setup)
        ImmSrc = 2'b10;     // 24-bit shifted branch (ExtImm will be 0)
        ALUControl = 2'b00; // Default (not relevant for branch target calc in this setup)
        MemtoReg = 0;       // Default
        RegWrite = 0;       // Default
        MemWrite = 0;       // Default
        PCSrc = 1;          // Habilitar salto condicional (será gated por AL)

        #10; // PC should update to PCNext (PCPlus8 + ExtImm)
        $display("Expected PC to jump to 0x0000002C");
        PCSrc = 0; // Desactivar salto

        // --- Test 8: Data Processing (ADDS, S-bit) - Flag Update ---
        $display("\n--- Test 8: ADDS (R4 = R0 + R0, sets Z flag if R0 is 0) ---");
        // Instr: ADDS R4, R0, R0 -> E0904000 (Cond=AL(1110), Op=DP(00), Funct=ADDS(001001), Rn=R0(0000), Rd=R4(0100), Rm=R0(0000))
        Instr = 32'hE0904000;
        RegSrc = 2'b00; // R0 as Rn and Rm
        RegWrite = 1;
        MemtoReg = 0;
        ALUSrc = 0;
        ALUControl = 2'b00; // ADD
        #10; // R4 gets 0, ALUFlags should be 0100 (Z=1)
        $display("Expected R4 = 0, ALUFlags.Z=1 (0100)");
        RegWrite = 0;

        // --- Test 9: Conditional RegWrite (SUBEQ R5, R0, R0) ---
        $display("\n--- Test 9: SUBEQ (R5 = R0 - R0, conditional on Z=1) ---");
        // Instr: SUBEQ R5, R0, R0 -> 02405000 (Cond=EQ(0000), Op=DP(00), Funct=SUBS(100100), Rn=R0, Rd=R5, Rm=R0)
        // Since ALUFlags.Z is currently 1 (from previous ADDS), the condition (EQ) will pass.
        Instr = 32'h02405000;
        RegSrc = 2'b00; // R0 as Rn and Rm
        RegWrite = 1;   // Base RegWrite from control unit (this gets gated by CondEx)
        MemtoReg = 0;
        ALUSrc = 0;
        ALUControl = 2'b01; // SUB
        #10; // R5 should get 0 (0-0=0), because Z was 1, so condition passes.
        $display("Expected R5 = 0 (Condition passes due to Z=1)");
        RegWrite = 0;

        // --- Test 10: Conditional RegWrite (SUBNE R6, R0, R0) ---
        $display("\n--- Test 10: SUBNE (R6 = R0 - R0, conditional on Z=0) ---");
        // Instr: SUBNE R6, R0, R0 -> 12406000 (Cond=NE(0001), Op=DP(00), Funct=SUBS(100100), Rn=R0, Rd=R6, Rm=R0)
        // Since ALUFlags.Z is currently 1 (from previous SUBEQ), the condition (NE) will FAIL.
        Instr = 32'h12406000;
        RegSrc = 2'b00; // R0 as Rn and Rm
        RegWrite = 1;   // Base RegWrite from control unit
        MemtoReg = 0;
        ALUSrc = 0;
        ALUControl = 2'b01; // SUB
        #10; // R6 should NOT get 0, because Z is 1, so condition FAILS.
        $display("Expected R6 to remain X/0 (Condition fails due to Z=1)");
        RegWrite = 0;

        // --- Fin de la simulación ---
        $display("\n--- Fin de la simulación ---");
        #10;
        $finish; // Termina la simulación
    end

endmodule
