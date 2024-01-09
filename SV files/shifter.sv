
// This module defines a 64-bit shifter that can perform both left and right shifts.
module shifter(
    input logic [63:0] value,     // Input value to be shifted
    input logic direction,        // Shift direction (0 for left, 1 for right)
    input logic [5:0] distance,   // Number of positions to shift
    output logic [63:0] result    // Result of the shift operation
);

    // always_comb block ensures combinational logic behavior
    always_comb begin
        // Check the direction of the shift
        if (direction == 0)
            result = value << distance; // Perform left shift if direction is 0
        else
            result = value >> distance; // Perform right shift if direction is 1
    end
endmodule

// shifter_testbench.v
// This module is a testbench to verify the functionality of the shifter module.
module shifter_testbench();
    logic [63:0] value;           // Test value to be shifted
    logic direction;              // Test direction for shifting
    logic [5:0] distance;         // Test number of positions to shift
    logic [63:0] result;          // Output to capture the result of the shift

    // Instance of the shifter module
    shifter dut (
        .value(value),
        .direction(direction),
        .distance(distance),
        .result(result)
    );

    // Test sequence
    initial begin
        // Initialize the value to a known pattern
        value = 64'hDEADBEEFDECAFBAD; // Hexadecimal value to start with

        // Test both shift directions: 0 for left and 1 for right
        for (dir = 0; dir < 2; dir++) begin
            direction <= dir[0]; // Set direction: 0 for left, 1 for right
            // Test all possible shift distances from 0 to 63
            for (i = 0; i < 64; i++) begin
                distance <= i; // Set the number of positions to shift
                #10; // Wait for 10 time units to allow the shift to complete
            end
        end
    end
endmodule
