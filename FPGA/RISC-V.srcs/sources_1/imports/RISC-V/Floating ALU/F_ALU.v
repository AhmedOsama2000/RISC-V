(* DONT_TOUCH = "TRUE" *) module Floating_Unit #(
	parameter FLEN 		  = 32,
	parameter DECODER_IN  = 3,
	parameter DECODER_OUT = 8
)
(
	input  wire                  rst_n,
	input  wire                  CLK,
	input  wire [FLEN-1:0] 		 Rs1,
	input  wire [FLEN-1:0] 		 Rs2,
	input  wire [DECODER_IN-1:0] FALU_ctrl,
	input  wire [2:0]            Funct3,
	input  wire [1:0] 			 Funct7_3_2,
	output reg  [FLEN-1:0]       Result,
	output reg                   overflow      
);

wire [DECODER_OUT-1:0] D_out;
wire [FLEN-1:0] 	   add_sub_res;
wire [FLEN-1:0] 	   mul_res;
// wire [FLEN-1:0] 	   div_res;
wire [FLEN-1:0] 	   cmp_res;
wire [FLEN-1:0] 	   cvt_res;

// wire add_sub_overflow;
wire mul_overflow;
// wire div_overflow;

// ALU Decoder
FALU_Decoder falu_decode (
	.FALU_Ctrl(FALU_ctrl),
	.D_out(D_out)
);

// Adder/subtractor
fadd_fsub add_sub (
	.frs1(Rs1),
	.frs2(Rs2),
	.En(D_out[0]),
	.Funct(Funct7_3_2[0]),		// 0 for add - 1 for sub
	.frd(add_sub_res)
);

// Mul Unit
FPU_MUL mul (
	.En(D_out[1]),
	.Rs1(Rs1),
	.Rs2(Rs2),
	.overflow(mul_overflow),
	.Result(mul_res)
);

// Div Unit


// Set Unit
F_CMP cmp (
	.En(D_out[3]),
	.Rs1(Rs1),
	.Rs2(Rs2),
	.Funct3_1_0(Funct3[1:0]),
	.Result(cmp_res)
);

// Shift Unit
F_CVT cvt (
	.En(D_out[4]),
	.Rs1(Rs1),
	.Rs2_0(Rs2[0]),
	.Funct7_3(Funct7_3_2[1]),
	.Result(cvt_res)
);

// EX Stage
// Register The Result
always @(posedge CLK,negedge rst_n) begin
	
	
	if (!rst_n) begin
		Result   <= 'b0;
		overflow <= 1'b0;
	end
	else if (FALU_ctrl == 3'b000) begin
		Result   <= add_sub_res;
		// overflow <= add_sub_overflow;
	end
	else if (FALU_ctrl == 3'b001) begin
		Result   <= mul_res;
		overflow <= mul_overflow;
	end
	/*else if (FALU_ctrl == 3'b010) begin
		Result   <= div_res;
		overflow <= div_overflow;
	end*/
	else if (FALU_ctrl == 3'b011) begin
		Result   <= cmp_res;
		overflow <= 1'b0;
	end
	else if (FALU_ctrl == 3'b100) begin
		Result   <= cvt_res;
		overflow <= 1'b0;
	end

end

endmodule