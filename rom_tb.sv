`timescale 1ns/1ps

module rom_tb;
    logic [7:0] address;
    logic clock;
    logic [31:0] q;

    rom rom_inst (
        .address(address),
        .clock(clock),
        .q(q)
    );

    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    initial begin
        address = 0;
        #20;
        $display("Time=%t address=%h q=%h", $time, address, q);
        address = 1;
        #20;
        $display("Time=%t address=%h q=%h", $time, address, q);
        $finish;
    end
endmodule