/*******************************************************************
						RV32IMF CORE INTERGRATION
*******************************************************************/
module RV32IMF #(
	parameter XLEN   = 32,
	parameter FLEN   = 32,
	parameter IMM    = 32, 
	parameter I_WORD = 8 ,
	parameter D_WORD = 4 

)
(
	input 	wire 						rst_n,
	input 	wire 						CLK,

	input	wire 						EN_PC,

	////////////// INSTRUCATION CACHE //////////////
	// input 
	input	wire 	[XLEN*I_WORD-1:0]	I_Cache_Data_RD_MEM ,
	input	wire 						I_Cache_RD_Valid_MEM ,
	
	// output
	output	wire 						I_Cache_WR_EN_MEM ,
	output	wire 	[XLEN-1:0] 			I_Cache_Data_ADD_AXI ,

	////////////// DATA CACHE //////////////
	// input
	input	wire 						D_Cache_RD_Valid_MEM ,
	input	wire 						D_Cache_Write_ready_MEM ,
	input	wire 	[XLEN*D_WORD-1:0]	D_Cache_Data_RD_MEM ,

	// output
	output	wire 						D_Cache_WR_Byte_MEM ,
	output	wire 						D_Cache_WR_HWORD_MEM ,
	output	wire 						D_Cache_WR_EN_MEM ,
	output	wire 						D_Cache_RD_EN_MEM ,
	output	wire 	[XLEN-1:0]			D_Cache_Write_ADD_MEM ,
	output	wire 	[XLEN-1:0]			D_Cache_Write_Data_MEM 

);

// -------------------------------------- Internal Signals -------------------------------------- //
// -------------------------------------- PC Signals -------------------------------------- //
wire [XLEN-1:0]   pc_prog_out;   
wire              pc_valid; 
// -------------------------------------- I$ Signals -------------------------------------- //
wire [31:0] 	  get_instr;
wire        	  i_cache_stall;
wire              i_cache_ready;
wire              i_cache_pc;
// -------------------------------------- D$ Signals -------------------------------------- //
wire [XLEN-1:0]   d_cache_data_out;
wire              d_cache_ready;
wire              d_cache_stall;
// -------------------------------------- Controller Signals -------------------------------------- //
wire [4:0]        opcode = get_instr[6:2];
wire 	   		  nop_ins;
wire [6:0]   	  funct7 = get_instr[31:25];
wire [2:0]   	  funct3 = get_instr[14:12];
wire 	          mem_rd_en;
wire 	          mem_wr_en;
wire [1:0]   	  isrc_to_reg;
wire 	          fsrc_to_reg;
wire              regI_wr_En;
wire              regI_rd_En;
wire              regF_wr_En;
wire              regF_rd_En;
wire              ialu_src1_sel;
wire              ialu_src2_sel;
wire              falu_Src1_Sel;
wire              int_op;
wire              fp_op;
wire              i2f_op;
wire              branch;
wire              jump;
wire              jump_src;
wire              add_op;
wire              undef_instr;
wire              ialu_ctrl;
wire              falu_ctrl;
wire              idiv;
wire              lb;
wire              lh;
wire              sb;
wire              sh;

