module DFF3(q, d, reset, clk);
	output logic [2:0] q;
	input logic [2:0] d;
	input logic clk;
	input logic reset;
	genvar i;
	
	generate 
		for (i = 0; i < 3; i++) begin : generate_statement			
			D_FF dffSubmodule(.q(q[i]), .d(d[i]), .reset, .clk);
		end
	endgenerate
endmodule