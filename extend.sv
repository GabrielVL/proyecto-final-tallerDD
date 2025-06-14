module extend (
    input  logic [23:0] Instr,
    input  logic [1:0]  ImmSrc,
    output logic [31:0] ExtImm
);
    always_comb begin
        case (ImmSrc)
            2'b00: ExtImm = {{24{Instr[7]}}, Instr[7:0]}; // 8-bit immediate
            2'b01: ExtImm = {{20{Instr[11]}}, Instr[11:0]}; // 12-bit immediate
            2'b10: ExtImm = {{6{Instr[23]}}, Instr[23:0], 2'b00}; // Branch offset
            default: ExtImm = 32'h00000000;
        endcase
    end
endmodule