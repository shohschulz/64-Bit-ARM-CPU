
// mux64x4_1 is a module that implements a 64-bit wide 4-to-1 multiplexer
// Each bit of the four 64-bit inputs can be individually selected based on a single select signa

`timescale 10ps/1fs   //for the delay

module mux64x4_1(output_bits, input_bits_0, input_bits_1, input_bits_2, input_bits_3, select_bits);
    output logic [63:0] output_bits;
    input  logic [63:0] input_bits_0, input_bits_1, input_bits_2, input_bits_3;
    input  logic [1:0] select_bits;
    
    //  variables for the 64-bit operations
    logic [63:0] output_0, output_1, output_2, output_3;
    
    genvar i;
    generate
        for (i = 0; i < 64; i++) begin : eachBit
            mux4_1 each_mux (
                .output_bit(output_bits[i]), 
                .input_bits({input_bits_3[i], input_bits_2[i], input_bits_1[i], input_bits_0[i]}), 
                .select_bits(select_bits)
            );
        end
    endgenerate
endmodule

// testbench for the mux64x4_1
module mux64x4_1_testbench;
    logic [63:0] input_bits_0, input_bits_1, input_bits_2, input_bits_3;
    logic [1:0] select_bits;
    logic [63:0] output_bits;

    mux64x4_1 DUT (
        .output_bits(output_bits), 
        .input_bits_0(input_bits_0), 
        .input_bits_1(input_bits_1), 
        .input_bits_2(input_bits_2), 
        .input_bits_3(input_bits_3), 
        .select_bits(select_bits)
    );

    initial begin
        // set inputs to certain values
        input_bits_0 = 64'h5555555555555555; // Pattern 0101...
        input_bits_1 = 64'h3333333333333333; // Pattern 0011...
        input_bits_2 = 64'h0F0F0F0F0F0F0F0F; // Pattern 00001111...
        input_bits_3 = 64'h00FF00FF00FF00FF; // Pattern 0000000011111111...
        select_bits = 2'b00; #10;
        select_bits = 2'b01; #10;
        select_bits = 2'b10; #10;
        select_bits = 2'b11; #10;
    end
endmodule 