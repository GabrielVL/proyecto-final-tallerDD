module full_subtractor_nb #(
    // número de bits (4 por defecto)
    parameter n = 4
)(
    // parámetros de entrada
    input wire [n-1:0] a,
    input wire [n-1:0] b,
    input wire Cin,
    // parámetros de salida
    output wire [n-1:0] Result,
    output wire Cout
);

// conexiones intermedias para los carry, (Cin - Cout)
wire [n:0] Borrow;
assign Borrow[0] = Cin;

// instancias de restador de 1 bit y conectarlas en cadena
genvar i;
generate 
    for (i = 0; i < n; i += 1) begin : gen_subtractor
        // asignación de cada entrada y salida de instancias de full_res_1b
        full_subtractor_1b subtractor(
            .a(a[i]),
            .b(b[i]),
            .Cin(Borrow[i]),
            .Result(Result[i]),
            .Cout(Borrow[i+1])
        );
    
    end
endgenerate

assign Cout = Borrow[n];

endmodule