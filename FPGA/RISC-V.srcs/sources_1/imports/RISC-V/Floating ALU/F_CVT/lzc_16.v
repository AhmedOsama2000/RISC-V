module lzc_16
(
	input [15:0] a,
	output [3:0] c,
	output v
);

	wire [2:0] z0;
	wire [2:0] z1;

	wire v0;
	wire v1;

	wire s0;
	wire s1;
	wire s2;
	wire s3;
	wire s4;
	wire s5;
	wire s6;
	wire s7;
	wire s8;

	lzc_8 lzc_8_comp_0
	(
		.a ( a[7:0] ),
		.c ( z0 ),
		.v ( v0 )
	);

	lzc_8 lzc_8_comp_1
	(
		.a ( a[15:8] ),
		.c ( z1 ),
		.v ( v1 )
	);

	assign s0 = v1 | v0;
	assign s1 = (~ v1) & z0[0];
	assign s2 = z1[0] | s1;
	assign s3 = (~ v1) & z0[1];
	assign s4 = z1[1] | s3;
	assign s5 = (~ v1) & z0[2];
	assign s6 = z1[2] | s5;

	assign v = s0;
	assign c[0] = s2;
	assign c[1] = s4;
	assign c[2] = s6;
	assign c[3] = v1;

endmodule
