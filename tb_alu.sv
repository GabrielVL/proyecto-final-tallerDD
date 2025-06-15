// tb_alu.sv
// Testbench para el módulo ALU

module tb_alu;

    // Define el ancho de datos para la ALU y sus submódulos
    parameter n_param = 4; // Para una verificación básica, 4 bits es suficiente

    // Entradas para el módulo ALU
    reg [n_param-1:0] a, b;
    reg [1:0] ALUControl;

    // Salidas del módulo ALU
    wire [n_param-1:0] ALUResult;
    wire [3:0] ALUFlags; // {N, Z, C, V}

    // Instancia del ALU bajo prueba
    alu #( .n(n_param) ) dut (
        .a(a),
        .b(b),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .ALUFlags(ALUFlags)
    );

    // Definiciones de códigos de operación locales para el testbench
    localparam [1:0] ADD = 2'b00,
                      SUB = 2'b01,
                      AND = 2'b10,
                      OR  = 2'b11;

    // Bloque inicial para aplicar estímulos y monitorear señales
    initial begin
        // Configuración del monitoreo de señales
        $monitor("Tiempo=%0t ALUControl=%b (Op) a=%h b=%h | ALUResult=%h ALUFlags=%b (N=%b Z=%b C=%b V=%b)",
                 $time, ALUControl, a, b, ALUResult, ALUFlags, ALUFlags[3], ALUFlags[2], ALUFlags[1], ALUFlags[0]);

        // --- Inicialización ---
        a = {n_param{1'b0}}; // Todos ceros
        b = {n_param{1'b0}};
        ALUControl = ADD; // Operación por defecto
        #10; // Pequeño retardo para observar el estado inicial

        // --- Test ADD ---
        $display("\n--- Test ADD (ALUControl=00) ---");
        ALUControl = ADD;
        a = 4'd5; b = 4'd3;  #10; // 5 + 3 = 8 (1000). N=1, Z=0, C=0, V=1. (n=4)
        a = 4'd7; b = 4'd1;  #10; // 7 + 1 = 8 (1000). N=1, Z=0, C=0, V=1. (n=4)
        a = 4'd0; b = 4'd0;  #10; // 0 + 0 = 0. N=0, Z=1, C=0, V=0.
        a = 4'd8; b = 4'd8;  #10; // 8 + 8 = 16 (overflow for 4-bit signed/unsigned). N=0, Z=1, C=1, V=1.
        a = 4'b0111; b = 4'b0111; #10; // 7 + 7 = 14 (0111+0111 = 1110). N=1, Z=0, C=0, V=1.
        a = 4'b0101; b = 4'b0101; #10; // 5 + 5 = 10 (0101+0101 = 1010). N=1, Z=0, C=0, V=1.


        // --- Test SUB ---
        $display("\n--- Test SUB (ALUControl=01) ---");
        ALUControl = SUB;
        a = 4'd5; b = 4'd3;  #10; // 5 - 3 = 2 (0010). N=0, Z=0, C=1, V=0.
        a = 4'd3; b = 4'd5;  #10; // 3 - 5 = -2 (1110). N=1, Z=0, C=0, V=0.
        a = 4'd8; b = 4'd0;  #10; // 8 - 0 = 8 (1000). N=1, Z=0, C=1, V=0.
        a = 4'd0; b = 4'd0;  #10; // 0 - 0 = 0. N=0, Z=1, C=1, V=0.
        a = 4'b1000; b = 4'b0001; #10; // (-8) - (1) = -9 -> Result=7 (0111). N=0, Z=0, C=0, V=1.
        a = 4'b0111; b = 4'b1000; #10; // (7) - (-8) = 15 -> Result=f (1111). N=1, Z=0, C=1, V=1.


        // --- Test AND ---
        $display("\n--- Test AND (ALUControl=10) ---");
        ALUControl = AND;
        a = 4'b1100; b = 4'b1010; #10; // 1100 & 1010 = 1000. N=1, Z=0, C=0, V=0.
        a = 4'b0011; b = 4'b0101; #10; // 0011 & 0101 = 0001. N=0, Z=0, C=0, V=0.
        a = 4'b1010; b = 4'b0101; #10; // 1010 & 0101 = 0000. N=0, Z=1, C=0, V=0.

        // --- Test OR ---
        $display("\n--- Test OR (ALUControl=11) ---");
        ALUControl = OR;
        a = 4'b1100; b = 4'b1010; #10; // 1100 | 1010 = 1110. N=1, Z=0, C=0, V=0.
        a = 4'b0011; b = 4'b0101; #10; // 0011 | 0101 = 0111. N=0, Z=0, C=0, V=0.
        a = 4'b0000; b = 4'b0000; #10; // 0000 | 0000 = 0000. N=0, Z=1, C=0, V=0.

        // --- Test Default ALUControl ---
        $display("\n--- Test Default ALUControl (e.g., 2'bXX) ---");
        ALUControl = 2'bXX; // Unspecified or invalid control code
        a = 4'b1010; b = 4'b0101; #10; // ALUResult should be 0. N=0, Z=1, C=0, V=0.

        // --- End of Simulation ---
        $display("\n--- Fin de la simulación ---");
        #10;
        $finish; // Termina la simulación
    end

endmodule
