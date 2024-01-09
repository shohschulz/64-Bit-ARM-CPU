
// 32:1 multiplexer constructed using 16:1 and 2:1 multiplexers.

`timescale 1ns/10ps		//for the delay

module mux32_1(output_bit, input_bits, select_bits);
    output logic output_bit;
    input  logic [31:0] input_bits;
    input  logic [4:0] select_bits;
    
    // Intermediate variables for logic operations
    logic intermediate_output_0, intermediate_output_1;
    
    // using previously defined 16:1 and 2:1 multiplexers to construct a 32:1 multiplexer
    mux16_1 Mux0 (.output_bit(intermediate_output_0), .input_bits(input_bits[15:0]),  .select_bits(select_bits[3:0]));
    mux16_1 Mux1 (.output_bit(intermediate_output_1), .input_bits(input_bits[31:16]), .select_bits(select_bits[3:0]));
    mux2_1  Mux  (.output_bit(output_bit), .input_bit_0(intermediate_output_0), .input_bit_1(intermediate_output_1), .select_bit(select_bits[4]));
    
endmodule


module mux32_1_testbench();
	logic [31:0] input_bits;
    logic [4:0] select_bits;
    logic output_bit;

    mux32_1 DUT (.output_bit, .input_bits, .select_bits);

    integer idx;
    initial begin

        // iterating through all possible input combinations

		/*
		
		the following patterns below are different bit patterns that are used to test the mux's in different scenarios

		*/

		//alternating bits
        input_bits = 32'b10101010101010101010101010101010;
        for (idx = 0; idx < 32; idx++) begin
            select_bits = idx;
            #10;
        end

		//grouped bits
        input_bits = 32'b11110000111100001111000011110000; 
        for (idx = 0; idx < 32; idx++) begin
            select_bits = idx;
            #10;
        end

        // all zeroes
        input_bits = 32'b00000000000000000000000000000000;
        for (idx = 0; idx < 32; idx++) begin
            select_bits = idx;
            #10;
        end
        
        // all ones
        input_bits = 32'b11111111111111111111111111111111;
        for (idx = 0; idx < 32; idx++) begin
            select_bits = idx;
            #10;
        end
    end
endmodule 