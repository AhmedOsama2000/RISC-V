module F_CVT #(
	parameter FLEN = 32
)
(
	input  wire            En,
	input  wire [FLEN-1:0] Rs1,
	input  wire  		   Rs2_0,
	input  wire 	   	   Funct7_3,
	output reg  [FLEN-1:0] Result
);

localparam FCVT_W_S  = 2'b00;
localparam FCVT_WU_S = 2'b01;
localparam FCVT_S_W  = 2'b10;
localparam FCVT_S_WU = 2'b11;
localparam EXP_BIAS  = 127;

wire [1:0] get_instr;

wire [4:0] 		lzc_rs;
reg  [4:0]      shmt_l;
reg  [4:0] 		shmt_r;
reg  [FLEN-1:0] shft_rs;
reg  [FLEN-1:0] tw_cmp_i2f;
reg  [FLEN-1:0] tw_cmp_f2i;

reg        sign;
reg [7:0]  exp;
reg [22:0] mantisa;

// Calcuales the position of the leading one (shift amount)
lzc_32 lzc (
	.a(tw_cmp_i2f),
	.c(lzc_rs)
);

assign get_instr = {Funct7_3,Rs2_0};

always @(*) begin
	
	sign   = 1'b0;
	Result = 'b0;
	tw_cmp_f2i = 'b0;
	if (En) begin
		case (get_instr)
			FCVT_W_S , FCVT_WU_S: begin
				sign = Rs1[FLEN-1];
				tw_cmp_f2i = shft_rs;
				tw_cmp_f2i[shmt_r] = 1'b1;
				if (sign) begin
					Result = ~tw_cmp_f2i + 1'b1;
				end
				else begin
					Result = tw_cmp_f2i;
				end
			end
			FCVT_S_W: begin
				sign = Rs1[FLEN-1];
				Result = {sign,exp,mantisa};
			end
			FCVT_S_WU: begin
				sign = 1'b0;
				Result = {sign,exp,mantisa};
			end
			default: sign = 'b0;
		endcase
	end
	else begin
		sign = 1'b0;
		Result = 'b0;
	end

end

always @(*) begin
	exp 	   = 'b0;
	mantisa    = 'b0;
	shmt_l     = 'b0;
	shmt_r     = 'b0;
	shft_rs    = 'b0;
	tw_cmp_i2f = 'b0;
	// Integer ==> Floating Conversion
	if (En && Rs1 != 0 && get_instr[1]) begin
		if (Rs1[FLEN-1]) begin
			tw_cmp_i2f = ~Rs1 + 1'b1;
		end
		else begin
			tw_cmp_i2f = Rs1;
		end
		exp     = lzc_rs + EXP_BIAS;
		shmt_l  = 32  - lzc_rs;
		shft_rs = tw_cmp_i2f << shmt_l;
		mantisa = shft_rs[FLEN-1:9];
	end
	// Floating ==> Integer Conversion
	else if (En && Rs1 != 0 && !get_instr[1]) begin
		{exp,mantisa} = Rs1[FLEN-2:0];
		shmt_r = exp - EXP_BIAS;
		shft_rs = {mantisa >> (23 - shmt_r)};
	end
	else begin
		{exp,mantisa} = 'b0;
		shmt_r 		  = 'b0;
		shmt_l 		  = 'b0;
		shft_rs 	  = 'b0;
		tw_cmp_i2f    = 'b0;
	end
end

endmodule