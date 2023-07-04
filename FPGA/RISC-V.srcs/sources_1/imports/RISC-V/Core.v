/*******************************************************************
						RV32IMF CORE INTERGRATION
*******************************************************************/
(* DONT_TOUCH = "TRUE" *) module RV32IMF #(
	parameter XLEN   = 32,
	parameter FLEN   = 32,
	parameter IMM    = 32 
)
(
	input 	wire 						rst_n,
	input 	wire 						CLK,
	input	wire 						EN_PC,
	output  wire                        PC_done,
	output  wire [XLEN-1:0]             ireg_30,
	output  wire [XLEN-1:0]             ireg_31,
	output  wire [FLEN-1:0]             freg_30,
	output  wire [FLEN-1:0]             freg_31
);

// 10 MHz Clock
reg clock_10;
reg [2:0] counter;

always @(posedge CLK)
begin
    if(counter != 4)
        counter <= counter + 1;
    else
        counter <= 0;
end

initial
    clock_10 <= 0;
    
always @(posedge CLK) begin
    if(counter == 4)
        clock_10 <= ~clock_10;
end   

// -------------------------------------- Internal Signals -------------------------------------- //
// -------------------------------------- PC Signals -------------------------------------- //
wire [XLEN-1:0]   pc_prog_out;   
wire              pc_valid; 
wire [XLEN-1:0]   pc_mem_wb;
// -------------------------------------- IMemory Signals -------------------------------------- //
wire [31:0] 	  get_instr;
// -------------------------------------- IF/ID Register Signals -------------------------------------- //
wire 			  flush_ctrl;
wire              EN_PC_if_id;
wire [31:0]       pc_if_id;
wire [31:0]       instr_if_id;
// -------------------------------------- DMemory Signals -------------------------------------- //
wire [XLEN-1:0]   sel_store_src;
wire [XLEN-1:0]   data_mem_out;
// -------------------------------------- Controller Signals -------------------------------------- //
wire [6:0]        opcode;
assign opcode = instr_if_id[6:0];
wire 	   		  nop_ins;
wire [6:0]   	  funct7;
assign funct7 = instr_if_id[31:25];
wire [2:0]   	  funct3;
assign funct3 =  instr_if_id[14:12];
wire 	          mem_wr_en;
wire [1:0]   	  isrc_to_reg;
wire 	          fsrc_to_reg;
wire              regI_wr_En;
wire              regF_wr_En;
wire              ialu_src1_sel;
wire              ialu_src2_sel;
wire              falu_Src1_Sel;
wire              int_op;
wire              fp_op;
wire              branch;
wire              jump;
wire              Sub;
wire              undef_instr;
wire    [2:0]     ialu_ctrl;
wire    [2:0]     falu_ctrl;
wire              idiv;
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
wire [XLEN-1:0]   irs1_out_id_ex;
wire [XLEN-1:0]   irs2_out_id_ex;
wire [FLEN-1:0]   frs1_out_id_ex;
wire [FLEN-1:0]   frs2_out_id_ex;

