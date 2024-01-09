`timescale 1ns / 10ps

// mux64x2_1 is a module that implements a 64-bit wide 2-to-1 multiplexer. 
// Each bit of the two 64-bit inputs can be individually selected based on a single select signal.
module mux64x2_1 (output_data, input_a, input_b, select);
    output logic [63:0] output_data; // Output: Selected data based on 'select' signal
    input  logic [63:0] input_a, input_b; // Inputs: Two 64-bit data inputs for selection
    input  logic select; // Input: Selection signal to choose between input_a and input_b

    // Generate 64 instances of 2-to-1 multiplexers using a for loop
    genvar bit_index;
    generate
        for (bit_index = 0; bit_index < 64; bit_index++) begin : gen_mux_each_bit
            mux2_1 bit_mux (
                .output_bit(output_data[bit_index]), // Output for this bit
                .input_bit_0(input_a[bit_index]),      // Input A for this bit
                .input_bit_1(input_b[bit_index]),      // Input B for this bit
                .select_bit(select)                  // Selection signal for this bit
            );
        end
    endgenerate
endmodule

// Testbench for the mux64x2_1 module
module mux64x2_1_testbench;
    logic [63:0] output_data; // Output from the DUT
    logic [63:0] input_a, input_b; // Test inputs to the DUT
    logic select; // Test select signal

    // Instantiate the Device Under Test (DUT) with the test signal connections
    mux64x2_1 dut (
        .output_data(output_data), 
        .input_a(input_a), 
        .input_b(input_b), 
        .select(select)
    );

    // Test scenarios
    initial begin
        // Test case 1: select = 0, expect output_data to match input_a
        input_a = 64'h0000000000100000;
        input_b = 64'h0000000000000000; 
        select = 0; 
        #10;

        // Test case 2: select = 0, expect output_data to match input_a
        input_a = 64'h00000007b0000000;
        input_b = 64'h0000000e06000000; 
        select = 0; 
        #10;

        // Test case 3: select = 0, expect output_data to match input_a
        input_a = 64'h000000000000001a;
        input_b = 64'h00000000000002a0; 
        select = 0; 
        #10;

        // Test case 4: select = 1, expect output_data to match input_b
        input_a = 64'h00000007b0000000;
        input_b = 64'h0000000e06000000; 
        select = 1; 
        #10;

        // Test case 5: select = 1, expect output_data to match input_b
        input_a = 64'h000000000000001a;
        input_b = 64'h00000000000002a0; 
        select = 1; 
        #10;
    end
endmodule
