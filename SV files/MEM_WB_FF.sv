module MEM_WB_FF(reg_wr_mem, writeData, rd, finalRegWr, finalWriteData, finalRd, clk, reset);
	input logic clk, reset;
	input logic reg_wr_mem;
	input logic [4:0] rd;
	input logic [63:0] writeData; 
	output logic finalRegWr;
	output logic [63:0] finalWriteData; 
	output logic [4:0] finalRd;
	
	DFF64 data (.q(finalWriteData), .d(writeData), .reset, .clk);
	D_FF reg_wr1 (.q(finalRegWr), .d(reg_wr_mem), .reset, .clk);
	DFF5 finalRd1 (.q(finalRd), .d(rd), .reset, .clk);
	
endmodule

