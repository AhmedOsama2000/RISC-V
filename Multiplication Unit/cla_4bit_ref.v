`timescale 1ns/1ns

module cla_4bit_ref (
    op1,op2,cin,sum,cout
);
parameter width = 4;

input  [width-1:0] op1;
input  [width-1:0] op2;
input  cin;
output [width-1:0] sum;
output cout;

wire [width-1:0] g;
wire [width-1:0] p;
wire [width:0] c;

//gp generator

pg_gen u_pg_gen_0 (.a( op1[0]),.b( op2[0]),.g( g[0]  ),.p( p[0]  ));
pg_gen u_pg_gen_1 (.a( op1[1]),.b( op2[1]),.g( g[1]  ),.p( p[1]  ));
pg_gen u_pg_gen_2 (.a( op1[2]),.b( op2[2]),.g( g[2]  ),.p( p[2]  ));
pg_gen u_pg_gen_3 (.a( op1[3]),.b( op2[3]),.g( g[3]  ),.p( p[3]  ));

//carry generator
assign c[0] = cin;
assign c[1] = g[0] + ( c[0] & p[0] );
assign c[2] = g[1] + ( (g[0] + ( c[0] & p[0]) ) & p[1] );
assign c[3] = g[2] + ( (g[1] + ( (g[0] + (c[0] & p[0]) ) & p[1])) & p[2] );
assign c[4] = g[3] + ( (g[2] + ( (g[1] + ( (g[0] + (c[0] & p[0]) ) & p[1])) & p[2] )) & p[3]);
assign cout = c[width];


//sum generator
    assign sum[0] = p[0] ^ c[0];
    assign sum[1] = p[1] ^ c[1];
    assign sum[2] = p[2] ^ c[2];
    assign sum[3] = p[3] ^ c[3];



endmodule