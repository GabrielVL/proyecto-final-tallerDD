module dmem(input logic clk,
				input logic [31:0] a, b, wd_a,
				input logic we_a,
				output logic [31:0] rd_a, rd_b);
				
	
	logic [16:0] _a;
	
	always_comb begin
		if(a[18:2] < 0 | a[18:2] >= 70000) _a = 17'd_0;
		else _a = a[18:2];
	end
	
	logic [31:0] wd_b = 32'd_0;
	logic we_b = 0;
	
	ram iram(_a, b[16:0],
				 clk, 
				 wd_a, wd_b, 
				 we_a, we_b,
				 rd_a, rd_b);
	
		
endmodule
