module DFFwithEnable (q, d, enable, reset, clk);
	output reg q;
	input d, enable, reset, clk;
	always_ff @(posedge clk)
	if (reset)
		q <= 0; // On reset, set to 0
	else if(enable)
		q <= d; // Otherwise out = d
	else begin
		q <= q; 
	end

endmodule


	
	