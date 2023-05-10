module mul_top(
    a_i,b_i,mul_o

    );
    parameter length = 32;
    input   [length-1 : 0]  a_i,b_i;
    output  [length*2-1:0]  mul_o;
    reg [length-1 : 0] a_i_temp , b_i_temp ;


    always @(*) begin 
        if(a_i[length-1]) begin
            a_i_temp = b_i;
            b_i_temp = a_i;
        end else begin
            a_i_temp = a_i;
            b_i_temp = b_i;
        end
    end


    wire    [length   : 0]  booth_o0 ;
    wire    [length   : 0]  booth_o1 ;
    wire    [length   : 0]  booth_o2 ;
    wire    [length   : 0]  booth_o3 ;
    wire    [length   : 0]  booth_o4 ;
    wire    [length   : 0]  booth_o5 ;
    wire    [length   : 0]  booth_o6 ;
    wire    [length   : 0]  booth_o7 ;
    wire    [length   : 0]  booth_o8 ;
    wire    [length   : 0]  booth_o9 ;
    wire    [length   : 0]  booth_o10;
    wire    [length   : 0]  booth_o11;
    wire    [length   : 0]  booth_o12;
    wire    [length   : 0]  booth_o13;
    wire    [length   : 0]  booth_o14;
    wire    [length   : 0]  booth_o15;

    wire    [length*2-1: 0]  pp0 ;
    wire    [length*2-1: 0]  pp1 ;
    wire    [length*2-1: 0]  pp2 ;
    wire    [length*2-1: 0]  pp3 ;
    wire    [length*2-1: 0]  pp4 ;
    wire    [length*2-1: 0]  pp5 ;
    wire    [length*2-1: 0]  pp6 ;
    wire    [length*2-1: 0]  pp7 ;
    wire    [length*2-1: 0]  pp8 ;
    wire    [length*2-1: 0]  pp9 ;
    wire    [length*2-1: 0]  pp10;
    wire    [length*2-1: 0]  pp11;
    wire    [length*2-1: 0]  pp12;
    wire    [length*2-1: 0]  pp13;
    wire    [length*2-1: 0]  pp14;
    wire    [length*2-1: 0]  pp15;


