//assumption: Instruction memory inputs a 64 bit number.
//extends most significant bit
module signExtension #(parameter width =  26) (in, out); 
	input logic [width-1:0] in;
	output logic [63:0] out;
	integer i; 
	always_comb begin
		for(int i = 0; i < width; i++) begin
			out[i] = in[i];
		end
		for(int i = width; i < 64; i++) begin
			out[i] = in[width - 1];
		end
	end

endmodule
