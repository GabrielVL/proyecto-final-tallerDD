module dmem (
    input  logic        clk,
    input  logic [31:0] a, b, wd_a,
    input  logic        we_a,
    output logic [31:0] rd_a, rd_b
);
    logic [16:0] _a;
    
    always_comb begin
        if (a[18:2] >= 70000) _a = 17'd0;
        else _a = a[18:2];
    end
    
    logic [31:0] wd_b = 32'd0;
    logic we_b = 1'b0;
    
    ram ram_inst (
        .address_a(_a),
        .address_b(b[16:0]),
        .clock(clk),
        .data_a(wd_a),
        .data_b(wd_b),
        .wren_a(we_a),
        .wren_b(we_b),
        .q_a(rd_a),
        .q_b(rd_b)
    );
endmodule