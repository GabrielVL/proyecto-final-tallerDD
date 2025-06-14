module regfile (
    input  logic        clk,
    input  logic        reset,
    input  logic        we3,
    input  logic [3:0]  ra1, ra2, wa3,
    input  logic [31:0] wd3,
    output logic [31:0] rd1, rd2
);
    logic [31:0] rf[14:0]; // R0-R14 (R15 handled by datapath)

    // Write port with reset
    always_ff @(posedge clk or posedge reset)
        if (reset) rf <= '{default:0}; // Reset to 0
        else if (we3 && wa3 != 4'd15) rf[wa3] <= wd3;

    // Read ports (combinational)
    assign rd1 = (ra1 != 4'd15) ? rf[ra1] : 32'b0;
    assign rd2 = (ra2 != 4'd15) ? rf[ra2] : 32'b0;

endmodule