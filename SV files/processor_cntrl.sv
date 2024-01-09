// Control Logic for Processor Datapath Signal Decoding
`timescale 1ns / 10ps

// Decodes the 32-bit opcode from the instruction and sets control signals for the processor's datapath.
module processor_cntrl (
		reg2loc, reg_wr, unc_br,//Decode
		alu_src, alu_op, imm_add, set_flg, br_tkn, //Execute
		mem_wr, mem_rd, //Memory
		ldurb, movz, movk, transfer, //Write back
		z_flag, n_flag, v_flag, c_flag, // ALU Flags: Zero, Negative, Overflow, Carry out
		nz_flag, nn_flag, nv_flag, nc_flag, // Updated ALU Flags
		fastZero, ForwardFlag, instr
	);

	
    input logic z_flag, n_flag, v_flag, c_flag;
    input logic nz_flag, nn_flag, nv_flag, nc_flag;
    input logic fastZero, ForwardFlag;
	 input logic [31:0] instr;
    output logic reg2loc, reg_wr, mem_wr, br_tkn;
    output logic unc_br, set_flg, mem_rd, alu_src;
    output logic imm_add;
	 output logic ldurb, movk, movz;
	 output logic [3:0] transfer; 
    output logic [2:0] alu_op;
    
   
    
    // Opcodes as parameters
    parameter ADDI = 	10'b1001000100;
    parameter ADDS = 	11'b10101011000;
	parameter B = 		6'b000101;               
	parameter BLT =		8'b01010100;             
	parameter CBZ = 	8'b10110100;  
	parameter STUR = 	11'b11111000000;        
	parameter SUBS = 	11'b11101011000;                   
	parameter LDUR = 	11'b11111000010;
	parameter LDURB = 11'b00111000010; 
	parameter STURB = 11'b00111000000;
	parameter LSL = 	11'b11010011011;			
	parameter LSR = 	11'b11010011010;         
	parameter MOVZ =  9'b110100101;
	parameter MOVK =  9'b111100101;
	// Set control signals based on the current instruction opcode
	always_comb begin
		if (instr[31:22] == ADDI) begin
			reg2loc  = 1'bx;
			imm_add  = 1'b0;
			alu_src  = 1'b1;
			reg_wr   = 1'b1;
			mem_wr   = 1'b0;
			set_flg  = 1'b0; 
			br_tkn   = 1'b0;
			unc_br   = 1'bx;
			alu_op   = 3'b010;
			mem_rd   = 1'b0;
			
			ldurb    = 1'b0;
			movz     = 1'b0;
			movk     = 1'b0;
			transfer = 4'bxxxx;
			
		end
		else if (instr[31:21] == ADDS) begin
			reg2loc = 1'b1;
			imm_add  = 1'bx;
			alu_src  = 1'b0;
			reg_wr  = 1'b1;
			mem_wr  = 1'b0;
			set_flg  = 1'b1;
			br_tkn   = 1'b0;
			unc_br   = 1'bx;
			alu_op   = 3'b010;
			mem_rd   = 1'b0;
			
			ldurb    = 1'b0;
			movz     = 1'b0;
			movk     = 1'b0;
			transfer = 4'bxxxx;
		end
		else if (instr[31:26] == B) begin
			reg2loc  = 1'bx;
			imm_add  = 1'bx;
			alu_src  = 1'bx;
			reg_wr  = 1'b0;
			mem_wr  = 1'b0;
			set_flg   = 1'b0;
			br_tkn   = 1'b1;
			unc_br   = 1'b1;
			alu_op     = 3'bxxx;
			mem_rd   = 1'b0;
			
			ldurb    = 1'bx;
			movz     = 1'bx;
			movk     = 1'bx;
			transfer = 4'bxxxx;
		end
		else if (instr[31:24] == BLT) begin // what is instr[4:0], why do we care
			reg2loc  = 1'bx;
			imm_add  = 1'bx;
			alu_src  = 1'bx;
			reg_wr  = 1'b0;
			mem_wr  = 1'b0;
			set_flg  = 1'b0;
			//send in wire from EX to check if the EX instruction is ADDS or SUBS
			//if previous set_flags instruction is true
			if(ForwardFlag) begin 
				br_tkn  = (nv_flag != nn_flag);
			end
			else br_tkn = (v_flag != n_flag);
			unc_br   = 1'b0;
			alu_op   = 3'bxxx;
			mem_rd   = 1'b0;
			
			ldurb    = 1'bx;
			movz     = 1'bx;
			movk     = 1'bx;
			transfer = 4'bxxxx;
		end
		else if (instr[31:24] == CBZ) begin
			reg2loc  = 1'b0;
			imm_add   = 1'bx;
			alu_src   = 1'b0;
			reg_wr  = 1'b0;
			mem_wr  = 1'b0;
			set_flg   = 1'b0;
			//fast flag
			br_tkn   = fastZero;
			unc_br   = 1'b0;
			alu_op     = 3'b000;
			mem_rd   = 1'b0;
			
			ldurb    = 1'bx;
			movz     = 1'bx;
			movk     = 1'b0;
			transfer = 4'bxxxx;
		end
		else if (instr[31:21] == LDUR) begin
			reg2loc  = 1'bx;
			imm_add   = 1'b1;
			alu_src   = 1'b1;
			reg_wr  = 1'b1;
			mem_wr  = 1'b0;
			set_flg   = 1'b0;
			br_tkn   = 1'b0;
			unc_br   = 1'bx;
			alu_op     = 3'b010;
			mem_rd   = 1'b1;
			
			ldurb    = 1'b0;
			movz     = 1'b0;
			movk     = 1'b0;
			transfer = 4'b1000;
		end
		else if (instr[31:21] == STUR) begin
			reg2loc  = 1'b0;
			imm_add  = 1'b1;
			alu_src  = 1'b1;
			reg_wr   = 1'b0;
			mem_wr   = 1'b1;
			set_flg  = 1'b0;
			br_tkn   = 1'b0;
			unc_br   = 1'bx;
			alu_op   = 3'b010;
			mem_rd   = 1'b0;
			
			
			ldurb    = 1'b0;
			movz     = 1'b0;
			movk     = 1'b0;
			transfer = 4'b1000;
		end
		else if (instr[31:21] == SUBS) begin
			reg2loc  = 1'b1;
			imm_add  = 1'bx;
			alu_src  = 1'b0;
			reg_wr   = 1'b1;
			mem_wr   = 1'b0;
			set_flg  = 1'b1;
			br_tkn   = 1'b0;
			unc_br   = 1'bx;
			alu_op   = 3'b011;
			mem_rd   = 1'b0;
			
			
			ldurb    = 1'b0;
			movz     = 1'b0;
			movk     = 1'b0;
			transfer = 4'bxxxx;
		end
		else if (instr[31:21] == LDURB) begin
			reg2loc = 1'bx;
			imm_add  = 1'b1;
			alu_src  = 1'b1;
			reg_wr  = 1'b1;
			mem_wr  = 1'b0;
			set_flg  = 1'b0; 
			br_tkn   = 1'b0;
			unc_br   = 1'bx;
			alu_op   = 3'b010;
			mem_rd   = 1'b1;
			//ldurb
			
			ldurb    = 1'b1;
			movz     = 1'b0;
			movk     = 1'b0;
			transfer = 4'b0001;
		end
		else if (instr[31:21] == STURB) begin
			reg2loc = 1'b0;
			imm_add  = 1'b1;
			alu_src  = 1'b1;
			reg_wr  = 1'b0;
			mem_wr  = 1'b1;
			set_flg  = 1'b0; 
			br_tkn   = 1'b0;
			unc_br   = 1'bx;
			alu_op   = 3'b010;
			mem_rd   = 1'b0;
			
			
			ldurb    = 1'bx;
			movz     = 1'b0;
			movk     = 1'b0;
			transfer = 4'b0001;
		end
		else if (instr[31:23] == MOVZ) begin
			reg2loc = 1'bx;
			imm_add  = 1'bx;
			alu_src  = 1'b1;
			reg_wr  = 1'b1;
			mem_wr  = 1'b0;
			set_flg  = 1'b0; 
			br_tkn   = 1'b0;
			unc_br   = 1'bx;
			alu_op   = 3'b000;
			mem_rd   = 1'b0;
			
			
			ldurb    = 1'b0;
			movz     = 1'b1;
			movk     = 1'b0;
			transfer = 4'bxxxx;
		end
		
		else if (instr[31:23] == MOVK) begin
			reg2loc = 1'b0; 
			imm_add  = 1'bx;
			alu_src  = 1'bx;
			reg_wr  = 1'b1;
			mem_wr  = 1'b0;
			set_flg  = 1'b0; 
			br_tkn   = 1'b0;
			unc_br   = 1'bx;
			alu_op   = 3'b000;
			mem_rd   = 1'b0;
			
			
			ldurb    = 1'bx;
			movz     = 1'bx;
			movk     = 1'b1;
			transfer = 4'bxxxx;
		end
		
		else begin
			// When the operation is not recognized, default to not writing or reading from memory or registers.
			reg2loc  = 1'b0;
			imm_add   = 1'b0;
			alu_src   = 1'b0;
			reg_wr  = 1'b0;
			mem_wr  = 1'b0;
			set_flg   = 1'b0;
			br_tkn   = 1'b0;
			unc_br   = 1'b0;
			alu_op     = 3'b000;
			mem_rd   = 1'b0;
			
			ldurb    = 1'b0;
			movz     = 1'b0;
			movk     = 1'b0;
		end
	end
endmodule

