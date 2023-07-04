(* DONT_TOUCH = "TRUE" *) module ID_EX_REG #(
	parameter IMM_GEN = 32,
	parameter XLEN    = 32,
	parameter FLEN    = 32
)
(
	////////////////////////// INPUT //////////////////////
	input wire 				 CLK,
	input wire          	 rst_n,
	// PC src
	input wire [31:0] 		 PC_I,
	input wire [6:0]         Opcode_I,
	input wire               Branch_I,
	input wire               Jump_I,
	// IMM src
	input wire [IMM_GEN-1:0] IMM_I,
	// ALU Function Decision
	input wire [2:0]         Funct3_I,
	input wire [6:0]         Funct7_I,
	// RegFiles srcs
	input wire [XLEN-1:0]    iRs1_I,
	input wire [XLEN-1:0]    iRs2_I,
	input wire [FLEN-1:0]    fRs1_I,
	input wire [FLEN-1:0]    fRs2_I,
	input wire [XLEN-1:0]    imem_wb_data,
	input wire [FLEN-1:0]    fmem_wb_data,
	input wire [1:0]		 iSrc_to_Reg_I,
	input wire 		         fSrc_to_Reg_I,
	input wire  		     RegI_Wr_En_I,
	input wire 			     RegF_Wr_En_I,
	input wire [4:0]       	 if_id_rs1,
	input wire [4:0]      	 if_id_rs2,
	input wire [4:0]      	 if_id_rd,
	input wire [4:0]         mem_wb_rd,
	input wire               ireg_mem_wb_wr,
	input wire               freg_mem_wb_wr,
	// ALU srcs
	input wire				 int_op_I,
	input wire			     fp_op_I,
	input wire       		 Sub_I,
	input wire               IDiv_I,
	input wire 		 		 IALU_Src1_Sel_I,
	input wire 		 		 IALU_Src2_Sel_I,
	input wire 		 		 FALU_Src1_Sel_I,
	input wire [2:0]         IALU_Ctrl_I,
	input wire [2:0]         FALU_Ctrl_I,
	// Memory srcs
	input wire               store_src_I,
	input wire 		         MEM_Wr_En_I,
	////////////////////////// OUTPUT //////////////////////
	// PC src
	output reg [31:0] 		 PC_O,
	output reg [6:0]         Opcode_O,
	output reg        		 Branch_O,
	output reg               Jump_O,
	// IMM src
	output reg [IMM_GEN-1:0] IMM_O,
	// ALU Function Decision
	output reg [2:0]         Funct3_O,
	output reg [6:0]         Funct7_O,
	// RegFiles srcs
	output reg [XLEN-1:0]    iRs1_O,
	output reg [XLEN-1:0]    iRs2_O,
	output reg [FLEN-1:0]    fRs1_O,
	output reg [FLEN-1:0]    fRs2_O,
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
	output reg       		 Sub_O,
	output reg               IDiv_O,
	output reg 		 		 IALU_Src1_Sel_O,
	output reg 		 		 IALU_Src2_Sel_O,
	output reg 		 		 FALU_Src1_Sel_O,
	output reg [2:0]         IALU_Ctrl_O,
	output reg [2:0]         FALU_Ctrl_O,
	// Memory srcs
	output reg               store_src_O,
	output reg 		 		 MEM_Wr_En_O
);

reg [XLEN-1:0] passed_irs1;
reg [XLEN-1:0] passed_irs2;
reg [FLEN-1:0] passed_frs1;
reg [FLEN-1:0] passed_frs2;

always @(posedge CLK,negedge rst_n) begin
	
	if (!rst_n) begin
		PC_O 		    <= 'b0;
		Branch_O 	    <= 1'b0;
		Jump_O          <= 1'b0;
		IMM_O 		    <= 'b0;
		Opcode_O        <= 7'b0;
		Funct3_O        <= 'b0;
		Funct7_O        <= 7'b0;
		iSrc_to_Reg_O   <= 2'b0;
		fSrc_to_Reg_O   <= 1'b0;
		RegI_Wr_En_O    <= 1'b0;
		RegF_Wr_En_O    <= 1'b0;
		id_ex_rs1       <= 'b0;
		id_ex_rs2 	    <= 'b0;
		id_ex_rd 	    <= 'b0;
		int_op_O        <= 1'b0;
		fp_op_O         <= 1'b0;
		IDiv_O          <= 1'b0;
		IALU_Src1_Sel_O <= 1'b0;
		IALU_Src2_Sel_O <= 1'b0;
		FALU_Src1_Sel_O <= 1'b0;
		IALU_Ctrl_O     <= 3'b0;
		FALU_Ctrl_O     <= 3'b0;
		Sub_O        	<= 1'b0;
		store_src_O     <= 1'b0;
		MEM_Wr_En_O     <= 1'b0;
		iRs1_O          <= 32'b0;
		iRs2_O          <= 32'b0;
		fRs1_O          <= 32'b0;
		fRs2_O          <= 32'b0;
	end
	else begin
		PC_O 		    <= PC_I;
		Branch_O 	    <= Branch_I;
		Jump_O          <= Jump_I;
		Opcode_O        <= Opcode_I;
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
		IDiv_O          <= IDiv_I;
		IALU_Src1_Sel_O <= IALU_Src1_Sel_I;
		IALU_Src2_Sel_O <= IALU_Src2_Sel_I;
		FALU_Src1_Sel_O <= FALU_Src1_Sel_I;
		IALU_Ctrl_O     <= IALU_Ctrl_I;
		FALU_Ctrl_O     <= FALU_Ctrl_I;
		Sub_O        	<= Sub_I;
		iRs1_O          <= passed_irs1;
		iRs2_O          <= passed_irs2;
		fRs1_O          <= passed_frs1;
		fRs2_O          <= passed_frs2;
		store_src_O     <= store_src_I;
		MEM_Wr_En_O     <= MEM_Wr_En_I;
		iSrc_to_Reg_O   <= iSrc_to_Reg_I;
		fSrc_to_Reg_O   <= fSrc_to_Reg_I;
	end

end

always @(*) begin
	passed_irs1 = iRs1_I;
	passed_frs1 = fRs1_I;
	if ((mem_wb_rd == if_id_rs1) && ireg_mem_wb_wr) begin
		passed_irs1 = imem_wb_data;
	end
	else if ((mem_wb_rd == if_id_rs1) && freg_mem_wb_wr) begin
		passed_frs1 = fmem_wb_data;
	end
	else begin
		passed_irs1 = iRs1_I;
		passed_frs1 = fRs1_I;
	end
end
always @(*) begin
	passed_irs2 = iRs2_I;
	passed_frs2 = fRs2_I;
	if ((mem_wb_rd == if_id_rs2) && ireg_mem_wb_wr) begin
		passed_irs2 = imem_wb_data;
	end
	else if ((mem_wb_rd == if_id_rs2) && freg_mem_wb_wr) begin
		passed_frs2 = fmem_wb_data;
	end
	else begin
		passed_irs2 = iRs2_I;
		passed_frs2 = fRs2_I;
	end
end

endmodule