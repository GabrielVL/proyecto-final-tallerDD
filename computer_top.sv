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

    logic [31:0] PC, Instr;
    logic button_pulse;
    logic [2:0] instr_type; // 0: Other, 1: MOV, 2: STR, 3: LDR, 4: ADD, 5: SUB, 6: AND, 7: B

    // Program Counter
    always_ff @(posedge clk or negedge reset) begin
        if (!reset)
            PC <= 32'd0;
        else if (button_pulse)
            PC <= PC + 32'd4;
    end

    // Instancia de memoria de instrucciones
    imem u_imem (
        .a(PC),
        .reset(!reset),
        .Instr(Instr)
    );

    // Instancia del debouncer
    debouncer u_debouncer (
        .clk(clk),
        .reset(!reset),
        .button(button),
        .button_pulse(button_pulse)
    );

    // Clasificación de instrucciones
    always_comb begin
        casez (Instr[31:20])
            12'b111000111010: instr_type = 3'd1; // MOV (E3A0)
            12'b111001011000: instr_type = 3'd2; // STR (E58)
            12'b111001011001: instr_type = 3'd3; // LDR (E59)
            12'b111000001000: instr_type = 3'd4; // ADD (E08)
            12'b111000000100: instr_type = 3'd5; // SUB (E04)
            12'b111000000000: instr_type = 3'd6; // AND (E00)
            12'b1110101?????: instr_type = 3'd7; // B/BL (EA/EB)
            default:          instr_type = 3'd0; // Other
        endcase
    end

    // Displays de 7 segmentos
    seg7 u_hex0 (.data(PC[3:0]), .seg(hex0)); // PC[3:0]
    seg7 u_hex1 (.data(PC[7:4]), .seg(hex1)); // PC[7:4]
    
    // HEX4 y HEX5 según instrucción
    always_comb begin
        case (instr_type)
            3'd1: begin // MOV: 'MO'
                hex4 = 7'b1000000; // 'O'
                hex5 = 7'b0001001; // 'M'
            end
            3'd2: begin // STR: 'ST'
                hex4 = 7'b0010010; // 'T'
                hex5 = 7'b0010010; // 'S'
            end
            3'd3: begin // LDR: 'LD'
                hex4 = 7'b0100001; // 'D'
                hex5 = 7'b1000111; // 'L'
            end
            3'd4: begin // ADD: 'AD'
                hex4 = 7'b0100001; // 'D'
                hex5 = 7'b0001000; // 'A'
            end
            3'd5: begin // SUB: 'SB'
                hex4 = 7'b0000011; // 'b'
                hex5 = 7'b0010010; // 'S'
            end
            3'd6: begin // AND: 'AN'
                hex4 = 7'b0101011; // 'n'
                hex5 = 7'b0001000; // 'A'
            end
            3'd7: begin // B: 'BR'
                hex4 = 7'b0101111; // 'r'
                hex5 = 7'b0000011; // 'b'
            end
            default: begin // Other: Off
                hex4 = 7'b1111111;
                hex5 = 7'b1111111;
            end
        endcase
    end

    // LEDs para depuración
    always_ff @(posedge clk) begin
        led_debug[0] <= button_pulse; // LEDR[0]: Pulso del botón
        led_debug[3:1] <= PC[2:0];    // LEDR[3:1]: PC[2:0]
    end

endmodule