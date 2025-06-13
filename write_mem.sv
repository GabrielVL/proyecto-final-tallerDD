module write_mem(input[2:0] btn,
					  output enable,
					  output [31:0] addr,
					  output [31:0] data
		);
		
	always @ (btn) begin

		case(btn)
		
			3'b110:begin
				enable = 1'b1;
				addr = 7'd6;
				data = 7'd9;
			end
			
			3'b101:begin
				enable = 1'b1;
				addr = 7'b0;
				data = 7'd8;
			end
			
			default: begin
				enable = 1'b0;
				addr = 7'b0;
				data = 7'd9;
			end
			
		endcase
	end
	
endmodule