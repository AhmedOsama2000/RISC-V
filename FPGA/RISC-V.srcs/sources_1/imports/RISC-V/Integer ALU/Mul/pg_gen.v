module pg_gen(
    a,b,g,p
);
input a;
input b;
output g;
output p;

assign g = a & b;   // carry 
assign p = a ^ b;   // sum 

endmodule