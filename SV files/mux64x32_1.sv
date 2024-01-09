/*
	A 64x32:1 multiplexer using 32:1 multiplexers for each bit of a 64-bit wide data bus.
*/


`timescale 1ns/10ps		//for the delay
module mux64x32_1 (OutputData, InputData, ReadRegister);

    output logic [63:0] OutputData;		//64 bit output vector
    input  logic [31:0][63:0] InputData;	//2d input array, essentially 32 64-bit vectors
    input  logic [4:0]  ReadRegister;		// 5 bit input vector to select the 32 input vectors

    // this represents a 64x32:1 multiplexer using individual 32:1 multiplexers for each bit of the 64-bit data bus
	
	// thus a mux is basically choosing every bit of 32 64-bit registers

    genvar bitIdx;

    generate
        for (bitIdx=0; bitIdx<64; bitIdx++) begin : BitMultiplexers
            mux32_1 MuxBit (		//instantiate a mux32_1 module for each iteration i. thus creaing 64 instances

                .output_bit(OutputData[bitIdx]), 
                .input_bits({	//this will select the i-th bit bit from each 64 bit vector
                    InputData[31][bitIdx], InputData[30][bitIdx], InputData[29][bitIdx], InputData[28][bitIdx],
                    InputData[27][bitIdx], InputData[26][bitIdx], InputData[25][bitIdx], InputData[24][bitIdx],
                    InputData[23][bitIdx], InputData[22][bitIdx], InputData[21][bitIdx], InputData[20][bitIdx],
                    InputData[19][bitIdx], InputData[18][bitIdx], InputData[17][bitIdx], InputData[16][bitIdx],
                    InputData[15][bitIdx], InputData[14][bitIdx], InputData[13][bitIdx], InputData[12][bitIdx],
                    InputData[11][bitIdx], InputData[10][bitIdx], InputData[9][bitIdx],  InputData[8][bitIdx],
                    InputData[7][bitIdx],  InputData[6][bitIdx],  InputData[5][bitIdx],  InputData[4][bitIdx],
                    InputData[3][bitIdx],  InputData[2][bitIdx],  InputData[1][bitIdx],  InputData[0][bitIdx]
                }), 
                .select_bits(ReadRegister)		//decides what input vector bit is passed to the output
            );
        end
    endgenerate

endmodule