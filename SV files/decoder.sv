`timescale 1ns/10ps

module decoder2to4(o1, o2, o3, o4, i1, i2, enable);
	output logic o1, o2, o3, o4; 
	input logic i1, i2, enable; 
	
	not(noti1, i1); 
	not(noti2, i2);
	not(noti3, i3);
	
	and #0.05 (o1, noti1, noti2, enable); 
	and #0.05(o2, i1, noti2, enable); 
	and #0.05(o3, noti1, i2, enable); 
	and #0.05(o4, i1, i2, enable); 
	
endmodule

module decoder3to8(o1, o2, o3, o4, o5, o6, o7, o8, i1, i2, i3, enable);

	output logic o1, o2, o3, o4, o5, o6, o7, o8;
	input logic i1, i2, i3, enable;
	logic noti1, noti2, noti3;
	
	not(noti1, i1); 
	not(noti2, i2);
	not(noti3, i3);
	
	and #0.05(o1, noti1, noti2, noti3, enable); 
	and #0.05(o2, i1, noti2, noti3, enable); 
	and #0.05(o3, noti1, i2, noti3, enable); 
	and #0.05(o4, i1, i2, noti3, enable); 
	and #0.05(o5, noti1, noti2, i3, enable); 
	and #0.05(o6, i1, noti2, i3, enable); 
	and #0.05(o7, noti1, i2, i3, enable); 
	and #0.05(o8, i1, i2, i3, enable); 
	
endmodule

module decoder5to32(out, in, enable);

		input logic [4:0] in;
		input logic enable; 
		logic [3:0] mid;
		output logic [31:0]out;
	
	decoder2to4 d24SubModule (.o1(mid[0]), .o2(mid[1]), .o3(mid[2]), .o4(mid[3]), .i1(in[3]), .i2(in[4]), .enable);
	
	decoder3to8 d38SubModule1 (.o1(out[0]), .o2(out[1]), .o3(out[2]), .o4(out[3]), .o5(out[4]), .o6(out[5]), .o7(out[6]), .o8(out[7]), .i1(in[0]), .i2(in[1]), .i3(in[2]), .enable(mid[0]));
	
	decoder3to8 d38SubModule2 (.o1(out[8]), .o2(out[9]), .o3(out[10]), .o4(out[11]), .o5(out[12]), .o6(out[13]), .o7(out[14]), .o8(out[15]), .i1(in[0]), .i2(in[1]), .i3(in[2]), .enable(mid[1]));
	
	decoder3to8 d38SubModule3 (.o1(out[16]), .o2(out[17]), .o3(out[18]), .o4(out[19]), .o5(out[20]), .o6(out[21]), .o7(out[22]), .o8(out[23]), .i1(in[0]), .i2(in[1]), .i3(in[2]), .enable(mid[2]));
	
	decoder3to8 d38SubModule4 (.o1(out[24]), .o2(out[25]), .o3(out[26]), .o4(out[27]), .o5(out[28]), .o6(out[29]), .o7(out[30]), .o8(out[31]), .i1(in[0]), .i2(in[1]), .i3(in[2]), .enable(mid[3]));
	
endmodule

module decoder5to32tb(); 

	logic [4:0] in;
   logic enable; 
		
	logic [31:0]out;
	integer idx;
initial begin 
		for (idx = 0; idx < 32; idx++) begin
            enable = 1;
				in = idx;
            #10;
        end
$stop;
end

decoder5to32 dut (.*);

endmodule
