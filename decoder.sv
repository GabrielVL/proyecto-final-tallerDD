module decoder (
    input  logic [31:0] FullInstr,
    output logic [1:0]  RegSrc,
    output logic [1:0]  ImmSrc,
    output logic        MemtoReg,
    output logic        ALUSrc,
    output logic        RegWrite,
    output logic        MemWrite,
    output logic [2:0]  ALUControl,
    output logic        PCS,
    output logic        PCS_ALU_SrcA,
    output logic [1:0]  FlagW
);
    logic [1:0] Op;
    logic [5:0] Funct;
    logic [3:0] Rd;

    assign Op = FullInstr[27:26];
    assign Funct = FullInstr[25:20];
    assign Rd = FullInstr[15:12];

    always_comb begin
        RegSrc = 2'b00;
        ImmSrc = 2'b00;
        MemtoReg = 1'b0;
        ALUSrc = 1'b0;
        RegWrite = 1'b0;
        MemWrite = 1'b0;
        ALUControl = 3'b000;
        PCS = 1'b0;
        PCS_ALU_SrcA = 1'b0;
        FlagW = 2'b00;

        case (Op)
            2'b00: begin // Data processing
                if (Funct[5] == 1'b0) begin
                    case (Funct[4:1])
                        4'b1100: begin // ORR
                            ALUControl = 3'b110;
                            RegWrite = 1;
                            FlagW = Funct[0] ? 2'b11 : 2'b00;
                        end
                        default: begin
                            ALUControl = 3'b000; // Default ADD
                            RegWrite = 1;
                            FlagW = Funct[0] ? 2'b11 : 2'b00;
                        end
                    endcase
                    ALUSrc = Funct[5];
                end
            end
            2'b01: begin // Load/Store
                ALUSrc = ~Funct[5]; // I=0 for register offset
                ALUControl = 3'b001; // SUB for address calculation
                if (Funct[5] == 1) begin // Immediate offset
                    ImmSrc = 2'b01;
                end else begin // Register offset
                    ImmSrc = 2'b00;
                end
                if (Funct[0] == 1) begin // LDR
                    MemtoReg = 1;
                    RegWrite = 1;
                end else begin // STR
                    MemWrite = 1;
                    RegWrite = 0;
                end
            end
            2'b10: begin // Branch
                ImmSrc = 2'b10;
                ALUSrc = 1;
                PCS = 1;
                PCS_ALU_SrcA = 1;
            end
            default: begin
                RegWrite = 0;
                MemWrite = 0;
            end
        endcase
    end
endmodule