`timescale 1ns / 1ps

module decoder_tb;
// Declaración de entradas para el módulo decoder (reg para poder asignar valores)
    reg [1:0] Op;
    reg [5:0] Funct;
    reg [3:0] Rd;

    // Declaración de salidas del módulo decoder (wire para recibir los valores)
    wire [1:0] FlagW;
    wire PCS, RegW, MemW;
    wire MemtoReg, ALUSrc;
    wire [1:0] ImmSrc, RegSrc, ALUControl;

    // Instanciar el Módulo Bajo Prueba (UUT - Unit Under Test)
    decoder dut (
        .Op(Op),
        .Funct(Funct),
        .Rd(Rd),
        .FlagW(FlagW),
        .PCS(PCS),
        .RegW(RegW),
        .MemW(MemW),
        .MemtoReg(MemtoReg),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .RegSrc(RegSrc),
        .ALUControl(ALUControl)
    );

    // Bloque inicial para aplicar estímulos y monitorear salidas
    initial begin
        // Configurar el monitoreo de señales: muestra las entradas y todas las salidas en cada cambio
        $monitor("Tiempo=%0t Op=%b Funct=%b Rd=%b | PCS=%b RegW=%b MemW=%b MemtoReg=%b ALUSrc=%b ImmSrc=%b RegSrc=%b ALUControl=%b FlagW=%b",
                 $time, Op, Funct, Rd, PCS, RegW, MemW, MemtoReg, ALUSrc, ImmSrc, RegSrc, ALUControl, FlagW);

        // --- Inicialización de Entradas ---
        // Se inicializan todas las entradas a un estado conocido al principio de la simulación
        Op = 2'b00;
        Funct = 6'b000000;
        Rd = 4'b0000;
        #10; // Pequeño retardo para observar el estado inicial

        // --- Casos de Prueba ---

        $display("\n--- Test 1: Data-processing immediate (Op=2'b00, Funct[5]=0) ---");
        // Debería activar ALUOp=1, RegW=1, y ALUControl=10 (AND) para Funct[4:1]=0000
        Op = 2'b00; Funct = 6'b000000; Rd = 4'b0000;
        #10;

        $display("\n--- Test 2: Data-processing immediate (Op=2'b00, Funct[5]=1) ---");
        // Debería activar ALUOp=1, RegW=1, ALUSrc=1
        Op = 2'b00; Funct = 6'b100000; Rd = 4'b0000;
        #10;

        $display("\n--- Test 3: LDR (Load Register) - Op=2'b01, Funct[0]=1 ---");
        // Debería tener RegW=1, MemW=0, MemtoReg=1, ALUSrc=1, ALUControl=00 (ADD)
        Op = 2'b01; Funct = 6'b000001; Rd = 4'b0000;
        #10;

        $display("\n--- Test 4: STR (Store Register) - Op=2'b01, Funct[0]=0 ---");
        // Debería tener RegW=0, MemW=1, MemtoReg=0, ALUSrc=1, ALUControl=00 (ADD)
        Op = 2'b01; Funct = 6'b000000; Rd = 4'b0000;
        #10;

        $display("\n--- Test 5: Branch (B) - Op=2'b10 ---");
        // Debería tener PCS=1, Branch=1, ImmSrc=10
        Op = 2'b10; Funct = 6'b000000; Rd = 4'b0000;
        #10;

        $display("\n--- Test 6: Unimplemented Op (Op=2'b11) ---");
        // Todas las salidas de control deberían ser 0
        Op = 2'b11; Funct = 6'b000000; Rd = 4'b0000;
        #10;

        // --- Pruebas de ALUDecoder y FlagW (con Op=2'b00 para activar ALUOp) ---

        $display("\n--- Test 7: ALUDecoder - ADD (Funct[4:1]=4'b0100) sin S bit ---");
        // ALUControl=00, FlagW=00
        Op = 2'b00; Funct = 6'b001000; Rd = 4'b0000;
        #10;

        $display("\n--- Test 8: ALUDecoder - SUB (Funct[4:1]=4'b0010) sin S bit ---");
        // ALUControl=01, FlagW=00
        Op = 2'b00; Funct = 6'b000100; Rd = 4'b0000;
        #10;

        $display("\n--- Test 9: ALUDecoder - AND (Funct[4:1]=4'b0000) con S bit ---");
        // ALUControl=10, FlagW=10 (FlagW[0] es 0 porque no es ADD/SUB)
        Op = 2'b00; Funct = 6'b000001; Rd = 4'b0000;
        #10;

        $display("\n--- Test 10: ALUDecoder - ORR (Funct[4:1]=4'b1100) con S bit ---");
        // ALUControl=11, FlagW=10
        Op = 2'b00; Funct = 6'b011001; Rd = 4'b0000;
        #10;

        $display("\n--- Test 11: ALUDecoder - MOV (Funct[4:1]=4'b1010) sin S bit ---");
        // ALUControl=00, FlagW=00
        Op = 2'b00; Funct = 6'b010100; Rd = 4'b0000;
        #10;

        // --- Pruebas de PCS Logic ---

        $display("\n--- Test 12: PCS - Rd=4'b1111 y RegW=1 (como en un MOVS PC, #inm) ---");
        // Op=00, Funct=100000 (activa RegW=1), Rd=4'b1111. Debería dar PCS=1
        Op = 2'b00; Funct = 6'b100000; Rd = 4'b1111;
        #10;

        $display("\n--- Test 13: PCS - Branch activo (Op=2'b10) ---");
        // Op=2'b10 (activa Branch=1). Debería dar PCS=1
        Op = 2'b10; Funct = 6'b000000; Rd = 4'b0000;
        #10;

        $display("\n--- Test 14: PCS - Ni Rd=4'b1111 ni Branch ---");
        // Op=00, Funct=000000 (RegW=1), Rd=0000. Debería dar PCS=0
        Op = 2'b00; Funct = 6'b000000; Rd = 4'b0000;
        #10;

        // Finalizar la simulación
        $display("\n--- Fin de la simulación ---");
        $finish;
    end

endmodule
