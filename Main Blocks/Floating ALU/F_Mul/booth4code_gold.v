module booth4code_gold (
    a_i,b_i,booth_o
);
    parameter length = 32;
    input      [length-1 : 0]  a_i;         //full 128-bit input
    input      [2:0]           b_i;         //3 of 128 bit input
    output reg [length   : 0]  booth_o;     //booth output

always @(*) begin
    case(b_i)
        3'b000 : booth_o = 0;
        3'b001 : booth_o = { a_i[length-1], a_i};
        3'b010 : booth_o = { a_i[length-1], a_i};
        3'b011 : booth_o =   a_i<<1;
        3'b100 : booth_o = ~(a_i<<1) + 1'b1;
        3'b101 : booth_o = ~{a_i[length-1],a_i} + 1'b1 ;
        3'b110 : booth_o = ~{a_i[length-1],a_i} + 1'b1 ;
        3'b111 : booth_o = 0;
        default: booth_o = 0;
    endcase
end



endmodule