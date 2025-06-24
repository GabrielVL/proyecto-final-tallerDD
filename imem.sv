module imem (
    input logic [31:0] a,
    input logic reset,
    output logic [31:0] Instr
);

    logic [31:0] INST_RAM[0:255];

    // Cargar memfile.dat
    initial $readmemh("memfile.dat", INST_RAM);

    assign Instr = (reset) ? 32'd0 : INST_RAM[a[31:2]];

endmodule