// -------------------------------------- Scoreboard Signals -------------------------------------- //
wire              stall_core;
wire              fpu_ins;
wire              pc_change;
// -------------------------------------- IMM_EXT Signals -------------------------------------- //
wire [XLEN-1:0]   imm_o;
// -------------------------------------- RegFile Signals -------------------------------------- //
wire [XLEN-1:0]   irs1_out;
wire [XLEN-1:0]   irs2_out;
wire [FLEN-1:0]   frs1_out;
wire [FLEN-1:0]   frs2_out;
// -------------------------------------- ID/EX Register Signals -------------------------------------- //
wire  [31:0]      pc_id_ex;
wire 			  branch_id_ex;
wire 			  jump_id_ex;
wire  [IMM-1:0]   imm_id_ex;
wire  [2:0]       funct3_id_ex;
wire  [6:0]       funct7_id_ex;
wire 			  regi_wr_en_id_ex;
wire 			  regf_wr_en_id_ex;
wire  [4:0]	      id_ex_rs1;
wire  [4:0]	      id_ex_rs2;
wire  [4:0]	      id_ex_rd;
wire 			  add_op_id_ex;
wire 			  ialu_src1_sel_id_ex;
wire 			  ialu_src2_sel_id_ex;
wire 			  falu_src1_sel_id_ex;
wire              idiv_id_ex;
wire              int_op_id_ex;
wire              fp_op_id_ex;
wire              i2f_op_id_ex;
wire  [2:0]		  ialu_ctrl_id_ex;
wire  [2:0]		  falu_ctrl_id_ex;
wire 			  mem_rd_en_id_ex;
wire 			  mem_wr_En_id_ex;
wire  [1:0]		  isrc_to_reg_id_ex;
wire  			  fsrc_to_reg_id_ex;
wire              store_src_id_ex;
wire 			  lb_id_ex;
wire 			  lh_id_ex;
wire 			  sb_id_ex;
wire 			  sh_id_ex;
// -------------------------------------- EX/MEM Register Signals -------------------------------------- //
wire  [31:0]      pc_ex_mem;
wire 			  regi_wr_en_ex_mem;
wire 			  regf_wr_en_ex_mem;
wire [4:0]	      ex_mem_rd;
wire              int_op_ex_mem;
wire              fp_op_ex_mem;
wire              i2f_op_ex_mem;
wire 			  mem_rd_en_ex_mem;
wire 			  mem_wr_En_ex_mem;
wire  [1:0]		  isrc_to_reg_ex_mem;
wire  			  fsrc_to_reg_ex_mem;
wire [31:0]       store_to_mem;
wire 			  lb_ex_mem;
wire 			  lh_ex_mem;
wire 			  sb_ex_mem;
wire 			  sh_ex_mem;
// -------------------------------------- MEM/WB Register Signals -------------------------------------- //
wire 			  regi_wr_en_mem_wb;
wire 			  regf_wr_en_mem_wb;
wire [4:0]	      mem_wb_rd;
wire [31:0]       pc4_to_reg;
wire [XLEN-1:0]   iresult_mem_wb;
wire [FLEN-1:0]   fresult_mem_wb;
wire [1:0]	      isrc_to_reg_mem_wb;
wire              fsrc_to_reg_mem_wb;
wire [XLEN-1:0]   ireg_rd;
wire [XLEN-1:0]   freg_rd;
// -------------------------------------- FORWARD SIGNALS -------------------------------------- //
wire   [1:0]      iforw_src1;
wire   [1:0]      iforw_src2;
wire   [1:0]      fforw_src1;
wire   [1:0]      fforw_src2;
wire   [XLEN-1:0] iforw1_out;
wire   [XLEN-1:0] iforw2_out;  
// -------------------------------------- ALU SIGNALS -------------------------------------- //
wire              div_done;
wire              div_by_zero;
wire              branch_taken;
wire              ioverflow;
wire [XLEN-1:0]   irs1_src;
wire [XLEN-1:0]   irs2_src;
wire [FLEN-1:0]   frs1_src;
wire [FLEN-1:0]   frs2_src;
wire [XLEN-1:0]   iresult;
wire [FLEN-1:0]   fresult;
// -------------------------------------- Floating Point Exceptions -------------------------------------- //
wire              nan;
wire              pinf;
wire              ninf;
wire              fexception;
wire              foverflow;
/*******************************************************************
FETCH STAGE
*******************************************************************/

/*******************************************************************
PROGRAM COUNTER
*******************************************************************/
PC prog_count (
	.CLK(CLK),
	.RST(rst_n),
	.PC_next_sel(pc_change),
	.PC_stall(stall_core || ~EN_PC),
	.PC_jump_branch(iresult),
	.PC(pc_prog_out),      
	.Valid(pc_valid) 
); 

