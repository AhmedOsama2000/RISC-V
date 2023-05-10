module Control_Unit #(
	parameter ALU_DECODER_IN = 3
)
(
	// INPUT
	input wire [4:0]  Opcode,
	input wire        NOP_Ins,	
	input wire [6:0]  Funct7,
	input wire [2:0]  Funct3,
	input wire        i_cache_en,
	// OUTPUT
	// Memory Control Signals
	output wire       MEM_Rd_En,
	output wire       MEM_Wr_En,
	// Register Write Source
	output wire [1:0] iSrc_to_Reg,
	output wire       fSrc_to_Reg,
	// RegFile Control Signals
	output wire 	  RegI_Wr_En,
	output wire       RegI_Rd_En,
	output wire 	  RegF_Wr_En,
	output wire       RegF_Rd_En,
	// Integer ALU Source signals
	output wire 	  IALU_Src1_Sel,
	output wire 	  IALU_Src2_Sel,
	output wire       int_op,
	output wire       fp_op,
	output wire       i2f_op,
	// Floating ALU Source signals
	output wire       FALU_Src1_Sel,
	// PC signals
	output wire       Branch,
	output wire       Jump,
	output wire       Jump_Src,
	// ALU ADD/SUB Operation
	output wire       Add_Op,
	// undefined instruction
	output wire       undef_instr,
	// To ALU Decoders
	output wire [ALU_DECODER_IN-1:0] IALU_Ctrl,
	output wire [ALU_DECODER_IN-1:0] FALU_Ctrl,
	// To scoreboard and ID/EX Register
	output wire       IDiv,
	// To Data Cache
	output wire       store_src,
	output wire       LB,
	output wire       LH,
	output wire       SB,
	output wire       SH
);

Main_Decoder main_ctrl (
	.Opcode(Opcode),
	.NOP_Ins(NOP_Ins),	
	.i_cache_en(i_cache_en),
	.Funct7_6_2(Funct7[6:2]), 
	// Memory Control Signals
	.MEM_Rd_En(MEM_Rd_En),
	.MEM_Wr_En(MEM_Wr_En),
	.store_src(store_src),
	// Register Write Source
	.iSrc_to_Reg(iSrc_to_Reg),
	.fSrc_to_Reg(fSrc_to_Reg),
	// RegFile Control Signals
	.RegI_Wr_En(RegI_Wr_En),
	.RegI_Rd_En(RegI_Rd_En),
	.RegF_Wr_En(RegF_Wr_En),
	.RegF_Rd_En(RegF_Rd_En),
	// Integer ALU Source signals
	.IALU_Src1_Sel(IALU_Src1_Sel),
	.IALU_Src2_Sel(IALU_Src2_Sel),
	.int_op(int_op),
	.fp_op(fp_op),
	.i2f_op(i2f_op),
	// Floating ALU Source signals
	.FALU_Src1_Sel(FALU_Src1_Sel),
	// PC signals
	.Branch(Branch),
	.Jump(Jump),
	// .Jump_Src(Jump_Src),
	// ALU ADD/SUB Operation
	.Add_Op(Add_Op),
	// undefined instruction
	.undef_instr(undef_instr)
);

IALU_Control ialu_ctrl  
(
	.Funct3(Funct3),
	.Funct7_5(Funct7[5]),
	.Funct7_0(Funct7[0]),
	.undef_instr(undef_instr),
	.Add_Op(Add_Op),
	.IALU_Ctrl(IALU_Ctrl),
	.IDiv(IDiv)
);

FALU_Control falu_ctrl  
(
	.Funct7_6_2(Funct7[6:2]),
	.undef_instr(undef_instr),
	.FALU_Ctrl(FALU_Ctrl)
);

Memory_Ctrl mem_ctrl (
	.Funct3_0(Funct3[0]),
	.MEM_Rd_En(MEM_Rd_En),
	.MEM_Wr_En(MEM_Wr_En),
	.LB(LB),
	.LH(LH),
	.SB(SB),
	.SH(SH)
);

endmodule