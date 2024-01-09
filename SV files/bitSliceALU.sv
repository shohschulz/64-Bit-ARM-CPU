`timescale 10ps/1fs
module bitSliceALU (out, cout, cin, a, b, select_bits);
	input logic a, b, cin;
	input logic [2:0] select_bits;
	output logic out, cout; 
	
	logic [5:0] muxIn;
	logic mux2Out;
	//logic adderOut;
	
	
	 xor #5 (muxIn[5], a, b);
	 or #5 (muxIn[4], a, b);
	 and #5 (muxIn[3], a, b);
	 not #5 (bNeg, b);
	
	fullAdder add(.sum(muxIn[2]), .cout, .a, .b(mux2Out), .cin);
	
	// still needs multiply/divide functionality
	
	mux2_1 m21 (.output_bit(mux2Out), .input_bit_0(b), .input_bit_1(bNeg), .select_bit(select_bits[0]));
	
	//2 most sig inputs dont care, only need 6
	mux8_1 m81 (.output_bit(out), .input_bits({1'b0, muxIn[5], muxIn[4], muxIn[3], muxIn[2], muxIn[2], 1'b0, b}), .select_bits);
	
endmodule

module bitSliceALUtb();
	logic a, b, cin;
	logic [2:0] select_bits;
	logic out, cout; 
	
	bitSliceALU dut (.*);
	
	initial begin
	
	a = 1; b = 1; select_bits = 3'b010; cin = 0; #500;
	
	a = 0; b = 1; select_bits = 3'b010; cin = 0; #500;
	//sub
	a = 1; b = 1; select_bits = 3'b011; cin = 0; #500;
	
	a = 1; b = 1; select_bits = 3'b101; cin = 0; #500;
	$stop;
	end

endmodule


module bitSlice64 (out, zero, overflow, negative, carryOut, A, B, select_bits);
	output logic zero, overflow, carryOut, negative; 
	output logic [63:0] out; 
	input logic [63:0] A, B;
	input logic [2:0] select_bits;
	logic [63:0] w;
	
	
	//for S0 input for first bitSlice
	bitSliceALU first (.out(out[0]), .cout(w[0]), .cin(select_bits[0]), .a(A[0]), .b(B[0]), .select_bits(select_bits[2:0]));
	genvar i; 
	generate 
		
		for(i = 1; i < 63; i++) begin : bsGenerate
					//do I want to wire select bits to every bit slice
					//figure out select bits logic
					bitSliceALU all (.out(out[i]), .cout(w[i]), .cin(w[i - 1]), .a(A[i]), .b(B[i]), .select_bits(select_bits[2:0]));
		end
	endgenerate
	//for carryOut and negative logic
	bitSliceALU last (.out(out[63]), .cout(carryOut), .cin(w[62]), .a(A[63]), .b(B[63]), .select_bits(select_bits[2:0]));
	
	
	xor #5 (overflow, carryOut, w[62]);
	
	//dont want to destroy data, so must set negative to the value of the last bit output, instead of directly wiring
	assign negative = out[63];
	
	//#0.05 nor(zero, out[63:0]);
	
	logic [15:0] outNor;
	
		//fencepost
		
	genvar j; 
	
	generate
		for(j = 0; j < 16; j++) begin : norGen
			
			nor #5 (outNor[j], out[4*(j + 1) - 1], out[4*(j + 1) - 2], out[4*(j + 1) - 3], out[4*(j + 1) - 4]);
		end
	
	endgenerate
	
	logic [3:0] outAnd;
		
		//fencepost
		
	genvar k; 
	
	generate
		for(k = 0; k < 4; k++) begin : andGen
		
			and #5 (outAnd[k], outNor[4*(k + 1) - 1], outNor[4*(k + 1) - 2], outNor[4*(k + 1) - 3], outNor[4*(k + 1) - 4]);
		end
	
	endgenerate
	
	and #5 (zero, outAnd[3], outAnd[2], outAnd[1], outAnd[0]); 

endmodule

	
	
		
