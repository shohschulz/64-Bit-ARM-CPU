`timescale 10ps/1fs 
module fullAdder(sum, cout, a, b, cin);
	input logic a, b, cin; 
	output logic sum, cout; 
	logic middle;
	logic coutMid;
	logic abAnd;
		
	 
	 xor #5 (middle, a, b);
	 xor #5 (sum, cin, middle);
	 and #5 (coutMid, middle, cin);
	 and #5 (abAnd, a, b);
	 or  #5 (cout, coutMid, abAnd);

endmodule

module fullAddertb(); 

	 logic a, b, cin; 
	 logic sum, cout; 
	 
	 fullAdder dut (.*);
	 
	 initial begin
	 
	 a = 1; b = 1; cin = 0; #50;
	 //cout = 1; sum = 0;
	 a = 1; b = 1; cin = 1; #50;
	 //cout = 1; sum = 0;
	 a = 0; b = 0; cin = 0; #50;
	 //cout = 0; sum = 0; 
	 a = 1; b = 0; cin = 0; #50;
	 //cout = 0; sum = 1;
	 a = 0; b = 1; cin = 0; #50;
	 //cout = 0; sum = 1;
	 $stop;
	end
	
endmodule 
