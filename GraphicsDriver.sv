module GraphicsDriver(
    input  logic clk_25,
	 input  logic rst,
    output logic vga_hsync,
    output logic vga_vsync,
    output logic vga_blk,
    output logic vga_sync,
    output logic [9:0] hs,
    output logic [9:0] vs,
    output logic frame_start
);

    // Parámetros VGA 640x480 @ 60Hz
    localparam H_VISIBLE     = 640;
    localparam H_FRONT_PORCH = 16;
    localparam H_SYNC_PULSE  = 96;
    localparam H_BACK_PORCH  = 48;
    localparam H_TOTAL       = H_VISIBLE + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;

    localparam V_VISIBLE     = 480;
    localparam V_FRONT_PORCH = 10;
    localparam V_SYNC_PULSE  = 2;
    localparam V_BACK_PORCH  = 33;
    localparam V_TOTAL       = V_VISIBLE + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;

    logic [9:0] h_count = 0;
    logic [9:0] v_count = 0;

    assign hs = h_count;
    assign vs = v_count;

    assign vga_blk = (h_count < H_VISIBLE) && (v_count < V_VISIBLE); //Visible

	 //Sync
    assign vga_hsync = ~(h_count >= (H_VISIBLE + H_FRONT_PORCH) &&
                         h_count <  (H_VISIBLE + H_FRONT_PORCH + H_SYNC_PULSE));

    assign vga_vsync = ~(v_count >= (V_VISIBLE + V_FRONT_PORCH) &&
                         v_count <  (V_VISIBLE + V_FRONT_PORCH + V_SYNC_PULSE));

    assign vga_sync = vga_hsync & vga_vsync;

    // Frame start se activa un solo ciclo cuando ambos contadores vuelven a cero
    //assign frame_start = (h_count == 0 && v_count == 0);
	 assign frame_start = (h_count < H_VISIBLE) && (v_count < V_VISIBLE);

    always_ff @(posedge clk_25) begin
        if (h_count == H_TOTAL - 1) begin
            h_count <= 0;
            if (v_count == V_TOTAL - 1)
                v_count <= 0;
            else
                v_count <= v_count + 1;
        end else begin
            h_count <= h_count + 1;
        end
    end

endmodule
