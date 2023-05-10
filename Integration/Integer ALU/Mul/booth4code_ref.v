module booth4code_ref (
    a_i,b_i,booth_o
);
    parameter length = 32;
    input      [length-1 : 0]  a_i;         //full 32-bit input
    input      [2:0]           b_i;         //3 of 32-bit input
    output reg [length   : 0]  booth_o;     //booth output

    wire [32:0] Pos, Neg, Pos2, Neg2;

    assign Pos  = {a_i[length-1],  a_i};
    assign Neg  = ~{a_i[length-1],  a_i} + 1;
    assign Pos2 = {Pos[length-1:0], 1'b0};
    assign Neg2 = {Neg[length-1:0], 1'b0};
always @(*) begin
    case(b_i)
        3'b000 : booth_o = 0;
        3'b001 : booth_o = Pos;
        3'b010 : booth_o = Pos;
        3'b011 : booth_o = Pos2;
        3'b100 : booth_o = Neg2;
        3'b101 : booth_o = Neg;
        3'b110 : booth_o = Neg;
        3'b111 : booth_o = 0;
        default: booth_o = 0;
    endcase
end



endmodule