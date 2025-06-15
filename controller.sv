module controller(
	input logic clk,
	input logic rst,

	input logic [31:0] Instr,
	input logic [3:0] ALUFlags,
	
	output logic [1:0] RegSrc,
	output logic RegWrite,
	output logic [1:0] ImmSrc,
	output logic ALUSrc,
	output logic [1:0] ALUControl,
	output logic MemWrite,
	output logic MemtoReg,
	output logic PCSrc
);
						
	logic [1:0] FlagW_raw;
	logic PCS_raw, RegW_raw, MemW_raw;
	
	// Instancia del decodificador (decoder)
	decoder dec(
		.Op(Instr[27:26]),
		.Funct(Instr[25:20]),
		.Rd(Instr[15:12]),
		.Instr_full(Instr),
		.FlagW(FlagW_raw),
		.PCS(PCS_raw),
		.RegW(RegW_raw),
		.MemW(MemW_raw),
		.MemtoReg(MemtoReg),
		.ALUSrc(ALUSrc),
		.ImmSrc(ImmSrc),
		.RegSrc(RegSrc),
		.ALUControl(ALUControl)
	);

	// Instancia de la logica condicional (condlogic)
	condlogic cl(
		.clk(clk),
		.rst(rst),
		.Cond(Instr[31:28]),
		.ALUFlags(ALUFlags),
		.FlagW(FlagW_raw),
		.PCS(PCS_raw),
		.RegW(RegW_raw),
		.MemW(MemW_raw),
		.PCSrc(PCSrc),
		.RegWrite(RegWrite),
		.MemWrite(MemWrite)
	);
				
endmodule
