`timescale 1ns / 1ps

module arm_tb;

    reg clk;
    reg rst;
    reg [31:0] external_address;
    wire [7:0] external_q_b;
    wire [31:0] debug_arm_regs_tb [15:0];

    arm dut (
        .clk(clk),
        .rst(rst),
        .address(external_address),
        .q_b(external_q_b),
        .debug_arm_regs(debug_arm_regs_tb)
    );

    wire [3:0] ALUFlags_int;
    wire RegWrite_raw_int, ALUSrc_int, MemtoReg_raw_int, PCSrc_raw_int, MemWrite_raw_int;
    wire [1:0] RegSrc_int, ImmSrc_int, ALUControl_int;
    wire [31:0] PC_int, Instr_int, ReadData_int;
    wire [31:0] ALUResult_int, WriteData_int;
    wire CondEx_int;

    assign RegSrc_int = dut.RegSrc;
    assign RegWrite_raw_int = dut.RegWrite;
    assign ImmSrc_int = dut.ImmSrc;
    assign ALUSrc_int = dut.ALUSrc;
    assign ALUControl_int = dut.ALUControl;
    assign MemtoReg_raw_int = dut.MemtoReg;
    assign PCSrc_raw_int = dut.PCSrc;
    assign MemWrite_raw_int = dut.MemWrite;
    assign ALUFlags_int = dut.ALUFlags;
    assign PC_int = dut.PC;
    assign Instr_int = dut.Instr;
    assign ALUResult_int = dut.ALUResult;
    assign WriteData_int = dut.WriteData;
    assign ReadData_int = dut.ReadData_from_mem;
    assign CondEx_int = dut.controlUnit.cl.CondEx;

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 0;
        external_address = 32'h0;

        $monitor("t=%0t | PC=%h Instr=%h Flags=%b RegW=%b MemW=%b CondEx=%b ALURes=%h R0=%h R1=%h R2=%h R15=%h",
                 $time, PC_int, Instr_int, ALUFlags_int, RegWrite_raw_int, MemWrite_raw_int, CondEx_int,
                 ALUResult_int, debug_arm_regs_tb[0], debug_arm_regs_tb[1], debug_arm_regs_tb[2], debug_arm_regs_tb[15]);

        // Rápido: 20 ciclos solamente
        #10;
        rst = 1; #10; rst = 0;

        $display("\n--- Ejecutando programa 20 ciclos ---");
        for (int i = 0; i < 20; i++) #10;

        external_address = 32'd8;
        #10;
        $display("RAM[8] Esperado=8'h05, Obtenido=%h", external_q_b);

        $finish;
    end

endmodule