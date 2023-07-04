(* keep_hierarchy = "yes" *) module Multiblacation_Unit #( parameter XLEN = 32)
(
    input   [XLEN-1 : 0]    Multiplacant_i,
    input   [XLEN-1 : 0]    Multiplier_i,
    input                   En,
    input   [1:0]           operation_i,
    output reg  [XLEN-1:0]  product_o
);


    localparam MUL     = 2'b00 ;      // it doesn’t matter whether rs1 and rs2 are signed or unsigned because the result is the same.
    localparam MULH    = 2'b01 ;     // multiplies 2 signed operands rs1 and rs2 and stores the upper 32 bits in rd.
    localparam MULHSU  = 2'b10 ;    // multiplies 2 unsigned operands rs1 and rs2 and stores the upper 32 bits in rd.
   
   /* parameter MULHU   = 2'b11 ;   // multiplies signed operand rs1 and unsigned r operands2 and stores the upper 32 bits in rd.*/

    //////////// Note //////////////
/*
    For RISC-V, if you want to get the 64-bit result of a 32x32 bit multiplication, 
    you need to use 2 instructions: MUL, and one of the MULH variants.

    referance : https://tomverbeure.github.io/rtl/2018/08/12/Multipliers.html
*/
    ///////////////////////////////

wire  is_unsign_operation ;
wire sign_Multiplacant, sign_Multiplier ;
wire [XLEN - 1:0] Multiplacant_mul ,Multiplier_mul ;
wire [XLEN*2 - 1:0]   mul_o_temp ; 
wire converation_enable ; 

assign  is_unsign_operation =  (operation_i == MULHSU) ? 1'b1 : 1'b0 ;
assign  sign_Multiplier     =  Multiplier_i [XLEN - 1] ;
assign  sign_Multiplacant   =  Multiplacant_i [XLEN - 1]  ;
assign Multiplier_mul       =  (is_unsign_operation & sign_Multiplier) ? ~Multiplier_i + 1'b1 : Multiplier_i ;
assign Multiplacant_mul     =  (is_unsign_operation & sign_Multiplacant)? ~Multiplacant_i  + 1'b1 : Multiplacant_i ;
assign converation_enable   =  is_unsign_operation & ((sign_Multiplacant & !sign_Multiplier) | (!sign_Multiplacant & sign_Multiplier) | (sign_Multiplacant & sign_Multiplier)) ? 1'b1 : 1'b0 ;



 mul_top #(.XLEN(XLEN)) mul_unit (
    .a_i(Multiplacant_mul),
    .b_i(Multiplier_mul),
    .En(En),
    .mul_o(mul_o_temp)
    );
   


//internal
 wire [XLEN*2 - 1:0]   mul_o;

assign mul_o = (converation_enable) ? ~mul_o_temp + 1'b1 : mul_o_temp ;


always @(*) begin
     case (operation_i)
                MUL:         product_o =  mul_o[XLEN-1:0] ;

                MULH, MULHSU: product_o =  mul_o[XLEN*2 -1:XLEN]; 

                default : begin
                            product_o = 'b0 ;
                          end
      endcase
        
end

endmodule 






















