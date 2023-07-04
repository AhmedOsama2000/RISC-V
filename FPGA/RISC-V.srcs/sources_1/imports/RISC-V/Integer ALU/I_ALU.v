(* DONT_TOUCH = "TRUE" *) module I_ALU #(
	parameter XLEN 		  = 32,
	parameter DECODER_IN  = 3,
	parameter DECODER_OUT = 2**DECODER_IN
)
(
	input  wire                  rst_n,
	input  wire                  CLK,
	input  wire [XLEN-1:0] 		 Rs1,
	input  wire [XLEN-1:0] 		 Rs2,
	input  wire [DECODER_IN-1:0] IALU_ctrl,
	input  wire [2:0]            Funct3,
	input  wire  			     Funct7_5,
	input  wire                  Sub,
	output reg [XLEN-1:0]        Result,
	output wire                  div_by_zero,
	output wire                  div_done,	
	output reg                   overflow           
);

wire [DECODER_OUT-1:0] D_out;
wire [XLEN-1:0] 	   add_sub_res;
wire [XLEN-1:0] 	   mul_res;
wire [XLEN-1:0]        div_res;
wire [XLEN-1:0] 	   set_res;
wire [XLEN-1:0] 	   logic_res;
wire [XLEN-1:0] 	   shift_res;
wire                   add_sub_overflow;

// ALU Decoder
IALU_Decoder alu_decode (
	.IALU_Ctrl(IALU_ctrl),
	.D_out(D_out)
);

// Adder/subtractor
CLA_ADD_SUB CLA (
	.En(D_out[0]),
	.Rs1(Rs1),
	.Rs2(Rs2),
	.Sub(Sub),
	.Result(add_sub_res),
	.overflow(add_sub_overflow)
);

// Mul Unit
Multiblacation_Unit mul (
	.En(D_out[1]),
	.Multiplier_i(Rs1),
	.Multiplacant_i(Rs2),
	.operation_i(Funct3[1:0]),
	.product_o(mul_res)
);

Division_BLOCK div (
	.data_valid(D_out[2]),
	.CLK(CLK),
	.rst_n(rst_n),
	.dividend(Rs1),
	.divisor(Rs2),
	.operation(Funct3[1:0]),
	.div_by_zero(div_by_zero),
	.product_o(div_res),
	.data_ready(div_done)
);

// Set Unit
SET_UNIT set (
	.En(D_out[3]),
	.Rs1(Rs1),
	.Rs2(Rs2),
	.Funct3_0(Funct3[0]),
	.Result(set_res)
);

// Logic Unit
Logical_Unit Logic (
	.En(D_out[4]),
	.Rs1(Rs1),
	.Rs2(Rs2),
	.Funct3_1_0(Funct3[1:0]),
	.Result(logic_res)
);

// Shift Unit
Shift_Unit shift (
	.En(D_out[5]),
	.Rs1(Rs1),
	.Rs2(Rs2[4:0]),
	.funct3_2(Funct3[2]),
	.funct7_5(Funct7_5),
	.Result(shift_res)
);

// EX Stage
// Register The Result
always @(posedge CLK,negedge rst_n) begin
	
	overflow <= add_sub_overflow;
	if (!rst_n) begin
		Result   <= 'b0;
		overflow <= 1'b0;
	end
	else if (div_done) begin
	   Result    <= div_res;
	end
	else if (IALU_ctrl == 3'b000 || IALU_ctrl == 3'b110) begin
		Result   <= add_sub_res;
	end
	else if (IALU_ctrl == 3'b001) begin
		Result   <= mul_res;
	end
	else if (IALU_ctrl == 3'b011) begin
		Result   <= set_res;
	end
	else if (IALU_ctrl == 3'b100) begin
		Result   <= logic_res;
	end
	else if (IALU_ctrl == 3'b101) begin
		Result   <= shift_res;
	end

end

endmodule