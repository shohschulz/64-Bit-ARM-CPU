/*

2x1 multiplexer that accepts three 1-bit inputs and outputs a single bit.

*/

`timescale 1ns/10ps // for the delay

module mux2_1(output_bit, input_bit_0, input_bit_1, select_bit);
    output logic output_bit;
    input logic input_bit_0, input_bit_1, select_bit;
    
    // variables for logic operations
    logic and_result_0, and_result_1, not_select_bit;
    
    // logic gates to implement the multiplexer functionality, with delays
	// using non-RTL code
    not #0.05 NotGate (not_select_bit, select_bit);
    and #0.05 AndGate_0 (and_result_0, input_bit_0, not_select_bit);
    and #0.05 AndGate_1 (and_result_1, input_bit_1, select_bit);
    or  #0.05 OrGate (output_bit, and_result_1, and_result_0); 
    
endmodule

module mux2_1_testbench;
    logic input_bit_0, input_bit_1, select_bit;
    logic output_bit;

    mux2_1 DUT (.output_bit, .input_bit_0, .input_bit_1, .select_bit);

    integer idx;
    initial begin
		
        // iterating through all possible input combinations
        for (idx = 0; idx < 8; idx++) begin
            {select_bit, input_bit_1, input_bit_0} = idx;
            #10;
        end
    end
endmodule 