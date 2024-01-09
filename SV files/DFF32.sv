module DFF32(q, d, reset, clk);
	output logic [31:0] q;
	input logic [31:0] d;
	input logic clk;
	input logic reset;
	genvar i;
	
	generate 
		for (i = 0; i < 32; i++) begin : generate_statement
			D_FF dffSubmodule(.q(q[i]), .d(d[i]), .reset, .clk);
		end
	endgenerate
endmodule
