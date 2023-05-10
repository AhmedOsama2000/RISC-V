module lzc_4
(
	input [3:0] a,
	output [1:0] c,
	output v
);
	wire a0;
	wire a1;
	wire a2;
	wire a3;

	wire s0;
	wire s1;
	wire s2;
	wire s3;
	wire s4;

	assign a0 = a[0];
	assign a1 = a[1];
	assign a2 = a[2];
	assign a3 = a[3];

	assign s0 = a3 | a2;
	assign s1 = a1 | a0;
	assign s2 = s1 | s0;
	assign s3 = (~ s0) & a1;
	assign s4 = a3 | s3;

	assign v = s2;
	assign c[0] = s4;
	assign c[1] = s0;

endmodule
