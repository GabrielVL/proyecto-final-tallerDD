module counter #(parameter N = 8) (
	input logic clk, rst, en,
	output logic [N-1:0] Q);
	
	always_ff @ (negedge clk or posedge rst)
		if (rst) 
			Q = 8'h00;
		else
			if (en)
				Q = Q + 1'b1;
endmodule
		
		