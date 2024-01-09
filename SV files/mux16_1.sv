

//creating a 16:1 multiplexer constructed using 4:1 multiplexers.

`timescale 1ns/10ps   //for the delay

module mux16_1(output_bit, input_bits, select_bits);
    output logic output_bit;
    input  logic [15:0] input_bits;
    input  logic [3:0] select_bits;
    
    // Intermediate variables for logic operations
    logic [3:0] intermediate_output_bits;
    
    // using the previously defined 4:1 multiplexers to construct a 16:1 multiplexer
    mux4_1 Mux0 (.output_bit(intermediate_output_bits[0]), .input_bits(input_bits[3:0]),   .select_bits(select_bits[1:0]));
    mux4_1 Mux1 (.output_bit(intermediate_output_bits[1]), .input_bits(input_bits[7:4]),   .select_bits(select_bits[1:0]));
    mux4_1 Mux2 (.output_bit(intermediate_output_bits[2]), .input_bits(input_bits[11:8]),  .select_bits(select_bits[1:0]));
    mux4_1 Mux3 (.output_bit(intermediate_output_bits[3]), .input_bits(input_bits[15:12]), .select_bits(select_bits[1:0]));
    mux4_1 Mux  (.output_bit(output_bit),                  .input_bits(intermediate_output_bits[3:0]), .select_bits(select_bits[3:2]));
    
endmodule

module mux16_1_testbench;
    logic [15:0] input_bits;
    logic [3:0] select_bits;
    logic output_bit;

    mux16_1 DUT (.output_bit, .input_bits, .select_bits);

    integer idx;
    initial begin

        /*

        iterates from idx = 0 to idx = 1048575 (because it stops before idx = 1048576). 
        The value 1048576 was chosen as the upper limit to ensure that every possible 
        combination of select_bits and input_bits is tested in the testbench.

        The total number of combinations for 20 bits is 2^20 == 1048576
         
        */

        for(idx=0; idx<1048576; idx++) begin
            {select_bits, input_bits} = idx;
            #10;
        end
    end
endmodule 




