module fullAdder64 (A, B, out); 

	output logic [63:0] out; 
	input logic [63:0] A, B; 
	logic [63:0] w;
	
	fullAdder first(.sum(out[0]), .cout(w[0]), .a(A[0]), .b(B[0]), .cin(1'b0));
	
	genvar i;
	
	generate 
		for (i = 1; i < 64; i++) begin : adder
			fullAdder rest (.sum(out[i]), .cout(w[i]), .a(A[i]), .b(B[i]), .cin(w[i-1]));
		end
	endgenerate
	
endmodule

