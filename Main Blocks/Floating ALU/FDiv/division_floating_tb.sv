module division_floating_tb ();


	parameter XLEN = 32 ;

 	//inputs
	logic     CLK;
	logic     rst_n;
   	shortreal dividend;
    shortreal divisor;
    logic     data_valid;

	//outputs    
	logic      divided_by_zero;
	logic   [XLEN-1:0]  product_o;
	logic            data_ready;


// Clock Generator // 
		
	always #1  CLK = ~ CLK;

	 division_floating DUt 
 (
 	//inputs
	.CLK(CLK),
	.rst_n(rst_n),
    .dividend(dividend),
    .divisor(divisor),
    .data_valid(data_valid),

	//outputs    
	.divided_by_zero(divided_by_zero),
	.product_o(product_o),
	.data_ready(data_ready)
);



	initial 

	begin
		//test reset
			rst_n = 1'b0 ;
			 CLK  = 1'b0;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////			    test cases of DIV Signed                    /////////////////////////////////	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
		 
		  //test  Division_signed	- / +    |dividend| > |divisor|  
		@(negedge   CLK)
			rst_n = 1'b1 ;	
			data_valid = 1'b1 ;
			dividend = 91.34375;
			divisor =  0.14453125;
			
			@(negedge  CLK)
			data_valid = 1'b0;		
			repeat(35)@(negedge  CLK) ;
			data_valid = 1'b1;
			dividend = 14.0;
			divisor =  2.0;
			
			@(negedge  CLK)
			data_valid = 1'b0;		
			repeat(35)@(negedge  CLK) ;

			data_valid = 1'b1;
			dividend = 3.0;
			divisor =  2.0;
			
			@(negedge  CLK)
			data_valid = 1'b0;		
			repeat(35)@(negedge  CLK) ;

			data_valid = 1'b1;
			dividend = 18.5;
			divisor =  2;
			
			@(negedge  CLK)
			data_valid = 1'b0;		
			repeat(35)@(negedge  CLK) ;
	
			data_valid = 1'b1;
			dividend = 22.0;
			divisor =  7.0;
			
			@(negedge  CLK)
			data_valid = 1'b0;		
			repeat(35)@(negedge  CLK) ;

	$stop;

		
	end

endmodule 