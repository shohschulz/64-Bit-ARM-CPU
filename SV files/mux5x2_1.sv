`timescale 1ns/10ps

// mux5x2_1 is a module that creates a 5-bit wide 2-to-1 multiplexer.
// It selects between two 5-bit inputs based on a single select signal.
module mux5x2_1(output_data, input_a, input_b, select);
    output logic [4:0] output_data; // 5-bit output based on select signal
    input logic [4:0] input_a, input_b; // Two 5-bit inputs for selection
    input logic select; // Selection signal to choose between input_a and input_b

    // Instantiate 5 instances of 2-to-1 multiplexers
    genvar bit_index;
    generate
        for (bit_index = 0; bit_index < 5; bit_index++) begin : gen_mux_each_bit
            mux2_1 bit_mux (
                .output_bit(output_data[bit_index]), // Output for this bit
                .input_bit_0(input_a[bit_index]),   // Input A for this bit
                .input_bit_1(input_b[bit_index]),   // Input B for this bit
                .select_bit(select)                 // Selection signal for this bit
            );
        end
    endgenerate
endmodule

// Testbench for the mux5x2_1 module
module mux5x2_1_testbench;
    logic [4:0] input_a, input_b, output_data;
    logic select;

    // Instantiate the Device Under Test (DUT)
    mux5x2_1 dut (
        .output_data(output_data),
        .input_a(input_a),
        .input_b(input_b),
        .select(select)
    );

    // Test scenarios
    initial begin
        // Test case with select = 1, expect output_data to match input_a
        input_a = 5'b11110; input_b = 5'b00100;
        select = 1'b1; #10;

        // Test case with select = 0, expect output_data to match input_b
        select = 1'b0; #10;

        // Another test case with select = 1
        input_a = 5'b01111; input_b = 5'b11100;
        select = 1'b1; #10;

        // Another test case with select = 0
        select = 1'b0; #10;
    end
endmodule