module tb_condcheck;

    // Declaración de entradas para el DUT (tipo reg porque el testbench las controlará)
    reg [3:0] Cond;  // Código de la condición
    reg [3:0] Flags; // Banderas de estado: {neg, zero, carry, overflow}

    // Declaración de salida del DUT (tipo wire porque el DUT la generará)
    wire CondEx;    // Resultado de la comprobación de la condición

    // Instancia del Módulo Bajo Prueba (DUT - Device Under Test)
    condcheck dut (
        .Cond(Cond),
        .Flags(Flags),
        .CondEx(CondEx)
    );

    // Bloque inicial para aplicar estímulos y monitorear señales
    initial begin
        // Configura el monitoreo de señales para ver los cambios en tiempo real
        // Incluye Flags desglosados para mejor depuración
        $monitor("Tiempo=%0t Cond=%b Flags=%b (neg=%b zero=%b carry=%b overflow=%b) | CondEx=%b",
                 $time, Cond, Flags, Flags[3], Flags[2], Flags[1], Flags[0], CondEx);

        // --- Inicialización de Entradas ---
        // Se inicializan todas las entradas a un estado conocido al principio de la simulación
        Cond = 4'b0000;
        Flags = 4'b0000; // neg=0, zero=0, carry=0, overflow=0
        #10; // Pequeño retardo para observar el estado inicial

        // --- Casos de Prueba para cada Condición ---

        $display("\n--- Test 1: EQ (Equal) - Cond=4'b0000 ---");
        Cond = 4'b0000; // ASIGNACIÓN DE CONDICIÓN
        // CondEx = zero
        Flags = 4'b0100; #10; // Flags={0100}, neg=0, zero=1, carry=0, overflow=0. Expected CondEx=1
        Flags = 4'b0000; #10; // Flags={0000}, neg=0, zero=0, carry=0, overflow=0. Expected CondEx=0

        $display("\n--- Test 2: NE (Not Equal) - Cond=4'b0001 ---");
        Cond = 4'b0001; // ASIGNACIÓN DE CONDICIÓN
        // CondEx = ~zero
        Flags = 4'b0000; #10; // Flags={0000}, neg=0, zero=0, carry=0, overflow=0. Expected CondEx=1
        Flags = 4'b0100; #10; // Flags={0100}, neg=0, zero=1, carry=0, overflow=0. Expected CondEx=0

        $display("\n--- Test 3: CS (Carry Set) - Cond=4'b0010 ---");
        Cond = 4'b0010; // ASIGNACIÓN DE CONDICIÓN
        // CondEx = carry
        Flags = 4'b0010; #10; // Flags={0010}, neg=0, zero=0, carry=1, overflow=0. Expected CondEx=1
        Flags = 4'b0000; #10; // Flags={0000}, neg=0, zero=0, carry=0, overflow=0. Expected CondEx=0

        $display("\n--- Test 4: CC (Carry Clear) - Cond=4'b0011 ---");
        Cond = 4'b0011; // ASIGNACIÓN DE CONDICIÓN
        // CondEx = ~carry
        Flags = 4'b0000; #10; // Flags={0000}, neg=0, zero=0, carry=0, overflow=0. Expected CondEx=1
        Flags = 4'b0010; #10; // Flags={0010}, neg=0, zero=0, carry=1, overflow=0. Expected CondEx=0

        $display("\n--- Test 5: MI (Minus) - Cond=4'b0100 ---");
        Cond = 4'b0100; // ASIGNACIÓN DE CONDICIÓN
        // CondEx = neg
        Flags = 4'b1000; #10; // Flags={1000}, neg=1, zero=0, carry=0, overflow=0. Expected CondEx=1
        Flags = 4'b0000; #10; // Flags={0000}, neg=0, zero=0, carry=0, overflow=0. Expected CondEx=0

        $display("\n--- Test 6: PL (Plus) - Cond=4'b0101 ---");
        Cond = 4'b0101; // ASIGNACIÓN DE CONDICIÓN
        // CondEx = ~neg
        Flags = 4'b0000; #10; // Flags={0000}, neg=0, zero=0, carry=0, overflow=0. Expected CondEx=1
        Flags = 4'b1000; #10; // Flags={1000}, neg=1, zero=0, carry=0, overflow=0. Expected CondEx=0

        $display("\n--- Test 7: VS (Overflow Set) - Cond=4'b0110 ---");
        Cond = 4'b0110; // ASIGNACIÓN DE CONDICIÓN
        // CondEx = overflow
        Flags = 4'b0001; #10; // Flags={0001}, neg=0, zero=0, carry=0, overflow=1. Expected CondEx=1
        Flags = 4'b0000; #10; // Flags={0000}, neg=0, zero=0, carry=0, overflow=0. Expected CondEx=0

        $display("\n--- Test 8: VC (Overflow Clear) - Cond=4'b0111 ---");
        Cond = 4'b0111; // ASIGNACIÓN DE CONDICIÓN
        // CondEx = ~overflow
        Flags = 4'b0000; #10; // Flags={0000}, neg=0, zero=0, carry=0, overflow=0. Expected CondEx=1
        Flags = 4'b0001; #10; // Flags={0001}, neg=0, zero=0, carry=0, overflow=1. Expected CondEx=0

        $display("\n--- Test 9: HI (Higher) - Cond=4'b1000 ---");
        Cond = 4'b1000; // ASIGNACIÓN DE CONDICIÓN
        // CondEx = carry & ~zero
        Flags = 4'b0010; #10; // Flags={0010}, neg=0, zero=0, carry=1, overflow=0. Expected CondEx=1
        Flags = 4'b0110; #10; // Flags={0110}, neg=0, zero=1, carry=1, overflow=0. Expected CondEx=0
        Flags = 4'b0000; #10; // Flags={0000}, neg=0, zero=0, carry=0, overflow=0. Expected CondEx=0

        $display("\n--- Test 10: LS (Lower or Same) - Cond=4'b1001 ---");
        Cond = 4'b1001; // ASIGNACIÓN DE CONDICIÓN
        // CondEx = ~(carry & ~zero)
        Flags = 4'b0110; #10; // Flags={0110}, neg=0, zero=1, carry=1, overflow=0. Expected CondEx=1 (because zero=1)
        Flags = 4'b0000; #10; // Flags={0000}, neg=0, zero=0, carry=0, overflow=0. Expected CondEx=1 (because carry=0)
        Flags = 4'b0010; #10; // Flags={0010}, neg=0, zero=0, carry=1, overflow=0. Expected CondEx=0

        $display("\n--- Test 11: GE (Greater or Equal) - Cond=4'b1010 ---");
        Cond = 4'b1010; // ASIGNACIÓN DE CONDICIÓN
        // CondEx = ge (neg == overflow)
        Flags = 4'b0000; #10; // Flags={0000}, neg=0, overflow=0. ge=1. Expected CondEx=1
        Flags = 4'b1001; #10; // Flags={1001}, neg=1, overflow=1. ge=1. Expected CondEx=1
        Flags = 4'b1000; #10; // Flags={1000}, neg=1, overflow=0. ge=0. Expected CondEx=0
        Flags = 4'b0001; #10; // Flags={0001}, neg=0, overflow=1. ge=0. Expected CondEx=0

        $display("\n--- Test 12: LT (Less Than) - Cond=4'b1011 ---");
        Cond = 4'b1011; // ASIGNACIÓN DE CONDICIÓN
        // CondEx = ~ge (neg != overflow)
        Flags = 4'b1000; #10; // Flags={1000}, neg=1, overflow=0. ge=0. Expected CondEx=1
        Flags = 4'b0001; #10; // Flags={0001}, neg=0, overflow=1. ge=0. Expected CondEx=1
        Flags = 4'b0000; #10; // Flags={0000}, neg=0, overflow=0. ge=1. Expected CondEx=0

        $display("\n--- Test 13: GT (Greater Than) - Cond=4'b1100 ---");
        Cond = 4'b1100; // ASIGNACIÓN DE CONDICIÓN
        // CondEx = ~zero & ge
        Flags = 4'b0000; #10; // Flags={0000}, zero=0, ge=1. Expected CondEx=1
        Flags = 4'b1001; #10; // Flags={1001}, zero=0, ge=1. Expected CondEx=1
        Flags = 4'b0100; #10; // Flags={0100}, zero=1, ge=0. Expected CondEx=0 (due to zero=1, ge=0)
        Flags = 4'b1000; #10; // Flags={1000}, zero=0, ge=0. Expected CondEx=0 (due to ge=0)

        $display("\n--- Test 14: LE (Less or Equal) - Cond=4'b1101 ---");
        Cond = 4'b1101; // ASIGNACIÓN DE CONDICIÓN
        // CondEx = ~(~zero & ge)
        Flags = 4'b0100; #10; // Flags={0100}, zero=1, ge=0. Expected CondEx=1
        Flags = 4'b1000; #10; // Flags={1000}, zero=0, ge=0. Expected CondEx=1
        Flags = 4'b0000; #10; // Flags={0000}, zero=0, ge=1. Expected CondEx=0

        $display("\n--- Test 15: AL (Always) - Cond=4'b1110 ---");
        Cond = 4'b1110; // ASIGNACIÓN DE CONDICIÓN
        // CondEx = 1'b1
        Flags = 4'b0000; #10; // Expected CondEx=1
        Flags = 4'b1111; #10; // Expected CondEx=1

        $display("\n--- Test 16: Default/Invalid Cond - Cond=4'b1111 ---");
        Cond = 4'b1111; // ASIGNACIÓN DE CONDICIÓN
        // CondEx = 1'b0
        Flags = 4'b0000; #10; // Expected CondEx=0
        Flags = 4'b1111; #10; // Expected CondEx=0

        // --- Fin de la simulación ---
        $display("\n--- Fin de la simulación ---");
        #10;
        $finish; // Termina la simulación
    end

endmodule
