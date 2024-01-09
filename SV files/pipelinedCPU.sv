//Calculate branch in decode, wire zero checker to brTaken immediately. 
`timescale 1ns/10ps
module pipelinedCPU (reset, clk);
	input logic clk, reset; 
		
	//Instruction Fetch ----------------------------------
		//all logic in procedural order--------------------
		logic [31:0] instruction;
		logic [63:0] pc;
		logic [63:0] incrementedAddress;
		logic [63:0] brOut;
		logic [63:0] branchAddress;
		logic [4:0] out_rd;
		logic [4:0] out_rn; 
		logic [4:0] out_rm; 
		logic [1:0] shamt; 
		logic [8:0] imm9;
		logic [11:0] imm12;
		logic [15:0] imm16;
		logic [18:0] imm19;
		logic [25:0] imm26;
		logic [10:0] opcode;
		
		logic [63:0] se_imm9;
		logic [63:0] ze_imm12;
		logic [63:0] se_imm19;
		logic [63:0] se_imm26;
		logic [63:0] shifted26, shifted19;
		logic [63:0] const_src;
		logic [63:0] shift0, shift1, shift2, shift3;
		logic [63:0]shamt_movz;
		logic [63:0] movz_movk; 
		logic [63:0] unc_br_mux_out;
		
		logic [63:0] shft0, shft1, shft2, shft3; //shifted outputs of MOVK 
		logic [63:0] shamt_movk;
		logic [63:0] secondB;
		logic [63:0] preForwardB;
		logic [63:0] postMovk;
		logic [4:0] rd_rm_sel;
		
		logic [63:0] data_a, data_b;
		logic clk_bar;
		logic [1:0] ForwardA, ForwardB, ForwardData;
		logic ForwardFlag; //control
		logic [63:0] forwardAOut, forwardBOut, forwardDataOut; //data wires into Ex
		logic reg2loc, reg_wr, unc_br, br_tkn,//Decode
		alu_src, imm_add, set_flg, //Execute
		mem_wr, mem_rd, //Memory
		ldurb, movz, movk; //Write back
		logic [2:0] alu_op; 
		logic [3:0] transfer;
		logic nn_flag, nz_flag, nv_flag, nc_flag; //not registered
		logic z_flag, n_flag, v_flag, c_flag; //registered
		
		logic [63:0] outDataA, outDataB, outDataIn; //data out
		logic [4:0] outRd; //data out 
		logic outreg_wr, outmem_wr, outmem_rd, outset_flg, outldurb; //control out
		logic [2:0] outalu_op; 
		logic [3:0] outtransfer;
		
		logic [63:0] aluA, aluB;
		logic [63:0] alu_out;
		logic [63:0] aluMem, dataInMem;	//outputs of EX/MEM
		logic [4:0] rdMem; 
		logic reg_wr_mem, mem_wr_mem, mem_rd_mem, ldurb_mem;
		logic [3:0] transfer_mem;
		
		logic [63:0] datamem_out;
		logic [63:0] zeroExtendedLdurb;
		logic [63:0] ldurbOut;
		logic [63:0] write; 
		
		logic finalRegWr;
		logic [4:0] finalRd;
		logic [63:0] finalWriteData;
		//-------------------------------------------------
	instructmem selecting (.address(pc), .instruction, .clk);
	fullAdder64 addressIncremented (.out(incrementedAddress), .A(pc), .B(64'h4));
	mux64x2_1 br_tkn1 (.output_data(brOut), .input_a(incrementedAddress), .input_b(branchAddress), .select(br_tkn));
	DFF64 pc1 (.q(pc), .d(brOut), .reset, .clk);
	//----------------------------------------------------
	
	//IF/ID-----------------------------------------------
		logic [31:0] registeredInstruction;
		logic [63:0] registeredPC; 
	IF_ID_FF IFID (.registeredInstruction, .instruction, .registeredPC, .pc, .clk, .reset); // still needs wires for input 
	
	//----------------------------------------------------
	
	//Instruction Decode----------------------------------
		
		
		//outputs out of IF/ID 
		assign opcode = registeredInstruction[31:21]; //only for R-type
		assign out_rd = registeredInstruction[4:0];
		assign out_rn = registeredInstruction[9:5];
		assign out_rm = registeredInstruction[20:16];
		assign shamt = registeredInstruction[22:21];
		assign imm9 = registeredInstruction[20:12];
		assign imm12 = registeredInstruction[21:10];
		assign imm19 = registeredInstruction[23:5];
		assign imm26 = registeredInstruction[25:0];
		assign imm16 = registeredInstruction[20:5];
	//Pre-Forwarding
   signExtension #(.width(19)) se_19_module (.in(imm19), .out(se_imm19));
   signExtension se_26 (.in(imm26), .out(se_imm26));
   signExtension #(.width(9)) se_9_module (.in(imm9), .out(se_imm9));
	zeroExtension #(.width(12)) ze_12_module (.in(imm12), .out(ze_imm12));
	leftShift2 left_shift_2(.imm26(se_imm26), .imm19(se_imm19), .shifted26, .shifted19);
	mux64x2_1 imm_add_mux ( .output_data(const_src), .input_a(ze_imm12), .input_b(se_imm9),.select(imm_add)); // mux to select between sign-extended 9-bit and zero-extended 12-bit immediate values
	movzInputs movz1 (.imm16, .shift0, .shift1, .shift2, .shift3); //generates our imm16 shifted by 4 different amounts
	mux64x4_1 movzShamt(.output_bits(shamt_movz), .input_bits_0(shift0), .input_bits_1(shift1), .input_bits_2(shift2), .input_bits_3(shift3), .select_bits(shamt)); //chooses between a shifted movz
	mux64x2_1 immMovz(.output_data(movz_movk), .input_a(const_src), .input_b(shamt_movz), .select(movz)); //compares movz and imm
	movkInputs k(.rd(forwardBOut), .imm16(imm16), .shft0, .shft1, .shft2, .shft3); //generates movk shifted 4 diff amounts 
	mux64x4_1 movkShamt(.output_bits(shamt_movk), .input_bits_0(shft0), .input_bits_1(shft1), .input_bits_2(shft2), .input_bits_3(shft3), .select_bits(shamt)); //chooses between a shifted movk
	mux64x2_1 finalMux(.output_data(postMovk), .input_a(forwardBOut), .input_b(shamt_movk), .select(movk));
	mux64x2_1 alu_src_mux (.output_data(preForwardB),.input_a(data_b),.input_b(movz_movk),.select(alu_src));
	
	mux64x2_1 uncond_branch(.output_data(unc_br_mux_out), .input_a(shifted19), .input_b(shifted26), .select(unc_br));
	fullAdder64 branchAddress1 (.out(branchAddress), .A(registeredPC), .B(unc_br_mux_out));
	
	mux5x2_1 reg2loc1 (.output_data(rd_rm_sel), .input_a(out_rd), .input_b(out_rm), .select(reg2loc));
	//wr_data will come from the end of the last stage, reg_wr comes later as well, 
		 
		not(clk_bar, clk); 
	regfile reg_f (.ReadData1(data_a), .ReadData2(data_b), .WriteData(finalWriteData), .ReadRegister1(out_rn), .ReadRegister2(rd_rm_sel), .WriteRegister(finalRd), .RegWrite(finalRegWr), .clk(clk_bar));
		//outputs from regfile
		
		logic fastZero;
	zeroChecker accelBranch (.out(fastZero), .in(postMovk));
	
	//Forwarding -----------------------------------------------------------------------------------------------------------
		
	
	mux64x4_1 forwardA1(.output_bits(forwardAOut), .input_bits_0(data_a), .input_bits_1(write), .input_bits_2(alu_out), .input_bits_3(0), .select_bits(ForwardA));
	mux64x4_1 forwardB1(.output_bits(forwardBOut), .input_bits_0(preForwardB), .input_bits_1(write), .input_bits_2(alu_out), .input_bits_3(0), .select_bits(ForwardB));
	mux64x4_1 forwardData1(.output_bits(forwardDataOut), .input_bits_0(data_b), .input_bits_1(write), .input_bits_2(alu_out), .input_bits_3(0), .select_bits(ForwardData)); //STUR directly after LDUR, address and information both reliant on LDUR
	forwarding_unit fwd(.ForwardA, .ForwardB, .ForwardData, .ForwardFlag, .RegWriteEx(outreg_wr), .RegWriteMem(reg_wr_mem), .RdEx(outRd), .RdMem(rdMem), .Rn(out_rn), .Rm(out_rm), .Rd(out_rd), .movk, .Set_Flags(outset_flg), .opcode, .memWrEx(outmem_wr), .memWrMem(mem_wr_mem));	
		//forward unit in progress.
		//when Rn and Rm are reliant on RdEx
	// ---------------------------------------------------------------------------------------------------------------------
	
		
		
	processor_cntrl controlling (
		.reg2loc, .reg_wr, .unc_br,//Decode
		.alu_src, .alu_op, .imm_add, .set_flg, .br_tkn, //Execute
		.mem_wr, .mem_rd, //Memory
		.ldurb, .movz, .movk, .transfer, //Write back
		.z_flag, .n_flag, .v_flag, .c_flag, // Registered ALU Flags
		.nz_flag, .nn_flag, .nv_flag, .nc_flag, // ALU flags combinational 
		.fastZero, .ForwardFlag, .instr(registeredInstruction)//Accelerate Branch aka fast zero
	);
		
		 
	//----------------------------------------------------
	
	//ID/EX-----------------------------------------------
		
		
	ID_EX_FF IDEX (
	.outDataA, .outDataB, .outDataIn, .outRd, //data out
	.outreg_wr, .outmem_wr, .outmem_rd, .outalu_op, .outset_flg, .outldurb, .outtransfer, //control signals
	.dataA(forwardAOut), .dataB(postMovk), .dataIn(forwardDataOut), .rd(out_rd), //data in
	.reg_wr, .mem_wr, .mem_rd, .alu_op, .set_flg, .ldurb, .transfer, //control in
	.clk, .reset 
	); 
	
	//Execute------------------------------------------------------------------------
	
		
		
		
	alu init_alu (.A(outDataA),.B(outDataB),.cntrl(outalu_op),.result(alu_out),.negative(nn_flag),.zero(nz_flag),.overflow(nv_flag),.carry_out(nc_flag));
	
	DFFwithEnable make_z  (.q(z_flag), .d(nz_flag), .clk, .reset, .enable(outset_flg));
   DFFwithEnable make_neg (.q(n_flag), .d(nn_flag), .clk, .reset, .enable(outset_flg));
   DFFwithEnable set_carryout (.q(c_flag), .d(nc_flag), .clk, .reset, .enable(outset_flg));
   DFFwithEnable set_overflow (.q(v_flag), .d(nv_flag), .clk, .reset, .enable(outset_flg));
	//--------------------------------------------------------------------------------
	
	//EX/MEM----------------------------------------------
	   
	EX_MEM_FF exmem (
		.alu_out, .outRd, .outDataIn, //data in 
		.reg_wr(outreg_wr), .mem_wr(outmem_wr), .mem_rd(outmem_rd), .ldurb(outldurb), .transfer(outtransfer), //control
		.aluMem, .dataInMem, .rdMem, //data out
		.reg_wr_mem, .mem_wr_mem, .mem_rd_mem, .ldurb_mem, .transfer_mem,//control out
		.clk, .reset
	);	
	
	//Memory
		
	datamem mem_store (.address(aluMem), .write_enable(mem_wr_mem), .read_enable(mem_rd_mem), .write_data(dataInMem), .clk, .xfer_size(transfer_mem), .read_data(datamem_out));
	zeroExtension ldurb1 (.in(datamem_out[7:0]), .out(zeroExtendedLdurb));
	mux64x2_1 LDURB (.output_data(ldurbOut), .input_a(datamem_out), .input_b(zeroExtendedLdurb), .select(ldurb_mem));
	mux64x2_1 memToReg (.output_data(write), .input_a(aluMem), .input_b(ldurbOut), .select(mem_rd_mem));
	//----------------------------------------------------
	
	//MEM/WB
		
	MEM_WB_FF memwb (.reg_wr_mem, .writeData(write), .rd(rdMem), .finalRegWr, .finalWriteData, .finalRd, .clk, .reset);
	//----------------------------------------------------
	
	//WriteBack, just write data to register inputs
	
endmodule

module pipelinedCPU_testbench();

    // we set a smaller delay to match the timescale and for quicker simulations
    parameter delay = 100; // this delay should represent  the half-period of the clock signal.

    logic reset;
    logic clk;

    pipelinedCPU dut (.reset(reset), .clk(clk));

    // set up the clock with a period of `delay * 2`
    initial begin
        clk = 0;
        forever #(delay) clk = ~clk; // toggle the clock every 10 ns for a 50MHz clock
    end
    
    initial begin
        $display("%t: Starting testbench", $time);
        reset = 1;  // assert reset
        #delay;		  // wait half a clock cycle to ensure reset setup time is met
		  #delay;
		  #delay; 
		  #delay;
		  #delay;
        reset = 0;  // deassert reset to start the CPU
        
        // we will let the simulation run for a certain number of cycles
        for (int i = 0; i < 1500; i++) begin
            @(posedge clk); // waiting for the positive edge of the clock
        end
        $display("%t: Testbench completed", $time);
        $stop; // just gonna stop the simulation
    end
    
endmodule
