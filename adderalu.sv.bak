module adderalu #(parameter N = 8)              // Parametrización: N define el ancho de los operandos (default: 8 bits)
    (
     input logic [N-1:0] a, b,                  // Entradas: dos números de N bits para sumar
     input logic cin,                           // Acarreo entrante
     output logic [N-1:0] s,                    // Salida: suma de los operandos
     output logic cout                          // Acarreo saliente
    );

   // Suma con acarreo
   assign {cout, s} = a + b + cin;              // Concatenación para capturar el acarreo saliente (cout) y el resultado (s)

endmodule
