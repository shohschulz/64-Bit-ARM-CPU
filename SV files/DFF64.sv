module DFF64(q, d, reset, clk);
	output logic [63:0] q;
	input logic [63:0] d;
	input logic clk;
	input logic reset;
	genvar i;
	
	generate 
		for (i = 0; i < 64; i++) begin : generate_statement			
			D_FF dffSubmodule(.q(q[i]), .d(d[i]), .reset, .clk);
		end
	endgenerate
endmodule
