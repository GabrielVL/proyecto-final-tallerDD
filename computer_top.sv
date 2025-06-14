module computer_top (
    input  logic clk, reset,
    output logic [31:0] Instr_to_processor, // New name for instruction output to TB
    output logic [31:0] WriteData,
    output logic [31:0] DataAdr,
    output logic        MemWrite,
    output logic [31:0] PC_from_arm
);

    logic [31:0] Instr_internal; // Internal wire for the instruction from ROM
    logic [31:0] ReadData;       // Internal wire for data read from mem_map

    // Instantiate the ARM processor
    // Connects internal signals to its ports, and exposes PC, WriteData, DataAdr, MemWrite
    arm arm_processor (
        .clk(clk),
        .reset(reset),
        .Instr(Instr_internal),    // arm_processor receives instruction from internal wire
        .ReadData(ReadData),
        .WriteData(WriteData),
        .DataAdr(DataAdr),
        .MemWrite(MemWrite),
        .PC(PC_from_arm)
    );

    // Instantiate the ROM for instructions
    // The ROM outputs the instruction to the internal wire
    rom instruction_rom (
        .address(PC_from_arm[9:2]), // Use the PC output from arm_processor
                                    // Assuming a 256-word (8-bit address) ROM, word-addressed
                                    // Adjust PC bit slice if your ROM depth or addressing differs
        .clock(clk),
        .q(Instr_internal) // ROM drives the internal instruction wire
    );

    // Assign the internal instruction wire to the top-level output for testbench observation
    assign Instr_to_processor = Instr_internal;

    // Instantiate the Memory Map / RAM controller
    // This module handles reads and writes for both the main data RAM
    // and any memory-mapped peripheral registers.
    mem_map main_memory_map (
        .clk(clk),
        .we(MemWrite),
        .a(DataAdr),
        .wd(WriteData),
        .rd(ReadData)
    );

endmodule
