`timescale 1 ns / 1 ns
module tb_computer_top;
    logic clk, reset, button;
    logic [6:0] op7seg;
    logic [20:0] debug_bx_check;
    logic [3:0] debug_alu_op;
    logic debug_s_bit;
    logic debug_bx_match;
    logic button_pulse;

    computer_top dut (
        .clk(clk),
        .reset(reset),
        .button(button),
        .op7seg(op7seg),
        .debug_bx_check(debug_bx_check),
        .debug_alu_op(debug_alu_op),
        .debug_s_bit(debug_s_bit),
        .debug_bx_match(debug_bx_match)
    );

    assign button_pulse = dut.db.button_out;

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz
    end

    initial begin
        reset = 1;
        button = 1;
        #20 reset = 0;
        
        // Presiones cada 0.2ms, duración 20µs
        for (int i = 0; i < 80; i++) begin // Hasta PC=0x140
            #200000 button = 0; #20000 button = 1;
        end
        #5000000 $finish; // 5ms después
    end

    initial begin
        $monitor("Time=%0t PC=%h Instr=%h op7seg=%b bx_check=%h alu_op=%h s_bit=%b bx_match=%b button=%b pulse=%b", 
                 $time, dut.PC, dut.Instr, op7seg, debug_bx_check, debug_alu_op, debug_s_bit, debug_bx_match, button, button_pulse);
    end
endmodule
