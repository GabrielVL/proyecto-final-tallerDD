module debouncer (
    input  logic clk,
    input  logic reset,
    input  logic button_in,
    output logic button_out
);
    logic [1:0] sync;
    logic [15:0] counter;
    logic button_sync, button_prev;
    logic debouncing;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            sync <= 2'b11;
        else
            sync <= {sync[0], button_in};
    end
    assign button_sync = sync[1];

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 16'd0;
            button_prev <= 1'b1;
            button_out <= 1'b0;
            debouncing <= 1'b0;
        end else begin
            button_prev <= button_sync;
            button_out <= 1'b0;

            if (debouncing) begin
                if (counter == 0) begin
                    debouncing <= 1'b0;
                end else begin
                    counter <= counter - 1;
                end
            end else if (button_prev && !button_sync) begin
                counter <= 16'd1_000;
                debouncing <= 1'b1;
                button_out <= 1'b1;
            end
        end
    end
endmodule