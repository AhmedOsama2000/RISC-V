module booth_encoder(
	input	[2:0] x,
	output		  single,
	output		  double,
	output		  negative
	);

	wire double_pos, double_neg;
	wire	[2:0] not_x;

	assign not_x 	  = ~x;
	assign double_pos = x[0] & x[1] & not_x[2];
	assign double_neg = not_x[0] & not_x[1] & x[2];
	assign negative   = x[2];
	assign single     = x[0] ^ x[1];
	assign double     = double_neg | double_pos;

endmodule