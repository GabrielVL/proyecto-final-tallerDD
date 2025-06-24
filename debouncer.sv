module debouncer (
    input logic clk, reset, button,
    output logic button_pulse
);

    logic [15:0] counter;
    logic button_sync, button_prev, button_out;

    // Sincronización del botón (evita metastabilidad)
    logic button_d1, button_d2;
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            button_d1 <= 1'b1;
            button_d2 <= 1'b1;
        end else begin
            button_d1 <= button;
            button_d2 <= button_d1;
        end
    end
    assign button_sync = button_d2;

    // Contador para debounce (10 ms a 50 MHz)
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 16'd0;
            button_out <= 1'b1;
        end else if (button_sync != button_out) begin
            if (counter == 16'd500_000) begin
                counter <= 16'd0;
                button_out <= button_sync;
            end else begin
                counter <= counter + 1;
            end
        end else begin
            counter <= 16'd0;
        end
    end

    // Generación de pulso en transición de 1 a 0
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            button_prev <= 1'b1;
            button_pulse <= 1'b0;
        end else begin
            button_prev <= button_out;
            button_pulse <= button_prev && !button_out;
        end
    end

endmodule