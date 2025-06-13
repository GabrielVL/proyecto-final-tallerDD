module testbench;
    logic        clk, reset;
    logic [31:0] WriteData, DataAdr;
    logic        MemWrite;

    // Instantiate top-level module
    computer_top dut (
        .clk(clk),
        .reset(reset),
        .WriteData(WriteData),
        .DataAdr(DataAdr),
        .MemWrite(MemWrite)
    );

    // Clock generation (50 MHz = 20 ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 20 ns period
    end

    // Reset and stimulus
    initial begin
        reset = 1; #40; reset = 0; // Reset for 2 cycles
        #20000; $finish; // Run for 20 us
    end

    // Monitor outputs
    initial
        $monitor("Time=%0t PC=%h Instr=%h MemWrite=%b DataAdr=%h WriteData=%h",
                 $time, dut.PC, dut.Instr, dut.MemWrite, dut.DataAdr, dut.WriteData);

    // Initialize dmem for LDR testing
    initial begin
        dut.dmem.RAM[1] = 32'h00000005; // Data at address 0x4 (word 1)
        dut.dmem.RAM[2] = 32'h0000000A; // Data at address 0x8 (word 2)
    end

endmodule
