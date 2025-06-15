module tb_flopenr;

    // Define el parámetro WIDTH para el testbench y el DUT.
    // Puedes cambiarlo aquí para probar diferentes anchos de datos.
    parameter WIDTH = 8; // Puedes cambiar a 4, 16, 32, etc.

    // Declaración de entradas para el DUT (tipo reg porque el testbench las controlará)
    reg clk;
    reg rst;
    reg en;
    reg [WIDTH-1:0] d;

    // Declaración de salida del DUT (tipo wire porque el DUT la generará)
    wire [WIDTH-1:0] q;

    // Instancia del Módulo Bajo Prueba (DUT - Device Under Test)
    // Se pasa el parámetro WIDTH al módulo flopenr
    flopenr #( .WIDTH(WIDTH) ) dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .d(d),
        .q(q)
    );

    // Generador de reloj: crea un pulso de reloj constante
    always #5 clk = ~clk; // Un periodo de reloj de 10 unidades de tiempo (5 alto, 5 bajo)

    // Bloque inicial para aplicar estímulos y monitorear señales
    initial begin
        // Inicializa las señales de control y datos al inicio
        clk = 0;
        rst = 0;
        en = 0;
        d = {WIDTH{1'b0}}; // Inicializa d a todos ceros, adaptable al WIDTH

        // Configura el monitoreo de señales para ver los cambios en tiempo real
        $monitor("Tiempo=%0t clk=%b rst=%b en=%b d=%h q=%h", $time, clk, rst, en, d, q);

        // --- Inicio de los Casos de Prueba ---

        // Test 1: Reset Asíncrono
        $display("\n--- Test 1: Reset Asíncrono (q debería ir a 0) ---");
        #10; // Espera un ciclo de reloj completo
        rst = 1; // Activa el reset
        d = {WIDTH{1'b1}}; // Cambia d para verificar que no afecta con reset
        #10;
        rst = 0; // Desactiva el reset
        #10; // Espera para que q se estabilice después del reset

        // Test 2: Enable Desactivado (q debería mantener su valor)
        $display("\n--- Test 2: Enable Desactivado (q debería mantener 0) ---");
        en = 0; // Asegura que enable está desactivado
        d = {WIDTH{1'b1}}; // Cambia d, q no debería cambiar
        #10;
        d = {WIDTH{1'b0}}; // Cambia d de nuevo
        #10;

        // Test 3: Enable Activado (q debería seguir a d en el flanco positivo de clk)
        $display("\n--- Test 3: Enable Activado (q debería seguir a d) ---");
        en = 1; // Activa enable
        d = 8'hAA; // Nuevo valor para d
        #10; // Espera al siguiente flanco positivo
        d = 8'h55; // Cambia d
        #10; // Espera al siguiente flanco positivo
        d = 8'hC3; // Otro valor
        #10;

        // Test 4: Combinación de Enable y Reset
        $display("\n--- Test 4: Combinación de Enable y Reset ---");
        d = 8'hFF;
        en = 1;
        #5; // clk=1, d=FF, q=C3
        rst = 1; // Reset activo, q debería ir a 0 inmediatamente
        #5; // clk=0, q=0
        rst = 0; // Reset inactivo
        #5; // clk=1, q=0 (en=1, pero d=FF se cargará en el siguiente flanco)
        #5; // clk=0, q=FF (se actualizó en el flanco positivo anterior)

        // Test 5: Probar diferentes valores de datos para asegurar el ancho
        $display("\n--- Test 5: Probar valores extremos de datos ---");
        en = 1;
        d = {WIDTH{1'b0}}; // Todos ceros
        #10;
        d = {WIDTH{1'b1}}; // Todos unos
        #10;
        d = {1'b1, {WIDTH-1{1'b0}}}; // Solo el bit más significativo
        #10;
        d = {{(WIDTH-1){1'b0}}, 1'b1}; // Solo el bit menos significativo
        #10;

        // --- Fin de la simulación ---
        $display("\n--- Fin de la simulación ---");
        #10;
        $finish; // Termina la simulación
    end

endmodule
