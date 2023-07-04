(* DONT_TOUCH = "TRUE" *) module Main_Decoder
(
	// INPUT
	input wire [6:0] Opcode,
	input wire       EN_PC,
	input wire       NOP_Ins,
	input wire       if_id_flush,	
	input wire [4:0] Funct7_6_2, 
	// OUTPUT
	// Memory Control Signals
	output reg       MEM_Wr_En,
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
localparam R_TYPE_I = 7'b0110011;

// I_Type Format
localparam IMM 		= 7'b0010011;
localparam LOAD_I   = 7'b0000011;
localparam LOAD_F   = 7'b0000111;
localparam JALR     = 7'b1100111;

// S_Type
localparam STORE_I  = 7'b0100011;
localparam STORE_F  = 7'b0100111;
// SB_Type
localparam BRANCH 	= 7'b1100011; 

// UJ_Type
localparam JAL      = 7'b1101111;

// U_Type
localparam LUI 	    = 7'b0110111;
localparam AUIPC    = 7'b0010111;

// Floating Point Instructions
localparam R_TYPE_F = 7'b1010011;

reg [3:0] reg_flags;
reg [2:0] alu_src_flags;

reg main_alu_src1;
reg main_alu_src2;

reg PC_Change;
reg pc_src_flags;

assign {RegF_Wr_En,RegI_Wr_En} 					   = reg_flags;
assign {FALU_Src1_Sel,IALU_Src1_Sel,IALU_Src2_Sel} = alu_src_flags;

always @(*) begin
	
	MEM_Wr_En     = 1'b0;
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
	store_src     = 1'b0;

	// NOP insertion or Instruction is corrupted
	if (NOP_Ins || !EN_PC || if_id_flush) begin
		main_alu_src1 = 1'b0;
		main_alu_src2 = 1'b0;
		iSrc_to_Reg   = 2'b00;
		fSrc_to_Reg   = 1'b0;
		reg_flags     = 'b0;
		alu_src_flags = 'b0;
		Branch        = 1'b0;
	    Jump          = 1'b0;
		undef_instr   = 1'b0;
		int_op        = 1'b0;
		fp_op         = 1'b0;
		store_src     = 1'b0;
		MEM_Wr_En     = 1'b0;
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
				int_op  	  = 1'b1;
				fp_op         = 1'b1;
				reg_flags 	  = 2'b01;
				alu_src_flags = 3'b001;
				iSrc_to_Reg   = 2'b01;
			end
			LOAD_F: begin
				int_op  	  = 1'b1;
				fp_op         = 1'b1;
				reg_flags 	  = 2'b10;
				alu_src_flags = 3'b001;
				fSrc_to_Reg   = 1'b1;
			end
			STORE_I: begin
				int_op  	  = 1'b1;
				fp_op         = 1'b1;
				alu_src_flags = 3'b001;
				MEM_Wr_En     = 1'b1;
			end
			STORE_F: begin
				int_op  	  = 1'b1;
				fp_op         = 1'b1;
				store_src     = 1'b1;
				main_alu_src1 = 1'b1;
				alu_src_flags = 3'b001;
				MEM_Wr_En     = 1'b1;
			end
			BRANCH: begin
				int_op  	  = 1'b1;
				alu_src_flags = 3'b011;
				PC_Change     = 1'b1;
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
				int_op  	  = 1'b1;
				Jump          = 1'b1;
				reg_flags     = 2'b01;
				PC_Change     = 1'b1;
				iSrc_to_Reg   = 2'b10;
				alu_src_flags = 3'b001;
			end
			LUI: begin
				reg_flags     = 2'b01;
				alu_src_flags = 3'b001;
			end
			AUIPC: begin
				reg_flags     = 2'b01;
				alu_src_flags = 3'b011;
			end
			R_TYPE_F : begin
				if (Funct7_6_2 == 5'b10100 || Funct7_6_2 == 5'b11000) begin
					reg_flags   = 2'b01;
					fp_op       = 1'b1;
					int_op      = 1'b1;
					iSrc_to_Reg = 2'b11;
				end
				else if (Funct7_6_2 == 5'b11010) begin
					fp_op         = 1'b1;
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
				MEM_Wr_En     = 1'b0;
				reg_flags     = 2'b0;
				alu_src_flags = 3'b0;
				pc_src_flags  = 2'b0;
				undef_instr   = 1'b1;
				int_op        = 1'b0;
				fp_op         = 1'b0;
			end
		endcase
	end
	
end

endmodule