module forwarding_unit(ForwardA, ForwardB, ForwardData, ForwardFlag, RegWriteEx, RegWriteMem, RdEx, RdMem, Rn, Rm, Rd, movk, Set_Flags, opcode, memWrEx, memWrMem);

    //might be more inputs that are missing that are from the diagram
    input logic [4:0] RdEx, RdMem, Rn, Rm, Rd; 
    input logic RegWriteEx, RegWriteMem, Set_Flags, movk, memWrEx, memWrMem;
	 input logic [10:0] opcode;
	output logic [1:0] ForwardA, ForwardB, ForwardData;  
	output logic ForwardFlag; 
	
	always_comb begin 
		//-----------------------------------------------------------------
		if ((RegWriteEx) & (RdEx != 5'b11111) & (RdEx == Rn)) begin
			ForwardA = 2'b10;
      end 
      else if ((RegWriteMem) & (RdMem != 5'b11111) & (RdMem == Rn)) begin 
			ForwardA = 2'b01;
      end 
      
		else begin
            ForwardA = 2'b00;
      end
		//------------------------------------------------------------------
		if((RegWriteEx) & (RdEx != 5'b11111) & (RdEx == Rd) & ((movk) || (opcode[10:3] == 8'b10110100))) begin //Movk & cbz
			ForwardB = 2'b10;
		end	
		else if ((RegWriteMem) & (RdMem != 5'b11111) & (RdMem == Rd) & ((movk) || (opcode[10:3] == 8'b10110100))) begin //Movk & cbz
			ForwardB = 2'b01;
		end
		else if ((RegWriteEx) & (RdEx != 5'b11111) & (RdEx == Rm) & ((opcode == 11'b10101011000) || (opcode == 11'b11101011000))) begin //Rtype
			ForwardB = 2'b10;
		end
		else if ((RegWriteMem) & (RdMem != 5'b11111) & (RdMem == Rm) & ((opcode == 11'b10101011000) || (opcode == 11'b11101011000))) begin //Rtype
			ForwardB = 2'b01;
		end
		else begin
			ForwardB = 2'b00;
		end
		//------------------------------------------------------------------
		if ((RegWriteEx) & (RdEx != 5'b11111) & (RdEx == Rd) & (!memWrEx) & ((opcode == 11'b11111000000) || (opcode == 11'b00111000000))) begin //stur after any instruction
			ForwardData = 2'b10; 
		end
		else if ((RegWriteMem) & (RdMem != 5'b11111) & (RdMem == Rd) & (!memWrMem) & ((opcode == 11'b11111000000) || (opcode == 11'b00111000000))) begin //if its stur, filler, stur  
			ForwardData = 2'b01;
		end 
		else begin
			ForwardData = 2'b00;
		end
		//-----------------------------------------------------------------
		if(Set_Flags) begin
			ForwardFlag = 1; 
		end
		else begin
			ForwardFlag = 0; 
		end
	end
endmodule

////Forwarding Unit
//
////note: reliant on memory stage or execution stage 
//
//module forwarding_unit(ForwardA, ForwardB, ForwardData, ForwardFlag, RegWriteEx, RegWriteMem, RdEx, RdMem, Rn, Rm, Rd, movk, Set_Flags, opcode, memWrEx, memWrMem);
//
//    //might be more inputs that are missing that are from the diagram
//    input logic [4:0] RdEx, RdMem, Rn, Rm, Rd; 
//    input logic RegWriteEx, RegWriteMem, Set_Flags, movk, memWrEx, memWrMem;
//	 input logic [10:0] opcode;
//	output logic [1:0] ForwardA, ForwardB, ForwardData;  
//	output logic ForwardFlag; 
//    always_comb begin
//         
//
//        //EX hazard:
//        // Checks if RegWriteEx is true 
//        // Then checks if RdEx not equal to 31 
//        // Checks if RdEx (next) is the same as Rn (prev) in the current instruction
//        if ((RegWriteEx) & (RdEx != 5'b11111) & (RdEx == Rn)) begin
//			ForwardA = 2'b10;
//        end 
//        //Mem hazard:
//        // check whats coming out of Rmux
//        else if ((RegWriteMem) & (RdMem != 5'b11111) & (RdMem == Rn)) begin 
//			ForwardA = 2'b01;
//        end 
//        else begin
//            ForwardA = 2'b00;
//        end
//  
//
//        
//
//			//if the current instruction is movk and it needs forwarding then forwardB is true
//			//if the current instruction is stur or sturb then forwarding must
//			
//		//-------------------------------------------------------------------------------------
//        if ((RegWriteEx) & (RdEx != 5'b11111) & (RdEx == Rd)) begin 
//				if( ((opcode == 11'b11111000000) || (opcode == 11'b00111000000)) & (!memWrEx) ) begin
//					 //stur or sturb after anything
//						ForwardData = 2'b10;
//						ForwardB = 2'b00;
//				end
//				else if (movk) begin
//					ForwardB = 2'b10;
//					ForwardData = 2'b00;
//				end
//				else begin
//					ForwardData = 2'b00;
//					ForwardB = 2'b00; //stur after stur
//				end
//		  end 
//		  
//        else if ((RegWriteMem) & (RdMem != 5'b11111) & (RdMem == Rd)) begin 
//			if( (opcode == 11'b11111000000) || (opcode == 11'b00111000000) ) begin
//				ForwardData = 2'b01; //stur after ldur
//				ForwardB = 2'b00;
//			end
//			else if (movk) begin
//			ForwardData = 2'b00;
//			ForwardB = 2'b10;
//			end
//				else begin
//				ForwardData = 2'b00;
//				ForwardB = 2'b00;
//			  end
//		  end 
//        
//		//---------------------------------------------------------------------------------------
//		//Ex Hazard:
//        else if ((RegWriteEx) & (RdEx != 5'b11111) & (RdEx == Rm) & ((opcode == 11'b10101011000) || (opcode == 11'b11101011000)) ) begin //opcode corresponds to adds subs
//			ForwardB = 2'b10;
//		end 
//        // Mem hazard:
//        else if ((RegWriteMem) & (RdMem != 5'b11111) & (RdMem == Rm) & ((opcode == 11'b10101011000) || (opcode == 11'b11101011000) )) begin
//			ForwardB = 2'b01;
//		end 
//        else begin
//			ForwardB = 2'b00;
//			ForwardData = 2'b00;
//		end
//		
//      //if previous instruction sets the flags and the current instruction is a branch we need the immdiate value
//		if(Set_Flags) begin
//			ForwardFlag = 1; 
//		end
//		else ForwardFlag = 0; 
//	end
//endmodule
