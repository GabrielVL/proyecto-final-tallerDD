module shift (
    input  logic [31:0] a,
    input  logic [7:0]  shamt,
    input  logic [1:0]  sh,    
    output logic [31:0] y
);
    always_comb
        case (sh)
            2'b00: y = a << shamt;  
            2'b01: y = a >> shamt;  
            2'b10: y = $signed(a) >>> shamt; 
            2'b11: y = (a >> shamt) | (a << (32 - shamt)); 
            default: y = a;
        endcase
endmodule