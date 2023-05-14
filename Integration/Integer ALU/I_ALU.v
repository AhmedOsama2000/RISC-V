module I_ALU #(
	parameter XLEN 		  = 32,
	parameter DECODER_IN  = 3,
	parameter DECODER_OUT = 2^(DECODER_IN) 
)
(
	input  wire                  rst_n,
	input  wire                  CLK,
	input  wire [XLEN-1:0] 		 Rs1,
	input  wire [XLEN-1:0] 		 Rs2,
	input  wire                  Add_Op,
	input  wire [DECODER_IN-1:0] IALU_ctrl,
	input  wire [2:0]            Funct3,
	input  wire  			     Funct7_5,
	output reg [XLEN-1:0]        Result,
	output wire					 Branch_taken,
	output wire                  div_by_zero,
	output wire                  div_done,	
	output reg                   overflow           
);

wire [DECODER_OUT-1:0] D_out;
wire [XLEN-1:0] 	   add_sub_res;
wire [XLEN-1:0] 	   mul_res;
wire [XLEN-1:0]        div_res;
wire                   div_ready;
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
	.Add_Op(Add_Op),
	.Funct7_5(Funct7_5),
	.Result(add_sub_res),
	.overflow(add_sub_overflow)
);

// Mul Unit
mul_top_ref mul (
	.En(D_out[1]),
	.Multiplier(Rs1),
	.Multiplicand(Rs2),
	.Funct_1_0(Funct3[1:0]),
	.Result(mul_res)
);

Division_BLOCK div (
	.data_valid(D_out[2]),
	.CLK(CLK),
	.rst_n(rst_n),
	.dividend(Rs1),
	.divisor(Rs2),
	.operation(Funct3[1:0]),
	.divided_by_zero(div_by_zero),
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

// Branch Unit
Branch_Unit branch (
	.Rs1(Rs1),
	.Rs2(Rs2),
	.funct3(Funct3),
	.En(D_out[6]),
	.Branch_taken(Branch_taken)
);

// EX Stage
// Register The Result
always @(posedge CLK,negedge rst_n) begin
	
	overflow <= add_sub_overflow;
	if (!rst_n) begin
		Result   <= 'b0;
		overflow <= 1'b0;
	end
	else if (IALU_ctrl == 3'b000) begin
		Result   <= add_sub_res;
	end
	else if (IALU_ctrl == 3'b001) begin
		Result   <= mul_res;
	end
	else if (IALU_ctrl == 3'b010) begin
		Result   <= div_res;
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