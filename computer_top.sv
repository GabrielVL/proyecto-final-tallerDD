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
    logic [1:0] instr_type; // 0: Otros, 1: MOV, 2: STR, 3: LDR

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
            12'b111000111010: instr_type = 2'd1; // MOV (E3A0)
            12'b111001011000: instr_type = 2'd2; // STR (E58)
            12'b111001011001: instr_type = 2'd3; // LDR (E59)
            default:          instr_type = 2'd0; // Otros
        endcase
    end

    // Displays de 7 segmentos
    seg7 u_hex0 (.data(PC[3:0]), .seg(hex0)); // PC[3:0]
    seg7 u_hex1 (.data(PC[7:4]), .seg(hex1)); // PC[7:4]
    
    // HEX4 y HEX5 según instrucción
    always_comb begin
        case (instr_type)
            2'd1: begin // MOV: 'MO'
                hex4 = 7'b1000000; // 'O'
                hex5 = 7'b0001001; // 'M'
            end
            2'd2: begin // STR: 'ST'
                hex4 = 7'b0010010; // 'T'
                hex5 = 7'b0010010; // 'S'
            end
            2'd3: begin // LDR: 'LD'
                hex4 = 7'b0100001; // 'D'
                hex5 = 7'b1000111; // 'L'
            end
            default: begin // Apagado
                hex4 = 7'b1111111;
                hex5 = 7'b1111111;
            end
        endcase
    end

    // LEDs para depuración
    assign led_debug[0] = button_pulse; // LEDR[0]: Pulso del botón
    assign led_debug[3:1] = PC[2:0];    // LEDR[3:1]: PC[2:0]

endmodule