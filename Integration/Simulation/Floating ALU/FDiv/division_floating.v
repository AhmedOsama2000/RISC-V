module division_floating #( parameter XLEN = 32

)(
 	//inputs
	input  wire               CLK,
	input  wire               rst_n,
    input  wire [XLEN - 1:0]  dividend,
    input  wire [XLEN - 1:0]  divisor,
    input  wire               data_valid,

	//outputs    
	output wire               divided_by_zero,
	output wire  [XLEN - 1:0]  product_o,
	output wire               data_ready
);


wire [7:0]  dividend_exponent, divisor_exponent ;
wire                dividend_sign, divisor_sign ;
wire [22:0] dividend_mantissa, divisor_mantissa ;

reg [23:0] dividend_mantissa_norm, divisor_mantissa_norm,divisor_mantissa_shift;
reg [23:0] dividend_mantissa_div, divisor_mantissa_div;

// format dividend 
assign dividend_sign     = dividend[XLEN-1] ; 
assign dividend_exponent = dividend[XLEN-2:23];
assign dividend_mantissa = dividend[22:0];

// format divisor 
assign divisor_sign     = divisor[XLEN-1] ; 
assign divisor_exponent = divisor[XLEN-2:23];
assign divisor_mantissa = divisor[22:0];

// signals for instantiation 
wire [23:0] quotient, remainder ;
wire [23:0] remainder_new;
wire [23:0] remainder_restore;
wire [23:0] quotient_new;

reg [23:0] quotient_norm;

// signals for product output 
reg product_o_sign ;
reg [22:0] product_o_mantissa ;
reg [7:0]  product_o_exponent ;

wire [4:0] shft1;
wire [4:0] shft2;
wire [4:0] shft3;

lz_counting_right lzc1 (
	.A({{8'b0},{1'b1},dividend_mantissa}),
	.LZC(shft1)
);

lz_counting_right lzc2 (
	.A({{8'b0},{1'b1},divisor_mantissa}),
	.LZC(shft2)
);

lz_counting lzc3 (
	.A({quotient,{8'b0}}),
	.LZC(shft3)
);

 non_restoring_floating  non_restoring_U (
	//inputs
	.CLK(CLK),
	.rst_n(rst_n),
    .dividend({dividend_mantissa_norm}),
    .divisor({divisor_mantissa_norm}),
    .data_valid(data_valid),

	//outputs    
	.quotient(quotient),
	.remainder(remainder),
	.data_ready(data_ready)
);

 always @(*) begin

 	dividend_mantissa_div = {1'b1,dividend_mantissa};
 	divisor_mantissa_div  = {1'b1,divisor_mantissa};

 	dividend_mantissa_norm = dividend_mantissa_div >> shft1;
 	divisor_mantissa_norm  = divisor_mantissa_div >> shft2;

 	quotient_norm = quotient << shft3;

 if (data_ready) begin
 	for (i = 0;i < 33;i = i + 1) begin
 		
 	end
 		if (divisor_mantissa > dividend_mantissa) begin
 			
 			remainder_new = divisor_mantissa - remainder;
 			if (remainder_new >= 0) begin
 				quotient_new      = {quotient[23:1],1'b1};
 			end
 			else begin
 				remainder_restore = remainder_new + divisor_mantissa;
 				quotient_new      = {quotient[23:1],1'b0}; 
 			end
 			divisor_mantissa_shift = divisor_mantissa >> 1;

 		end
		product_o_sign = divisor[XLEN-1] ^ dividend[XLEN-1] ;
		product_o_mantissa  = quotient_norm[22:0] ;
		product_o_exponent = dividend[XLEN-2:23] - divisor[XLEN-2:23] + 127; 
	end

end

assign product_o = {product_o_sign, product_o_exponent, product_o_mantissa} ;
assign divided_by_zero = (divisor == 'd0) ? 1'b1 : 1'b0 ;

endmodule 