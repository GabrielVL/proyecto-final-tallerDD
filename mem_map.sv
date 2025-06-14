module mem_map (
    input  logic        clk,
    input  logic        we,
    input  logic [31:0] a,
    input  logic [31:0] wd,
    output logic [31:0] rd
);
    logic [31:0] mem[0:255];
    
    always_ff @(posedge clk) begin
        if (we) mem[a[9:2]] <= wd;
    end
    
    assign rd = mem[a[9:2]];
endmodule