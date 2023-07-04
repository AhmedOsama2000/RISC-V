module lzc_8
(
	input [7:0] a,
	output [2:0] c,
	output v
);

	wire [1:0] z0;
	wire [1:0] z1;

	wire v0;
	wire v1;

	wire s0;
	wire s1;
	wire s2;
	wire s3;
	wire s4;
	wire s5;
	wire s6;

	lzc_4 lzc_4_comp_0
	(
		.a (a[3:0]),
		.c (z0),
		.v (v0)
	);

	lzc_4 lzc_4_comp_1
	(
		.a ( a[7:4] ),
		.c ( z1 ),
		.v ( v1 )
	);

	assign s0 = v1 | v0;
	assign s1 = (~ v1) & z0[0];
	assign s2 = z1[0] | s1;
	assign s3 = (~ v1) & z0[1];
	assign s4 = z1[1] | s3;

	assign v = s0;
	assign c[0] = s2;
	assign c[1] = s4;
	assign c[2] = v1;

endmodule
