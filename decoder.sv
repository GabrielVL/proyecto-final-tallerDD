module decoder (
    input  logic [31:0] FullInstr,
    output logic [1:0]  RegSrc, ImmSrc,
    output logic        MemtoReg, ALUSrc,
    output logic        RegWrite, MemWrite,
    output logic [2:0]  ALUControl,
    output logic [1:0]  FlagW,
    output logic        PCS,          // Primary PCS (Branch) signal for conditional logic
    output logic        PCS_ALU_SrcA  // Control for SrcA mux in Datapath for PC+8
    // Removed Branch_internal from outputs, PCS will serve this purpose for the controller
);

    logic [1:0] Op;       // Bits 27:26
    logic [5:0] Funct;    // Bits 25:20 for Data Processing, Bits 25:24 for Load/Store, Bits 25:24 for Branch (unused Funct for Branch)
    logic [3:0] Rd;       // Bits 15:12 for destination register

    assign Op    = FullInstr[27:26];
    assign Funct = FullInstr[25:20];
    assign Rd    = FullInstr[15:12];

    always_comb begin
        RegSrc        = 2'b00;
        ImmSrc        = 2'b00;
        MemtoReg      = 1'b0;
        ALUSrc        = 1'b0;
        RegWrite      = 1'b0;
        MemWrite      = 1'b0;
        ALUControl    = 3'b000; // Default to ADD for safety
        PCS           = 1'b0;
        FlagW         = 2'b00; // Default to no flag write
        PCS_ALU_SrcA  = 1'b0;

        case (Op)
            2'b00: begin // Data Processing / MRS / MSR (Check bit 4 for immediate)
                case (FullInstr[4])
                    1'b0: begin // Data Processing Register (Operand2 is Reg)
                        ALUSrc = 1'b0; // Use WriteData (shifted Rm)
                    end
                    1'b1: begin // Data Processing Immediate (Operand2 is Immediate)
                        ALUSrc = 1'b1; // Use ExtImm
                    end
                endcase

                RegWrite = 1'b1; // Default to register write for DP instructions
                ImmSrc = (FullInstr[25] == 1'b1) ? 2'b00 : 2'b00; // Placeholder for Data Processing Immediate
                                                              // Your extend.sv uses ImmSrc=00 for 8-bit rotated immediate

                // Determine ALU operation based on Funct (bits 24:21)
                case (Funct[4:1]) // Bits 24:21 of instruction
                    4'b0000: ALUControl = 3'b000; // AND
                    4'b0001: ALUControl = 3'b001; // EOR
                    4'b0010: ALUControl = 3'b010; // SUB
                    4'b0011: ALUControl = 3'b010; // RSB (Using 010 for RSB based on your ALU, typically 011 for RSB)
                    4'b0100: ALUControl = 3'b011; // ADD
                    4'b0101: ALUControl = 3'b100; // ADC
                    4'b0110: ALUControl = 3'b101; // SBC
                    4'b0111: ALUControl = 3'b110; // RSC
                    4'b1000: ALUControl = 3'b111; // TST (sets flags, no Rd write)
                    4'b1001: ALUControl = 3'b111; // TEQ (sets flags, no Rd write)
                    4'b1010: ALUControl = 3'b010; // CMP (sets flags, no Rd write)
                    4'b1011: ALUControl = 3'b011; // CMN (sets flags, no Rd write)
                    4'b1100: ALUControl = 3'b000; // ORR
                    4'b1101: ALUControl = 3'b001; // MOV (pseudo-op, often handled by ORR with 0 or ADD with 0)
                    4'b1110: ALUControl = 3'b001; // BIC
                    4'b1111: ALUControl = 3'b001; // MVN (pseudo-op, often handled by ORR with ~0 or SUB with 0)
                    default: ALUControl = 3'bXXX;
                endcase

                // Flag write control (from S bit, Instr[20]) and specific instructions
                if (FullInstr[20] == 1'b1 || Funct[4:1] == 4'b1000 || Funct[4:1] == 4'b1001 || Funct[4:1] == 4'b1010 || Funct[4:1] == 4'b1011) begin
                    FlagW = 2'b11; // Update all flags
                    if (Funct[4:1] == 4'b1000 || Funct[4:1] == 4'b1001 || Funct[4:1] == 4'b1010 || Funct[4:1] == 4'b1011) begin
                        RegWrite = 1'b0; // TST, TEQ, CMP, CMN do not write back to registers
                    end
                end else begin
                    FlagW = 2'b00; // No flag update
                end
            end
            2'b01: begin // Load/Store Word/Byte
                // Check L-bit (Load/Store bit, Instr[20])
                if (FullInstr[20] == 1'b1) begin // LDR (Load)
                    RegWrite = 1'b1;
                    MemtoReg = 1'b1; // Data from memory goes to register
                end else begin // STR (Store)
                    MemWrite = 1'b1; // Write to memory
                    RegWrite = 1'b0; // No register write for STR
                end
                ALUSrc = 1'b1; // Base register + Immediate for address calculation
                ImmSrc = 2'b01; // 12-bit immediate for Load/Store
                ALUControl = 3'b011; // ADD (to calculate memory address)
            end
            2'b10: begin // Branch (B, BL) / Branch and Exchange (BX, BLX)
                PCS = 1'b1; // PCS signal for PC update (always branch for this Opcode)
                PCS_ALU_SrcA = 1'b1; // Use PC+8 for ALU SrcA for branch address calculation
                ALUControl = 3'b000; // ADD (PC+8 + offset)
                ImmSrc = 2'b10; // 24-bit immediate for branch offset
                RegWrite = 1'b0; // No register write for simple branch
            end
            2'b11: begin // Coprocessor / SWI / Undefined
                // Handle as NOP or specific operations
                RegWrite = 1'b0;
                MemWrite = 1'b0;
                FlagW = 2'b00;
                ALUControl = 3'b000;
            end
            default: begin // Should not happen with 2-bit Op
                RegSrc = 2'bXX;
                ImmSrc = 2'bXX;
                MemtoReg = 1'bX;
                ALUSrc = 1'bX;
                RegWrite = 1'bX;
                MemWrite = 1'bX;
                ALUControl = 3'bXXX;
                PCS = 1'bX;
                PCS_ALU_SrcA = 1'bX;
                FlagW = 2'bXX;
            end
        endcase
    end

    // Debugging displays para decoder.sv
    always_comb begin
        $display("Time %0t: decoder - Op=%b, Funct=%b, Rd=%b, FullInstr=%h", $time, Op, Funct, Rd, FullInstr);
        $display("Time %0t: decoder - RegW=%b, MemW=%b, ALUSrc=%b, ImmSrc=%b", $time, RegWrite, MemWrite, ALUSrc, ImmSrc);
        $display("Time %0t: decoder - MemtoReg=%b, ALUControl=%b, FlagW=%b", $time, MemtoReg, ALUControl, FlagW);
        $display("Time %0t: decoder - PCS (final) = %b, PCS_ALU_SrcA = %b", $time, PCS, PCS_ALU_SrcA);
    end

endmodule
