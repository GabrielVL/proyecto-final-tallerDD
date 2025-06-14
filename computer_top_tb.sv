`timescale 1ps/1ps

module computer_top_tb;
    // Inputs
    logic        clk_tb, reset_tb;
    
    // Outputs
    logic [31:0] PC_tb, Instr_tb, DataAdr_tb, WriteData_tb;
    logic        MemWrite_tb;
    
    // Error counter
    integer error_count = 0;
    
    // Instantiate the Unit Under Test (UUT)
    computer_top dut (
        .clk(clk_tb),
        .reset(reset_tb),
        .PC(PC_tb),
        .Instr(Instr_tb),
        .DataAdr(DataAdr_tb),
        .WriteData(WriteData_tb),
        .MemWrite(MemWrite_tb)
    );
    
    // Clock generation
    initial begin
        clk_tb = 0;
        forever #5000 clk_tb = ~clk_tb; // 10000ps period
    end
    
    // Stimulus process
    initial begin
        reset_tb = 1; #10000; reset_tb = 0; // Reset for 10000ps
        #15000; // Check first instruction at ~25000ps
        if (PC_tb !== 32'h00000000 || Instr_tb !== 32'h010aa0e3) begin
            $display("Error: Tiempo %0t: Fetch de la primera instrucción inesperado. Esperado PC=0x00000000, Instr=0x010aa0e3. Obtenido PC=%h, Instr=%h", $time, PC_tb, Instr_tb);
            error_count = error_count + 1;
        end
        #10000; // Check second instruction at ~35000ps
        if (PC_tb !== 32'h00000004 || Instr_tb !== 32'h461fa0e3) begin
            $display("Error: Tiempo %0t: Fetch de la segunda instrucción inesperado. Esperado PC=0x00000004, Instr=0x461fa0e3. Obtenido PC=%h, Instr=%h", $time, PC_tb, Instr_tb);
            error_count = error_count + 1;
        end
        #10000; // Check third instruction and STR at ~45000ps
        if (PC_tb !== 32'h00000008 || Instr_tb !== 32'h001080e5) begin
            $display("Error: Tiempo %0t: Fetch de la tercera instrucción inesperado. Esperado PC=0x00000008, Instr=0x001080e5. Obtenido PC=%h, Instr=%h", $time, PC_tb, Instr_tb);
            error_count = error_count + 1;
        end
        if (WriteData_tb !== 32'h00000118 || DataAdr_tb !== 32'h2000 || MemWrite_tb !== 1) begin
            $display("Error: Tiempo %0t: Escritura de STR falló. Esperado WriteData=0x00000118, DataAdr=0x2000, MemWrite=1. Obtenido WriteData=%h, DataAdr=%h, MemWrite=%b", $time, WriteData_tb, DataAdr_tb, MemWrite_tb);
            error_count = error_count + 1;
        end
        #10000;
        $display("Simulation finished with %d errors", error_count);
        $finish;
    end
endmodule