//module booth4code_gold (a_i,b_i,booth_o);
booth4code_gold booth4_0  (a_i_temp , {b_i_temp[1:0],1'b0}   , booth_o0 );
booth4code_gold booth4_1  (a_i_temp ,  b_i_temp[3:1]         , booth_o1 );
booth4code_gold booth4_2  (a_i_temp ,  b_i_temp[5:3]         , booth_o2 );
booth4code_gold booth4_3  (a_i_temp ,  b_i_temp[7:5]         , booth_o3 );
booth4code_gold booth4_4  (a_i_temp ,  b_i_temp[9:7]         , booth_o4 );
booth4code_gold booth4_5  (a_i_temp ,  b_i_temp[11:9]        , booth_o5 );
booth4code_gold booth4_6  (a_i_temp ,  b_i_temp[13:11]       , booth_o6 );
booth4code_gold booth4_7  (a_i_temp ,  b_i_temp[15:13]       , booth_o7 );
booth4code_gold booth4_8  (a_i_temp ,  b_i_temp[17:15]       , booth_o8 );
booth4code_gold booth4_9  (a_i_temp ,  b_i_temp[19:17]       , booth_o9 );
booth4code_gold booth4_10 (a_i_temp ,  b_i_temp[21:19]       , booth_o10);
booth4code_gold booth4_11 (a_i_temp ,  b_i_temp[23:21]       , booth_o11);
booth4code_gold booth4_12 (a_i_temp ,  b_i_temp[25:23]       , booth_o12);
booth4code_gold booth4_13 (a_i_temp ,  b_i_temp[27:25]       , booth_o13);
booth4code_gold booth4_14 (a_i_temp ,  b_i_temp[29:27]       , booth_o14);
booth4code_gold booth4_15 (a_i_temp ,  b_i_temp[31:29]       , booth_o15);


assign  pp0  = {{ 31{booth_o0 [length]}} , {booth_o0   }};
assign  pp1  = {{ 29{booth_o1 [length]}} , {booth_o1  } , {  2{1'b0}}};  //<< 2  
assign  pp2  = {{ 27{booth_o2 [length]}} , {booth_o2  } , {  4{1'b0}}};  //<< 4  
assign  pp3  = {{ 25{booth_o3 [length]}} , {booth_o3  } , {  6{1'b0}}};  //<< 6  
assign  pp4  = {{ 23{booth_o4 [length]}} , {booth_o4  } , {  8{1'b0}}};  //<< 8  
assign  pp5  = {{ 21{booth_o5 [length]}} , {booth_o5  } , { 10{1'b0}}};  //<< 10 
assign  pp6  = {{ 19{booth_o6 [length]}} , {booth_o6  } , { 12{1'b0}}};  //<< 12 
assign  pp7  = {{ 17{booth_o7 [length]}} , {booth_o7  } , { 14{1'b0}}};  //<< 14 
assign  pp8  = {{ 15{booth_o8 [length]}} , {booth_o8  } , { 16{1'b0}}};  //<< 16 
assign  pp9  = {{ 13{booth_o9 [length]}} , {booth_o9  } , { 18{1'b0}}};  //<< 18 
assign  pp10 = {{ 11{booth_o10[length]}} , {booth_o10 } , { 20{1'b0}}};  //<< 20 
assign  pp11 = {{ 9{booth_o11[length]}} , {booth_o11 } , { 22{1'b0}}};  //<< 22 
assign  pp12 = {{ 7{booth_o12[length]}} , {booth_o12 } , { 24{1'b0}}};  //<< 24 
assign  pp13 = {{ 5{booth_o13[length]}} , {booth_o13 } , { 26{1'b0}}};  //<< 26 
assign  pp14 = {{  3{booth_o14[length]}} , {booth_o14 } , { 28{1'b0}}};  //<< 28 
assign  pp15 = {{  1{booth_o15[length]}} , {booth_o15 } , { 30{1'b0}}};  //<< 30 

wire cout_l1_0 ;
wire cout_l1_1 ;
wire cout_l1_2 ;
wire cout_l1_3 ;

wire [length*2 : 0] cpr_o_l1_0  ;
wire [length*2 : 0] cpr_o_l1_1  ;
wire [length*2 : 0] cpr_o_l1_2  ;
wire [length*2 : 0] cpr_o_l1_3  ;
wire [length*2 : 0] cpr_o_l1_4  ;
wire [length*2 : 0] cpr_o_l1_5  ;
wire [length*2 : 0] cpr_o_l1_6  ;
wire [length*2 : 0] cpr_o_l1_7  ;


//wallace tree
//
//first level of wallace tree: 42compressor
//module compressor42_gold (in1,in2,in3,in4,cin,out1,out2,cout);
//out1 needs to be multiplied by two (out1<<1)
//module        compressor42_gold   (in1  ,in2  ,in3  ,in4  , cin  ,out1        ,out2        ,cout      );
compressor42_gold compressor42_gold_1_0  (pp0  ,pp1  ,pp2  ,pp3  , 1'b0 ,cpr_o_l1_0  ,cpr_o_l1_1  ,cout_l1_0);
compressor42_gold compressor42_gold_1_1  (pp4  ,pp5  ,pp6  ,pp7  , 1'b0 ,cpr_o_l1_2  ,cpr_o_l1_3  ,cout_l1_1);
compressor42_gold compressor42_gold_1_2  (pp8  ,pp9  ,pp10 ,pp11 , 1'b0 ,cpr_o_l1_4  ,cpr_o_l1_5  ,cout_l1_2);
compressor42_gold compressor42_gold_1_3  (pp12 ,pp13 ,pp14 ,pp15 , 1'b0 ,cpr_o_l1_6  ,cpr_o_l1_7  ,cout_l1_3);

wire [length*2 : 0] cpr_o_l2_0 ;
wire [length*2 : 0] cpr_o_l2_1 ;
wire [length*2 : 0] cpr_o_l2_2 ;
wire [length*2 : 0] cpr_o_l2_3 ;

wire  cout_l2_0;
wire  cout_l2_1;

//second level of wallace tree: 42compressor
//module compressor42_gold (in1,in2,in3,in4,cin,out1,out2,cout);
//out1 needs to be multiplied by two (out1<<1)
//module        compressor42_gold   (in1                          ,in2                       ,in3                          ,in4                       , cin  ,out1        ,out2        ,cout      );
compressor42_gold compressor42_gold_2_0  (cpr_o_l1_0 [length*2-1:0]<<1 ,cpr_o_l1_1 [length*2-1:0] ,cpr_o_l1_2 [length*2-1:0]<<1 ,cpr_o_l1_3 [length*2-1:0] , 1'b0 ,cpr_o_l2_0  ,cpr_o_l2_1  ,cout_l2_0 );
compressor42_gold compressor42_gold_2_1  (cpr_o_l1_4 [length*2-1:0]<<1 ,cpr_o_l1_5 [length*2-1:0] ,cpr_o_l1_6 [length*2-1:0]<<1 ,cpr_o_l1_7 [length*2-1:0] , 1'b0 ,cpr_o_l2_2  ,cpr_o_l2_3  ,cout_l2_1 );

wire [length*2 : 0] cpr_o_l3_0 ;
wire [length*2 : 0] cpr_o_l3_1 ;

wire  cout_l3_0;

//third level of wallace tree: 42compressor
//module compressor42_gold (in1,in2,in3,in4,cin,out1,out2,cout);
//out1 needs to be multiplied by two (out1<<1)
//module        compressor42_gold   (in1                          ,in2                       ,in3                          ,in4                       , cin  ,out1        ,out2        ,cout      );
compressor42_gold compressor42_gold_3_0  (cpr_o_l2_0 [length*2-1:0]<<1 ,cpr_o_l2_1 [length*2-1:0] ,cpr_o_l2_2 [length*2-1:0]<<1 ,cpr_o_l2_3 [length*2-1:0] , 1'b0 ,cpr_o_l3_0  ,cpr_o_l3_1  ,cout_l3_0 );

wire cout;
//carry lookahead adder
//module cla (op1,op2,sum,cout);
cla_gold cla_0 (cpr_o_l3_0[length*2-1:0]<<1 ,cpr_o_l3_1[length*2-1:0] ,mul_o ,cout);

endmodule