module alu (
    input  logic [31:0] a, b,
    input  logic [2:0]  ALUControl,
    output logic [31:0] Result,
    output logic [3:0]  ALUFlags
);
    logic neg, zero, carry, overflow;
    
    always_comb begin
        // Default assignments to prevent latches
        Result = 32'h00000000;
        carry = 1'b0;
        overflow = 1'b0;
        
        case (ALUControl)
            3'b000: begin // ADD
                {carry, Result} = a + b;
                overflow = (a[31] == b[31] && Result[31] != a[31]);
            end
            3'b001: begin // SUB
                {carry, Result} = a - b;
                overflow = (a[31] == ~b[31] && Result[31] != a[31]);
            end
            3'b010: begin // AND
                Result = a & b;
                carry = 1'b0;
                overflow = 1'b0;
            end
            3'b011: begin // OR
                Result = a | b;
                carry = 1'b0;
                overflow = 1'b0;
            end
            3'b100: begin // XOR
                Result = a ^ b;
                carry = 1'b0;
                overflow = 1'b0;
            end
            default: begin
                Result = 32'h00000000;
                carry = 1'b0;
                overflow = 1'b0;
            end
        endcase
        
        neg = Result[31];
        zero = (Result == 32'h0);
    end
    
    assign ALUFlags = {neg, zero, carry, overflow};
endmodule