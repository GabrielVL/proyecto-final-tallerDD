module imem(input logic [31:0] a,
            output logic [31:0] rd);

    logic [31:0] INST_RAM[0:135]; 
    initial
        $readmemh("memfile.dat", INST_RAM);

    assign rd = INST_RAM[a[31:2]]; 
endmodule