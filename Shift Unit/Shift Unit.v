module Shift_Unit #(
	parameter XLEN   = 32
)
(
	// INPUT
	input  wire signed [XLEN-1:0] Src1,
	input  wire  	   [XLEN-1:0] Src2,
	input  wire  			 	  funct3_2, 
	input  wire              	  funct7_5,
	input  wire              	  En,

	// OUTPUT
	output reg         [XLEN-1:0] Result
);

localparam SLL = 2'b00;
localparam SRL = 2'b01;
localparam SRA = 2'b11;

always @(*) begin
	if (En) begin
		
		case ({funct7_5,funct3_2})
		SLL    : Result = Src1 << Src2;

		SRL    : Result = Src1 >> Src2;

		SRA    : Result = Src1 >>> Src2;

		default: Result = 'b0;
		endcase

	end
	else begin	
		Result = 'b0;
	end
	
end

endmodule