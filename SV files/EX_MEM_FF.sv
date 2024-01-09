module EX_MEM_FF (
	alu_out, outRd, outDataIn, //data
	reg_wr, mem_wr, mem_rd, ldurb, transfer, //control
	aluMem, dataInMem, rdMem, //data out
	reg_wr_mem, mem_wr_mem, mem_rd_mem, ldurb_mem, transfer_mem,//control out
	clk, reset
);
	input logic clk, reset;
	input logic [63:0] alu_out, outDataIn;
	input logic [4:0] outRd;
	input logic reg_wr, mem_wr, mem_rd, ldurb;
	input logic [3:0] transfer; 
	
	output logic [63:0] aluMem, dataInMem;
	output logic [4:0] rdMem; 
	output logic reg_wr_mem, mem_wr_mem, mem_rd_mem, ldurb_mem;
	output logic [3:0] transfer_mem;
	
	DFF64 aluMem1 (.q(aluMem), .d(alu_out), .reset, .clk);
	DFF64 dataInMem1 (.q(dataInMem), .d(outDataIn), .reset, .clk);
	DFF5 rd1 (.q(rdMem), .d(outRd), .reset, .clk);
	D_FF reg_wr1 (.q(reg_wr_mem), .d(reg_wr), .reset, .clk);
	D_FF mem_wr1 (.q(mem_wr_mem), .d(mem_wr), .reset, .clk);
	D_FF mem_rd1 (.q(mem_rd_mem), .d(mem_rd), .reset, .clk);
	D_FF ldurb1 (.q(ldurb_mem), .d(ldurb), .reset, .clk);
	DFF4 transfer1 (.q(transfer_mem), .d(transfer), .reset, .clk);
	
endmodule
