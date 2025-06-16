module computer_top (
    input  logic        clk,
    input  logic        reset
);

    logic [31:0] WriteData, DataAdrA;
    logic MemWriteEnable;
    logic [31:0] PC = 32'd0;
    logic [31:0] Instr, ReadDataA;

    // ARM
    arm arm(
        .clk(clk), 
        .reset(reset), 
        .PC(PC), 
        .Instr(Instr), 
        .MemWrite(MemWriteEnable), 
        .ALUResult(DataAdrA), 
        .WriteData(WriteData), 
        .ReadData(ReadDataA)
    );
                
    // IMEN
    imem imem(
        .a(PC), 
        .rd(Instr)
    );
    
    // DMEM
	 
	 dmem dmem(clk_25Mhz, 
				 DataAdrA, DataAdrB, 
				 WriteData, MemWriteEnable,
				 ReadDataA, ReadDataB);

endmodule