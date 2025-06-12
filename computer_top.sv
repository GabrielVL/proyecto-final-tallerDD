module computer_top (
    input  logic        clk, reset,
    output logic [31:0] WriteData, DataAdr,
    output logic        MemWrite
);
    logic [31:0] PC, Instr, ReadData;

    // Instantiate ARM processor
    arm processor (
        .clk(clk),
        .reset(reset),
        .PC(PC),
        .Instr(Instr),
        .MemWrite(MemWrite),
        .ALUResult(DataAdr),
        .WriteData(WriteData),
        .ReadData(ReadData)
    );

    // Instantiate instruction memory (ROM)
    imem imem (
        .a(PC),
        .rd(Instr)
    );

    // Instantiate data memory (RAM)
    dmem dmem (
        .clk(clk),
        .we(MemWrite),
        .a(DataAdr),
        .wd(WriteData),
        .rd(ReadData)
    );

endmodule