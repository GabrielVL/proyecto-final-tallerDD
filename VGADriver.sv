module VGADriver(
    input logic clk, rst,
    input logic [0:4][0:9] breakout_matrix,  // 5x10 grid of blocks
    input [8:0] paddle_pos,                  // 9-bit paddle position (0-511)
    input [8:0] ball_pos_x,                  // 9-bit ball X position
    input [7:0] ball_pos_y,                  // 8-bit ball Y position
    input logic player_win,
    output logic vga_hs, vga_vs, vga_blk, vga_sync,
    output logic [7:0] vga_r, vga_g, vga_b,
    output logic clk_25
);

    logic [9:0] hcount, vcount;
    logic video_on;
    logic [7:0] pixel_r, pixel_g, pixel_b;

    // Divisor de reloj: clk -> clk_25MHz
    always_ff @(posedge clk or posedge rst)
        if (rst) clk_25 <= 0;
        else     clk_25 <= ~clk_25;


    // Generador de sincronización VGA
    GraphicsDriver vga_ctrl (
        .clk_25(clk_25),
        .rst(rst),
        .hs(hcount),
        .vs(vcount),
        .vga_hsync(vga_hs),
        .vga_vsync(vga_vs),
        .frame_start(video_on),
        .vga_blk(vga_blk),
        .vga_sync(vga_sync)
    );

    // Lógica de dibujo
    DrawScreen draw (
        .hcount(hcount),
        .vcount(vcount),
        .video_on(video_on),
        .breakout_matrix(breakout_matrix),
        .paddle_pos(paddle_pos),
        .ball_pos_x(ball_pos_x),
        .ball_pos_y(ball_pos_y),
        .player_win(player_win),
        .r(pixel_r),
        .g(pixel_g),
        .b(pixel_b)
    );

    assign vga_r = pixel_r;
    assign vga_g = pixel_g;
    assign vga_b = pixel_b;

endmodule
