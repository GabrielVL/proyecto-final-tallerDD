`timescale 1 ns / 1 ns

module computer_top_tb();
    logic clk = 0;
    logic reset;

    // Instantiate computer_top
    computer_top dut(
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    always #5 clk = ~clk;


    logic [31:0] instruction_memory [0:135]; // Instruction memory array
    integer i;

    initial begin
        // Initialize reset
        reset = 1;
        #22;
        reset = 0;

        // Load instructions from file
        $readmemh("memfile.dat", instruction_memory);

        // Monitor processor state
        $monitor("Time: %0t | PC: 0x%h | Instr: 0x%h | WriteData: 0x%h | MemWriteEnable: %b",
                 $time, dut.PC, dut.Instr, dut.WriteData, dut.MemWriteEnable);

        // Execute instructions
        for (i = 0; i < 128; i = i + 1) begin
            @(posedge clk);
        end

        // End simulation
        $display("Fin de simulación Computer_top.");
        $stop; // Stop simulation
    end
endmodule