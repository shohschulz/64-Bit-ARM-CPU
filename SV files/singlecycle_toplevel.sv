//Top level that is essentially the single-cycle cpu

`timescale 1ns/10ps

module singlecycle_toplevel(reset, clk);
    input logic reset, clk;

    // control signals
    logic reg2loc, reg_wr, mem_wr, br_tkn, unc_br, set_flg, mem_rd;
	 logic ldurb, sturb, movk, movz;
    logic z_flag, n_flag, v_flag, c_flag;   //zero flag, negative flag, overflow flag, carryout flag (
    logic nz_flag, nn_flag, nv_flag, nc_flag;   // new_zero flag, new_negative flag, new_overflow flag, new_carryout flag
    logic alu_src, imm_add;
	 logic [3:0] transfer;
   
    //Answer (Shoh): If these adders are for the program counter than yes. They need to be 64 bit. I'm assuming these adders to the "alus with + symbol in them"
    //from the diagram 
    
    logic adder1_c_out, adder2_c_out;

    // register  write source and ALU ops
    logic [1:0] wr_src;
    logic [2:0] alu_op;

  
    // immediate  values  
    logic [8:0] imm9;
    logic [11:0] imm12;
	 logic [15:0] imm16;
    logic [18:0] imm19;
    logic [25:0] imm26;

    // register identifiers
    logic [4:0] out_rd, out_rn, out_rm;
    logic [4:0] rd_rm_sel;
    logic [1:0] shamt;

    //sign extensions
    logic [63:0] se_imm19, ze_imm12, se_imm9, se_imm26;

    // main instruction
    logic [31:0] instr;

    // data paths
    logic [63:0] alu_in, alu_out;
    logic [63:0] datamem_out;
	 logic [63:0] after_mux_datamem;
	 logic [63:0] zero_extended;
	 logic [63:0] ldurb_movz;
    logic [63:0] pc, final_pc, const_src;
    logic [63:0] wr_data, br_tkn_mux_out, unc_br_mux_out;
    logic [63:0] data_a, data_b;
    
    //NOTE: these need to be figured out
    //Answer(Shoh): I have provided a shifter module for the specific functionality we are looking for called leftShift2.sv, wherever you see
    // "<<2" in the diagram, you can use the LeftShift2 module. 
    logic [63:0] shifter1_out, shifter2_out;
    logic [63:0] adder1_out, adder2_out;



    // sign extension modules
    signExtension #(.width(19)) se_19_module (.in(imm19), .out(se_imm19));
    signExtension se_26_module (.in(imm26), .out(se_imm26));
    signExtension #(.width(9)) se_9_module (.in(imm9), .out(se_imm9));

    // zero extension modules
    zeroExtension #(.width(12)) ze_12_module (.in(imm12), .out(ze_imm12));

    /*  
        PC update logic (intialized it here)

        Answer(Shoh): We will need a 64_2 mux. Not a 64_32. The WhichBranch signal from the diagram is one bit, and will only choosing between
        branching or not branching. (PC = PC + 4 or PC = PC + (output of Adder2))
    */
    logic [63:0] pcWire; 
	 //updating pc
	 mux64x2_1 setUp (.output_data(pcWire), .input_a(br_tkn_mux_out), .input_b(64'b0), .select(reset));
    DFF64 update_pc (.q(pc), .d(br_tkn_mux_out), .enable(1), .reset, .clk);
	 instructmem selecting (.address(pc), .instruction(instr), .clk);
    //unconditional branching 
    mux64x2_1 uncond_branch(.output_data(unc_br_mux_out), .input_a(shifter2_out), .input_b(shifter1_out), .select(unc_br));
    
	 //NOTE: IF YOUR CODE DOESNT WORK THEN ONE OF THE FIRST PLACES TO LOOK ARE THE ADDER1, ADDER2, LEFTSHIFT IMPLEMENTATIONS IN THIS FILE
    leftShift2 left_shift_2(.imm26(se_imm26), .imm19(se_imm19), .shifted26(shifter1_out), .shifted19(shifter2_out)); 

    // filling the rest bits after shifting
    

    fullAdder64 adder1 (.out(adder1_out), .A(pc), .B(unc_br_mux_out));
    fullAdder64 adder2 (.out(adder2_out), .A(pc), .B(64'h4)); // NOTE: I set B to that assuming  we are just adding 4 to the PC for the sequential instruction

    // branch taken mux 
	 mux64x2_1 branch_tkn_mux (.output_data(br_tkn_mux_out), .input_a(adder2_out), .input_b(adder1_out), .select(br_tkn));

    //need to find and select insttruction. you will need to use the  pc to do so
    
    
    processor_cntrl controlling (.out_rd, .out_rn, .out_rm,  .reg2loc, .alu_src, .alu_op, .reg_wr, .mem_wr, .br_tkn, .unc_br, 
                                .set_flg, .mem_rd, .imm9, .imm12, .imm19, .imm26, .imm16, .shamt, 
                                .instr, .z_flag, .n_flag, .v_flag, .c_flag, .nz_flag, .nn_flag, .nv_flag, .nc_flag,  .imm_add,
										  .ldurb, .sturb, .movk, .movz, .transfer, .wr_src);


    //regfile handling
    mux5x2_1 conn_rd_rm(rd_rm_sel, out_rd, out_rm, reg2loc);
    regfile reg_f (.ReadData1(data_a), .ReadData2(data_b), .WriteData(wr_data), .ReadRegister1(out_rn), .ReadRegister2(rd_rm_sel), .WriteRegister(out_rd), .RegWrite(reg_wr), .clk(clk));

    // ALU handling and operations
    mux64x2_1 imm_add_mux ( .output_data(const_src), .input_a(ze_imm12), .input_b(se_imm9),.select(imm_add)); // mux to select between sign-extended 9-bit and zero-extended 12-bit immediate values
    mux64x2_1 alu_src_mux (.output_data(alu_in),.input_a(data_b),.input_b(const_src),.select(alu_src)); // mux to select between register data and constant source for the ALU input
    alu init_alu (.A(data_a),.B(alu_in),.cntrl(alu_op),.result(alu_out),.negative(nn_flag),.zero(nz_flag),.overflow(nv_flag),.carry_out(nc_flag)); // ALU instantiation

    //setting flag
    DFFwithEnable make_z  (.q(z_flag), .d(nz_flag), .clk, .reset, .enable(set_flg));
    DFFwithEnable make_neg (.q(n_flag), .d(nn_flag), .clk, .reset, .enable(set_flg));
    DFFwithEnable set_carryout (.q(c_flag), .d(nc_flag), .clk, .reset, .enable(set_flg));
    DFFwithEnable set_overflow (.q(v_flag), .d(nv_flag), .clk, .reset, .enable(set_flg));

    //utilizing the data memory file
    datamem mem_store (.address(alu_out), .write_enable(mem_wr), .read_enable(mem_rd), .write_data(data_b), .clk, .xfer_size(transfer), .read_data(datamem_out));
	 
	 //sturb stuff
	 
	 
	 
	 //rest
	 
	 mux64x2_1 memToReg (.output_data(after_mux_datamem), .input_a(alu_out), .input_b(datamem_out), .select(mem_rd));
	 
	 zeroExtension ZE (.in(after_mux_datamem[7:0]), .out(zero_extended));
	 
	 mux64x2_1 LDURB (.output_data(ldurb_movz), .input_a(after_mux_datamem), .input_b(zero_extended), .select(ldurb));
	 
	 
	 logic [63:0] shift0, shift1, shift2, shift3; 
	 
	 movzInputs z(.imm16, .shift0, .shift1, .shift2, .shift3);
	 
	 logic[63:0]shamt_movz;
	 logic[63:0]movz_movk;
	 
	 mux64x4_1 movzShamt(.output_bits(shamt_movz), .input_bits_0(shift0), .input_bits_1(shift1), .input_bits_2(shift2), .input_bits_3(shift3), .select_bits(shamt));
	 mux64x2_1 movz1(.output_data(movz_movk), .input_a(ldurb_movz), .input_b(shamt_movz), .select(movz));
	 
	 logic [63:0] shft0, shft1, shft2, shft3;
	 logic [63:0] shamt_movk;
	 
	 movkInputs k(.rd(data_b), .imm16(imm16), .shft0, .shft1, .shft2, .shft3);
	 mux64x4_1 movkShamt(.output_bits(shamt_movk), .input_bits_0(shft0), .input_bits_1(shft1), .input_bits_2(shft2), .input_bits_3(shft3), .select_bits(shamt));
	 
	 
	 
	 mux64x2_1 write(.output_data(wr_data), .input_a(movz_movk), .input_b(shamt_movk), .select(movk));

endmodule



`timescale 1ns/10ps

module singlecycle_toplevel_testbench();

    // we set a smaller delay to match the timescale and for quicker simulations
    parameter delay = 10; // this delay should represent  the half-period of the clock signal.

    logic reset;
    logic clk;

    singlecycle_toplevel dut (.reset(reset), .clk(clk));

    // set up the clock with a period of `delay * 2`
    initial begin
        clk = 0;
        forever #(delay) clk = ~clk; // toggle the clock every 10 ns for a 50MHz clock
    end
    
    initial begin
        $display("%t: Starting testbench", $time);
        reset = 1;  // assert reset
        #delay;     // wait half a clock cycle to ensure reset setup time is met
        @(posedge clk);// deassert reset to start the CPU
        @(posedge clk);
		  reset = 0;
        // we will let the simulation run for a certain number of cycles
        for (int i = 0; i < 1000; i++) begin
            @(posedge clk); // waiting for the positive edge of the clock
        end
        $display("%t: Testbench completed", $time);
        $stop; // just gonna stop the simulation
    end
    
endmodule
