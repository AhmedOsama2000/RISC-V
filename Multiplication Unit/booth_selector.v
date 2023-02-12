module booth_selector(
	input	double,
	input	shifted,
	input	single,
	input	negative,
	input	y,
	output	prod
	);

	assign prod = (negative ^ ((y & single) | (shifted & double)));

endmodule