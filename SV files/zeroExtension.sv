//parameter can be overriden in module instantiation
//extends zeros to 64 bits. 
module zeroExtension #(parameter width = 8) (in, out); 
	input logic [width-1:0] in;
	output logic [63:0] out;
	
	integer i; 
	always_comb begin
		for(i = 0; i < width; i++) begin
			out[i] = in[i];
		end
		
		for(i = width; i < 64; i++) begin
			out[i] = 0;
		end
	end

endmodule
