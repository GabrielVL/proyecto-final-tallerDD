module full_subtractor_1b(
	// parámetros de entrada
	input wire a,
	input wire b,
	input wire Cin,
	// parámetros de salida
	output wire Result,
	output wire Cout
);

// asignación de resta de salida
assign Result = (a ^ b) ^ Cin;

// asignación del carry de salida
assign Cout = (~a & b) | ((~a ^ b) & Cin);

endmodule