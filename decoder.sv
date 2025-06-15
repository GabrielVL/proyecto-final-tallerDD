module decoder(
	input logic [1:0] Op,
	input logic [5:0] Funct,
	input logic [3:0] Rd,
	input logic [31:0] Instr_full,

	output logic [1:0] FlagW,
	output logic PCS, RegW, MemW,
	output logic MemtoReg, ALUSrc,
	output logic [1:0] ImmSrc, RegSrc, ALUControl
);

	logic [9:0] controls;
	logic Branch, ALUOp;

	always_comb begin
		casex(Op)
			2'b00: begin
				if(Funct[5]) controls = 10'b0000101001;
				else controls = 10'b0000001001;
			end

			2'b01: begin
				if(Funct[0]) begin
					controls = 10'b0001111001;
				end else begin
					controls = 10'b1001100101;
				end
			end

			2'b10: controls = 10'b0110100010;

			default: controls = 10'b0000000000;
		endcase
	end

	assign {RegSrc, ImmSrc, ALUSrc, MemtoReg, RegW, MemW, Branch, ALUOp} = controls;

	always_comb begin
		if (ALUOp) begin
			if (Op == 2'b01) begin
				ALUControl = 2'b00;
				FlagW = 2'b00;
			end else begin
				case(Funct[4:1])
					4'b0100: ALUControl = 2'b00;
					4'b0010: ALUControl = 2'b01;
					4'b0000: ALUControl = 2'b10;
					4'b1100: ALUControl = 2'b11;
					4'b1010: ALUControl = 2'b00;
					default: ALUControl = 2'b00;
				endcase
				
				FlagW = {2{Funct[5]}};
			end
		end else begin
			ALUControl = 2'b00;
			FlagW = 2'b00;
		end
	end

	assign PCS = ((Rd == 4'b1111) & RegW) | Branch;

endmodule