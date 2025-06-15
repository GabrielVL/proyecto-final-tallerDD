module alu #(parameter n = 2)(
	input logic [n-1:0] a, b,
	input logic [1:0] ALUControl,
	output logic [n-1:0] ALUResult,
	output logic [3:0] ALUFlags
);

localparam [1:0] ADD = 2'b00,
                   SUB = 2'b01,
                   AND = 2'b10,
                   OR  = 2'b11;
	logic N_local, Z_local, C_local, V_local;

	wire [n-1:0] adder_result;
	wire adder_cout;
	full_adder_nb #(n) adder_inst (
		 .a(a),
		 .b(b),
		 .Cin(1'b0),
		 .Sum(adder_result),
		 .Cout(adder_cout)
	);

	wire [n-1:0] subtractor_result;
	wire subtractor_cout;
	full_subtractor_nb #(n) subtractor_inst (
		 .a(a),
		 .b(b),
		 .Cin(1'b0),
		 .Result(subtractor_result),
		 .Cout(subtractor_cout)
	);

	wire [n-1:0] multiplier_result;
	wire [n-1:0] multiplier_Overf;
	multiplier_nb #(n) multiplier_inst (
		 .a(a),
		 .b(b),
		 .Overf(multiplier_Overf),
		 .Result(multiplier_result)
	);

	always_comb begin
		ALUResult = {n{1'b0}};
		N_local = 1'b0;
		C_local = 1'b0;
		V_local = 1'b0;

		case(ALUControl)
			ADD: begin
				 ALUResult = adder_result;
				 C_local = adder_cout;
				 V_local = (a[n-1] == b[n-1]) && (adder_result[n-1] != a[n-1]);
				 N_local = ALUResult[n-1];
			end

			SUB: begin
				 ALUResult = subtractor_result;
				 C_local = ~subtractor_cout;
				 V_local = (a[n-1] ^ b[n-1]) & (a[n-1] ^ ALUResult[n-1]);
				 N_local = ALUResult[n-1];
			end

			AND: begin
				 ALUResult = a & b;
				 N_local = ALUResult[n-1];
				 C_local = 1'b0;
				 V_local = 1'b0;
			end

			OR: begin
				 ALUResult = a | b;
				 N_local = ALUResult[n-1];
				 C_local = 1'b0;
				 V_local = 1'b0;
			end

			default: ALUResult = {n{1'b0}};
		endcase

		Z_local = (ALUResult == {n{1'b0}});

	end
	assign ALUFlags = {N_local, Z_local, C_local, V_local};

endmodule