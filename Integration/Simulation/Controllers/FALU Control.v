module FALU_Control
#(
	parameter ALU_DECODER_IN = 3
)
(
	// Input
	input  wire [4:0] Funct7_6_2,
	input  wire       undef_instr,      
	// Output
	output reg  [ALU_DECODER_IN-1:0] FALU_Ctrl
);

wire [4:0] instr_def;

assign instr_def = Funct7_6_2;

localparam ADD   = 5'b00000;
localparam SUB   = 5'b00001;

localparam MUL   = 5'b00010;
// localparam DIV   = 5'b00011;

localparam CMP   = 5'b10100;

localparam CVTFI = 5'b11000; // FLoating ==> Integer
localparam CVTIF = 5'b11010; // Integer  ==> Floating

always @(*) begin
	if (undef_instr) begin
		FALU_Ctrl = 3'b111;
	end
	else begin
		FALU_Ctrl = 3'b111;
		case (instr_def) 
			ADD , SUB     : FALU_Ctrl = 3'b000;
			MUL 	      : FALU_Ctrl = 3'b001;
			// DIV 	      : FALU_Ctrl = 3'b010; 
			CMP		      : FALU_Ctrl = 3'b011;
			CVTFI , CVTIF : FALU_Ctrl = 3'b100;
			default   	  : FALU_Ctrl = 3'b111;
		endcase
	end
end

endmodule