// -------------------------------------- ID/EX Register Signals -------------------------------------- //
wire  [31:0]      pc_id_ex;
wire 			  branch_id_ex;
wire 			  jump_id_ex;
wire  [IMM-1:0]   imm_id_ex;
wire  [6:0]		  opcode_id_ex;
wire  [2:0]       funct3_id_ex;
wire  [6:0]       funct7_id_ex;
wire 			  regi_wr_en_id_ex;
wire 			  regf_wr_en_id_ex;
wire  [4:0]	      id_ex_rs1;
wire  [4:0]	      id_ex_rs2;
wire  [4:0]	      id_ex_rd;
wire 			  Sub_id_ex;
wire 			  ialu_src1_sel_id_ex;
wire 			  ialu_src2_sel_id_ex;
wire 			  falu_src1_sel_id_ex;
wire              idiv_id_ex;
wire              int_op_id_ex;
wire              fp_op_id_ex;
wire  [2:0]		  ialu_ctrl_id_ex;
wire  [2:0]		  falu_ctrl_id_ex;
wire 			  mem_wr_En_id_ex;
wire  [1:0]		  isrc_to_reg_id_ex;
wire  			  fsrc_to_reg_id_ex;
wire              store_src_id_ex;
// -------------------------------------- EX/MEM Register Signals -------------------------------------- //
wire  [31:0]      pc_ex_mem;
wire 			  regi_wr_en_ex_mem;
wire 			  regf_wr_en_ex_mem;
wire [4:0]	      ex_mem_rd;
wire              int_op_ex_mem;
wire              fp_op_ex_mem;
wire 			  mem_wr_En_ex_mem;
wire  [1:0]		  isrc_to_reg_ex_mem;
wire  			  fsrc_to_reg_ex_mem;
wire [31:0]       store_to_mem;
// -------------------------------------- MEM/WB Register Signals -------------------------------------- //
wire              int_op_mem_wb;
wire              fp_op_mem_wb;
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
wire [XLEN-1:0]   data_mem_out_mem_wb;
// -------------------------------------- FORWARD SIGNALS -------------------------------------- //
wire   [1:0]      iforw_src1;
wire   [1:0]      iforw_src2;
wire   [2:0]      fforw_src1;
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
wire [FLEN-1:0]   fsrc1;
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
(* keep_hierarchy = "yes" *)  PC prog_count (
	// input
	.CLK(clock_10),
	.rst_n(rst_n),
	.stall_pc(stall_core),
	.PC_Addr(Intger_ALU.CLA.Result),
	.En_PC(EN_PC),
	.PC_done(PC_done),
	.PC_Change(pc_change),
	// output
	.PC_Out(pc_prog_out)     
); 

/*******************************************************************
INSTRUCTION Memory
*******************************************************************/
(* DONT_TOUCH = "TRUE" *)  IMem instr_mem (
    .PC(pc_prog_out),
    .instr(get_instr)
);

(* keep_hierarchy = "yes" *)  IF_ID_REG  IF_ID_Register (
	////////////////////////// INPUT //////////////////////
	.CLK(clock_10),
	.rst_n(rst_n),
	// PC src
	.EN_PC_I(EN_PC),
	.stall(stall_core),
	.flush(flush_if_id),
	.PC_I(pc_prog_out),
	.instr_I(get_instr),
	////////////////////////// OUTPUT //////////////////////
	.if_id_flush(flush_ctrl),
	.EN_PC_O(EN_PC_if_id),
	.PC_O(pc_if_id),
	.instr_O(instr_if_id)
);

