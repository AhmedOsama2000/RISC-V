module Main_Decoder
(
	// INPUT
	input wire [4:0] Opcode,
	input wire       EN_PC,
	input wire       NOP_Ins,	
	input wire [4:0] Funct7_6_2, 
	input wire       i_cache_en,
	// OUTPUT
	// Memory Control Signals
	output wire      MEM_Rd_En,
	output wire      MEM_Wr_En,
	output reg       store_src,
	// Register Write Source
	output reg [1:0] iSrc_to_Reg,
	output reg       fSrc_to_Reg,	
	// RegFile Control Signals
	output wire 	 RegI_Wr_En,
	output wire 	 RegF_Wr_En,
	// Integer ALU Source signals
	output wire 	 IALU_Src1_Sel,
	output wire 	 IALU_Src2_Sel,
	output reg       int_op,
	// Floating ALU Source signals
	output wire      FALU_Src1_Sel,
	output reg       fp_op,
	output reg       i2f_op,
	// PC signals
	output reg       Branch,
	output reg       Jump,
	// Floating point instruction detection
	output reg       fpu_ins,
	// undefined instruction
	output reg       undef_instr
);

// Supported ISA Based on the opcode
// Integer Instrustions
// R_TYPE Format
localparam R_TYPE_I = 5'b01100;

// I_Type Format
localparam IMM 		= 5'b00100;
localparam LOAD_I   = 5'b00000;
localparam LOAD_F   = 5'b00001;
localparam JALR     = 5'b11001;

// S_Type
localparam STORE_I  = 5'b01000;
localparam STORE_F  = 5'b01001;
// SB_Type
localparam BRANCH 	= 5'b11000; 

// UJ_Type
localparam JAL      = 5'b11011;

// U_Type
localparam LUI 	    = 5'b01101;
localparam AUIPC    = 5'b00101;

// Floating Point Instructions
localparam R_TYPE_F = 5'b10100;

reg [1:0] mem_flags;
reg [3:0] reg_flags;
reg [2:0] alu_src_flags;

reg main_alu_src1;
reg main_alu_src2;

reg PC_Change;
reg pc_src_flags;

assign {MEM_Rd_En,MEM_Wr_En}   					   = mem_flags;
assign {RegF_Wr_En,RegI_Wr_En} 					   = reg_flags;
assign {FALU_Src1_Sel,IALU_Src1_Sel,IALU_Src2_Sel} = alu_src_flags;

always @(*) begin
	
	mem_flags     = 'b0;
	iSrc_to_Reg   = 2'b00;
	fSrc_to_Reg   = 1'b0;
	reg_flags     = 2'b00;
	alu_src_flags = 'b0;
	Branch        = 1'b0;
	Jump          = 1'b0;
	undef_instr   = 1'b0;
	fpu_ins       = 1'b0;
	int_op        = 1'b0;
	fp_op         = 1'b0;
	i2f_op        = 1'b0;
	store_src     = 1'b0;

	// NOP insertion && Instruction is corrupted
	if (NOP_Ins || !i_cache_en || !EN_PC) begin
		main_alu_src1 = 1'b0;
		main_alu_src2 = 1'b0;
		mem_flags     = 'b0;
		iSrc_to_Reg   = 2'b00;
		fSrc_to_Reg   = 1'b0;
		reg_flags     = 'b0;
		alu_src_flags = 'b0;
		Branch        = 1'b0;
	    Jump          = 1'b0;
		undef_instr   = 1'b0;
		int_op        = 1'b0;
		fp_op         = 1'b0;
		i2f_op        = 1'b0;
		store_src     = 1'b0;
	end
	else begin
		case (Opcode)
			R_TYPE_I: begin
				reg_flags 	  = 2'b01;
				int_op  	  = 1'b1;
			end
			IMM:begin
				reg_flags 	  = 2'b01;
				alu_src_flags = 3'b001; 
				int_op  	  = 1'b1;
			end
			LOAD_I: begin
				reg_flags 	  = 2'b01;
				alu_src_flags = 3'b001;
				iSrc_to_Reg   = 2'b01;
				mem_flags     = 2'b10;
			end
			LOAD_F: begin
				reg_flags 	  = 2'b10;
				alu_src_flags = 3'b001;
				fSrc_to_Reg   = 1'b1;
				mem_flags     = 2'b10;
			end
			STORE_I: begin
				alu_src_flags = 3'b001;
				mem_flags     = 2'b01;
			end
			STORE_F: begin
				store_src     = 1'b1;
				main_alu_src1 = 1'b1;
				alu_src_flags = 3'b001;
				mem_flags     = 2'b01;
			end
			BRANCH: begin
				PC_Change     = 1'b1;
				reg_flags     = 4'b0010;
				Branch        = 1'b1;
			end
			JAL: begin
				PC_Change     = 1'b1;
				reg_flags     = 2'b01;
				iSrc_to_Reg   = 2'b10;
				alu_src_flags = 3'b001;
				Jump          = 1'b1;
			end
			JALR: begin
				Jump          = 1'b1;
				reg_flags     = 2'b01;
				PC_Change     = 1'b1;
				iSrc_to_Reg   = 2'b10;
				alu_src_flags = 3'b001;
			end
			LUI: begin
				int_op  	  = 1'b1;
				reg_flags     = 2'b01;
				alu_src_flags = 3'b001;
			end
			AUIPC: begin
				int_op  	  = 1'b1;
				reg_flags     = 2'b01;
				alu_src_flags = 3'b011;
			end
			R_TYPE_F : begin
				if (Funct7_6_2 == 5'b10100 || Funct7_6_2 == 5'b11000) begin
					reg_flags   = 2'b01;
					fp_op       = 1'b1;
					iSrc_to_Reg = 2'b11;
				end
				else if (Funct7_6_2 == 5'b11010) begin
					fp_op         = 1'b1;
					i2f_op        = 1'b1;
					alu_src_flags = 3'b100;
					reg_flags     = 2'b10;
				end
				else begin
					fp_op         = 1'b1;
					reg_flags     = 2'b10;
				end 
			end
			default: begin
				store_src     = 1'b0;
				fpu_ins       = 1'b0;
				PC_Change     = 1'b0;
				mem_flags     = 2'b0;
				reg_flags     = 2'b0;
				alu_src_flags = 3'b0;
				pc_src_flags  = 2'b0;
				undef_instr   = 1'b1;
				int_op        = 1'b0;
				fp_op         = 1'b0;
				i2f_op        = 1'b0;
			end
		endcase
	end
	
end

endmodule