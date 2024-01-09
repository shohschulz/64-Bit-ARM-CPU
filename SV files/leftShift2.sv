//shifts a 64 bit input number, 2 places to the left

module leftShift2(imm26, imm19, shifted26, shifted19);
	input logic [63:0] imm26; //26 bit input
	input logic [63:0] imm19; //19 bit input 
	output logic [63:0] shifted26;
	output logic [63:0] shifted19; 
	
	assign shifted26 = {imm26[61:0], 2'b0};
	assign shifted19 = {imm19[61:0], 2'b0};
endmodule
