module imem (
    input  logic [31:0] a,
    output logic [31:0] rd
);
    logic [31:0] ROM[63:0]; // 64 words

    initial
        $readmemh("memfile.dat", ROM); // Load ARMv4 machine code

    assign rd = ROM[a[31:2]]; // Word-aligned
endmodule