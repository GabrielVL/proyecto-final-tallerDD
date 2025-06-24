
`timescale 1ns / 1ps

module tb_computer_top;

    // Signals
    logic clk;
    logic reset;
    logic button;
    logic [6:0] hex0, hex1, hex4, hex5;
    logic [3:0] led_debug;

    // Internal signals to monitor
    logic [31:0] PC, Instr;
    logic button_pulse;
    logic [2:0] instr_type;

    // Instantiate the DUT
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

    // Clock generation: 50 MHz (20 ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Force button_pulse to bypass debouncer
    assign button_pulse = dut.u_debouncer.button_pulse;

    // Stimulus
    initial begin
        // Initialize inputs
        reset = 0;  // Active-low reset
        button = 1; // Active-low button (not pressed)
        force dut.u_debouncer.button_pulse = 0; // Initialize pulse
        #40000;     // Hold reset for 40 us

        reset = 1;  // Release reset
        #100000;    // Wait 100 us to stabilize

        // Simulate 46 button presses to reach PC=0xB8
        repeat (46) begin
            force dut.u_debouncer.button_pulse = 1; // Simulate button press
            #20; // Hold pulse for 1 clock cycle
            force dut.u_debouncer.button_pulse = 0; // Release pulse
            #40; // Wait 2 clock cycles for PC update
        end

        release dut.u_debouncer.button_pulse; // Release force
        #1000; // 1 us
        $finish;
    end

    // Monitor internal signals
    assign PC = dut.PC;
    assign Instr = dut.Instr;
    assign instr_type = dut.instr_type;

    // Display outputs with instruction mnemonic
    initial begin
        $display("Time(ns)  | PC       | Instr    | Type | Mnemonic | Btn_Pulse | HEX5     | HEX4     | HEX1     | HEX0     | LED_Debug");
        $display("----------|----------|----------|------|----------|-----------|----------|----------|----------|----------|----------");
        $monitor("%9t | %h | %h | %2d   | %-8s | %b         | %b | %b | %b | %b | %b",
                 $time, PC, Instr, instr_type,
                 (instr_type == 0) ? "Other" :
                 (instr_type == 1) ? "MOV" :
                 (instr_type == 2) ? "STR" :
                 (instr_type == 3) ? "LDR" :
                 (instr_type == 4) ? "ADD" :
                 (instr_type == 5) ? "SUB" :
                 (instr_type == 6) ? "AND" :
                 (instr_type == 7) ? "B" : "Unknown",
                 button_pulse, hex5, hex4, hex1, hex0, led_debug);
    end

    // Assertions to check instruction decoding
    always @(posedge clk) begin
        if (reset && button_pulse) begin
            case (PC)
                32'h00: assert(instr_type == 3'd7) else $error("PC=00: Expected B (7), got %d", instr_type); // BL
                32'h04: assert(instr_type == 3'd7) else $error("PC=04: Expected B (7), got %d", instr_type); // BL
                32'h08: assert(instr_type == 3'd7) else $error("PC=08: Expected B (7), got %d", instr_type); // BL
                32'h0C: assert(instr_type == 3'd7) else $error("PC=0C: Expected B (7), got %d", instr_type); // BL
                32'h58: assert(instr_type == 3'd1) else $error("PC=58: Expected MOV (1), got %d", instr_type); // MVN
                32'h78: assert(instr_type == 3'd0) else $error("PC=78: Expected Other (0), got %d", instr_type); // STRB
                32'h7C: assert(instr_type == 3'd0) else $error("PC=7C: Expected Other (0), got %d", instr_type); // SUBS
                32'h80: assert(instr_type == 3'd7) else $error("PC=80: Expected B (7), got %d", instr_type); // BNE
                32'h84: assert(instr_type == 3'd0) else $error("PC=84: Expected Other (0), got %d", instr_type); // BX
                32'h98: assert(instr_type == 3'd4) else $error("PC=98: Expected ADD (4), got %d", instr_type); // ADD
                32'hA0: assert(instr_type == 3'd1) else $error("PC=A0: Expected MOV (1), got %d", instr_type); // MOV
                32'hB0: assert(instr_type == 3'd1) else $error("PC=B0: Expected MOV (1), got %d", instr_type); // MVN
                32'hB4: assert(instr_type == 3'd2) else $error("PC=B4: Expected STR (2), got %d", instr_type); // STR
            endcase
        end
    end

    // Dump waveform
    initial begin
        $dumpfile("tb_computer_top.vcd");
        $dumpvars(0, tb_computer_top);
    end

endmodule