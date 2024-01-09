//produces 4 shifted outputs, each begin shifted by a increasing multiple of 16.
module movkInputs(rd, imm16, shft0, shft1, shft2, shft3);
	input logic [63:0] rd;
	input logic [15:0] imm16; 
	output logic [63:0] shft0, shft1, shft2, shft3;
	
	assign shft0 = {rd[63:16], imm16};
	assign shft1 = {rd[63:32], imm16, rd[15:0]};
	assign shft2 = {rd[63:48], imm16, rd[31:0]};
	assign shft3 = {imm16, rd[47:0]};
endmodule
