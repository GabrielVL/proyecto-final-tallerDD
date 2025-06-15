module full_adder_1b(
	// parametros de entrada
	input wire a,
	input wire b,
	input wire Cin,
	// parametros de salida
	output wire Sum,
	output wire Cout
);

// asiganacion de suma de salida
assign Sum = (a ^ b) ^ Cin;

// asignacion del carry de salida
assign Cout = (a & b) | ((a ^ b) & Cin);

endmodule