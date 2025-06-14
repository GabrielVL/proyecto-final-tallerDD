module flopenr #(parameter WIDTH = 32) (
    input logic clk, reset, en,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            q <= {WIDTH{1'b0}}; // Reset to all zeros
        end else if (en) begin
            q <= d;
        end
    end

endmodule
