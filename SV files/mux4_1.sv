/*

4:1 multiplexer constructed using 2:1 mux's

*/

`timescale 1ns/10ps   //for the delay

module mux4_1(output_bit, input_bits, select_bits);
    output logic output_bit;
    input  logic [3:0] input_bits;
    input  logic [1:0] select_bits;
    
    //  variables for logic operations
    logic intermediate_output_0, intermediate_output_1;
    
    // using our previously defined 2:1 multiplexers to construct a 4:1 multiplexer, with delays
    mux2_1  Mux0 (.output_bit(intermediate_output_0), .input_bit_0(input_bits[0]), .input_bit_1(input_bits[1]), .select_bit(select_bits[0]));
    mux2_1  Mux1 (.output_bit(intermediate_output_1), .input_bit_0(input_bits[2]), .input_bit_1(input_bits[3]), .select_bit(select_bits[0]));
    mux2_1  Mux (.output_bit(output_bit), .input_bit_0(intermediate_output_0), .input_bit_1(intermediate_output_1), .select_bit(select_bits[1]));
    
endmodule

module mux4_1_testbench;
    logic [3:0] input_bits;
    logic [1:0] select_bits;
    logic output_bit;

    mux4_1 DUT (.output_bit, .input_bits, .select_bits);

    integer idx;
    initial begin
        // Iterating through all possible input combinations
        for(idx=0; idx<64; idx++) begin
            {select_bits, input_bits} = idx;
            #10;
        end
    end
endmodule 