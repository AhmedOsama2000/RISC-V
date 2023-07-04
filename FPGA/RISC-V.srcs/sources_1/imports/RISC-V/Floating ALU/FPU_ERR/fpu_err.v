(* DONT_TOUCH = "TRUE" *) module fpu_err #(
	parameter EXP 	   = 8,
	parameter MANTISAA = 23,
	parameter FLEN     = 32 
)
(
	input  wire [FLEN-1:0] Result,
	output reg             NaN,
	output reg             pinf, // positive inf
	output reg             ninf  // negative inf
);

wire                sign;
wire [EXP-1:0] 	    exp;
wire [MANTISAA-1:0] mantissa;

assign {sign,exp,mantissa} = Result;

always @(*) begin
	NaN  = 1'b0;
	pinf = 1'b0;
	ninf = 1'b0;
	if (exp == 8'hFF && |mantissa) begin	
		NaN  = 1'b1;
	end
	else if (sign && exp == 8'hFF) begin
		ninf = 1'b1;
	end
	else if (!sign && exp == 8'hFF) begin
		pinf = 1'b1;
	end
	else begin
		NaN  = 1'b0;
		pinf = 1'b0;
		ninf = 1'b0;
	end
end

endmodule