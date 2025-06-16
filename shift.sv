module shift(input logic [31:0] i_data,
							 input logic [1:0] i_mode,
							 input logic [4:0] i_shift_count,
							 output logic [31:0] o_data);

	logic [63:0] l_shifted;
	logic [63:0] r_shifted;
	
	assign l_shifted = {i_data, i_data} << i_shift_count;
	assign r_shifted = {i_data, i_data} >> i_shift_count;

	always_comb begin
		case (i_mode)
			2'b00:
				begin
					o_data = l_shifted[31:0];				// logical left	
				end
			2'b01:
				begin
					o_data = r_shifted[63:32];				// logical right
				end
			2'b10:	
				begin							// cyclic left
					o_data = l_shifted[63:32];
				end
			2'b11:	
				begin							// cyclic right
					o_data = r_shifted[31:0];
				end
			default:
				begin
					o_data = {32{1'bx}};	// x-state, (nor 1, nor 0)
				end
		endcase
	end
endmodule