/*******************************************************************
INSTRUCTION CACHE
*******************************************************************/
I_Cache_TOP I_Cache (

// input
	.CLK(CLK),
	.RST(rst_n),
	.I_Cache_RD_EN_PC(pc_valid), 
	.I_Cache_Data_Wr(pc_prog_out),		
	.I_Cache_Data_RD_MEM(I_Cache_Data_RD_MEM),			// AXI
	.I_Cache_RD_Valid_MEM(I_Cache_RD_Valid_MEM),		// AXI
	
	// output
	//.PC(i_cache_pc),/////////////////////////////////////
	.I_Cache_Data(get_instr),		
	.I_Cache_Ready(i_cache_ready),
	.I_Cache_STALL(i_cache_stall),
	.I_Cache_WR_EN_MEM(I_Cache_WR_EN_MEM),				// AXI
	.I_Cache_Data_ADD_AXI(I_Cache_Data_ADD_AXI) 		// AXI

);

/*******************************************************************
DECODE STAGE
*******************************************************************/

/*******************************************************************
CONTROLLER
*******************************************************************/
Control_Unit Controller (
	.Opcode(opcode),
	.NOP_Ins(nop_ins),	
	.Funct7(funct7),
	.Funct3(funct3),
	.i_cache_en(i_cache_ready),
	// Memory Control Signals
	.store_src(store_src),
	.MEM_Rd_En(mem_rd_en),
	.MEM_Wr_En(mem_wr_en),
	// Register Write Srcs
	.iSrc_to_Reg(isrc_to_reg),
	.fSrc_to_Reg(fsrc_to_reg),
	// RegFile Control Signals
	.RegI_Wr_En(regI_wr_En),
	.RegI_Rd_En(regI_rd_En),
	.RegF_Wr_En(regF_wr_En),
	.RegF_Rd_En(regF_rd_En),
	// Integer ALU Source signals
	.IALU_Src1_Sel(ialu_src1_sel),
	.IALU_Src2_Sel(ialu_src2_sel),
	// Floating ALU Source signals
	.FALU_Src1_Sel(falu_Src1_Sel),
	.int_op(int_op),
	.fp_op(fp_op),
	.i2f_op(fp_op),
	// PC signals
	.Branch(branch),
	.Jump(jump),
	.Jump_Src(jump_src),
	// ALU ADD/SUB Operation
	.Add_Op(add_op),
	// undefined instruction
	.undef_instr(undef_instr),
	// To ALU Decoders
	.IALU_Ctrl(ialu_ctrl),
	.FALU_Ctrl(falu_ctrl),
	// To scoreboard
	.IDiv(idiv),
	// To Data Cache
	.LB(lb),
	.LH(lh),
	.SB(sb),
	.SH(sh)
);
/*******************************************************************
SCOREBOARD ---- HAZARD
*******************************************************************/
Hazard Scoreboard (
	// INPUT
	.CLK(CLK),
	.rst_n(rst_n),
	// Floating instruction detection
	.fpu_ins(fpu_ins),
	// Instruction Board Detection
	// Div   Detection
	.IDiv(idiv),
	// Load  Detection
	.MEM_Rd_En(mem_rd_en),
	// Store Detection
	.MEM_Wr_En(mem_wr_en),
	// PC Change Detection        
	.pc_change(pc_change),
	.Div_Done(div_done), // From Integer ALU
	// From Caches
	.d_ready(),
	.d_stall(),
	.i_stall(),
	// Register Sources
	.IF_ID_rs1(get_instr[19:15]),
	.IF_ID_rs2(get_instr[24:20]),
	.IF_ID_rd(get_instr[11:7]),
	// Registered Destination Sources
	.ID_EX_Reg_rd(id_ex_rd),
	// OUTPUT
	.PC_Stall(stall_core),
	.NOP_Ins(nop_ins) // no-operation insertion
);
/*******************************************************************
REGISTER FILES
*******************************************************************/

/*******************************************************************
INTEGER REGISTER FILE
*******************************************************************/
RegFile_I #(
	.XLEN(XLEN)
)
	Integer_RegFile 
(
	.rst_n(rst_n),
	.CLK(CLK),
	.Reg_Wr(regI_wr_En),
	.Reg_Rd(regI_rd_En),
	.Rs1_rd(get_instr[19:15]),
	.Rs2_rd(get_instr[24:20]),
	.Rd_Wr(mem_wb_rd),
	.Rd_In(ireg_rd),
	.Rs1_Out(irs1_out),
	.Rs2_Out(irs2_out)
);

