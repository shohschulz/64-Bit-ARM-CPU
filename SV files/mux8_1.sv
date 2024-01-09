`timescale 10ps/1fs 
module mux8_1(output_bit, input_bits, select_bits);
	input logic [7:0]input_bits; 
	input logic [2:0]select_bits; 
	output logic output_bit; 
	
	logic mid, mid2;
	//more sig
	mux4_1 mx41 (.output_bit(mid), .input_bits(input_bits[7:4]), .select_bits(select_bits[1:0])); 
	//less sig
	mux4_1 mx412 (.output_bit(mid2), .input_bits(input_bits[3:0]), .select_bits(select_bits[1:0])); 
	
	mux2_1 mux21 (.output_bit, .input_bit_0(mid2), .input_bit_1(mid), .select_bit(select_bits[2]));
	
endmodule

module mux81tb (); 

	 logic [7:0]input_bits;
	 logic [2:0]select_bits; 
	 logic output_bit; 
	
	mux8_1 dut (.*); 
	
	initial begin 
	
	integer i;
	
	for (int i = 0; i < 8; i++) begin
		select_bits = i;
		input_bits = 8'b10101010;
		#50;
	end
	$stop;
	end

endmodule
