module arm (
    input  logic        clk, rst,
    input  logic [31:0] address,
    output logic [7:0]  q_b,      
        output logic [31:0] debug_arm_regs [15:0]
);

    logic [3:0] ALUFlags;
    logic RegWrite, ALUSrc, MemtoReg, PCSrc, MemWrite;
    logic [1:0] RegSrc, ImmSrc, ALUControl;
    logic [31:0] PC, Instr;
    logic [31:0] ALUResult, WriteData; 
    logic [7:0] ram_q_a; 
    logic [31:0] ReadData_from_mem; 

    logic [31:0] internal_datapath_regs [15:0];

    // Control unit
    controller controlUnit (
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

    // Datapath
    datapath dpUnit (
        .clk(clk),
        .rst(rst),
        .RegSrc(RegSrc),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .ALUControl(ALUControl),
        .MemtoReg(MemtoReg),
        .PCSrc(PCSrc),
        .ALUFlags(ALUFlags),
        .PC(PC),
        .Instr(Instr),
        .ALUResult(ALUResult),
        .WriteData(WriteData),
        .ReadData(ReadData_from_mem),
        .debug_datapath_regs(internal_datapath_regs) 
    );

    // ROM 
    rom rom_inst (
        .address(PC[7:0]),
        .clock(clk),
        .q(Instr)          
    );

    // RAM 
    ram ram_inst (
        .address_a(ALUResult[14:0]),  
        .address_b(address[14:0]),    
        .clock(clk),
        .data_a(WriteData[7:0]),      
        .data_b(8'd0),                
        .wren_a(MemWrite),            
        .wren_b(1'b0),                
        .q_a(ram_q_a),               
        .q_b(q_b)                    
    );


    assign ReadData_from_mem = {24'b0, ram_q_a};


    generate
        genvar i;
        for (i = 0; i < 16; i = i + 1) begin : reg_debug_assign
            assign debug_arm_regs[i] = internal_datapath_regs[i];
        end
    endgenerate

endmodule
