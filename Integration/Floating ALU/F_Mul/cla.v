module cla (
    op1,op2,sum,cout
);
parameter  width = 64; 
input  [width-1:0] op1;
input  [width-1:0] op2;
output [width-1:0] sum;
output cout;

wire [width>>2:0] c;      //
assign c[0] = 1'b0;
assign cout = c[width>>2];

cla_4bit u_cla_4bit_0  (.op1( op1[ 0*4+3: 0*4] ),.op2( op2[ 0*4+3: 0*4] ),.cin( c[0 ] ),.sum( sum[ 0*4+3: 0*4] ),.cout( c[0 +1]));
cla_4bit u_cla_4bit_1  (.op1( op1[ 1*4+3: 1*4] ),.op2( op2[ 1*4+3: 1*4] ),.cin( c[1 ] ),.sum( sum[ 1*4+3: 1*4] ),.cout( c[1 +1]));
cla_4bit u_cla_4bit_2  (.op1( op1[ 2*4+3: 2*4] ),.op2( op2[ 2*4+3: 2*4] ),.cin( c[2 ] ),.sum( sum[ 2*4+3: 2*4] ),.cout( c[2 +1]));
cla_4bit u_cla_4bit_3  (.op1( op1[ 3*4+3: 3*4] ),.op2( op2[ 3*4+3: 3*4] ),.cin( c[3 ] ),.sum( sum[ 3*4+3: 3*4] ),.cout( c[3 +1]));
cla_4bit u_cla_4bit_4  (.op1( op1[ 4*4+3: 4*4] ),.op2( op2[ 4*4+3: 4*4] ),.cin( c[4 ] ),.sum( sum[ 4*4+3: 4*4] ),.cout( c[4 +1]));
cla_4bit u_cla_4bit_5  (.op1( op1[ 5*4+3: 5*4] ),.op2( op2[ 5*4+3: 5*4] ),.cin( c[5 ] ),.sum( sum[ 5*4+3: 5*4] ),.cout( c[5 +1]));
cla_4bit u_cla_4bit_6  (.op1( op1[ 6*4+3: 6*4] ),.op2( op2[ 6*4+3: 6*4] ),.cin( c[6 ] ),.sum( sum[ 6*4+3: 6*4] ),.cout( c[6 +1]));
cla_4bit u_cla_4bit_7  (.op1( op1[ 7*4+3: 7*4] ),.op2( op2[ 7*4+3: 7*4] ),.cin( c[7 ] ),.sum( sum[ 7*4+3: 7*4] ),.cout( c[7 +1]));
cla_4bit u_cla_4bit_8  (.op1( op1[ 8*4+3: 8*4] ),.op2( op2[ 8*4+3: 8*4] ),.cin( c[8 ] ),.sum( sum[ 8*4+3: 8*4] ),.cout( c[8 +1]));
cla_4bit u_cla_4bit_9  (.op1( op1[ 9*4+3: 9*4] ),.op2( op2[ 9*4+3: 9*4] ),.cin( c[9 ] ),.sum( sum[ 9*4+3: 9*4] ),.cout( c[9 +1]));
cla_4bit u_cla_4bit_10 (.op1( op1[10*4+3:10*4] ),.op2( op2[10*4+3:10*4] ),.cin( c[10] ),.sum( sum[10*4+3:10*4] ),.cout( c[10+1]));
cla_4bit u_cla_4bit_11 (.op1( op1[11*4+3:11*4] ),.op2( op2[11*4+3:11*4] ),.cin( c[11] ),.sum( sum[11*4+3:11*4] ),.cout( c[11+1]));
cla_4bit u_cla_4bit_12 (.op1( op1[12*4+3:12*4] ),.op2( op2[12*4+3:12*4] ),.cin( c[12] ),.sum( sum[12*4+3:12*4] ),.cout( c[12+1]));
cla_4bit u_cla_4bit_13 (.op1( op1[13*4+3:13*4] ),.op2( op2[13*4+3:13*4] ),.cin( c[13] ),.sum( sum[13*4+3:13*4] ),.cout( c[13+1]));
cla_4bit u_cla_4bit_14 (.op1( op1[14*4+3:14*4] ),.op2( op2[14*4+3:14*4] ),.cin( c[14] ),.sum( sum[14*4+3:14*4] ),.cout( c[14+1]));
cla_4bit u_cla_4bit_15 (.op1( op1[15*4+3:15*4] ),.op2( op2[15*4+3:15*4] ),.cin( c[15] ),.sum( sum[15*4+3:15*4] ),.cout( c[15+1]));

endmodule