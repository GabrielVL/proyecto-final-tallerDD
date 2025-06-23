module computer_top (
    input  logic        clk,
    input  logic        reset,
    input  logic        button,
    output logic [6:0]  op7seg,
    output logic [20:0] debug_bx_check,
    output logic [3:0]  debug_alu_op,
    output logic        debug_s_bit,
    output logic        debug_bx_match
);
    logic [31:0] WriteData, DataAdrA;
    logic MemWriteEnable;
    logic [31:0] PC;
    logic [31:0] PC_arm;
    logic [31:0] Instr, ReadDataA;
    logic [3:0] op;
    logic button_pulse;

    debouncer db (
        .clk(clk),
        .reset(reset),
        .button_in(button),
        .button_out(button_pulse)
    );

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            PC <= 32'd0;
        else if (button_pulse)
            PC <= PC + 32'd4;
    end

    imem imem (
        .a(PC), 
        .rd(Instr)
    );
    
    arm arm (
        .clk(clk), 
        .reset(reset), 
        .PC(PC_arm),
        .Instr(Instr), 
        .MemWrite(MemWriteEnable), 
        .ALUResult(DataAdrA), 
        .WriteData(WriteData), 
        .ReadData(ReadDataA)
    );
    
    dmem dmem (
        .clk(clk),
        .a(DataAdrA),
        .b(32'b0),
        .wd_a(WriteData),
        .we_a(MemWriteEnable),
        .rd_a(ReadDataA),
        .rd_b()
    );
    
    Decoder_type decode (
        .Instr(Instr), 
        .op(op),
        .debug_bx_check(debug_bx_check),
        .debug_alu_op(debug_alu_op),
        .debug_s_bit(debug_s_bit),
        .debug_bx_match(debug_bx_match)
    );
    
    Decoder_7seg decode7seg (
        .op(op), 
        .op7seg(op7seg)
    );
endmodule