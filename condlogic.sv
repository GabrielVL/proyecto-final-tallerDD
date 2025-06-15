module condlogic(
	input logic clk, rst,
	input logic [3:0] Cond,
	input logic [3:0] ALUFlags,
	input logic [1:0] FlagW,
	input logic PCS, RegW, MemW,
	output logic PCSrc, RegWrite, MemWrite
);

	logic [1:0] FlagWrite;
	logic [3:0] Flags;
	logic CondEx;

	assign FlagWrite = FlagW;

	flopenr #(2) flagreg1(
		.clk(clk),
		.rst(rst),
		.en(FlagWrite[1]),
		.d(ALUFlags[3:2]),
		.q(Flags[3:2])
	);

	flopenr #(2) flagreg0(
		.clk(clk),
		.rst(rst),
		.en(FlagWrite[0]),
		.d(ALUFlags[1:0]),
		.q(Flags[1:0])
	);
	
	//condcheck
	condcheck cc(
		.Cond(Cond),
		.Flags(Flags),
		.CondEx(CondEx)
	);

	assign RegWrite = RegW & CondEx;
	assign MemWrite = MemW & CondEx;
	assign PCSrc = PCS & CondEx;
endmodule