module computer_top (
    input  logic        clk, reset,
    output logic [31:0] PC,
    output logic [31:0] Instr,
    output logic [31:0] DataAdr,
    output logic [31:0] WriteData,
    output logic        MemWrite
);
    logic [31:0] ReadData;

    arm arm_processor (
        .clk(clk),
        .reset(reset),
        .Instr(Instr),
        .ReadData(ReadData),
        .PC(PC),
        .ALUResult(DataAdr),
        .WriteData(WriteData),
        .MemWrite(MemWrite)
    );

    rom rom_inst (
        .address(PC[9:2]), // Word-aligned
        .clock(clk),
        .q(Instr)
    );

    mem_map mem (
        .clk(clk),
        .we(MemWrite),
        .a(DataAdr),
        .wd(WriteData),
        .rd(ReadData)
    );
endmodule