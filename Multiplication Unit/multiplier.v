module multiplier #(parameter data_width = 32, parameter group_count = 17)	( 
	input	[data_width-1 : 0]	Multiplicand,
	input	[data_width-1 : 0]	Multiplier,
	output	[2*data_width-1 :0]	Product
	);

wire 	[group_count-1 : 0]	single, double, negative;
wire	[data_width : 0]	pp2d  [group_count-1 : 0];
wire	[data_width : 0]	epp2d [group_count-1 : 0];
wire	[63:0] fpp0;
wire	[61:0] fpp1;
wire	[59:0] fpp2;
wire	[57:0] fpp3;
wire	[55:0] fpp4;
wire	[53:0] fpp5;
wire	[51:0] fpp6;
wire	[49:0] fpp7;
wire	[47:0] fpp8;
wire	[45:0] fpp9;
wire	[43:0] fpp10;
wire	[41:0] fpp11;
wire	[39:0] fpp12;
wire	[37:0] fpp13;
wire	[35:0] fpp14;
wire	[33:0] fpp15;
wire	[31:0] fpp16;

wire	[31:0] ext [31 : 0];


					//partial product generation//
	genvar i, j;	
		generate
			for(i = 0; i < group_count; i = i + 1 ) begin
				case (i)
					1'b0:	  	booth_encoder b_e0 (.x({Multiplicand[1], Multiplicand[0], 1'b0}), .single(single[i]), .double(double[i]), .negative(negative[i]));
					5'b10000:   booth_encoder b_e2 (.x({1'b0, 1'b0, Multiplicand[data_width-1]}), .single(single[i]), .double(double[i]), .negative(negative[i]));
					default: 	booth_encoder b_e1 (.x({Multiplicand[2*i + 1], Multiplicand[2*i], Multiplicand[2*i - 1]}), .single(single[i]), .double(double[i]), .negative(negative[i]));
				endcase
				for (j = 0; j < data_width; j = j + 1) begin
					case (j) 
						1'b0: begin	booth_selector b_s0 (.double(double[i]), .shifted(1'b0), .single(single[i]), .y(Multiplier[i]), .negative(negative[i]), .prod(pp2d[i][j]));
									booth_selector b_s1 (.double(double[i]), .shifted(Multiplier[j]), .single(single[i]), .y(Multiplier[i+1]), .negative(negative[i]), .prod(pp2d[i][j+1]));
							  end
						5'b11111:	booth_selector b_s0 (.double(double[i]), .shifted(Multiplier[j]), .single(single[i]), .y(1'b0), .negative(negative[i]), .prod(pp2d[i][j+1]));
						default:	booth_selector b_s0 (.double(double[i]), .shifted(Multiplier[j]), .single(single[i]), .y(Multiplier[i+1]), .negative(negative[i]), .prod(pp2d[i][j+1]));
					endcase
				end
				ripple_carry_adder #(33) rca(.a(pp2d[i]), .b({32'b0000000000000000, negative[i]}), .cin(1'b0), .sum(epp2d[i]), .cout());
			end
		endgenerate

		generate
				for (i = 0; i < group_count - 1; i = i + 1) begin
					for (j= 0; j < data_width -1; j = j + 1) 
						assign ext[i][j] = negative[i] & (double[i] | single[i]);
				end
		endgenerate
	
	assign fpp0  = {ext[0][30:0], epp2d[0]};
	assign fpp1  = {ext[1][28:0], epp2d[1]};
	assign fpp2  = {ext[2][26:0], epp2d[2]};
	assign fpp3  = {ext[3][24:0], epp2d[3]};
	assign fpp4  = {ext[4][22:0], epp2d[4]};
	assign fpp5  = {ext[5][20:0], epp2d[5]};
	assign fpp6  = {ext[6][18:0], epp2d[6]};
	assign fpp7  = {ext[7][16:0], epp2d[7]};
	assign fpp8  = {ext[8][14:0], epp2d[8]};
	assign fpp9  = {ext[9][12:0], epp2d[9]};
	assign fpp10 = {ext[10][10:0], epp2d[10]};
	assign fpp11 = {ext[11][8:0], epp2d[11]};
	assign fpp12 = {ext[12][6:0], epp2d[12]};
	assign fpp13 = {ext[13][4:0], epp2d[13]};
	assign fpp14 = {ext[14][2:0], epp2d[14]};
	assign fpp15 = {ext[15][0], epp2d[15]};
	assign fpp16 = {epp2d[16][31:0]};

											//stage 1 //
	wire    has000, hac000, has001, hac001, has010, hac010, has011, hac011, has020, hac020, 
			has021, hac021, has030, hac030, has031, hac031, has040, hac040, has041, hac041;

	wire	[59:0] fas00, fac00;
	wire	[53:0] fas01, fac01;
	wire	[47:0] fas02, fac02;
	wire	[41:0] fas03, fac03;
	wire	[35:0] fas04, fac04;
	wire	[31:0] has05, hac05;

	wire	[63:0] st000;
	wire	[60:0] st001;
	wire	[57:0] st002;
	wire	[54:0] st003;
	wire	[51:0] st004;
	wire	[48:0] st005;
	wire	[45:0] st006;
	wire	[42:0] st007;
	wire	[39:0] st008;
	wire	[36:0] st009;
	wire	[33:0] st010;
	wire	[31:0] st011;

	half_adder ha0sc00 (.a(fpp0[2]), .b(fpp1[0]) , .sum(has000), .cout(hac000));
	half_adder ha0sc01 (.a(fpp0[3]), .b(fpp1[1]) , .sum(has001), .cout(hac001));
	generate
		for (i = 0; i < 60; i = i + 1) begin
			full_adder fa001 (.a(fpp0[i + 4]), .b(fpp1[i + 2]), .cin(fpp2[i]), .sum(fas00[i]), .cout(fac00[i]));
		end
	endgenerate

	half_adder ha0sc10 (.a(fpp3[2]), .b(fpp4[0]) , .sum(has010), .cout(hac010));
	half_adder ha0sc11 (.a(fpp3[3]), .b(fpp4[1]) , .sum(has011), .cout(hac011));
	generate
		for (i = 0; i < 54; i = i + 1) begin	
			full_adder fa002 (.a(fpp3[i + 4]), .b(fpp5[i + 2]), .cin(fpp6[i]), .sum(fas01[i]), .cout(fac01[i]));
		end
	endgenerate

	half_adder ha0sc20 (.a(fpp6[2]), .b(fpp7[0]) , .sum(has020), .cout(hac020));
	half_adder ha0sc21 (.a(fpp6[3]), .b(fpp7[1]) , .sum(has021), .cout(hac021));
	generate
		for (i = 0; i < 48; i = i + 1) begin
			full_adder fa003 (.a(fpp6[i + 4]), .b(fpp7[i + 2]), .cin(fpp8[i]), .sum(fas02[i]), .cout(fac02[i]));
		end
	endgenerate

	half_adder ha0sc30 (.a(fpp9[2]), .b(fpp9[0]) , .sum(has030), .cout(hac030));
	half_adder ha0sc31 (.a(fpp9[3]), .b(fpp9[1]) , .sum(has031), .cout(hac031));
	generate
		for (i = 0; i < 42; i = i + 1) begin
			full_adder fa004 (.a(fpp9[i + 4]), .b(fpp10[i + 2]), .cin(fpp11[i]), .sum(fas03[i]), .cout(fac03[i]));
		end
	endgenerate

	half_adder ha0sc40 (.a(fpp12[2]), .b(fpp13[0]) , .sum(has040), .cout(hac040));
	half_adder ha0sc41 (.a(fpp12[3]), .b(fpp13[1]) , .sum(has041), .cout(hac041));
	generate
		for (i = 0; i < 36; i = i + 1) begin
			full_adder fa005 (.a(fpp12[i + 4]), .b(fpp13[i + 2]), .cin(fpp14[i]), .sum(fas04[i]), .cout(fac04[i]));
		end
	endgenerate

	generate
		for (i = 0; i < 32; i = i + 1) begin
			half_adder ha006 (.a(fpp15[i+2]), .b(fpp16[i]) , .sum(has05[i]), .cout(hac05[i]));
		end
	endgenerate

	assign st000 = {fas00, has001, has000, fpp0[1], fpp0[0]} ;
	assign st001 = {fac00[58:0], hac001, hac000} ;
	assign st002 = {fas01, has011, has010, fpp3[1], fpp3[0]} ;
	assign st003 = {fac01[52:0], hac011, hac010} ;
	assign st004 = {fas02, has021, has020, fpp6[1], fpp6[0]} ;
	assign st005 = {fac02[46:0], hac021, hac020} ;
	assign st006 = {fas03, has031, has030, fpp9[1], fpp9[0]} ;
	assign st007 = {fac03[40:0], hac031, hac030} ;
	assign st008 = {fas04, has041, has040, fpp12[1], fpp12[0]} ;
	assign st009 = {fac04[34:0], hac041, hac040} ;
	assign st010 = {has05, fpp15[1], fpp15[0]} ;
	assign st011 = hac05 ;

									//stage2//
	wire    has100, hac100, has101, hac101, has102, hac102, has110, hac110, has111, hac111, has112, hac112, 
			has120, hac120, has121, hac121, has122, hac122, has130, hac130, has131, hac131;

	wire	[57:0] fas10, fac10;
	wire	[48:0] fas11, fac11;
	wire	[39:0] fas12, fac12;
	wire	[31:0] fas13, fac13;
	
	wire	[63:0] st100;
	wire	[59:0] st101;
	wire	[54:0] st102;
	wire	[50:0] st103;
	wire	[45:0] st104;
	wire	[41:0] st105;
	wire	[35:0] st106;
	wire	[33:0] st107;
	
	half_adder ha1sc00 (.a(st000[3]), .b(st001[0]) , .sum(has100), .cout(hac100));
	half_adder ha1sc01 (.a(st000[4]), .b(st001[1]) , .sum(has101), .cout(hac101));
	half_adder ha1sc02 (.a(st000[5]), .b(st001[2]) , .sum(has102), .cout(hac102));
	generate
		for (i = 0; i < 58; i = i + 1) begin
			full_adder fa101 (.a(st000[i + 6]), .b(st001[i + 3]), .cin(st002[i]), .sum(fas10[i]), .cout(fac10[i]));
		end
	endgenerate

	half_adder ha1sc10 (.a(st003[3]), .b(st004[0]) , .sum(has110), .cout(hac110));
	half_adder ha1sc11 (.a(st003[4]), .b(st004[1]) , .sum(has111), .cout(hac111));
	half_adder ha1sc12 (.a(st003[5]), .b(st004[2]) , .sum(has112), .cout(hac112));
	generate
		for (i = 0; i < 49; i = i + 1) begin	
			full_adder fa102 (.a(st003[i + 6]), .b(st004[i + 3]), .cin(st005[i]), .sum(fas11[i]), .cout(fac11[i]));
		end
	endgenerate

	half_adder ha1sc20 (.a(st006[3]), .b(st007[0]) , .sum(has120), .cout(hac120));
	half_adder ha1sc21 (.a(st006[4]), .b(st007[1]) , .sum(has121), .cout(hac121));
	half_adder ha1sc22 (.a(st006[5]), .b(st007[2]) , .sum(has122), .cout(hac122));
	generate
		for (i = 0; i < 40; i = i + 1) begin
			full_adder fa103 (.a(st006[i + 6]), .b(st007[i + 3]), .cin(st008[i]), .sum(fas12[i]), .cout(fac12[i]));
		end
	endgenerate

	half_adder ha1sc30 (.a(st009[3]), .b(st010[0]) , .sum(has130), .cout(hac130));
	half_adder ha1sc31 (.a(st009[4]), .b(st010[1]) , .sum(has131), .cout(hac131));
		generate
		for (i = 0; i < 32; i = i + 1) begin
			full_adder fa104 (.a(st009[i + 5]), .b(st010[i + 2]), .cin(st011[i]), .sum(fas13[i]), .cout(fac13[i]));
		end
	endgenerate


	assign st100 = {fas10, has102, has101, has100, st000[2], st000[1], st000[0]} ;
	assign st101 = {fac10[56:0], hac102, hac101, hac100} ;
	assign st102 = {fas11, has112, has111, has110, st003[2], st003[1], st003[0]} ;
	assign st103 = {fac11[47:0], hac112, hac111, hac110} ;
	assign st104 = {fas12, has122, has121, has120, st006[2], st006[1], st006[0]} ;
	assign st105 = {fac12[38:0], hac122, hac121, hac120} ;
	assign st106 = {fas13, has131, has120, st006[2], st006[1], st006[0]} ;
	assign st107 = {fac13[31:0], hac131, hac130} ;
	

								//stage3//
	wire    has200, hac200, has201, hac201, has202, hac202, has203, hac203, has204,
			hac204, has210, hac210, has211, hac211, has212, hac212, has213, hac213;

	wire	[54:0] fas20, fac20;
	wire	[41:0] fas21, fac21;
	wire	[33:0] has22, hac22;
	
	wire	[63:0] st200;
	wire	[58:0] st201;		
	wire	[50:0] st202;
	wire	[44:0] st203;
	wire	[35:0] st204;
	wire	[33:0] st205;
	
	half_adder ha2sc00 (.a(st100[4]), .b(st101[0]) , .sum(has200), .cout(hac200));
	half_adder ha2sc01 (.a(st100[5]), .b(st101[1]) , .sum(has201), .cout(hac201));
	half_adder ha2sc02 (.a(st100[6]), .b(st101[2]) , .sum(has202), .cout(hac202));
	half_adder ha2sc03 (.a(st100[7]), .b(st101[3]) , .sum(has203), .cout(hac203));
	half_adder ha2sc04 (.a(st100[8]), .b(st101[4]) , .sum(has204), .cout(hac204));
	generate
		for (i = 0; i < 55; i = i + 1) begin
			full_adder fa201 (.a(st100[i + 9]), .b(st101[i + 4]), .cin(st102[i]), .sum(fas20[i]), .cout(fac20[i]));
		end
	endgenerate

	half_adder ha2sc10 (.a(st103[5]), .b(st104[0]) , .sum(has210), .cout(hac210));
	half_adder ha2sc11 (.a(st103[6]), .b(st104[1]) , .sum(has211), .cout(hac211));
	half_adder ha2sc12 (.a(st103[7]), .b(st104[2]) , .sum(has212), .cout(hac212));
	half_adder ha2sc13 (.a(st103[8]), .b(st104[3]) , .sum(has213), .cout(hac213));
	generate
		for (i = 0; i < 43; i = i + 1) begin	
			full_adder fa202 (.a(st103[i + 9]), .b(st104[i + 4]), .cin(st105[i]), .sum(fas21[i]), .cout(fac21[i]));
		end
	endgenerate

	generate
		for (i = 0; i < 34; i = i + 1) begin
			half_adder ha203 (.a(st106[i+3]), .b(st107[i]) , .sum(has22[i]), .cout(hac22[i]));
		end
	endgenerate


	assign st200 = {fas20, has204, has203, has202, has201, has200, st100[3:0]} ;
	assign st201 = {fac20[53:0], hac204, hac203, hac202, hac201, hac200} ;
	assign st202 = {fas21, has213, has212, has211, has210, st103[4:0]} ;
	assign st203 = {fac21[40:0], hac213, hac212, hac211, hac210} ;
	assign st204 = {has22, st106[2], st106[1], st106[0]} ;
	assign st205 = hac22 ;
	


								//stage4//
	wire    has310, hac310, has311, hac311;

	wire	[50:0] fas30, fac30;
	wire	[7:0]  has30, hac30;
	wire	[33:0] fas32, fac32;
	
	wire	[63:0] st300;
	wire	[57:0] st301;		
	wire	[44:0] st302;
	wire	[34:0] st303;
		
	generate
		for (i = 0; i < 8; i = i + 1) begin
			half_adder ha301 (.a(st200[i+5]), .b(st201[i]) , .sum(has30[i]), .cout(hac30[i]));
		end
	endgenerate
	generate
		for (i = 0; i < 50; i = i + 1) begin
			full_adder fa301 (.a(st200[i + 13]), .b(st201[i + 8]), .cin(st202[i]), .sum(fas30[i]), .cout(fac30[i]));
		end
	endgenerate

	half_adder ha3sc10 (.a(st203[9]),  .b(st204[0]) , .sum(has310), .cout(hac310));
	half_adder ha3sc11 (.a(st203[10]), .b(st204[1]) , .sum(has311), .cout(hac311));
	generate
		for (i = 0; i < 34; i = i + 1) begin	
			full_adder fa302 (.a(st203[i + 11]), .b(st204[i + 2]), .cin(st205[i]), .sum(fas32[i]), .cout(fac32[i]));
		end
	endgenerate


	assign st300 = {fas30, has30, st200[4:0]} ;
	assign st301 = {fac30[49:0], hac30} ;
	assign st302 = {fas32, has311, has310, st203[8:0]} ;
	assign st303 = {fac32[32:0], hac311, hac310} ;
	



								//stage5//
	wire	[44:0] fas40, fac40;
	wire	[12:0] has40, hac40;
		
	wire	[63:0] st400;
	wire	[56:0] st401;		
	wire	[34:0] st402;
			
	generate
		for (i = 0; i < 13; i = i + 1) begin
			half_adder ha401 (.a(st300[i+6]), .b(st301[i]) , .sum(has40[i]), .cout(hac40[i]));
		end
	endgenerate
	generate
		for (i = 0; i < 45; i = i + 1) begin
			full_adder fa401 (.a(st300[i + 19]), .b(st301[i + 13]), .cin(st302[i]), .sum(fas40[i]), .cout(fac40[i]));
		end
	endgenerate

	assign st400 = {fas40, has40, st300[5:0]} ;
	assign st401 = {fac40[43:0], hac40} ;
	assign st402 = st303 ;
	
	
								//stage6//
	wire	[34:0] fas50, fac50;
	wire	[21:0] has50, hac50;
		
	wire	[63:0] st500;
	wire	[55:0] st501;		
				
	generate
		for (i = 0; i < 22; i = i + 1) begin
			half_adder ha501 (.a(st400[i+7]), .b(st401[i]) , .sum(has50[i]), .cout(hac50[i]));
		end
	endgenerate
	generate
		for (i = 0; i < 35; i = i + 1) begin
			full_adder fa501 (.a(st400[i + 28]), .b(st401[i + 22]), .cin(st402[i]), .sum(fas50[i]), .cout(fac50[i]));
		end
	endgenerate

	assign st500 = {fas50, has50, st400[6:0]} ;
	assign st501 = {fac40[33:0], hac40} ;
	
	


								//stage7//
	wire	[55:0] fas60, fac60;
			
	wire	[63:0] st600;
					
	full_adder fa700(.a(st500[8]), .b(st501[0]), .cin(1'b0), .sum(fas60[0]), .cout(fac60[0]));
	generate
		for (i = 0; i < 55; i = i + 1) begin
			full_adder fa601 (.a(st500[i + 9]), .b(st501[i + 1]), .cin(fac60[i]), .sum(fas60[i+1]), .cout(fac60[i+1]));
		end
	endgenerate

	assign st600 = {fas60, st500[7:0]} ;
	assign Product = st600 ;
	



endmodule