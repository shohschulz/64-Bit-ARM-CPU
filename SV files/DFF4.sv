module DFF4(q, d, reset, clk);
	output logic [3:0] q;
	input logic [3:0] d;
	input logic clk;
	input logic reset;
	genvar i;
	
	generate 
		for (i = 0; i < 4; i++) begin : generate_statement			
			D_FF dffSubmodule(.q(q[i]), .d(d[i]), .reset, .clk);
		end
	endgenerate
endmodule