module ID_EX #(

parameter width_source = 5, 
parameter width_imm_Gen = 6 

) 

(

//INPUTS
input 		wire  	                        MEM_REG_i, REG_EN_i, ALU_Src_i, ALU_OP_i, M_Rd_En_i, M_Wr_En_i,   
input 		wire                            CLK, rst_n,
input 		wire                            IF_ID_RS1, IF_ID_RS2, IF_ID_Rd,
input 		wire  [width_source - 1 : 0]    Rs1_i, Rs2_i, 
input 		wire  [width_imm_Gen - 1 : 0]   IMM_Gen_i, 

//OUTPUTS  
output 		reg  	                       MEM_REG_o, REG_EN_o, ALU_Src_o, ALU_OP_o, M_Rd_En_o, M_Wr_En_o,   
output 		reg                            ID_EX_RS1, ID_EX_RS2, ID_EX_Rd,
output 		reg  [width_source - 1 : 0]    Rs1_o, Rs2_o, 
output 		reg  [width_imm_Gen - 1 : 0]   IMM_Gen_o 
 );


	always @(posedge CLK)
		begin
			if (~rst_n)
				begin
					MEM_REG_o <= 1'b0 ; 
					REG_EN_o  <= 1'b0 ; 
					ALU_Src_o <= 1'b0 ;
					ALU_OP_o  <= 1'b0 ;
					M_Rd_En_o <= 1'b0 ;
					M_Wr_En_o <= 1'b0 ;
					
					ID_EX_RS1 <= 1'b0 ; 
					ID_EX_RS2 <= 1'b0 ;
					ID_EX_Rd  <= 1'b0 ;
					
					Rs1_o     <= 'b0 ;   
					Rs2_o     <= 'b0 ;
					IMM_Gen_o <= 'b0 ;	
					
				end
			
					
			else 
				begin
					MEM_REG_o <=   MEM_REG_i ;
					REG_EN_o  <=   REG_EN_i  ;
					ALU_Src_o <=   ALU_Src_i ;
					ALU_OP_o  <=   ALU_OP_i  ;
					M_Rd_En_o <=   M_Rd_En_i ;
					M_Wr_En_o <=   M_Wr_En_i ;
					
					ID_EX_RS1 <=   IF_ID_RS1 ; 
					ID_EX_RS2 <=   IF_ID_RS2 ;
					ID_EX_Rd  <=   IF_ID_Rd  ;
					
					Rs1_o     <=  Rs1_i      ;  
					Rs2_o     <=  Rs2_i      ;
					IMM_Gen_o <=  IMM_Gen_i  ;
				
				end
		
		end 
		
		
endmodule 
 