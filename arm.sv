module arm (
    input  logic        clk, reset,
    input  logic [31:0] Instr, // Instr is an INPUT to arm.sv (comes from ROM)
    output logic [31:0] ReadData,
    output logic [31:0] WriteData,
    output logic [31:0] DataAdr,
    output logic        MemWrite, // This MemWrite will be driven by condlogic's MemWrite_final
    output logic [31:0] PC // PC is an output from arm.sv
);

    logic [31:0]      ALUResult;
    logic [3:0]       ALUFlags;
    logic             MemtoReg_from_decoder, ALUSrc_from_decoder, PCSrc_final, Stall_final;
    logic [1:0]       RegSrc, ImmSrc;
    logic [2:0]       ALUControl;
    logic             PCS_ALU_SrcA; // Control for SrcA mux in datapath
    logic [3:0]       Cond;
    logic [1:0]       FlagW;

    // Internal wires for control signals from decoder to condlogic
    logic             RegWrite_from_decoder;
    logic             MemWrite_from_decoder;
    logic             PCS_from_decoder; // This will connect to decoder.PCS

    // Internal wires for final control signals from condlogic to datapath
    logic             RegWrite_final; // Renamed to clearly indicate it's the final signal
    logic             MemWrite_final_for_output; // Renamed to clearly indicate it's the final signal


    // Instance of the datapath
    datapath processor (
        .clk(clk),
        .reset(reset),
        .Stall(Stall_final),
        .RegSrc(RegSrc),
        .ImmSrc(ImmSrc),
        .RegWrite(RegWrite_final), // Connect final RegWrite from condlogic
        .ALUSrc(ALUSrc_from_decoder),
        .ALUControl(ALUControl),
        .MemtoReg(MemtoReg_from_decoder),
        .PCSrc(PCSrc_final),
        .PCS_ALU_SrcA(PCS_ALU_SrcA),
        .ALUFlags(ALUFlags),
        .PC(PC),
        .ALUResult(ALUResult),
        .WriteData(WriteData),
        .Instr(Instr),
        .ReadData(ReadData)
    );

    // Instance of the decoder module
    decoder decode_unit (
        .FullInstr(Instr),
        .RegSrc(RegSrc),
        .ImmSrc(ImmSrc),
        .MemtoReg(MemtoReg_from_decoder), // Decoder drives this internal wire
        .ALUSrc(ALUSrc_from_decoder),     // Decoder drives this internal wire
        .RegWrite(RegWrite_from_decoder), // Decoder drives this internal wire
        .MemWrite(MemWrite_from_decoder), // Decoder drives this internal wire
        .ALUControl(ALUControl),
        .PCS(PCS_from_decoder),           // Decoder drives this internal wire
        .PCS_ALU_SrcA(PCS_ALU_SrcA),
        .FlagW(FlagW)
    );

    // Instance of the conditional logic (controller)
    condlogic control_unit (
        .clk(clk),
        .reset(reset),
        .Cond(Instr[31:28]),
        .ALUFlags(ALUFlags),
        .FlagW(FlagW),
        .PCS_from_decoder(PCS_from_decoder),         // Input: PCS signal from decoder
        .RegW_from_decoder(RegWrite_from_decoder), // Input: RegWrite signal from decoder
        .MemW_from_decoder(MemWrite_from_decoder), // Input: MemWrite signal from decoder
        .PCSrc(PCSrc_final),                  // Output: Final PCSrc to datapath
        .RegWrite(RegWrite_final),      // Output: Final RegWrite to datapath
        .MemWrite(MemWrite_final_for_output),      // Output: Final MemWrite to mem_map
        .Stall(Stall_final)
    );

    // Connect MemWrite from condlogic to output port of arm.sv
    assign MemWrite = MemWrite_final_for_output;

    // Debugging displays for arm.sv
    always_comb begin
        $display("Time %0t: arm - Stall = %b, PCSrc (from controller) = %b, PCS_ALU_SrcA = %b", $time, Stall_final, PCSrc_final, PCS_ALU_SrcA);
        $display("Time %0t: arm - PC = %h, Instr = %h, Instr[23] = %b (received by arm)", $time, PC, Instr, Instr[23]); // Debug Instr and its bit 23
    end

endmodule
