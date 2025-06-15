module datapath(
	 input logic clk,rst,
	 input logic [1:0] RegSrc,
	 input logic RegWrite,
	 input logic [1:0] ImmSrc,
	 input logic ALUSrc,
	 input logic [1:0] ALUControl,
	 input logic MemtoReg,
	 input logic PCSrc,
	 input logic [31:0] ReadData,
	 input logic [31:0] Instr,
	 output logic [3:0] ALUFlags,
	 output logic [31:0] PC,
	 output logic [31:0] ALUResult,WriteData,
	 output logic [31:0] debug_datapath_regs [15:0]
);
	
	 logic [31:0] PCNext,PCPlus4,PCPlus8;
	 logic [31:0] ExtImm,SrcA,SrcB,Result;
	 logic [3:0] RA1,RA2;

	 logic CondEx_internal;
	 logic [31:0] BranchTarget;
	 logic RegWrite_gated;
	 logic MemtoReg_gated;
	 logic PCSrc_gated;
	
	 adder #(32) branch_adder(PCPlus8, ExtImm, BranchTarget);
	
	 mux2 #(32) pcmux(PCPlus4, BranchTarget, PCSrc_gated, PCNext);
	 flopr #(32) pcreg(clk,rst,PCNext,PC);
	 adder #(32) pcadd1(PC,32'd4,PCPlus4);
	 adder #(32) pcadd2(PCPlus4,32'd4,PCPlus8);

	 mux2 #(4) ra1mux(Instr[19:16],4'b1111,RegSrc[0],RA1);
	 mux2 #(4) ra2mux(Instr[3:0],Instr[15:12],RegSrc[1],RA2);
	
	 regfile rf(
	 .clk(clk),
	 .rst(rst),
	 .we3(RegWrite_gated),
	 .ra1(RA1),
	 .ra2(RA2),
	 .wa3(Instr[15:12]),
	 .wd3(Result),
	 .r15(PCPlus8),
	 .rd1(SrcA),
	 .rd2(WriteData),
	 .debug_regs(debug_datapath_regs)
	);
	
	 mux2 #(32)resmux(ALUResult,ReadData,MemtoReg_gated,Result);
	
	 extend ext(
	 .Instr(Instr[23:0]),
	 .ImmSrc(ImmSrc),
	 .ExtImm(ExtImm)
	);
	
	 mux2 #(32) srcbmux(WriteData, ExtImm, ALUSrc, SrcB);
	
alu #(32) alu(
	.a(SrcA),
	.b(SrcB),
	.ALUControl(ALUControl),
	.ALUResult(ALUResult),
	.ALUFlags(ALUFlags)
	);

	 condcheck cc_inst (
		.Cond(Instr[31:28]),
		.Flags(ALUFlags),
		.CondEx(CondEx_internal)
	 );

	 assign RegWrite_gated = RegWrite & CondEx_internal;
	 assign MemtoReg_gated = MemtoReg & CondEx_internal;
	 assign PCSrc_gated = PCSrc & CondEx_internal;
	
endmodule