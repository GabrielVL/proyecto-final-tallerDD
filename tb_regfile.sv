module tb_regfile;

    // Parameters for the testbench (match the DUT's WIDTH, though it's fixed at 32-bit)
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 4; // Log2(16 registers)

    // Inputs to the Register File (reg because the testbench drives them)
    reg clk;
    reg we3; // Write Enable for port 3
    reg [ADDR_WIDTH-1:0] ra1, ra2, wa3; // Read addresses (port 1, 2), Write address (port 3)
    reg [DATA_WIDTH-1:0] wd3; // Write Data (port 3)
    reg [DATA_WIDTH-1:0] r15; // Value for PC + 8 (special read for R15)

    // Outputs from the Register File (wire because the DUT drives them)
    wire [DATA_WIDTH-1:0] rd1, rd2; // Read Data (port 1, 2)

    // Instantiate the Unit Under Test (DUT)
    regfile dut (
        .clk(clk),
        .we3(we3),
        .ra1(ra1),
        .ra2(ra2),
        .wa3(wa3),
        .wd3(wd3),
        .r15(r15),
        .rd1(rd1),
        .rd2(rd2)
    );

    // Clock Generator: Creates a clock with a 10ns period (5ns high, 5ns low)
    always #5 clk = ~clk;

    // Initial Block for Test Scenarios
    initial begin
        // Initialize all inputs to a known state
        clk = 0;
        we3 = 0; // Disable write initially
        ra1 = 4'h0;
        ra2 = 4'h0;
        wa3 = 4'h0;
        wd3 = 32'hDEADBEEF; // Some initial data
        r15 = 32'hFEEDC0DE; // Initial PC+8 value

        // Configure monitoring of key signals for comprehensive debugging
        $monitor("Tiempo=%0t clk=%b we3=%b | ra1=%h rd1=%h | ra2=%h rd2=%h | wa3=%h wd3=%h | r15=%h",
                 $time, clk, we3, ra1, rd1, ra2, rd2, wa3, wd3, r15);

        #10; // Allow initial values to propagate

        // --- Test 1: Write to several registers ---
        $display("\n--- Test 1: Writing to R0, R1, R7, R14 ---");
        // Write to R0
        we3 = 1; // Enable write
        wa3 = 4'h0; // Address R0
        wd3 = 32'h11110000;
        #10; // Wait for positive clock edge for write to occur

        // Write to R1
        wa3 = 4'h1; // Address R1
        wd3 = 32'h22220000;
        #10;

        // Write to R7
        wa3 = 4'h7; // Address R7
        wd3 = 32'h77770000;
        #10;

        // Write to R14
        wa3 = 4'hE; // Address R14
        wd3 = 32'hEEEE0000;
        #10;
        we3 = 0; // Disable write after all writes

        // --- Test 2: Read from written registers (Combinational Read) ---
        $display("\n--- Test 2: Reading from R0, R1, R7, R14 ---");
        // Read R0 and R1
        ra1 = 4'h0; // Read R0
        ra2 = 4'h1; // Read R1
        #1; // Read should be immediate (combinational)
        $display("Expected rd1=11110000, rd2=22220000"); // Display expected values

        // Read R7 and R14
        ra1 = 4'h7; // Read R7
        ra2 = 4'hE; // Read R14
        #1;
        $display("Expected rd1=77770000, rd2=EEEE0000");

        // --- Test 3: Special Read for R15 (PC + 8) ---
        $display("\n--- Test 3: Reading from R15 (PC + 8) ---");
        r15 = 32'hAAAA0000; // Set PC+8 to a known value
        ra1 = 4'hF; // Read R15 via rd1
        ra2 = 4'hF; // Read R15 via rd2
        #1;
        $display("Expected rd1=AAAA0000, rd2=AAAA0000 (from r15 input)");

        // Try to write to R15 and then read again.
        // The read should *still* come from r15 input, not the written value in rf[15].
        $display("\n--- Test 4: Writing to R15 and then reading R15 ---");
        we3 = 1;
        wa3 = 4'hF; // Write to R15
        wd3 = 32'hDEADDEAD; // A different value
        #10; // Write occurs
        we3 = 0;
        // Now, read R15 again. It should still be AAAA0000 from r15 input.
        ra1 = 4'hF;
        ra2 = 4'hF;
        #1;
        $display("Expected rd1=AAAA0000, rd2=AAAA0000 (from r15 input, not DEADDEAD)");
        // We can't directly observe rf[15] from the outside, but its value *did* change to DEADDEAD.

        // --- Test 5: Concurrent Read/Write ---
        $display("\n--- Test 5: Concurrent Write to R2 and Read R2/R3 ---");
        // Read current R2 and R3 (should be x or 0 if not written)
        ra1 = 4'h2;
        ra2 = 4'h3;
        #1;
        $display("rd1 (R2) before write: %h, rd2 (R3) before write: %h", rd1, rd2);

        // Write to R2 while reading from it, then read again after the clock edge
        we3 = 1;
        wa3 = 4'h2;
        wd3 = 32'hFFEEDDCC;
        #5; // At positive edge, rd1 should still show old R2 value (or x)
        $display("rd1 (R2) at posedge write: %h, rd2 (R3) at posedge write: %h", rd1, rd2);
        #5; // After positive edge, R2 should be updated
        we3 = 0;
        $display("rd1 (R2) after write: %h, rd2 (R3) after write: %h", rd1, rd2);
        $display("Expected rd1=FFEEDDCC, rd2=current R3 value");


        // --- Test 6: Read from uninitialized register ---
        $display("\n--- Test 6: Reading from uninitialized register (R5) ---");
        ra1 = 4'h5;
        ra2 = 4'h6;
        #1;
        $display("Expected rd1=00000000 or X, rd2=00000000 or X");


        // --- End of Simulation ---
        $display("\n--- End of Simulation ---");
        #10;
        $finish; // Terminate the simulation
    end

endmodule