/*******************************************************************
DECODE STAGE
*******************************************************************/
/*******************************************************************
CONTROLLER
*******************************************************************/
(* DONT_TOUCH = "TRUE" *) Control_Unit Controller (
    (* DONT_TOUCH = "TRUE" *) .EN_PC(EN_PC_if_id),
	.Opcode(opcode),
	.NOP_Ins(nop_ins),
	.fpu_ins(fpu_ins),
	.CTRL_FLUSH(flush_ctrl),
	.Funct7(funct7),
	.Funct3(funct3),
	// Memory Control Signals
	.store_src(store_src),
	.MEM_Wr_En(mem_wr_en),
	// Register Write Srcs
	.iSrc_to_Reg(isrc_to_reg),
	.fSrc_to_Reg(fsrc_to_reg),
	// RegFile Control Signals
	.RegI_Wr_En(regI_wr_En),
	.RegF_Wr_En(regF_wr_En),
	// Integer ALU Source signals
	.IALU_Src1_Sel(ialu_src1_sel),
	.IALU_Src2_Sel(ialu_src2_sel),
	// Floating ALU Source signals
	.FALU_Src1_Sel(falu_Src1_Sel),
	.int_op(int_op),
	.fp_op(fp_op),
	// PC signals
	.Branch(branch),
	.Jump(jump),
	// ALU ADD/SUB Operation
	.Sub(Sub),
	// undefined instruction
	.undef_instr(undef_instr),
	// To ALU Decoders
	.IALU_Ctrl(ialu_ctrl),
	.FALU_Ctrl(falu_ctrl),
	// To scoreboard
	.IDiv(idiv)
);
/*******************************************************************
SCOREBOARD ---- HAZARD
*******************************************************************/
(* keep_hierarchy = "yes" *) Hazard Scoreboard (
	// INPUT
	.CLK(clock_10),
	.rst_n(rst_n),
	// Floating instruction detection
	.fpu_ins(fpu_ins),
	.Opcode(opcode_id_ex),
	// Instruction Board Detection
	// Div   Detection
	.IDiv(idiv),
	// PC Change Detection        
	.pc_change(pc_change),
	.Div_Done(div_done), // From Integer ALU
	// Register Sources
	.IF_ID_rs1(instr_if_id[19:15]),
	.IF_ID_rs2(instr_if_id[24:20]),
	.IF_ID_rd(instr_if_id[11:7]),
	// Registered Destination Sources
	.ID_EX_Reg_rd(id_ex_rd),
	// OUTPUT
	.PC_Stall(stall_core),
	.NOP_Ins(nop_ins), // no-operation insertion
	.flush(flush_if_id)
);
/*******************************************************************
REGISTER FILES
*******************************************************************/

/*******************************************************************
INTEGER REGISTER FILE
*******************************************************************/
(* keep_hierarchy = "yes" *)  RegFile_I #(
	.XLEN(XLEN)
)
	Integer_RegFile 
(
	.rst_n(rst_n),
	.CLK(clock_10),
	.Reg_Wr(regi_wr_en_mem_wb),
	.Rs1_rd(instr_if_id[19:15]),
	.Rs2_rd(instr_if_id[24:20]),
	.Rd_Wr(mem_wb_rd),
	.Rd_In(ireg_rd),
	.Rs1_Out(irs1_out),
	.Rs2_Out(irs2_out),
	.ireg_30(ireg_30),
	.ireg_31(ireg_31)
);


/*******************************************************************
SINGLE PRECISION FLOATING POINT REGISTER FILE
*******************************************************************/
(* keep_hierarchy = "yes" *)  RegFile_F #(
	.FLEN(FLEN)
)
	Floating_RegFile 
(
	.rst_n(rst_n),
	.CLK(clock_10),
	.Reg_Wr(regf_wr_en_mem_wb),
	.Rs1_rd(instr_if_id[19:15]),
	.Rs2_rd(instr_if_id[24:20]),
	.Rd_Wr(mem_wb_rd),
	.Rd_In(freg_rd),
	.Rs1_Out(frs1_out),
	.Rs2_Out(frs2_out),
    .freg_30(freg_30),
	.freg_31(freg_31)
);
/*******************************************************************
IMM EXT
*******************************************************************/
(* keep_hierarchy = "yes" *)  IMM_EXT Imm_Ext (
	.IMM_IN(instr_if_id),
	.opcode(opcode),     
	.IMM_OUT(imm_o)
);
/*******************************************************************
EXCUTE STAGE
*******************************************************************/

