module ID_EX_REG #(
	parameter IMM_GEN 		 = 32
)
(
	////////////////////////// INPUT //////////////////////
	input wire 				 CLK,
	input wire          	 rst_n,
	// PC src
	input wire [31:0] 		 PC_I,
	input wire               Branch_I,
	input wire               Jump_I,
	// IMM src
	input wire [IMM_GEN-1:0] IMM_I,
	// ALU Function Decision
	input wire [2:0]         Funct3_I,
	input wire [6:0]         Funct7_I,
	// RegFiles srcs
	input wire [1:0]		 iSrc_to_Reg_I,
	input wire 		         fSrc_to_Reg_I,
	input wire  		     RegI_Wr_En_I,
	input wire 			     RegF_Wr_En_I,
	input wire [4:0]       	 if_id_rs1,
	input wire [4:0]      	 if_id_rs2,
	input wire [4:0]      	 if_id_rd,
	// ALU srcs
	input wire				 int_op_I,
	input wire			     fp_op_I,
    input wire				 i2f_op_I,
	input wire       		 Add_Op_I,
	input wire               IDiv_I,
	input wire 		 		 IALU_Src1_Sel_I,
	input wire 		 		 IALU_Src2_Sel_I,
	input wire 		 		 FALU_Src1_Sel_I,
	input wire [2:0]         IALU_Ctrl_I,
	input wire [2:0]         FALU_Ctrl_I,
	// Memory srcs
	input wire               store_src_I,
	input wire 		         MEM_Rd_En_I,
	input wire 		         MEM_Wr_En_I,
	input wire               LB_I,
	input wire               LH_I,
	input wire               SB_I,
	input wire               SH_I,
	////////////////////////// OUTPUT //////////////////////
	// PC src
	output reg [31:0] 		 PC_O,
	output reg        		 Branch_O,
	output reg               Jump_O,
	// IMM src
	output reg [IMM_GEN-1:0] IMM_O,
	// ALU Function Decision
	output reg [2:0]         Funct3_O,
	output reg [6:0]         Funct7_O,
	// RegFiles srcs
	output reg [1:0]		 iSrc_to_Reg_O,
	output reg 		         fSrc_to_Reg_O,
	output reg  		     RegI_Wr_En_O,
	output reg 			     RegF_Wr_En_O,
	output reg [4:0]         id_ex_rs1,
	output reg [4:0]         id_ex_rs2,
	output reg [4:0]         id_ex_rd,
	// ALU srcs
	output reg				 int_op_O,
	output reg			     fp_op_O,
    output reg				 i2f_op_O,
	output reg       		 Add_Op_O,
	output reg               IDiv_O,
	output reg 		 		 IALU_Src1_Sel_O,
	output reg 		 		 IALU_Src2_Sel_O,
	output reg 		 		 FALU_Src1_Sel_O,
	output reg [2:0]         IALU_Ctrl_O,
	output reg [2:0]         FALU_Ctrl_O,
	// Memory srcs
	output reg               store_src_O,
	output reg 		 		 MEM_Rd_En_O,
	output reg 		 		 MEM_Wr_En_O,
	// output reg 		 		 Src_to_Reg_O,
	output reg               LB_O,
	output reg               LH_O,
	output reg               SB_O,
	output reg               SH_O
);

always @(posedge CLK,negedge rst_n) begin
	
	if (!rst_n) begin
		PC_O 		    <= 'b0;
		Branch_O 	    <= 1'b0;
		Jump_O          <= 1'b0;
		IMM_O 		    <= 'b0;
		Funct3_O        <= 'b0;
		// Funct7_5_3_2_O  <= 'b0;
		iSrc_to_Reg_O   <= 2'b0;
		fSrc_to_Reg_O   <= 1'b0;
		RegI_Wr_En_O    <= 1'b0;
		RegF_Wr_En_O    <= 1'b0;
		id_ex_rs1       <= 'b0;
		id_ex_rs2 	    <= 'b0;
		id_ex_rd 	    <= 'b0;
		int_op_O        <= 1'b0;
		fp_op_O         <= 1'b0;
		i2f_op_O        <= 1'b0;
		IDiv_O          <= 1'b0;
		IALU_Src1_Sel_O <= 1'b0;
		IALU_Src2_Sel_O <= 1'b0;
		FALU_Src1_Sel_O <= 1'b0;
		IALU_Ctrl_O     <= 3'b0;
		FALU_Ctrl_O     <= 3'b0;
		Add_Op_O        <= 1'b0;
		store_src_O     <= 1'b0;
		MEM_Rd_En_O     <= 1'b0;
		MEM_Wr_En_O     <= 1'b0;
		// Src_to_Reg_O    <= 1'b0;
		LB_O            <= 1'b0;
		LH_O            <= 1'b0;
		SB_O            <= 1'b0;
		SH_O            <= 1'b0;
	end
	else begin
		PC_O 		    <= PC_I;
		Branch_O 	    <= Branch_I;
		Jump_O          <= Jump_I;
		IMM_O 		    <= IMM_I;
		Funct3_O        <= Funct3_I;
		Funct7_O 		<= Funct7_I;
		iSrc_to_Reg_O   <= iSrc_to_Reg_I;
		fSrc_to_Reg_O   <= fSrc_to_Reg_I;
		RegI_Wr_En_O    <= RegI_Wr_En_I;
		RegF_Wr_En_O    <= RegF_Wr_En_I;
		id_ex_rs1       <= if_id_rs1;
		id_ex_rs2 	    <= if_id_rs2;
		id_ex_rd 	    <= if_id_rd;
		int_op_O        <= int_op_I;
		fp_op_O         <= fp_op_I;
		i2f_op_O        <= i2f_op_I;
		IDiv_O          <= IDiv_I;
		IALU_Src1_Sel_O <= IALU_Src1_Sel_I;
		IALU_Src2_Sel_O <= IALU_Src2_Sel_I;
		FALU_Src1_Sel_O <= FALU_Src1_Sel_I;
		IALU_Ctrl_O     <= IALU_Ctrl_I;
		FALU_Ctrl_O     <= FALU_Ctrl_I;
		Add_Op_O        <= Add_Op_I;
		store_src_O     <= store_src_I;
		MEM_Rd_En_O     <= MEM_Rd_En_I;
		MEM_Wr_En_O     <= MEM_Wr_En_I;
		iSrc_to_Reg_O   <= iSrc_to_Reg_I;
		fSrc_to_Reg_O   <= fSrc_to_Reg_I;
		LB_O            <= LB_I;
		LH_O            <= LH_I;
		SB_O            <= SB_I;
		SH_O            <= SH_I;
	end

end

endmodule