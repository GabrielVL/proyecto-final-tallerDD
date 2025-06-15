`timescale 1ns/1ps

module computer_top_tb();
    logic clk = 0;
    logic reset = 1;
    logic enable = 1;
    logic [31:0] WriteData, DataAdr, ReadData;
    logic MemWrite;
    logic [31:0] ins, PC;

    computer_top dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .WriteData(WriteData),
        .DataAdr(DataAdr),
        .ReadData(ReadData),
        .MemWrite(MemWrite),
        .ins(ins),
        .PC(PC)
    );

    always begin
        clk <= ~clk; 
        #5;
    end

    initial begin
        reset = 1;
        #25; // Hold reset for 25 ns (5 clock cycles)
        reset = 0;
        #1000; // Run for 1000 ns
        $finish;
    end

    always @(negedge clk) begin
        $display("----------------------------------------------------");
        $display("Time = %t", $time);
        $display("WriteData = %d (0x%h)", WriteData, WriteData);
        $display("DataAdr = %d (0x%h)", DataAdr, DataAdr);
        $display("MemWrite = %b", MemWrite);
        $display("ReadData = %d (0x%h)", ReadData, ReadData);
        $display("ins = %b (0x%h)", ins, ins);
        $display("PC = %d (0x%h)", PC, PC);
        $display("----------------------------------------------------");
    end
endmodule