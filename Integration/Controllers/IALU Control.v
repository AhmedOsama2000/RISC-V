module IALU_Control
#(
	parameter ALU_DECODER_IN = 3
)
(
	// Input
	input  wire [2:0] Funct3,
	input  wire       Funct7_5,
	input  wire       Funct7_0,
	input  wire       undef_instr,
	input  wire       Add_Op,       
	// Output
	output reg  [ALU_DECODER_IN-1:0] IALU_Ctrl,
	output wire       IDiv
);

localparam ADD    = 5'b00000;
localparam SUB    = 5'b01000;

localparam MUL    = 5'b01000;
localparam MULH   = 5'b01001; 
localparam MULHSU = 5'b01010; 
localparam MULHU  = 5'b01011; 

localparam DIV    = 5'b01100;
localparam DIVU   = 5'b01101; 
localparam REM 	  = 5'b01110; 
localparam REMU   = 5'b01111;

localparam AND    = 5'b00111;
localparam OR  	  = 5'b00110; 
localparam XOR    = 5'b00100; 

localparam SLL    = 5'b00001;
localparam SRL    = 5'b00101; 
localparam SRA 	  = 5'b10101; 

localparam SLT    = 5'b00010; 
localparam SLTU   = 5'b00011;

localparam BRANCH = 5'b11111;

wire [4:0] instr_def;
assign IDiv = (instr_def == DIV || instr_def == REM || instr_def == DIVU || instr_def == REMU)? 1'b1:1'b0;

assign instr_def = {Funct7_5,Funct7_0,Funct3};

always @(*) begin
	if (undef_instr) begin
		IALU_Ctrl = 3'b111;
	end
	else begin
		IALU_Ctrl = 3'b111;
		case (instr_def) 
			ADD , SUB , Add_Op 			: IALU_Ctrl = 3'b000;
			MUL , MULH , MULHSU , MULHU	: IALU_Ctrl = 3'b001;
			DIV , DIVU , REM , REMU		: IALU_Ctrl = 3'b010; 
			SLT , SLTU					: IALU_Ctrl = 3'b011;
			AND , OR , XOR				: IALU_Ctrl = 3'b100;
			SLL , SRL , SRA 			: IALU_Ctrl = 3'b101;
			BRANCH						: IALU_Ctrl = 3'b110;
			default                     : IALU_Ctrl = 3'b111;
		endcase
	end
end

endmodule