/*
    
    This is the register file that will connect all the necessary parts. "RegWrite" will start by being sent to
    the decoder and the output of that will tell you which register is being writen at current clock cycle
    depending on the "WriteRegister". 
    
    After that then only the chose  register will be updated. Then, two large 32x64 to 64 multiplexors will read the output from
    the 32 registers and will select the 64-bit output 'ReadData1' and 'ReadData2' based on the  5-bit
    inputs 'ReadRegister1' and 'ReadRegister2'.

*/

//Shoh Schulz
//Chukwuemeka Emmanuel Mordi

`timescale 1ns/10ps

module regfile (ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, clk);
    input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
	input logic [63:0] WriteData;
	input logic RegWrite, clk;
	logic reset;

    output logic [63:0] ReadData1, ReadData2;

    logic [31:0] WriteEnable;
	 logic [31:0][63:0]RegisterData ;   // will be the i-th registers output data
					 
    // Note: Shoh could try make his 5x32 decoder out of 2 4x16 decoder and 1 1x2 decoder if this doesnt work

	decoder5to32 dec5_32 (.out(WriteEnable), .in(WriteRegister), .enable(RegWrite));

    genvar idx;

    //need to create 31 registers and create one more below that represents
    generate
		for (idx=0; idx<31; idx++) begin : for_each_reg

			//this needs to represent one register. so create one register file
            DFF64WithEnable dff_regis (.q(RegisterData[idx]), .d(WriteData), .enable(WriteEnable[idx]), .reset, .clk(clk)); 
		end
	endgenerate
    
    //hardwire the X31 to zero

    DFF64WithEnable X31 (.q(RegisterData[31]), .d(0), .enable(1), .reset(0), .clk(clk));
	 

    //create two 64x32:1 muxs

    mux64x32_1 first_mux (.OutputData(ReadData1), .InputData(RegisterData), .ReadRegister(ReadRegister1)); // dataIn, 2-D array from DataOut of 32 64-bit Registers
	mux64x32_1 second_mux (.OutputData(ReadData2), .InputData(RegisterData), .ReadRegister(ReadRegister2));
					 
endmodule