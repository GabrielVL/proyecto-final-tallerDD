module decoder (
    input  logic [1:0]  Op,
    input  logic [5:0]  Funct,
    input  logic [3:0]  Rd,
    output logic [1:0]  FlagW,
    output logic        PCS, RegW, MemW,
    output logic        MemtoReg, ALUSrc,
    output logic [1:0]  ImmSrc, RegSrc, ALUControl
);
    logic       Branch, ALUOp;

    // Main Decoder
    always_comb begin
        case (Op)
            2'b00: begin // Data processing
                Branch = 0;
                MemtoReg = 0;
                MemW = 0;
                ALUSrc = ~Funct[5]; // Immediate or register
                ALUOp = 1;
                RegW = ~Funct[0]; // Most instructions write except CMP
                RegSrc = 2'b00;
                ImmSrc = Funct[5] ? 2'b10 : 2'b00; // 12-bit or 8-bit immediate
            end
            2'b01: begin // Load/Store
                Branch = 0;
                MemtoReg = ~Funct[0]; // LDR
                MemW = Funct[0];      // STR
                ALUSrc = 1;           // Immediate offset
                ALUOp = 0;            // Add for address
                RegW = ~Funct[0];     // LDR writes
                RegSrc = Funct[0] ? 2'b10 : 2'b00; // STR uses Rd as source
                ImmSrc = 2'b01;
            end
            2'b10: begin // Branch
                Branch = 1;
                MemtoReg = 0;
                MemW = 0;
                ALUSrc = 0;
                ALUOp = 0;
                RegW = 0;
                RegSrc = 2'b00;
                ImmSrc = 2'b10; // 24-bit branch offset
            end
            default: begin
                Branch = 0;
                MemtoReg = 0;
                MemW = 0;
                ALUSrc = 0;
                ALUOp = 0;
                RegW = 0;
                RegSrc = 2'b00;
                ImmSrc = 2'b00;
            end
        endcase
    end

    // ALU Decoder
    always_comb begin
        if (ALUOp) begin
            case (Funct[4:1])
                4'b0100: ALUControl = 2'b00; // ADD
                4'b0010: ALUControl = 2'b01; // SUB
                4'b0000: ALUControl = 2'b10; // AND
                4'b1100: ALUControl = 2'b11; // ORR
                default: ALUControl = 2'b00;
            endcase
            FlagW = (Funct[0] == 1'b1) ? 2'b11 : 2'b00; // Update flags for CMP
        end else begin
            ALUControl = 2'b00; // ADD for load/store address
            FlagW = 2'b00;
        end
    end

    // PC Write Enable
    assign PCS = ((Rd == 4'd15) & RegW) | Branch;

endmodule