/*******************************************************************
SINGLE PRECISION FLOATING POINT REGISTER FILE
*******************************************************************/
RegFile_F #(
	.FLEN(FLEN)
)
	Floating_RegFile 
(
	.rst_n(rst_n),
	.CLK(CLK),
	.Reg_Wr(regF_wr_En),
	.Reg_Rd(RegF_Rd_En),
	.Rs1_rd(),
	.Rs2_rd(),
	.Rd_Wr(mem_wb_rd),
	.Rd_In(freg_rd),
	.Rs1_Out(frs1_out),
	.Rs2_Out(frs2_out)
);
/*******************************************************************
IMM EXT
*******************************************************************/
IMM_EXT Imm_Ext (
	.IMM_IN(get_instr),
	.opcode(opcode),     
	.IMM_OUT(imm_o)
);
/*******************************************************************
EXCUTE STAGE
*******************************************************************/

/*******************************************************************
ID/EX REGISTER
*******************************************************************/
ID_EX_REG ID_EX_Register (
	.CLK(CLK),
	.rst_n(rst_n),
	// PC src
	.PC_I(pc_prog_out),
	.Branch_I(branch),
	.Jump_I(jump),
	// IMM src
	.IMM_I(imm_o),
	// ALU Function Decision
	.Funct3_I(funct3),
	.Funct7_I(funct7),
	// RegFiles srcs
	.RegI_Wr_En_I(regI_wr_En),
	.RegF_Wr_En_I(regF_wr_En),
	.iSrc_to_Reg_I(isrc_to_reg),
	.fSrc_to_Reg_I(fsrc_to_reg),
	.if_id_rs1(get_instr[19:15]),
	.if_id_rs2(get_instr[24:20]),
	.if_id_rd(get_instr[11:7]),
	// ALU srcs
	.IDiv_I(idiv),
	.int_op_I(int_op),
	.fp_op_I(fp_op),
    .i2f_op_I(i2f_op),
	.Add_Op_I(add_op),
	.IALU_Src1_Sel_I(ialu_src1_sel),
	.IALU_Src2_Sel_I(ialu_src2_sel),
	.FALU_Src1_Sel_I(falu_Src1_Sel),
	.IALU_Ctrl_I(ialu_ctrl),
	.FALU_Ctrl_I(falu_ctrl),
	// Memory srcs
	.store_src_I(store_src),
	.MEM_Rd_En_I(mem_rd_en),
	.MEM_Wr_En_I(mem_wr_en),
	.LB_I(lb),
	.LH_I(lh),
	.SB_I(sb),
	.SH_I(sh),
	// PC src
	.PC_O(pc_id_ex),
	.Branch_O(branch_id_ex),
	.Jump_O(jump_id_ex),
	// IMM src
	.IMM_O(imm_id_ex),
	// ALU Function Decision
	.Funct3_O(funct3_id_ex),
	.Funct7_O(funct7_id_ex),
	// RegFiles srcs
	.RegI_Wr_En_O(regi_wr_en_id_ex),
	.RegF_Wr_En_O(regf_wr_en_id_ex),
	.iSrc_to_Reg_O(isrc_to_reg_id_ex),
	.fSrc_to_Reg_O(fsrc_to_reg_id_ex),
	.id_ex_rs1(id_ex_rs1),
	.id_ex_rs2(id_ex_rs2),
	.id_ex_rd(id_ex_rd),
	// ALU srcs
	.IDiv_O(idiv_id_ex),
	.int_op_O(int_op_id_ex),
	.fp_op_O(fp_op_id_ex),
    .i2f_op_O(i2f_op_id_ex),
	.Add_Op_O(add_op_id_ex),
	.IALU_Src1_Sel_O(ialu_src1_sel_id_ex),
	.IALU_Src2_Sel_O(ialu_src2_sel_id_ex),
	.FALU_Src1_Sel_O(falu_src1_sel_id_ex),
	.IALU_Ctrl_O(ialu_ctrl_id_ex),
	.FALU_Ctrl_O(falu_ctrl_id_ex),
	// Memory srcs
	.store_src_O(store_src_id_ex),
	.MEM_Rd_En_O(mem_rd_en_id_ex),
	.MEM_Wr_En_O(mem_wr_En_id_ex),
	.Src_to_Reg_O(src_to_reg_id_ex),
	.LB_O(lb_id_ex),
	.LH_O(lh_id_ex),
	.SB_O(sb_id_ex),
	.SH_O(sh_id_ex)
);
/*******************************************************************
FORWARD
*******************************************************************/
Forward_Unit ialu_forward (
	.int_op_id_ex(int_op_id_ex),
	.fp_op_id_ex(fp_op_id_ex),
	.i2f_op_id_ex(i2f_op_id_ex),
	.int_op_ex_mem(int_op_ex_mem),
	.fp_op_ex_mem(fp_op_ex_mem),
	.EX_MEM_Reg_Wr(regi_wr_en_ex_mem),
	.MEM_WB_Reg_Wr(regi_wr_en_mem_wb),
	.ID_EX_rs1(id_ex_rs1),
	.ID_EX_rs2(id_ex_rs2),
	.EX_MEM_rd(ex_mem_rd),
	.MEM_WB_rd(mem_wb_rd),
	.Forward_A(iforw_src1),
	.Forward_B(iforw_src2)
);

