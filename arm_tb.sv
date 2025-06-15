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

    wire [1:0] decoder_FlagW_out;
    wire decoder_PCS_out, decoder_RegW_out, decoder_MemW_out;
    wire decoder_MemtoReg_out, decoder_ALUSrc_out;
    wire [1:0] decoder_ImmSrc_out, decoder_RegSrc_out, decoder_ALUControl_out;

    wire [1:0] decoder_Op_in;
    wire [5:0] decoder_Funct_in;
    wire [3:0] decoder_Rd_in;

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

    assign decoder_FlagW_out = dut.controlUnit.dec.FlagW;
    assign decoder_PCS_out = dut.controlUnit.dec.PCS;
    assign decoder_RegW_out = dut.controlUnit.dec.RegW;
    assign decoder_MemW_out = dut.controlUnit.dec.MemW;
    assign decoder_MemtoReg_out = dut.controlUnit.dec.MemtoReg;
    assign decoder_ALUSrc_out = dut.controlUnit.dec.ALUSrc;
    assign decoder_ImmSrc_out = dut.controlUnit.dec.ImmSrc;
    assign decoder_RegSrc_out = dut.controlUnit.dec.RegSrc;
    assign decoder_ALUControl_out = dut.controlUnit.dec.ALUControl;

    assign decoder_Op_in = dut.controlUnit.dec.Op;
    assign decoder_Funct_in = dut.controlUnit.dec.Funct;
    assign decoder_Rd_in = dut.controlUnit.dec.Rd;

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 0;
        external_address = 32'h0;

        $monitor("Tiempo=%0t PC=%h Instr=%h Cond=%b Rn=%h Rd=%h Imm/Rm=%h ReadData=%h | Decodificador Entrada: Op=%b Funct=%b Rd=%h | Decodificador Salida: RegW=%b MemW=%b MemtoReg=%b ALUSrc=%b ImmSrc=%b RegSrc=%b ALUControl=%b FlagW=%b PCS=%b | Controlador Salida: RegWrite=%b MemWrite=%b PCSrc=%b CondEx=%b | ALUResult=%h ALUFlags=%b WriteData=%h | R0=%h R1=%h R2=%h R3=%h R4=%h R5=%h R6=%h R7=%h | R8=%h R9=%h R10=%h R11=%h R12=%h R13=%h R14=%h R15=%h | RAM_q_b=%h (ext_addr %h)",
                    $time, PC_int,
                    Instr_int, Instr_int[31:28], Instr_int[19:16], Instr_int[15:12], Instr_int[11:0], ReadData_int,
                    decoder_Op_in, decoder_Funct_in, decoder_Rd_in,
                    decoder_RegW_out, decoder_MemW_out, decoder_MemtoReg_out, decoder_ALUSrc_out, decoder_ImmSrc_out, decoder_RegSrc_out, decoder_ALUControl_out, decoder_FlagW_out, decoder_PCS_out,
                    RegWrite_raw_int, MemWrite_raw_int, PCSrc_raw_int, CondEx_int,
                    ALUResult_int, ALUFlags_int, WriteData_int,
                    debug_arm_regs_tb[0], debug_arm_regs_tb[1], debug_arm_regs_tb[2], debug_arm_regs_tb[3],
                    debug_arm_regs_tb[4], debug_arm_regs_tb[5], debug_arm_regs_tb[6], debug_arm_regs_tb[7],
                    debug_arm_regs_tb[8], debug_arm_regs_tb[9], debug_arm_regs_tb[10], debug_arm_regs_tb[11],
                    debug_arm_regs_tb[12], debug_arm_regs_tb[13], debug_arm_regs_tb[14], debug_arm_regs_tb[15],
                    external_q_b, external_address);

        #10;

        $display("\n--- Prueba 1: Reinicio del Sistema ---");
        rst = 1;
        #10;
        rst = 0;
        #10;

        $display("\n--- Prueba 2: Ejecutar Programa de Ejemplo (100 ciclos) ---");
        for (int i = 0; i < 100; i++) begin
            #10;
        end

        $display("\n--- Prueba 3: Lectura de RAM Externa en direccion 8 ---");
        external_address = 32'd8;
        #10;
        $display("Esperado RAM_q_b en direccion 8: 8'h05");
        $display("Obtenido RAM_q_b en direccion %h: %h", external_address, external_q_b);

        $display("\n--- Fin de la Simulacion ---");
        #10;
        $finish;
    end

endmodule