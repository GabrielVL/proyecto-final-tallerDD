module regfile #(
	parameter WIDTH = 32,
	parameter LOG2_NUM_REGS = 4
) (
	input logic clk, rst, we3,
	input logic [LOG2_NUM_REGS-1:0] ra1, ra2, wa3,
	input logic [WIDTH-1:0] wd3, r15,
	output logic [WIDTH-1:0] rd1, rd2,
	output logic [WIDTH-1:0] debug_regs [2**LOG2_NUM_REGS-1:0]
);

	reg [WIDTH-1:0] regs [2**LOG2_NUM_REGS-1:0];

	integer i;
	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			for (i = 0; i < 2**LOG2_NUM_REGS; i = i + 1) begin
				regs[i] <= {WIDTH{1'b0}};
			end
		end else if (we3) begin
			regs[wa3] <= wd3;
		end
	end

	assign rd1 = (ra1 == 4'b1111) ? r15 : regs[ra1];
	assign rd2 = (ra2 == 4'b1111) ? r15 : regs[ra2];

	generate
		genvar j;
		for (j = 0; j < 2**LOG2_NUM_REGS; j = j + 1) begin : reg_debug_assign_gen
			assign debug_regs[j] = regs[j];
		end
	endgenerate

endmodule