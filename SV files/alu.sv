`timescale 10ps/1fs
module alu(A, B, cntrl, result, negative, zero, overflow, carry_out);
	input logic [63:0] A, B;
	input logic [2:0] cntrl; 
	output logic negative, zero, overflow, carry_out; 
	output logic [63:0] result;
	
	bitSlice64 ALU (.out(result), .zero, .overflow, .negative, .carryOut(carry_out), .A, .B, .select_bits(cntrl));

endmodule


module alustim();

	parameter delay = 100000;

	logic		[63:0]	A, B;
	logic		[2:0]		cntrl;
	logic		[63:0]	result;
	logic					negative, zero, overflow, carry_out ;

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	

	alu dut (.A, .B, .cntrl, .result, .negative, .zero, .overflow, .carry_out);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	integer i;
	logic [63:0] test_val;
	initial begin
	
		$display("%t testing PASS_B operations", $time);
		cntrl = ALU_PASS_B;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end
		
		$display("%t testing ADD operations", $time);
		cntrl = ALU_ADD;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == A + B && negative == result[63] && zero == (A + B == '0));
		end
		
		$display("%t testing SUB operations", $time);
		cntrl = ALU_SUBTRACT;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == A - B && negative == result[63] && zero == (A - B == '0));
		end
		
		$display("%t testing AND operations", $time);
		cntrl = ALU_AND;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == (A & B) && negative == result[63] && zero == (A & B == '0));
		end
		
		$display("%t testing OR operations", $time);
		cntrl = ALU_OR;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == (A | B) && zero == (result == '0));
			
		end
		
		
		$display("%t testing XOR operations", $time);
		cntrl = ALU_XOR;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			#(delay);
			assert(result == (A ^ B) && zero == (result == '0));
			
		end
		
		$display("%t testing addition", $time);
		cntrl = ALU_ADD;
		A = 64'h0000000000000001; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h0000000000000002 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		
//		$display("%t testing OR", $time);
//		cntrl = ALU_OR;
//		A = 64'h0000000000000101; B = 64'h0000000000000011;
//		#(delay);
//		assert(result == 64'h0000000000000111 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
//		
//		$display("%t testing XOR", $time);
//		cntrl = ALU_OR;
//		A = 64'h0000000000000101; B = 64'h0000000000000110;
//		#(delay);
//		assert(result == 64'h0000000000000011 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		
		
$stop;		
	end
endmodule

