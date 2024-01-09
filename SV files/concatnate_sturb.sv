module concatenate_sturb(rd, datamem, out);
	input logic [7:0] rd; 
	input logic [63:0] datamem; 
	output logic [63:0] out;
	
	assign out = {datamem[63:8], rd[7:0]};
endmodule
