module tb_condlogic;

    // Entradas al módulo condlogic
    reg clk;
    reg rst;
    reg [3:0] Cond;    // Código de la condición (e.g., 4'b0000 para EQ)
    reg [3:0] ALUFlags; // Banderas de la ALU (N, Z, C, V)
    reg [1:0] FlagW;   // Bit de control para escribir N/Z (FlagW[1]) y C/V (FlagW[0])
    reg PCS;         // Control de Branch original
    reg RegW;        // Control de RegWrite original
    reg MemW;        // Control de MemWrite original

    // Salidas del módulo condlogic
    wire PCSrc;      // Control final para Branch
    wire RegWrite;   // Control final para RegWrite
    wire MemWrite;   // Control final para MemWrite

    // Internas para monitorear el comportamiento del DUT
    wire [3:0] Flags; // Salida de las banderas almacenadas en los flopenr
    wire CondEx;      // Salida de la comprobación de condición (CondEx)

    // Instancia del Módulo Bajo Prueba (DUT - Device Under Test)
    condlogic dut (
        .clk(clk),
        .rst(rst),
        .Cond(Cond),
        .ALUFlags(ALUFlags),
        .FlagW(FlagW),
        .PCS(PCS),
        .RegW(RegW),
        .MemW(MemW),
        .PCSrc(PCSrc),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite)
    );

    // Conexiones internas para monitoreo (opcional, pero útil para depuración)
    // Se conectan directamente a las salidas de los submódulos dentro de condlogic
    // para poder observarlas en el testbench.
    assign Flags = dut.Flags;
    assign CondEx = dut.CondEx;

    // Generador de reloj: 10 unidades de tiempo por ciclo
    always #5 clk = ~clk;

    // Bloque inicial para aplicar estímulos
    initial begin
        // Inicialización de todas las señales de entrada
        clk = 0;
        rst = 0;
        Cond = 4'b1110;  // Por defecto, condición 'Always' para empezar
        ALUFlags = 4'b0000; // Todas las banderas a 0
        FlagW = 2'b00;    // No escribir banderas por defecto
        PCS = 0;
        RegW = 0;
        MemW = 0;

        // Configuración del monitoreo de señales clave
        $monitor("Tiempo=%0t clk=%b rst=%b Cond=%b ALUFlags=%b (N=%b Z=%b C=%b V=%b) FlagW=%b | Flags=%b CondEx=%b | PCS=%b RegW=%b MemW=%b | PCSrc=%b RegWrite=%b MemWrite=%b",
                 $time, clk, rst, Cond, ALUFlags, ALUFlags[3], ALUFlags[2], ALUFlags[1], ALUFlags[0], FlagW,
                 Flags, CondEx,
                 PCS, RegW, MemW,
                 PCSrc, RegWrite, MemWrite);

        #10; // Espera para que las señales iniciales se propaguen

        // --- Test 1: Reset Asíncrono ---
        $display("\n--- Test 1: Reset Asíncrono ---");
        rst = 1; // Activa el reset
        // Cambiar ALUFlags y FlagW para ver que no afectan durante el reset
        ALUFlags = 4'b1111;
        FlagW = 2'b11;
        #10;
        rst = 0; // Desactiva el reset
        #10; // Espera un ciclo de reloj para la propagación

        // --- Test 2: Actualización de Banderas (CondEx=1) ---
        // Usar Cond = 4'b1110 (Always) para asegurar CondEx = 1
        $display("\n--- Test 2: Actualización de Banderas (CondEx=1) ---");
        Cond = 4'b1110; // Condición AL (Always) -> CondEx siempre 1
        FlagW = 2'b11;  // Habilitar escritura de todas las banderas
        ALUFlags = 4'b1010; // N=1, Z=0, C=1, V=0
        #10; // En el próximo flanco positivo, Flags debería ser 1010
        ALUFlags = 4'b0101; // N=0, Z=1, C=0, V=1
        #10; // Flags debería ser 0101
        FlagW = 2'b01;  // Solo escribir N/Z (FlagW[1]=0, FlagW[0]=1)
        ALUFlags = 4'b1100; // N=1, Z=1, C=0, V=0
        #10; // Flags debería ser {11,01} (N/Z de ALUFlags, C/V anteriores)

        // --- Test 3: Actualización de Banderas (CondEx=0) ---
        // Usar Cond = 4'b0000 (EQ) y asegurar zero=0 para que CondEx=0
        $display("\n--- Test 3: Actualización de Banderas (CondEx=0) ---");
        Cond = 4'b0000; // Condición EQ
        FlagW = 2'b11;  // Habilitar escritura de todas las banderas
        ALUFlags = 4'b0000; // Zero=0, CondEx=0. Flags no deberían cambiar (mantener 1101 de test anterior)
        #10;
        ALUFlags = 4'b1111; // Cambiar ALUFlags, pero Flags no debería actualizarse
        #10; // Flags debería seguir siendo 1101 (o lo que quedó del último update)

        // --- Test 4: RegWrite, MemWrite, PCSrc con CondEx=1 ---
        $display("\n--- Test 4: Controles de Escritura/PC con CondEx=1 ---");
        Cond = 4'b1110; // Condición AL (Always) -> CondEx siempre 1
        FlagW = 2'b00; // Deshabilitar escritura de banderas para no interferir
        // PCS, RegW, MemW activos -> PCSrc, RegWrite, MemWrite deberían ser 1
        PCS = 1; RegW = 1; MemW = 1;
        #10;
        // PCS, RegW, MemW inactivos -> PCSrc, RegWrite, MemWrite deberían ser 0
        PCS = 0; RegW = 0; MemW = 0;
        #10;

        // --- Test 5: RegWrite, MemWrite, PCSrc con CondEx=0 ---
        // Usar Cond = 4'b0000 (EQ) y asegurar zero=0 para que CondEx=0
        $display("\n--- Test 5: Controles de Escritura/PC con CondEx=0 ---");
        Cond = 4'b0000; // Condición EQ
        ALUFlags = 4'b0000; // Zero=0 -> CondEx=0
        // PCS, RegW, MemW activos -> PCSrc, RegWrite, MemWrite deberían ser 0 (por CondEx=0)
        PCS = 1; RegW = 1; MemW = 1;
        #10;
        // Cambiar ALUFlags para que zero=1 -> CondEx=1, los controles deberían activarse
        ALUFlags = 4'b0100; // Zero=1 -> CondEx=1
        #10;

        // --- Test 6: Verificación de condiciones específicas (EQ y NE) ---
        $display("\n--- Test 6: Verificación de Condiciones Específicas (EQ, NE) ---");
        // Test EQ: Cond=4'b0000
        Cond = 4'b0000; // EQ
        PCS = 1; RegW = 1; MemW = 1; // Activar señales base
        ALUFlags = 4'b0100; // Zero=1 -> CondEx=1. PCSrc=1, RegWrite=1, MemWrite=1
        #10;
        ALUFlags = 4'b0000; // Zero=0 -> CondEx=0. PCSrc=0, RegWrite=0, MemWrite=0
        #10;

        // Test NE: Cond=4'b0001
        Cond = 4'b0001; // NE
        ALUFlags = 4'b0000; // Zero=0 -> CondEx=1. PCSrc=1, RegWrite=1, MemWrite=1
        #10;
        ALUFlags = 4'b0100; // Zero=1 -> CondEx=0. PCSrc=0, RegWrite=0, MemWrite=0
        #10;

        // --- Fin de la simulación ---
        $display("\n--- Fin de la simulación ---");
        #10;
        $finish; // Termina la simulación
    end

endmodule
