//Registers the inputs from the instruction fetch aka in "the instruction" 

module IF_ID_FF (registeredInstruction, instruction, registeredPC, pc, clk, reset);
	input logic [31:0] instruction;
	input logic [63:0] pc;
	input logic clk, reset; 
	output logic [31:0] registeredInstruction;
	output logic [63:0] registeredPC;
	
	DFF32 instruction1 (.q(registeredInstruction), .d(instruction), .reset, .clk);
	DFF64 pc1 (.q(registeredPC), .d(pc), .reset, .clk);
	
endmodule

//Plan: DFF for every single we want registered, gonna do it individually. 

//Problem: Our immediates need to be generated from the instruction and not in the controller 