/*******************************************************************
ID/EX REGISTER
*******************************************************************/
(* keep_hierarchy = "yes" *)  ID_EX_REG ID_EX_Register (
	.CLK(clock_10),
	.rst_n(rst_n),
	// PC src
	.PC_I(pc_if_id),
	.Branch_I(branch),
	.Jump_I(jump),
	// IMM src
	.IMM_I(imm_o),
	.Opcode_I(opcode),
	// ALU Function Decision
	.Funct3_I(funct3),
	.Funct7_I(funct7),
	// RegFiles srcs
	.mem_wb_rd(mem_wb_rd),
	.imem_wb_data(ireg_rd),
	.fmem_wb_data(freg_rd),
	.iRs1_I(irs1_out),
	.iRs2_I(irs2_out),
	.fRs1_I(frs1_out),
	.fRs2_I(frs2_out),
	.RegI_Wr_En_I(regI_wr_En),
	.RegF_Wr_En_I(regF_wr_En),
	.iSrc_to_Reg_I(isrc_to_reg),
	.fSrc_to_Reg_I(fsrc_to_reg),
	.if_id_rs1(instr_if_id[19:15]),
	.if_id_rs2(instr_if_id[24:20]),
	.if_id_rd(instr_if_id[11:7]),
	.ireg_mem_wb_wr(regi_wr_en_mem_wb),
	.freg_mem_wb_wr(regf_wr_en_mem_wb),
	// ALU srcs
	.IDiv_I(idiv),
	.int_op_I(int_op),
	.fp_op_I(fp_op),
	.Sub_I(Sub),
	.IALU_Src1_Sel_I(ialu_src1_sel),
	.IALU_Src2_Sel_I(ialu_src2_sel),
	.FALU_Src1_Sel_I(falu_Src1_Sel),
	.IALU_Ctrl_I(ialu_ctrl),
	.FALU_Ctrl_I(falu_ctrl),
	// Memory srcs
	.store_src_I(store_src),
	.MEM_Wr_En_I(mem_wr_en),
	// PC src
	.PC_O(pc_id_ex),
	.Branch_O(branch_id_ex),
	.Jump_O(jump_id_ex),
	// IMM src
	.IMM_O(imm_id_ex),
	.Opcode_O(opcode_id_ex),
	// ALU Function Decision
	.Funct3_O(funct3_id_ex),
	.Funct7_O(funct7_id_ex),
	// RegFiles srcs
	.iRs1_O(irs1_out_id_ex),
	.iRs2_O(irs2_out_id_ex),
	.fRs1_O(frs1_out_id_ex),
	.fRs2_O(frs2_out_id_ex),
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
	.Sub_O(Sub_id_ex),
	.IALU_Src1_Sel_O(ialu_src1_sel_id_ex),
	.IALU_Src2_Sel_O(ialu_src2_sel_id_ex),
	.FALU_Src1_Sel_O(falu_src1_sel_id_ex),
	.IALU_Ctrl_O(ialu_ctrl_id_ex),
	.FALU_Ctrl_O(falu_ctrl_id_ex),
	// Memory srcs
	.store_src_O(store_src_id_ex),
	.MEM_Wr_En_O(mem_wr_En_id_ex)
);
/*******************************************************************
FORWARD
*******************************************************************/
(* keep_hierarchy = "yes" *)  IForward_Unit ialu_forward (
	.int_op_id_ex(int_op_id_ex),
	.int_op_ex_mem(int_op_ex_mem),
	.int_op_mem_wb(int_op_mem_wb),
	.EX_MEM_Reg_Wr(regi_wr_en_ex_mem),
	.MEM_WB_Reg_Wr(regi_wr_en_mem_wb),
	.ID_EX_rs1(id_ex_rs1),
	.ID_EX_rs2(id_ex_rs2),
	.EX_MEM_rd(ex_mem_rd),
	.MEM_WB_rd(mem_wb_rd),
	.Forward_A(iforw_src1),
	.Forward_B(iforw_src2)
);

