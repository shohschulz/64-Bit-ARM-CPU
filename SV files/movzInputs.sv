//inputs: imm16
//outputs: imm16 begin shifted multiple ways. 
module movzInputs(imm16, shift0, shift1, shift2, shift3); 
	input logic [15:0] imm16;
	output logic [63:0] shift0, shift1, shift2, shift3;
	
	assign shift0 = {48'b0, imm16};
	assign shift1 = {32'b0, imm16, 16'b0};
	assign shift2 = {16'b0, imm16, 32'b0};
	assign shift3 = {imm16, 48'b0}; 
endmodule
