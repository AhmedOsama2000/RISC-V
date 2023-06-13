module MEM_WB_REG #(
	parameter XLEN           = 32,
	parameter FLEN           = 32
)
(
	////////////////////////// INPUT //////////////////////
	input wire 				 CLK,
	input wire          	 rst_n,
	// PC src
	input wire [31:0] 		 PC_I,
	// RegFiles srcs
	input wire  		     RegI_Wr_En_I,
	input wire 			     RegF_Wr_En_I,
	input wire [4:0]      	 ex_mem_rd,
	// ALU srcs
	input wire               int_op_I,
	input wire [XLEN-1:0]    iresult_I,
	input wire [FLEN-1:0]    fresult_I,
	input wire               fexception_I,
	// Register srcs
	input wire [1:0]		 iSrc_to_Reg_I,
	input wire 		         fSrc_to_Reg_I,
	////////////////////////// OUTPUT //////////////////////
	// PC src
	output reg [31:0] 		 PC_O,
	// RegFiles srcs
	output reg  		     RegI_Wr_En_O,
	output reg 			     RegF_Wr_En_O,
	output reg [4:0]         mem_wb_rd,
	// ALU srcs
	output reg               int_op_O,
	output reg [XLEN-1:0]    iresult_O,
	output reg [FLEN-1:0]    fresult_O,
	// Memory srcs
	output reg [1:0]		 iSrc_to_Reg_O,
	output reg 		         fSrc_to_Reg_O
);

// Reconstruction Signals / Register sources
reg [4:0] recon_rd;      

always @(posedge CLK,negedge rst_n) begin
	
	if (!rst_n) begin
		PC_O 		    <= 'b0;
		RegI_Wr_En_O    <= 1'b0;
		RegF_Wr_En_O    <= 1'b0;
		mem_wb_rd 	    <= 'b0;
		iresult_O       <= 'b0;
		fresult_O       <= 'b0;
		int_op_O        <= 1'b0;
		iSrc_to_Reg_O   <= 2'b0;
		fSrc_to_Reg_O   <= 1'b0;
	end
	else if (fexception_I) begin
		RegF_Wr_En_O    <= 1'b0;
		RegI_Wr_En_O    <= RegI_Wr_En_I;
		iresult_O       <= iresult_I;
		iSrc_to_Reg_O   <= iSrc_to_Reg_I;
		int_op_O        <= int_op_I;
	end
	else begin
		PC_O 		    <= PC_I;
		int_op_O        <= int_op_I;
		RegI_Wr_En_O    <= RegI_Wr_En_I;
		RegF_Wr_En_O    <= RegF_Wr_En_I;
		mem_wb_rd 	    <= ex_mem_rd;
		iresult_O       <= iresult_I;
		fresult_O       <= fresult_I;
		iSrc_to_Reg_O   <= iSrc_to_Reg_I;
		fSrc_to_Reg_O   <= fSrc_to_Reg_I;
	end

end

endmodule