module computer_top (
    input logic clk,           // CLOCK_50 (PIN_AF14)
    input logic reset,         // KEY[0] (PIN_AJ4, active-low)
    input logic button,        // KEY[1] (PIN_AK4, active-low)
    output logic [6:0] hex0,   // HEX0 (PC[3:0])
    output logic [6:0] hex1,   // HEX1 (PC[7:4])
    output logic [6:0] hex4,   // HEX4 (e.g., 'M'/'S'/'L')
    output logic [6:0] hex5,   // HEX5 (e.g., 'O'/'T'/'D')
    output logic [3:0] led_debug // LEDR[3:0]
);

    logic [31:0] PC, Instr, ALUResult, WriteData, ReadData;
    logic button_pulse, MemWrite;
    logic [3:0] instr_type;
	 logic clk_enable; 
	 
    // Debouncer
    debouncer u_debouncer (
        .clk(clk),
        .reset(!reset),
        .button(button),
        .button_pulse(button_pulse)
    );

    // Clock enable based on button pulse
    always_ff @(posedge clk or negedge reset) begin
        if (!reset)
            clk_enable <= 1'b0;
        else
            clk_enable <= button_pulse;
    end

    // ARM module instance
    arm u_arm (
        .clk(clk & clk_enable), // Clock button pulse
        .reset(!reset),
        .PC(PC),
        .Instr(Instr),
        .MemWrite(MemWrite),
        .ALUResult(ALUResult),
        .WriteData(WriteData),
        .ReadData(ReadData)
    );

    // Instruction memory instance
    imem u_imem (
        .a(PC),
        .reset(!reset),
        .Instr(Instr)
    );
	 
	 dmem dmem(clk_25Mhz, 
				 DataAdrA, DataAdrB, 
				 WriteData, MemWriteEnable,
				 ReadDataA, ReadDataB);

    // Instruction decoder instance
    Decoder_type u_decoder (
        .Instr(Instr),
        .PC(PC),
        .instr_type(instr_type),
        .hex0(hex0),
        .hex1(hex1),
        .hex4(hex4),
        .hex5(hex5)
    );

    // Debug LEDs
    always_ff @(posedge clk) begin
        led_debug[0] <= button_pulse; // LEDR[0]: Button pulse
        led_debug[3:1] <= PC[2:0];    // LEDR[3:1]: PC[2:0]
    end

endmodule