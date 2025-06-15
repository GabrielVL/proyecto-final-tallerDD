module controller_tb;

    // Inputs to the controller module
    reg clk;
    reg rst;
    reg [31:0] Instr;    // Full 32-bit instruction (corrected size)
    reg [3:0] ALUFlags; // Flags from ALU (N, Z, C, V)

    // Outputs from the controller module
    wire [1:0] RegSrc;
    wire RegWrite;
    wire [1:0] ImmSrc;
    wire ALUSrc;
    wire [1:0] ALUControl;
    wire MemWrite;
    wire MemtoReg;
    wire PCSrc;

    // Internal signals for monitoring (connecting to wires inside DUT)
    // These help in debugging by exposing intermediate signals from sub-modules
    wire [1:0] FlagW_int;   // FlagW signal from decoder to condlogic
    wire PCS_int;           // PCS signal from decoder to condlogic
    wire RegW_int;          // RegW signal from decoder to condlogic
    wire MemW_int;          // MemW signal from decoder to condlogic
    wire [3:0] Flags_int;   // Flags stored in condlogic's internal flip-flops
    wire CondEx_int;        // Conditional Execution result from condlogic's condcheck

    // Instantiate the Unit Under Test (DUT)
    controller dut (
        .clk(clk),
        .rst(rst),
        .Instr(Instr),
        .ALUFlags(ALUFlags),
        .RegSrc(RegSrc),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .ALUControl(ALUControl),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .PCSrc(PCSrc)
    );

    // Connect internal wires for monitoring
    // Accessing internal signals of hierarchical modules (dut.FlagW, dut.cl.Flags, etc.)
    assign FlagW_int = dut.FlagW;
    assign PCS_int = dut.PCS;
    assign RegW_int = dut.RegW;
    assign MemW_int = dut.MemW;
    assign Flags_int = dut.cl.Flags;     // Access 'Flags' inside 'condlogic' instance 'cl'
    assign CondEx_int = dut.cl.CondEx;   // Access 'CondEx' inside 'condlogic' instance 'cl'

    // Clock Generator: Creates a 10ns period clock (5ns high, 5ns low)
    always #5 clk = ~clk;

    // Initial Block for Test Scenarios
    initial begin
        // Initialize all inputs to a known state
        clk = 0;
        rst = 0;
        Instr = 32'b0;      // Default instruction to all zeros
        ALUFlags = 4'b0000; // Default ALU flags to all zeros

        // Configure monitoring of key signals for comprehensive debugging
        // Displays inputs, intermediate signals from decoder/condlogic, and final outputs
        $monitor("Time=%0t clk=%b rst=%b Instr=%h Cond(Instr[31:28])=%b Op(Instr[27:26])=%b Funct(Instr[25:20])=%b Rd(Instr[15:12])=%b ALUFlags=%b | FlagW_dec=%b PCS_dec=%b RegW_dec=%b MemW_dec=%b MemtoReg_dec=%b ALUSrc_dec=%b ImmSrc_dec=%b RegSrc_dec=%b ALUControl_dec=%b | Flags_cond=%b CondEx_cond=%b | PCSrc_final=%b RegWrite_final=%b MemWrite_final=%b",
                 $time, clk, rst, Instr, Instr[31:28], Instr[27:26], Instr[25:20], Instr[15:12], ALUFlags,
                 FlagW_int, PCS_int, RegW_int, MemW_int, MemtoReg, ALUSrc, ImmSrc, RegSrc, ALUControl,
                 Flags_int, CondEx_int,
                 PCSrc, RegWrite, MemWrite);

        #10; // Allow initial values to propagate through combinatorial logic

        // --- Test 1: Reset Behavior ---
        $display("\n--- Test 1: Reset Behavior ---");
        rst = 1; // Assert reset
        // Change inputs during reset to verify they don't affect outputs (due to asynchronous reset)
        Instr = 32'hFFFFFFFF;
        ALUFlags = 4'b1111;
        #10; // Wait during reset
        rst = 0; // De-assert reset
        #10; // Wait one more clock cycle for flip-flops (like Flags_int) to update after reset removal

        // --- Test 2: Data Processing (ADD, no S bit) - AL (Always) ---
        // This test still verifies AL condition and RegWrite. Flags_int won't change here (FlagW_dec=00).
        $display("\n--- Test 2: ADD (no S) - AL (Always) ---");
        // Instr: {Cond=AL(1110), Op=DP(00), Funct=ADD_noS(001000), Rn=R0, Rd=R0, Imm/Rm=0}
        Instr = {4'b1110, 2'b00, 6'b001000, 4'h0, 4'h0, 12'h000};
        ALUFlags = 4'b0000;
        #10;
        #10;

        // --- Test 2a: Set Initial Flags (AL + S-bit) ---
        // This test is CRITICAL to set Flags_int to a known state for subsequent conditional tests.
        // Instr: {Cond=AL(1110), Op=DP(00), Funct=SUB_S(100100), Rn=R0, Rd=R0, Imm/Rm=0}
        // ALUFlags: Set to 4'b0100 (Z=1, NCV=0). This should make Flags_int = 0100
        $display("\n--- Test 2a: Set Initial Flags (AL + S-bit) ---");
        Instr = {4'b1110, 2'b00, 6'b100100, 4'h0, 4'h0, 12'h000}; // Cond=AL, Funct=SUB_S (has S-bit)
        ALUFlags = 4'b0100; // Simulate result with Z=1
        #10; // CondEx_cond=1 (due to AL), FlagW_dec=11 (due to S-bit). Flags_int should update on next posedge clk.
        #10; // Flags_int should now be 0100
        // Now, Flags_int is 0100 (Z=1). We can use this for conditional tests.

        // --- Test 3: Data Processing (SUB, with S bit) - EQ (Equal) - Z=1 (Condition TRUE) ---
        // Instruction: Cond=EQ(0000), Op=DP(00), Funct=SUB_S(100100), Rd=R0(0000)
        // ALUFlags: Z=1 (e.g., 4'b0100)
        // Expected condlogic: Flags_int is 0100 (from Test 2a), CondEx=1 (EQ=True). RegWrite_final=1, MemWrite_final=0, PCSrc_final=0
        $display("\n--- Test 3: SUB (S) - EQ (Z=1, Condition TRUE) ---");
        Instr = {4'b0000, 2'b00, 6'b100100, 4'h0, 4'h0, 12'h000}; // Cond=EQ, Funct=SUB_S
        ALUFlags = 4'b0000; // ALUFlags won't affect Flags_int here (FlagW_dec=11 but CondEx is based on CURRENT Flags)
        #10; // CondEx_cond should be 1. RegWrite_final should be 1. Flags_int should *still* be 0100.
        #10; // Propagate final outputs

        // --- Test 4: Data Processing (SUB, with S bit) - EQ (Equal) - Z=0 (Condition FALSE) ---
        // Same Instr, but ALUFlags state (Flags_int) should trigger CondEx=0
        // To make Flags_int.zero=0, we need another AL+S-bit instruction.
        $display("\n--- Test 4: Set Flags_int to Z=0 and Test EQ (Condition FALSE) ---");
        // First, set Flags_int to 0000 (Z=0)
        Instr = {4'b1110, 2'b00, 6'b100100, 4'h0, 4'h0, 12'h000}; // Cond=AL, Funct=SUB_S
        ALUFlags = 4'b0000; // Simulate result with Z=0
        #10;
        #10; // Flags_int should now be 0000 (Z=0)
        // Now, test EQ condition with Z=0 (false)
        Instr = {4'b0000, 2'b00, 6'b100100, 4'h0, 4'h0, 12'h000}; // Cond=EQ, Funct=SUB_S
        ALUFlags = 4'b0100; // ALUFlags doesn't matter here for CondEx evaluation
        #10; // CondEx_cond should be 0. RegWrite_final should be 0. Flags_int should *still* be 0000.
        #10;

        // --- Test 5: LDR - NE (Not Equal) - Z=0 (Condition TRUE) ---
        // First, ensure Flags_int.zero = 0 (it is from Test 4)
        // Instr: {Cond=NE(0001), Op=LDR/STR(01), Funct=LDR(000001), Rd=R0(0000)}
        // Expected condlogic: Flags_int.zero=0, CondEx=1. RegWrite_final=1, MemWrite_final=0, PCSrc_final=0
        $display("\n--- Test 5: LDR - NE (Z=0, Condition TRUE) ---");
        Instr = {4'b0001, 2'b01, 6'b000001, 4'h0, 4'h0, 12'h000}; // Cond=NE, Op=LDR, Funct=LDR
        ALUFlags = 4'b0000; // ALUFlags won't affect Flags_int here as FlagW_dec is 00 for LDR
        #10; // CondEx_cond should be 1. RegWrite_final should be 1.
        #10;

        // --- Test 6: STR - AL (Always) ---
        // Instr: {Cond=AL(1110), Op=LDR/STR(01), Funct=STR(000000), Rd=R0(0000)}
        // Expected condlogic: CondEx=1. RegWrite_final=0, MemWrite_final=1, PCSrc_final=0
        $display("\n--- Test 6: STR - AL (Always) ---");
        Instr = {4'b1110, 2'b01, 6'b000000, 4'h0, 4'h0, 12'h000}; // Cond=AL, Op=STR, Funct=STR
        #10; // CondEx_cond should be 1. MemWrite_final should be 1.
        #10;

        // --- Test 7: Branch (B) - AL (Always) ---
        // Instr: {Cond=AL(1110), Op=B(10), Funct=0(000000), Rd=0(0000)}
        // Expected condlogic: CondEx=1. PCSrc_final=1, RegWrite_final=0, MemWrite_final=0
        $display("\n--- Test 7: Branch - AL (Always) ---");
        Instr = {4'b1110, 2'b10, 6'b000000, 4'h0, 4'h0, 12'h000}; // Cond=AL, Op=B
        #10; // CondEx_cond should be 1. PCSrc_final should be 1.
        #10;

        // --- Test 8: Branch (B) - EQ (Z=0, Condition FALSE) ---
        // First, ensure Flags_int.zero=0 (it is from Test 4, and no S-bit instructions have changed it since)
        // Instr: {Cond=EQ(0000), Op=B(10), Funct=0(000000), Rd=0(0000)}
        // Expected condlogic: Flags_int.zero=0, CondEx=0. PCSrc_final=0, RegWrite_final=0, MemWrite_final=0
        $display("\n--- Test 8: Branch - EQ (Z=0, Condition FALSE) ---");
        Instr = {4'b0000, 2'b10, 6'b000000, 4'h0, 4'h0, 12'h000}; // Cond=EQ, Op=B
        ALUFlags = 4'b0000; // ALUFlags value doesn't affect CondEx directly here
        #10; // CondEx_cond should be 0. PCSrc_final should be 0.
        #10;

        // --- Test 9: Unimplemented Op - AL (Always) ---
        // Instr: {Cond=AL(1110), Op=Unimplemented(11), Funct=0(000000), Rd=0(0000)}
        // Expected decoder: All control signals from decoder are 0.
        // Expected condlogic: CondEx=1 (AL). Final outputs are 0 (because RegW_dec, MemW_dec, PCS_dec are 0)
        $display("\n--- Test 9: Unimplemented Op - AL (Always) ---");
        Instr = {4'b1110, 2'b11, 6'b000000, 4'h0, 4'h0, 12'h000}; // Cond=AL, Op=Unimplemented
        #10;
        #10;

        // --- End of Simulation ---
        $display("\n--- End of Simulation ---");
        #10;
        $finish; // Terminate the simulation
    end

endmodule