Forward_Unit falu_forward (
	.int_op_id_ex(int_op_id_ex),
	.fp_op_id_ex(fp_op_id_ex),
	.i2f_op_id_ex(i2f_op_id_ex),
	.int_op_ex_mem(int_op_ex_mem),
	.fp_op_ex_mem(fp_op_ex_mem),
	.EX_MEM_Reg_Wr(regf_wr_en_ex_mem),
	.MEM_WB_Reg_Wr(regf_wr_en_mem_wb),
	.ID_EX_rs1(id_ex_rs1),
	.ID_EX_rs2(id_ex_rs2),
	.EX_MEM_rd(ex_mem_rd),
	.MEM_WB_rd(mem_wb_rd),
	.Forward_A(fforw_src1),
	.Forward_B(fforw_src2)
);
/*******************************************************************
 ALU Sources MUX Selection
*******************************************************************/
mux2x1 fsel_src1 (
	.i0(frs1_out),
	.i1(irs1_out),
	.sel(falu_src1_sel_id_ex),
	.out(fsrc1)
);

mux2x1 isel_src1 (
	.i0(iforw1_out),
	.i1(pc_id_ex),
	.sel(ialu_src1_sel_id_ex),
	.out(irs1_src)
);

mux2x1 isel_src2 (
	.i0(iforw2_out),
	.i1(imm_id_ex),
	.sel(ialu_src2_sel_id_ex),
	.out(irs2_src)
);

mux4x1 iforw1_sel (
	.i0(irs1_out), 		   // Don't Forward
	.i1(ireg_rd),          // Forward From 5th Stage
	.i2(iresult),		   // Forward From 4th Stage
	.sel0(iforw_src1[0]),
	.sel1(iforw_src1[1]),
	.out(iforw1_out)
);

mux4x1 iforw2_sel (
	.i0(irs2_out), 		   // Don't Forward
	.i1(ireg_rd),          // Forward From 5th Stage
	.i2(iresult),		   // Forward From 4th Stage
	.sel0(iforw_src2[0]),
	.sel1(iforw_src2[1]),
	.out(iforw2_out)
);

mux4x1 fforw1_sel (
	.i0(fsrc1),            // Don't Forward
	.i1(freg_rd), 		   // Forward From 5th Stage
	.i2(fresult),		   // Forward From 4th Stage
	.sel0(fforw_src1[0]),
	.sel1(fforw_src1[1]),
	.out(frs1_src)
);

mux4x1 fforw2_sel (
	.i0(frs2_out),         // Don't Forward
	.i1(freg_rd),		   // Forward From 5th Stage
	.i2(fresult),		   // Forward From 4th Stage
	.sel0(fforw_src2[0]),
	.sel1(fforw_src2[1]),
	.out(frs2_src)
);
/*******************************************************************
Integer ALU
*******************************************************************/
// Integer ALU
I_ALU #(
	.XLEN(XLEN)
) 
	Intger_ALU 