(* keep_hierarchy = "yes" *)  FForward_Unit falu_forward (
	.fp_op_id_ex(fp_op_id_ex),
	.fp_op_ex_mem(fp_op_ex_mem),
	.fp_op_mem_wb(fp_op_mem_wb),
	.int_op_ex_mem(int_op_ex_mem),
	.int_op_mem_wb(int_op_mem_wb),
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
(* keep_hierarchy = "yes" *)  mux2x1 fsel_src1 (
	.i0(frs1_out_id_ex),
	.i1(irs1_out_id_ex),
	.sel(falu_src1_sel_id_ex),
	.out(fsrc1)
);

(* keep_hierarchy = "yes" *) mux2x1 isel_src1 (
	.i0(iforw1_out),
	.i1(pc_id_ex),
	.sel(ialu_src1_sel_id_ex),
	.out(irs1_src)
);

(* keep_hierarchy = "yes" *) mux2x1 isel_src2 (
	.i0(iforw2_out),
	.i1(imm_id_ex),
	.sel(ialu_src2_sel_id_ex),
	.out(irs2_src)
);

(* keep_hierarchy = "yes" *) mux4x1 iforw1_sel (
	.i0(irs1_out_id_ex), 		   // Don't Forward
	.i1(ireg_rd),          // Forward From 5th Stage
	.i2(iresult),		   // Forward From 4th Stage
	.sel0(iforw_src1[0]),
	.sel1(iforw_src1[1]),
	.out(iforw1_out)
);

(* keep_hierarchy = "yes" *) mux4x1 iforw2_sel (
	.i0(irs2_out_id_ex), 		   // Don't Forward
	.i1(ireg_rd),          // Forward From 5th Stage
	.i2(iresult),		   // Forward From 4th Stage
	.sel0(iforw_src2[0]),
	.sel1(iforw_src2[1]),
	.out(iforw2_out)
);

(* keep_hierarchy = "yes" *) mux8x1 fforw1_sel (
	.i0(fsrc1),            // Don't Forward
	.i1(freg_rd), 		   // Forward From 5th Stage
	.i2(fresult),		   // Forward From 4th Stage
	.i3(iresult),		   // Forward From 4th Stage (integer ==> Floating)
	.i4(ireg_rd),		   // Forward From 5th Stage (integer ==> Floating)
	.sel0(fforw_src1[0]),
	.sel1(fforw_src1[1]),
	.sel2(fforw_src1[2]),
	.out(frs1_src)
);

(* keep_hierarchy = "yes" *) mux4x1 fforw2_sel (
	.i0(frs2_out_id_ex),   // Don't Forward
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
(* keep_hierarchy = "yes" *) I_ALU #(
	.XLEN(XLEN)
) 
	Intger_ALU 
(
	.rst_n(rst_n),
	.CLK(clock_10),
	.Rs1(irs1_src),
	.Rs2(irs2_src),
	.Sub(Sub_id_ex),
	.IALU_ctrl(ialu_ctrl_id_ex),
	.Funct3(funct3_id_ex),
	.Funct7_5(funct7_id_ex[5]),
	.Result(iresult),
	.div_by_zero(div_by_zero),
	.div_done(div_done),	
	.overflow(ioverflow)  
);

(* keep_hierarchy = "yes" *) Branch_Unit #(
	.XLEN(XLEN)
) 
	Branch_Detect
(
	// INPUT
	.funct3(funct3_id_ex),
	.Rs1(iforw1_out),
	.Rs2(iforw2_out),
	.En(Intger_ALU.alu_decode.D_out[6]), 
	// OUTPUT
	.Branch_taken(branch_taken)
);

assign pc_change = (branch_taken & branch_id_ex) | (jump_id_ex);

/*******************************************************************
FLOATING ALU
*******************************************************************/
(* keep_hierarchy = "yes" *) Floating_Unit #(
	.FLEN(FLEN)
) 
	FPU
