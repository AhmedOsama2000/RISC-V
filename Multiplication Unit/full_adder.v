module full_adder(
	input	a,
	input	b,
	input	cin,
	output	sum,
	output	cout
	);
	
	wire sum1, cout1, cout2;

	half_adder h1(.a(a), .b(b), .sum(sum1), .cout(cout1));
	half_adder h2(.a(sum1), .b(cin), .sum(sum),  .cout(cout2));

	assign cout = cout1|cout2;

endmodule