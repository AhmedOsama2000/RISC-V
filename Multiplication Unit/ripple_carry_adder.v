module ripple_carry_adder #(parameter width = 4) (
	input	[width-1 : 0]	a, 
	input	[width-1 : 0]	b,
	input					cin,
	output	[width-1 : 0]	sum,
	output					cout
	);

	wire [width-1 : 0] c;
	genvar  i;

	generate
		for (i=0; i < width; i = i + 1) begin
			case (i)
				1'b0: full_adder fa (.a(a[i]), .b(b[i]), .cin(cin), .sum(sum[i]), .cout(c[i]));
				default: full_adder fa (.a(a[i]), .b(b[i]), .cin(c[i-1]), .sum(sum[i]), .cout(c[i]));
			endcase
		end		 
	endgenerate

assign cout = c[width-1];

endmodule