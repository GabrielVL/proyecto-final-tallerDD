module computer_top (
    input  logic clk, reset, enable,
    output logic [31:0] WriteData, DataAdr, ReadData,
    output logic MemWrite,
    output logic [31:0] ins, PC
);

    logic [7:0] ram_read_b;

    // ARM
    arm arm_inst (
        .clk(clk),
        .rst(reset),
        .address(DataAdr),        // Dirección para lectura externa
        .q_b(ram_read_b)          // Solo 8 bits disponibles
    );

    assign ReadData = {24'd0, ram_read_b}; 

    // ROM 
    rom rom_inst (
        .address(PC[7:0]),  
        .clock(clk),
        .q(ins)
    );

endmodule