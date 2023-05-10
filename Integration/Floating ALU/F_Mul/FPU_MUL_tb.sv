`timescale 1ns/1ps
module FPU_MUL_tb ();

parameter FLEN = 32 ;

reg							EN_tb ;
shortreal					A_operand_tb ;
shortreal					B_operand_tb ;
wire		[FLEN-1:0]		Data_out_tb ;


FPU_MUL DUT (
	.En(EN_tb),
	.Rs1(A_operand_tb),
	.Rs2(B_operand_tb),
	.Result(Data_out_tb)
);

initial
 begin

 	EN_tb = 1'b1;
	A_operand_tb = 12.250; 
	B_operand_tb = 3; 
	#5

	A_operand_tb = 12.250; 
	B_operand_tb = 0.25; 
	#5

	A_operand_tb = 0; 
	B_operand_tb = 0.25; 
	#5

	A_operand_tb = 15.54; 
	B_operand_tb = 0; 
	#5

	A_operand_tb = 170.54; 
	B_operand_tb = 40.55; 
	#5

	A_operand_tb = 7; 
	B_operand_tb = 3.142857; 
	#5

	A_operand_tb = 70.243; 
	B_operand_tb = 50.951; 
	#5

	A_operand_tb = -90.45; 
	B_operand_tb = -3.5; 
	#5

	A_operand_tb = -90.45; 
	B_operand_tb = 3.5; 
	#5

	A_operand_tb = 90.45; 
	B_operand_tb = -3.5; 
	#5
	$stop;

 end


endmodule