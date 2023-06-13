module EX_MEM_REG #(
	parameter XLEN           = 32,
	parameter FLEN           = 32,
	parameter IMM_GEN 		 = 32
)
(
	////////////////////////// INPUT //////////////////////
	input wire 				 CLK,
	input wire          	 rst_n,
	// PC src
	input wire [31:0] 		 PC_I,
	// RegFiles srcs
	input wire [1:0]		 iSrc_to_Reg_I,
	input wire 		         fSrc_to_Reg_I,
	// input wire [XLEN-1:0]    irs2_I,
	// input wire [FLEN-1:0]    frs2_I,
	input wire  		     RegI_Wr_En_I,
	input wire 			     RegF_Wr_En_I,
	input wire [4:0]      	 id_ex_rd,
	// ALU srcs
	input wire               IDiv,
	input wire               div_done,
	input wire				 int_op_I,
	input wire			     fp_op_I,
    input wire				 i2f_op_I,
	// Memory srcs
	input wire   [XLEN-1:0]  store_to_mem_I,
	input wire 		         MEM_Rd_En_I,
	input wire 		         MEM_Wr_En_I,
	// input wire 		 	 	 Src_to_Reg_I,
	input wire               LB_I,
	input wire               LH_I,
	input wire               SB_I,
	input wire               SH_I,
	////////////////////////// OUTPUT //////////////////////
	// PC src
	output reg [31:0] 		 PC_O,
	// RegFiles srcs
	output reg [1:0]		 iSrc_to_Reg_O,
	output reg 		         fSrc_to_Reg_O,
	// output reg [XLEN-1:0]    irs2_O,
	// output reg [FLEN-1:0]    frs2_O,
	output reg  		     RegI_Wr_En_O,
	output reg 			     RegF_Wr_En_O,
	output reg [4:0]         ex_mem_rd,
	// ALU srcs
	output reg				 int_op_O,
	output reg			     fp_op_O,
    output reg				 i2f_op_O,
	// Memory srcs
	output reg  [XLEN-1:0]   store_to_mem_O,
	output reg 		 		 MEM_Rd_En_O,
	output reg 		 		 MEM_Wr_En_O,
	// output reg 		 		 Src_to_Reg_O,
	output reg               LB_O,
	output reg               LH_O,
	output reg               SB_O,
	output reg               SH_O
);

// Reconstruction Signals / Register sources
reg [4:0] recon_rd;      

always @(posedge CLK,negedge rst_n) begin
	
	if (!rst_n) begin
		PC_O 		    <= 'b0;
		RegI_Wr_En_O    <= 1'b0;
		RegF_Wr_En_O    <= 1'b0;
		ex_mem_rd 	    <= 'b0;
		iSrc_to_Reg_O   <= 2'b0;
		fSrc_to_Reg_O   <= 1'b0;
		int_op_O        <= 1'b0;
		fp_op_O         <= 1'b0;
		i2f_op_O        <= 1'b0;
		// irs2_O          <= 'b0;
		// frs2_O          <= 'b0;
		MEM_Rd_En_O     <= 1'b0;
		MEM_Wr_En_O     <= 1'b0;
		store_to_mem_O  <= 'b0;
		LB_O            <= 1'b0;
		LH_O            <= 1'b0;
		SB_O            <= 1'b0;
		SH_O            <= 1'b0;
	end
	// Remember Destination Register
	else if (IDiv) begin 
		recon_rd		<= id_ex_rd;
	end
	// Reconstruct Control Signals
	else if (div_done) begin
		PC_O 		    <= PC_I;
		RegI_Wr_En_O    <= 1'b1;
		iSrc_to_Reg_O   <= 2'b0;
		fSrc_to_Reg_O   <= fSrc_to_Reg_I;
		RegF_Wr_En_O    <= RegF_Wr_En_I;
		ex_mem_rd 	    <= recon_rd;
		int_op_O        <= int_op_I;
		fp_op_O         <= fp_op_I;
		store_to_mem_O  <= store_to_mem_I;
		MEM_Rd_En_O     <= MEM_Rd_En_I;
		MEM_Wr_En_O     <= MEM_Wr_En_I;
		// irs2_O          <= irs2_I;
		// frs2_O          <= frs2_I;
		LB_O            <= LB_I;
		LH_O            <= LH_I;
		SB_O            <= SB_I;
		SH_O            <= SH_I;
	end
	else begin
		PC_O 		    <= PC_I;
		RegI_Wr_En_O    <= RegI_Wr_En_I;
		RegF_Wr_En_O    <= RegF_Wr_En_I;
		iSrc_to_Reg_O   <= iSrc_to_Reg_I;
		fSrc_to_Reg_O   <= fSrc_to_Reg_O;
		ex_mem_rd 	    <= id_ex_rd;
		int_op_O        <= int_op_I;
		fp_op_O         <= fp_op_I;
		MEM_Rd_En_O     <= MEM_Rd_En_I;
		MEM_Wr_En_O     <= MEM_Wr_En_I;
		// Src_to_Reg_O    <= Src_to_Reg_I;
		// irs2_O          <= irs2_I;
		// frs2_O          <= frs2_I;
		store_to_mem_O  <= store_to_mem_I;
		LB_O            <= LB_I;
		LH_O            <= LH_I;
		SB_O            <= SB_I;
		SH_O            <= SH_I;
	end

end

endmodule