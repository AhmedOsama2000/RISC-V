module Division_BLOCK #(
	parameter XLEN 		  = 32,
	parameter COUNT_WIDTH = $clog2(XLEN)
)
(
	//inputs
	input  wire               CLK,
	input  wire               rst_n,
    input  wire [XLEN - 1:0]  dividend,
    input  wire [XLEN - 1:0]  divisor,
    input  wire               data_valid,
    input  wire [1:0]         operation,

	//outputs    
	output                    divided_by_zero,
	output reg  [XLEN - 1:0]  product_o,
	output wire               data_ready
);


localparam DIV   = 2'b00;
localparam DIVU  = 2'b01;
localparam REM   = 2'b10;
localparam REMU  = 2'b11;
//internal signals

wire  is_sign_operation ;
wire sign_dividend, sign_divisor ;
wire [XLEN - 1:0] dividend_div ,divisor_div ;
wire [XLEN - 1:0]   quotient_temp, remainder_temp;
wire                converation_enable ; 

assign  is_sign_operation = ((operation == DIV) | (operation == REM)) ? 1'b1 : 1'b0 ;
assign  sign_dividend     =  dividend [XLEN - 1] ;
assign  sign_divisor      =  divisor [XLEN - 1]  ;
assign dividend_div       =  (is_sign_operation & sign_dividend) ? ~dividend + 1'b1 : dividend ;
assign divisor_div        =  (is_sign_operation & sign_divisor)  ? ~divisor  + 1'b1 : divisor ;
assign converation_enable =  is_sign_operation & ((sign_divisor & !sign_dividend) | (!sign_divisor & sign_dividend)) ? 1'b1 : 1'b0 ;
	




	Division_Unit #(.XLEN(XLEN),.COUNT_WIDTH(COUNT_WIDTH)) Division 
	(

	//inputs
	.CLK(CLK),
	.rst_n(rst_n),
    .dividend(dividend_div),
    .divisor(divisor_div),
    .data_valid(data_valid),

	//outputs    
	.quotient(quotient_temp),
	.remainder(remainder_temp),
	.divided_by_zero(divided_by_zero),
	.data_ready(data_ready)
);

//internal
 wire [XLEN - 1:0]   quotient, remainder;

assign remainder = (converation_enable) ? ~remainder_temp + 1'b1 : remainder_temp ;
assign quotient =  (converation_enable) ? ~quotient_temp + 1'b1 : quotient_temp ;

always @(*) begin
	 case (operation)
                DIV, DIVU: product_o =  quotient ;

                REM, REMU: product_o =  remainder; 

                default : begin
							product_o = 'b0 ;
						  end
      endcase
        
end

endmodule 

