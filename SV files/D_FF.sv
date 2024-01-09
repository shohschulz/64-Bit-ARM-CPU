module D_FF (q, d, reset, clk);
	output reg q;
	input d, reset, clk;
	always_ff @(posedge clk)
	if (reset)
		q <= 0; // On reset, set to 0
	else
		q <= d; // Otherwise out = d

endmodule


module DFF64WithEnable(q, d, enable, reset, clk);
	output logic [63:0] q;
	input logic [63:0] d;
	input logic enable;
	input logic clk;
	input logic reset;
	logic [63:0] data;
	genvar i;
	
	generate 
		for (i = 0; i < 64; i++) begin : generate_statement
			mux2_1 select (.output_bit(data[i]), .input_bit_0(q[i]), .input_bit_1(d[i]), .select_bit(enable));
			
			D_FF dffSubmodule(.q(q[i]), .d(data[i]), .reset, .clk);
		end
	endgenerate
endmodule

//32 registers
module DFF32x64 (out, in, clk, reset);
	input logic [31:0] out;
	input logic clk, reset;
	output logic [31:0] in;
	
	genvar i;
	
	generate 
		for (i = 0; i < 32; i++) begin : generate_statement
			DFF64 register(.q(out[i]), .d(in[i]));
		end
	endgenerate
endmodule
module D_FF64tb();

logic [63:0] q, d;
logic enable, reset, clk;

parameter CLOCK_PERIOD = 100;
	initial begin 
		clk <= 0; 
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

DFF64 dut(.*);

initial begin 
	q <= 150; enable <= 1; @(posedge clk);
									  @(posedge clk);
	reset <= 1; 				  @(posedge clk);
	reset <= 0; 				  @(posedge clk);
	$stop;
	end
 	
endmodule