(
	.rst_n(rst_n),
	.CLK(clock_10),
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
(* keep_hierarchy = "yes" *) fpu_err FPU_Exception (
	.Result(fresult),
	.NaN(nan),
	.pinf(pinf), // positive inf
	.ninf(ninf)  // negative inf
);

assign fexception = nan | pinf | ninf;

(* keep_hierarchy = "yes" *) mux2x1 mem_store_src (
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
(* keep_hierarchy = "yes" *) EX_MEM_REG #(
	.XLEN(XLEN),
	.FLEN(FLEN)
)
	EX_MEM_Register 
(
////////////////////////// INPUT //////////////////////
	.CLK(clock_10),
	.rst_n(rst_n),
	// PC src
	.PC_I(pc_id_ex),
	// RegFiles srcs
	.RegI_Wr_En_I(regi_wr_en_id_ex),
	.RegF_Wr_En_I(regf_wr_en_id_ex),
	.id_ex_rd(id_ex_rd),
	// .irs2_I(irs2_out),
	// .frs2_I(frs2_out),
	// ALU srcs
	.IDiv(idiv_id_ex),
	.div_done(div_done),
	.int_op_I(int_op_id_ex),
	.fp_op_I(fp_op_id_ex),
	// Memory srcs
	.MEM_Wr_En_I(mem_wr_En_id_ex),
	.iSrc_to_Reg_I(isrc_to_reg_id_ex),
	.fSrc_to_Reg_I(fsrc_to_reg_id_ex),
	.store_to_mem_I(sel_store_src),
	////////////////////////// OUTPUT //////////////////////
	// PC src
	.PC_O(pc_ex_mem),
	// RegFiles srcs
	.RegI_Wr_En_O(regi_wr_en_ex_mem),
	.RegF_Wr_En_O(regf_wr_en_ex_mem),
	.ex_mem_rd(ex_mem_rd),
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// ALU srcs
	.int_op_O(int_op_ex_mem),
	.fp_op_O(fp_op_ex_mem),
	// Memory srcs
	.MEM_Wr_En_O(mem_wr_En_ex_mem),
	.iSrc_to_Reg_O(isrc_to_reg_ex_mem),
	.fSrc_to_Reg_O(fsrc_to_reg_ex_mem),
	.store_to_mem_O(store_to_mem)
);
/*******************************************************************
 Data Memory
*******************************************************************/
(* keep_hierarchy = "yes" *) Data_Memory DMem (
	.clk(clock_10),
	.we(mem_wr_En_ex_mem),
	.di(store_to_mem),
	.addr(iresult),
	.dout(data_mem_out)
);

/*******************************************************************
WRITE_BACK STAGE 
*******************************************************************/
(* keep_hierarchy = "yes" *) MEM_WB_REG #(
	.XLEN(XLEN),
	.FLEN(FLEN)
) 
	MEM_WB_Register	
(
////////////////////////// INPUT //////////////////////
	.CLK(clock_10),
	.rst_n(rst_n),
	// PC src
	.PC_I(pc_ex_mem),
	// RegFiles srcs
	.RegI_Wr_En_I(regi_wr_en_ex_mem),
	.RegF_Wr_En_I(regf_wr_en_ex_mem),
	.ex_mem_rd(ex_mem_rd),
	// ALU srcs
	.int_op_I(int_op_ex_mem),
	.fp_op_I(fp_op_ex_mem),
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
	.int_op_O(int_op_mem_wb),
	.fp_op_O(fp_op_mem_wb),
	.iresult_O(iresult_mem_wb),
	.fresult_O(fresult_mem_wb),
	// Register Write srcs
	.iSrc_to_Reg_O(isrc_to_reg_mem_wb),
	.fSrc_to_Reg_O(fsrc_to_reg_mem_wb)
);

assign pc4_to_reg = pc_mem_wb + 3'b100;

(* keep_hierarchy = "yes" *) mux4x1_wb ireg_src (
	.i0(iresult_mem_wb),   // From Integer ALU
	.i1(data_mem_out), // From Data Memory in case of load		   
	.i2(pc4_to_reg),       // In Case of jump instructions
	.i3(fresult_mem_wb),
	.sel0(isrc_to_reg_mem_wb[0]),
	.sel1(isrc_to_reg_mem_wb[1]),
	.out(ireg_rd)
);

(* keep_hierarchy = "yes" *) mux2x1 freg_src (
	.i0(fresult_mem_wb),   // From Floating ALU
	.i1(data_mem_out), // From Data Memory in case of load
	.sel(fsrc_to_reg_mem_wb),
	.out(freg_rd)
);

endmodule

