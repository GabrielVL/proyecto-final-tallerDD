`timescale 1ns / 1ps // Unidad de tiempo: 1 nanosegundo, precisión: 1 picosegundo

module computer_top_tb;
    // Declaración de señales de interconexión con el módulo principal (DUT)
    logic clk, reset;
    // Estas señales son SALIDAS de 'computer_top' y son OBSERVADAS por el testbench.
    logic [31:0] Instr_tb;      // Renamed to match computer_top output
    logic [31:0] WriteData_tb;  // WriteData output from computer_top
    logic [31:0] DataAdr_tb;    // DataAdr output from computer_top
    logic MemWrite_tb;          // MemWrite output from computer_top
    logic [31:0] PC_from_arm_tb; // PC output from computer_top

    // Instancia del Diseño Bajo Prueba (DUT: Design Under Test)
    computer_top dut (
        .clk(clk),
        .reset(reset),
        .Instr_to_processor(Instr_tb), // Note: May need to match computer_top.sv output name
        .WriteData(WriteData_tb),
        .DataAdr(DataAdr_tb),
        .MemWrite(MemWrite_tb),
        .PC_from_arm(PC_from_arm_tb)
    );

    // Generación de reloj
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Período de reloj de 10ns (100 MHz)
    end

    // Estímulo de prueba principal
    initial begin
        // Inicializar señales al principio de la simulación
        reset = 1;      // Mantener el sistema en reset
        $display("Time %0t: Testbench - Reset: %b (Inicialmente alto)", $time, reset);
        #10; // Reset por 10ns
        reset = 0;  // Liberar el reset
        $display("Time %0t: Testbench - Reset: %b (Liberado)", $time, reset);

        // --- Test 1: Observar el Fetch de la Primera Instrucción (PC=0x00) ---
        // Esperamos 500ns para que la primera instrucción se propague
        #490; // Total time: 10ns (reset) + 490ns = 500ns
        if (PC_from_arm_tb === 32'h00000000 && Instr_tb === 32'h010aa0e3) begin
            $display("Éxito: Tiempo %0t: Fetch de la primera instrucción (0x010aa0e3) en PC 0x00000000 exitoso.", $time);
        end else begin
            $display("Error: Tiempo %0t: Fetch de la primera instrucción inesperado. Esperado PC=0x00000000, Instr=0x010aa0e3. Obtenido PC=%h, Instr=%h", $time, PC_from_arm_tb, Instr_tb);
        end
        // Expected: PC = 0x00000000, Instr = 0x010aa0e3, WriteData_tb = 0x00000000, DataAdr_tb = ?, MemWrite_tb = 0

        // --- Test 2: Observar el Fetch de la Segunda Instrucción (PC=0x04) ---
        #10; // Total time: 510ns (51 cycles)
        if (PC_from_arm_tb === 32'h00000004 && Instr_tb === 32'h461fa0e3) begin
            $display("Éxito: Tiempo %0t: Fetch de la segunda instrucción (0x461fa0e3) en PC 0x00000004 exitoso.", $time);
        end else begin
            $display("Error: Tiempo %0t: Fetch de la segunda instrucción inesperado. Esperado PC=0x00000004, Instr=0x461fa0e3. Obtenido PC=%h, Instr=%h", $time, PC_from_arm_tb, Instr_tb);
        end
        // Expected: PC = 0x00000004, Instr = 0x461fa0e3, WriteData_tb = 0x00000000 (r10 set but not yet WriteData), DataAdr_tb = ?, MemWrite_tb = 0

        // --- Test 3: Observar el Fetch de la Tercera Instrucción (PC=0x08) y Escritura ---
        #20; // Total time: 530ns (53 cycles)
        if (PC_from_arm_tb === 32'h00000008 && Instr_tb === 32'h001080e5) begin
            $display("Éxito: Tiempo %0t: Fetch de la tercera instrucción (0x001080e5) en PC 0x00000008 exitoso.", $time);
        end else begin
            $display("Error: Tiempo %0t: Fetch de la tercera instrucción inesperado. Esperado PC=0x00000008, Instr=0x001080e5. Obtenido PC=%h, Instr=%h", $time, PC_from_arm_tb, Instr_tb);
        end
        if (WriteData_tb === 32'h00000118 && MemWrite_tb === 1 && DataAdr_tb === 32'h2000) begin // Assuming r0 = 0x2000
            $display("Éxito: Tiempo %0t: Escritura de STR r1, [r0] con WriteData=0x00000118, DataAdr=0x2000, MemWrite=1 exitosa.", $time);
        end else begin
            $display("Error: Tiempo %0t: Escritura de STR falló. Esperado WriteData=0x00000118, DataAdr=0x2000, MemWrite=1. Obtenido WriteData=%h, DataAdr=%h, MemWrite=%b", $time, WriteData_tb, DataAdr_tb, MemWrite_tb);
        end
        // Expected: PC = 0x00000008, Instr = 0x001080e5, WriteData_tb = 0x00000118 (r1 = 0x46 shifted), DataAdr_tb = 0x2000, MemWrite_tb = 1

        // Finalizar la simulación
        #20; // Un pequeño buffer para que los $display se muestren
        $finish;
    end

    // Monitoreo continuo de la señal de reset en el testbench
    always @(reset) begin
        $display("Time %0t: Testbench - CAMBIO en Reset: %b", $time, reset);
    end

    // Añadir waveforms para depuración (genera un archivo .vcd)
    initial begin
        $dumpfile("computer_top_tb.vcd");
        $dumpvars(0, computer_top_tb); // Volcar todas las variables en el testbench
    end

endmodule