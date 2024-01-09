//control signals needed: reg_wr, mem_wr, mem_rd, alu_op, set_flg, ldurb, transfer
//control signal done with: reg2loc, br_tkn, unc_br, alu_src, imm_add, movk, movz
module ID_EX_FF (
	outDataA, outDataB, outDataIn, outRd, //data out
	outreg_wr, outmem_wr, outmem_rd, outalu_op, outset_flg, outldurb, outtransfer, //control signals
	dataA, dataB, dataIn, rd, //data in
	reg_wr, mem_wr, mem_rd, alu_op, set_flg, ldurb, transfer, //control in
	clk, reset 
);
	input logic clk, reset;
	input logic [63:0] dataA, dataB, dataIn; //data in
	input logic [4:0] rd; //data in
	input logic [2:0] alu_op;
	input logic [3:0] transfer;
	input logic reg_wr, mem_wr, mem_rd, set_flg, ldurb; //control in
	
	output logic [63:0] outDataA, outDataB, outDataIn; //data out
	output logic [4:0] outRd; //data out
	output logic [2:0] outalu_op; //control out
	output logic [3:0] outtransfer; //control out
	output logic outreg_wr, outmem_wr, outmem_rd, outset_flg, outldurb; //control out
	
	//control
	D_FF reg_wr1 (.q(outreg_wr), .d(reg_wr), .reset, .clk);
	D_FF mem_wr1 (.q(outmem_wr), .d(mem_wr), .reset, .clk);
	D_FF mem_rd1 (.q(outmem_rd), .d(mem_rd), .reset, .clk);
	DFF3 alu_op1 (.q(outalu_op), .d(alu_op), .reset, .clk);
	D_FF set_flg1 (.q(outset_flg), .d(set_flg), .reset, .clk);
	D_FF ldurb1 (.q(outldurb), .d(ldurb), .reset, .clk);
	DFF4 transfer1 (.q(outtransfer), .d(transfer), .reset, .clk);
	
	//data
	
	DFF64 dataA1 (.q(outDataA), .d(dataA), .reset, .clk);
	DFF64 dataB1 (.q(outDataB), .d(dataB), .reset, .clk);
	DFF64 dataIn1 (.q(outDataIn), .d(dataIn), .reset, .clk);
	DFF5 rd1 (.q(outRd), .d(rd), .reset, .clk);
	
endmodule
