`timescale 1 ns / 1 ns

module arm_tb();
    logic clk = 0;
    logic reset;
    logic [31:0] WriteData, ALUResult;
    logic MemWrite;
    logic [31:0] PC = 32'd0;
    logic [31:0] Instr, ReadData;

    // Instancia del procesador ARM
    arm arm (
        .clk(clk),
        .reset(reset),
        .PC(PC),
        .Instr(Instr),
        .MemWrite(MemWrite),
        .ALUResult(ALUResult),
        .WriteData(WriteData),
        .ReadData(ReadData)
    );

    // Memoria de datos simple
    logic [31:0] data_memory [0:1023]; // Memoria de datos de 4KB
    always @(posedge clk) begin
        if (MemWrite)
            data_memory[ALUResult[11:2]] <= WriteData; // Escribir en memoria
    end
    assign ReadData = data_memory[ALUResult[11:2]]; // Leer de memoria

    // Generación del reloj
    always #5 clk = ~clk;

    // Memoria de instrucciones
    logic [31:0] instruction_memory [0:135];
    integer i;

    initial begin
        // Inicialización de la memoria de datos
        for (i = 0; i < 1024; i = i + 1) begin
            data_memory[i] = 32'h0;
        end

        // Inicialización del reset
        reset = 1;
        #22;
        reset = 0;

        // Carga de instrucciones desde el archivo
        $readmemh("memfile.dat", instruction_memory);

        // Monitor para imprimir el estado del procesador
        $monitor("Tiempo: %0t | PC: 0x%h | Instr: 0x%h | WriteData: 0x%h | MemWrite: %b | ALUResult: 0x%h",
                 $time, PC, Instr, WriteData, MemWrite, ALUResult);

        // Ejecución de las instrucciones
        for (i = 0; i < 128; i = i + 1) begin
            if (PC[11:2] >= 136) begin
                $display("Error: PC out of instruction memory range.");
                $stop;
            end
            Instr = instruction_memory[PC[11:2]]; // Fetch using PC
            @(posedge clk); // Espera al siguiente ciclo de reloj
        end

        // Finalización de la simulación
        $display("Simulación del procesador ARM completa.");
        $stop; // Termina la simulación
    end
endmodule