module regfile (
    input  logic        clk,
    input  logic        reset,
    input  logic        we3,
    input  logic [3:0]  ra1, ra2, wa3,
    input  logic [31:0] wd3,
    input  logic [31:0] r15,
    output logic [31:0] rd1, rd2
);
    logic [31:0] rf[14:0];

    // Synchronous write and reset
    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < 15; i++) begin
                rf[i] <= (i == 8) ? 32'h00000118 : (i == 5) ? 32'hFFFFFEE8 : 32'h00000000; // r8 = 0x118, r5 = 0xFFFFFEE8
            end
        end else if (we3 && (wa3 != 4'hF)) begin
            rf[wa3] <= wd3;
        end
    end

    // Read ports
    assign rd1 = (ra1 == 4'hF) ? r15 : rf[ra1];
    assign rd2 = (ra2 == 4'hF) ? r15 : rf[ra2];

    // Debug output for r8, r5
    always_comb begin
        $display("Time %0t: regfile - r8 = %h, r5 = %h", $time, rf[8], rf[5]);
    end
endmodule