(
	.rst_n(rst_n),
	.CLK(CLK),
	.Rs1(irs1_src),
	.Rs2(irs2_src),
	.Add_Op(add_op_id_ex),
	.IALU_ctrl(ialu_ctrl_id_ex),
	.Funct3(funct3_id_ex),
	.Funct7_5(funct7_id_ex[5]),
	.Result(iresult),
	.Branch_taken(branch_taken),
	.div_by_zero(div_by_zero),
	.div_done(div_done),	
	.overflow(ioverflow)  
);

assign pc_change = (branch_taken & branch_id_ex) | (jump_id_ex);

/*******************************************************************
FLOATING ALU
*******************************************************************/
F_ALU #(
	.FLEN(FLEN)
) 
	Floating_ALU 
(
	.rst_n(rst_n),
	.CLK(CLK),
	.Rs1(frs1_src),
	.Rs2(frs2_src),
	.FALU_ctrl(falu_ctrl_id_ex),
	.Funct3(funct3_id_ex),
	.Funct7_3_2({funct7_id_ex[3],funct7_id_ex[2]}),
	.Result(fresult),
	.overflow(foverflow)   
);
/*******************************************************************
FPU EXCEPTIONS
*******************************************************************/
fpu_err FPU_Exception (
	.Result(fresult),
	.NaN(nan),
	.pinf(pinf), // positive inf
	.ninf(ninf)  // negative inf
);

assign fexception = nan | pinf | ninf;

mux2x1 mem_store_src (
	.i0(iforw2_out),
	.i1(frs2_out),
	.sel(store_src_id_ex),
	.out(sel_store_src)
);
/*******************************************************************
 MEMORY STAGE
*******************************************************************/
/*******************************************************************
 EX/MEM Register
*******************************************************************/
EX_MEM_REG #(
	.XLEN(XLEN),
	.FLEN(FLEN)
)
	EX_MEM_Register 
(
////////////////////////// INPUT //////////////////////
	.CLK(CLK),
	.rst_n(rst_n),
	// PC src
	.PC_I(pc_id_ex),
	// RegFiles srcs
	.RegI_Wr_En_I(regi_wr_en_id_ex),
	.RegF_Wr_En_I(regf_wr_en_id_ex),
	.id_ex_rd(id_ex_rd),
	.irs2_I(irs2_out),
	.frs2_I(frs2_out),
	// ALU srcs
	.IDiv(idiv_id_ex),
	.div_done(div_done),
	.int_op_I(int_op_id_ex),
	.fp_op_I(fp_op_id_ex),
	.i2f_op_I(i2f_op_id_ex),
	// Memory srcs
	.MEM_Rd_En_I(mem_rd_en_id_ex),
	.MEM_Wr_En_I(mem_wr_En_id_ex),
	.Src_to_Reg_I(src_to_reg_id_ex),
	.store_to_mem_I(sel_store_src),
	.LB_I(lb_id_ex),
	.LH_I(lh_id_ex),
	.SB_I(sb_id_ex),
	.SH_I(sh_id_ex),
	////////////////////////// OUTPUT //////////////////////
	// PC src
	.PC_O(pc_ex_mem),
	// RegFiles srcs
	.RegI_Wr_En_O(regi_wr_en_ex_mem),
	.RegF_Wr_En_O(regf_wr_en_ex_mem),
	.ex_mem_rd(ex_mem_rd),
	.irs2_O(irs2_out_ex_mem),
	.frs2_O(frs2_out_ex_mem),
	// ALU srcs
	.int_op_O(int_op_ex_mem),
	.fp_op_O(fp_op_ex_mem),
	.i2f_op_O(i2f_op_ex_mem),
	// Memory srcs
	.MEM_Rd_En_O(mem_rd_en_ex_mem),
	.MEM_Wr_En_O(mem_wr_En_ex_mem),
	.Src_to_Reg_O(src_to_reg_ex_mem),
	.store_to_mem_O(store_to_mem),
	.LB_O(lb_ex_mem),
	.LH_O(lh_ex_mem),
	.SB_O(sb_ex_mem),
	.SH_O(sh_ex_mem)
);
/*******************************************************************
 Data Cache
*******************************************************************/
D_Cache_TOP Data_Cache (
// input
	.CLK(CLK),
	.RST(rst_n),
	.D_Cache_WR_Byte_CPU(sb_ex_mem),		
	.D_Cache_WR_HWORD_CPU(sh_ex_mem),		
	.D_Cache_WR_EN_CORE(mem_wr_En_id_ex),		
	.D_Cache_RD_EN_CORE(mem_rd_en_ex_mem),		
	.D_Cache_RD_Byte_CPU(lb_ex_mem),      					    // BYTE
	.D_Cache_RD_HWord_CPU(lh_ex_mem),      						// HALF WORD
	.D_Cache_RD_Valid_MEM(D_Cache_RD_Valid_MEM),				// AXI
	.D_Cache_Write_ready_MEM(D_Cache_Write_ready_MEM),			// AXI
	.D_Cache_Data_ADD(iresult),		
	.D_Cache_Data_Wr(sel_store_src),		
	.D_Cache_Data_RD_MEM(D_Cache_Data_RD_MEM),					// AXI
	// output
	.D_Cache_Data(d_cache_data_out),		
	.D_Cache_Ready(d_cache_ready),
	.D_Cache_STALL(d_cache_stall),
	.D_Cache_WR_Byte_MEM(D_Cache_WR_Byte_MEM),					// AXI	
	.D_Cache_WR_HWORD_MEM(D_Cache_WR_HWORD_MEM),				// AXI	
	.D_Cache_WR_EN_MEM(D_Cache_WR_EN_MEM),						// AXI	
	.D_Cache_RD_EN_MEM(D_Cache_RD_EN_MEM),						// AXI	
	.D_Cache_Write_ADD_MEM(D_Cache_Write_ADD_MEM),				// AXI			
	.D_Cache_Write_Data_MEM(D_Cache_Write_Data_MEM) 			// AXI
);

