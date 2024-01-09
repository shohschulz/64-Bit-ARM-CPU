`timescale 1ns/10ps
module zeroChecker(out, in);
	input logic [63:0] in; 
	output logic out; 
	
	logic [15:0] outNor; 
	
	genvar j; 
	
	generate
		for(j = 0; j < 16; j++) begin : norGen
			
			nor #5 (outNor[j], in[4*(j + 1) - 1], in[4*(j + 1) - 2], in[4*(j + 1) - 3], in[4*(j + 1) - 4]);
		end
	endgenerate
	
	logic [3:0] outAnd;
		
	genvar k; 
	
	generate
		for(k = 0; k < 4; k++) begin : andGen
		
			and #5 (outAnd[k], outNor[4*(k + 1) - 1], outNor[4*(k + 1) - 2], outNor[4*(k + 1) - 3], outNor[4*(k + 1) - 4]);
		end
	
	endgenerate
	
	and #5 (out, outAnd[3], outAnd[2], outAnd[1], outAnd[0]);

endmodule
