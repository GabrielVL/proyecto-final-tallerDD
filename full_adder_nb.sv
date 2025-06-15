module full_adder_nb #(
	// numero de bits (4 por defecto)
	parameter n = 4 
)(
	// parametros de entrada
	input wire [n-1:0] a,
	input wire [n-1:0] b,
	input wire Cin,
	// parametros de salida
	output wire [n-1:0] Sum,
	output wire Cout
);

// conexiones intermedias para los carry, (Cin - Cout)
wire [n:0] Carry;
assign Carry[0] = Cin;

// instancias de sumador de 1 bit  y conectarlas en cadena
genvar i;
generate 
	for (i = 0; i < n; i += 1) begin : gen_adder
		// asignacion de cada entrada y salida de instancias de full_adder_1b
		full_adder_1b adder(
			.a(a[i]),
			.b(b[i]),
			.Cin(Carry[i]),
			.Sum(Sum[i]),
			.Cout(Carry[i+1])
		);
	
	end
endgenerate

assign Cout = Carry[n];

endmodule