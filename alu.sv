module alu (
    input  logic [31:0] a, b,
    input  logic [1:0]  ALUControl,
    output logic [31:0] Result,
    output logic [3:0]  ALUFlags
);
    logic        neg, zero, carry, overflow;
    logic [31:0] condinvb;
    logic [32:0] sum;

    // Conditional inversion for subtraction
    assign condinvb = ALUControl[0] ? ~b : b;
    assign sum = a + condinvb + ALUControl[0];

    // Result selection
    always_comb begin
        case (ALUControl)
            2'b00: Result = sum;        // ADD
            2'b01: Result = sum;        // SUB
            2'b10: Result = a & b;      // AND
            2'b11: Result = a | b;      // ORR
            default: Result = sum;
        endcase
    end

    // Flags: NZCV (Negative, Zero, Carry, Overflow)
    assign neg = Result[31];
    assign zero = (Result == 32'b0);
    assign carry = (ALUControl[1] == 1'b0) & sum[32];
    assign overflow = (ALUControl[1] == 1'b0) & (a[31] == b[31]) & (Result[31] != a[31]);
    assign ALUFlags = {neg, zero, carry, overflow};

endmodule