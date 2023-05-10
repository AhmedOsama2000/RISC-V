module mul_top_ref #(parameter XLEN = 32)(
    input  wire [XLEN-1 : 0]  Multiplier,
    input  wire [XLEN-1 : 0]  Multiplicand,
    input  wire [1 : 0]       Funct_1_0,
    input  wire               En,
    output reg  [XLEN-1 : 0]  Result
);
    
    // reg  [XLEN-1 : 0]   Result;             // combinational result generated (32bit output needed)
    wire [2*XLEN-1 : 0] Product;            // 64bit full product
    wire [2*XLEN-1 : 0] Product_Complement; // full product complementted

    assign Product_Complement = ~Product +1;

    parameter [1:0] MUL    = 2'b00;    //Does not matter signed or unsigned, stores the lower 32 bits
    parameter [1:0] MULH   = 2'b01;    //2 signed operands and stores the upper 32 bits 
    parameter [1:0] MULHSU = 2'b10;    //2 unsigned operands and stores the upper 32 bits 
    parameter [1:0] MULHU  = 2'b11;    // Mulr signed & Muld unsigned and stores the upper 32 bits 
    
    wire    [1:0] signed_unsigned;
    assign signed_unsigned = {Multiplier[XLEN-1], Multiplicand[XLEN-1]}; // flag for complementing inputs and outputs
    
    reg    [XLEN-1 : 0]    Mulr, Muld;
    
    // Logic for complementing inputs or outputs for every instrucion//
    always @(*) begin
        if (En) begin
            case(Funct_1_0) 
                MUL: begin
                    if (signed_unsigned[1]&signed_unsigned[0]) begin
                        assign Mulr = ~Multiplier   + 1;
                        assign Muld = ~Multiplicand + 1;
                    end
                    else begin
                        assign Mulr = Multiplier;
                        assign Muld = Multiplicand;
                    end
                    assign Result = Product[XLEN/2-1:0];
                end
                MULH: begin
                    if (signed_unsigned[0]) begin
                       assign Mulr = Multiplier;
                       assign Muld = ~Multiplicand + 1; 
                    end
                    else begin
                        assign Mulr = Multiplier;
                        assign Muld = Multiplicand;
                    end
                    assign Result = Product[XLEN-1:XLEN/2];
                end
                MULHU: begin
                    if (signed_unsigned[1]) begin
                        assign Mulr = ~Multiplier   + 1;
                        assign Muld = Multiplicand;
                        assign Result = Product_Complement[XLEN-1:XLEN/2];
                    end
                    else begin
                        assign Mulr = Multiplier;
                        assign Muld = Multiplicand;
                        assign Result = Product[XLEN-1:XLEN/2];
                    end
                end
                MULHSU: begin
                    case (signed_unsigned) 
                        2'b11: begin
                            assign Mulr = ~Multiplier   + 1;
                            assign Muld = ~Multiplicand + 1;     
                            assign Result = Product_Complement[XLEN-1:XLEN/2];
                        end
                        2'b10: begin
                            assign Mulr = ~Multiplier   + 1;
                            assign Result = Product[XLEN-1:XLEN/2]; 
                        end
                        default: begin
                        assign Mulr = Multiplier;
                        assign Muld = Multiplicand;
                        assign Result = Product[XLEN-1:XLEN/2];
                    end
                    endcase
                end
                default: begin
                    assign Mulr = Multiplier;
                    assign Muld = Multiplicand;
                    assign Result = Product[XLEN/2-1:0];
                end
            endcase
        end
        else begin
            Result = 'b0;
        end
    end

    //17 partial product generation //
    wire    [XLEN : 0] PP [XLEN/2 : 0];
    
    genvar i;
                //module booth4code_ref (Mulr,Multiplicand,booth_o);
                booth4code_ref booth_0   (Mulr , {Muld[1:0],1'b0}   , PP[0] );
                booth4code_ref booth_16  (Mulr , {1'b0, 1'b0, Muld[XLEN-1]}   , PP[16] );
        generate
            for (i = 1; i < XLEN/2; i = i +1) begin
                booth4code_ref booth_0  (Mulr , Muld[(2*i+1):(2*i-1)]   , PP[i]);
            end
        endgenerate

    wire [XLEN*2-1 : 0] ePP [XLEN/2 : 0];
    
    // partial products extension // 
assign  ePP[0]  = {{ 31{PP[0] [XLEN]}} , {PP[0]   }};
assign  ePP[1]  = {{ 29{PP[1] [XLEN]}} , {PP[1]  } , {  2{1'b0}}};  //<< 2  
assign  ePP[2]  = {{ 27{PP[2] [XLEN]}} , {PP[2]  } , {  4{1'b0}}};  //<< 4  
assign  ePP[3]  = {{ 25{PP[3] [XLEN]}} , {PP[3]  } , {  6{1'b0}}};  //<< 6  
assign  ePP[4]  = {{ 23{PP[4] [XLEN]}} , {PP[4]  } , {  8{1'b0}}};  //<< 8  
assign  ePP[5]  = {{ 21{PP[5] [XLEN]}} , {PP[5]  } , { 10{1'b0}}};  //<< 10 
assign  ePP[6]  = {{ 19{PP[6] [XLEN]}} , {PP[6]  } , { 12{1'b0}}};  //<< 12 
assign  ePP[7]  = {{ 17{PP[7] [XLEN]}} , {PP[7]  } , { 14{1'b0}}};  //<< 14 
assign  ePP[8]  = {{ 15{PP[8] [XLEN]}} , {PP[8]  } , { 16{1'b0}}};  //<< 16 
assign  ePP[9]  = {{ 13{PP[9] [XLEN]}} , {PP[9]  } , { 18{1'b0}}};  //<< 18 
assign  ePP[10] = {{ 11{PP[10][XLEN]}} , {PP[10] } , { 20{1'b0}}};  //<< 20 
assign  ePP[11] = {{ 9{PP[11][XLEN]}}  , {PP[11] } , { 22{1'b0}}};  //<< 22 
assign  ePP[12] = {{ 7{PP[12][XLEN]}}  , {PP[12] } , { 24{1'b0}}};  //<< 24 
assign  ePP[13] = {{ 5{PP[13][XLEN]}}  , {PP[13] } , { 26{1'b0}}};  //<< 26 
assign  ePP[14] = {{  3{PP[14][XLEN]}} , {PP[14] } , { 28{1'b0}}};  //<< 28 
assign  ePP[15] = {{  1{PP[15][XLEN]}} , {PP[15] } , { 30{1'b0}}};  //<< 30 
assign  ePP[16] = {{ PP[16][XLEN-1:0]  , {32{1'b0}}}};  //<< 32 


wire [3 : 0] Cout1;
wire [XLEN*2 : 0] cpr_o_1 [7 : 0];
//wallace tree
//
//first level of wallace tree: 42compressor
//module compressor42_ref (in1,in2,in3,in4,cin,out1,out2,cout);
//out1 needs to be multiplied by two (out1<<1)
//module        compressor42_ref   (in1  ,in2  ,in3  ,in4  , cin  ,out1        ,out2        ,cout      );
compressor42_ref compressor42_ref_1_0  (ePP[0]  ,ePP[1]  ,ePP[2]  ,ePP[3]  , 1'b0 ,cpr_o_1[0]  ,cpr_o_1[1]  ,Cout1[0]);
compressor42_ref compressor42_ref_1_1  (ePP[4]  ,ePP[5]  ,ePP[6]  ,ePP[7]  , 1'b0 ,cpr_o_1[2]  ,cpr_o_1[3]  ,Cout1[1]);
compressor42_ref compressor42_ref_1_2  (ePP[8]  ,ePP[9]  ,ePP[10] ,ePP[11] , 1'b0 ,cpr_o_1[4]  ,cpr_o_1[5]  ,Cout1[2]);
compressor42_ref compressor42_ref_1_3  (ePP[12] ,ePP[13] ,ePP[14] ,ePP[15] , 1'b0 ,cpr_o_1[6]  ,cpr_o_1[7]  ,Cout1[3]);



wire [1 : 0] Cout2;
wire [XLEN*2 : 0] cpr_o_2 [3 : 0];
//second level of wallace tree: 42compressor
//module compressor42_ref (in1,in2,in3,in4,cin,out1,out2,cout);
//out1 needs to be multiplied by two (out1<<1)
    //module        compressor42_ref   (in1                                     ,in2            ,in3                          ,in4       , cin  ,out1        ,out2        ,cout  );
compressor42_ref compressor42_ref_2_0  ({cpr_o_1[0][XLEN*2-2 : 0], 1'b0}  ,cpr_o_1[1][XLEN*2-1:0]  ,{cpr_o_1[2][XLEN*2-2 : 0], 1'b0}  ,cpr_o_1[3][XLEN*2-1:0]  , 1'b0 ,cpr_o_2[0]  ,cpr_o_2[1]  ,Cout2[0]);
compressor42_ref compressor42_ref_2_1  ({cpr_o_1[4][XLEN*2-2 : 0], 1'b0}  ,cpr_o_1[5][XLEN*2-1:0]  ,{cpr_o_1[6][XLEN*2-2 : 0], 1'b0}  ,cpr_o_1[7][XLEN*2-1:0]  , 1'b0 ,cpr_o_2[2]  ,cpr_o_2[3]  ,Cout2[1]);


wire  Cout3;
wire [XLEN*2 : 0] cpr_o_3 [1 : 0];
//third level of wallace tree: 42compressor
//module compressor42_ref (in1,in2,in3,in4,cin,out1,out2,cout);
//out1 needs to be multiplied by two (out1<<1)
  //module        compressor42_ref   (in1                                     ,in2            ,in3                          ,in4       , cin  ,out1        ,out2        ,cout  );
compressor42_ref compressor42_ref_3_0  ({cpr_o_2[0][XLEN*2-2 : 0], 1'b0}  ,cpr_o_2[1][XLEN*2-1:0]  ,{cpr_o_2[2][XLEN*2-2 : 0], 1'b0}  ,cpr_o_2[3][XLEN*2-1:0]  , 1'b0 ,cpr_o_3[0]  ,cpr_o_3[1]  ,Cout3);


wire  Cout4;
wire [XLEN*2 : 0] cpr_o_4 [1 : 0];
//fourth level of wallace tree: 42compressor
//module compressor42_ref (in1,in2,in3,in4,cin,out1,out2,cout);
//out1 needs to be multiplied by two (out1<<1)
    //module        compressor42_ref   (in1                                     ,in2     ,in3       ,in4    , cin  ,out1        ,out2        ,cout  );
compressor42_ref compressor42_ref_4_0  ({cpr_o_3[0][XLEN*2-2 : 0], 1'b0}  ,cpr_o_3[1][XLEN*2-1:0]  ,ePP[16]   ,{64'b0}  , 1'b0 ,cpr_o_4[0]  ,cpr_o_4[1]  ,Cout4);

wire cout;
//carry lookahead adder
//module cla (op1,op2,sum,cout);
cla_ref cla_0 ({cpr_o_4[0][XLEN*2-2 : 0], 1'b0} ,cpr_o_4[1][XLEN*2-1:0] ,Product ,cout);

endmodule