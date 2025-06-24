`timescale 1 ns / 1 ns

module computer_top_tb();
    logic clk = 0;
    logic reset;
    logic button;
    logic [6:0] hex0, hex1, hex4, hex5;
    logic [3:0] led_debug;

    // Instantiate computer_top
    computer_top dut (
        .clk(clk),
        .reset(reset),
        .button(button),
        .hex0(hex0),
        .hex1(hex1),
        .hex4(hex4),
        .hex5(hex5),
        .led_debug(led_debug)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize inputs
        reset = 0; // Active-low reset
        button = 1; // Active-low button (not pressed)
        #22;
        reset = 1; // Deassert reset
        #10;
        button = 0; // Press button
        #20;
        button = 1; // Release button
        #20;
        button = 0; // Press button again
        #20;
        button = 1; // Release button

        // Monitor processor state
        $monitor("Time: %0t | PC: 0x%h | Instr: 0x%h | WriteData: 0x%h | MemWrite: %b | hex0: %h | hex1: %h | led_debug: %b",
                 $time, dut.u_arm.PC, dut.u_imem.Instr, dut.u_arm.WriteData, dut.u_arm.MemWrite, hex0, hex1, led_debug);

        // Run simulation for 128 cycles
        repeat (128) @(posedge clk);

        // End simulation
        $display("Fin de simulación Computer_top.");
        $stop; // Stop simulation
    end
endmodule