/*******************************************************************
WRITE_BACK STAGE 
*******************************************************************/
MEM_WB_REG #(
	.XLEN(XLEN),
	.FLEN(FLEN)
) 
	MEM_WB_Register	
(
////////////////////////// INPUT //////////////////////
	.CLK(CLK),
	.rst_n(rst_n),
	// PC src
	.PC_I(pc_ex_mem),
	// RegFiles srcs
	.RegI_Wr_En_I(regi_wr_en_ex_mem),
	.RegF_Wr_En_I(regf_wr_en_ex_mem),
	.ex_mem_rd(ex_mem_rd),
	// ALU srcs
	.iresult_I(iresult),
	.fresult_I(fresult),
	.fexception_I(fexception),
	// Register Write srcs
	.iSrc_to_Reg_I(isrc_to_reg_ex_mem),
	.fSrc_to_Reg_I(fsrc_to_reg_ex_mem),
	////////////////////////// OUTPUT //////////////////////
	// PC src
	.PC_O(pc_mem_wb),
	// RegFiles srcs
	.RegI_Wr_En_O(regi_wr_en_mem_wb),
	.RegF_Wr_En_O(regf_wr_en_mem_wb),
	.mem_wb_rd(mem_wb_rd),
	// ALU srcs
	.iresult_O(iresult_mem_wb),
	.fresult_O(fresult_mem_wb),
	// Register Write srcs
	.iSrc_to_Reg_O(isrc_to_reg_mem_wb),
	.fSrc_to_Reg_O(fsrc_to_reg_mem_wb)
);

assign pc4_to_reg = pc_mem_wb + 3'b100;

mux4x1 ireg_src (
	.i0(iresult_mem_wb),   // From Integer ALU
	.i1(d_cache_data_out), // From Data Cache in case of load		   
	.i2(pc4_to_reg),       // In Case of jump instructions
	.sel0(isrc_to_reg_mem_wb[0]),
	.sel1(isrc_to_reg_mem_wb[1]),
	.out(ireg_rd)
);

mux2x1 freg_src (
	.i0(fresult_mem_wb),   // From Floating ALU
	.i1(d_cache_data_out), // From Data Cache in case of load
	.sel(fsrc_to_reg_mem_wb),
	.out(freg_rd)
);

endmodule