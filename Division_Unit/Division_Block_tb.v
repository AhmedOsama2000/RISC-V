module Division_BLOCK_tb () ;

parameter XLEN_tb 		  = 32 ;
parameter COUNT_WIDTH_tb = $clog2(XLEN_tb) ;
localparam DIV   = 2'b00;
localparam DIVU  = 2'b01;
localparam REM   = 2'b10;
localparam REMU  = 2'b11;

	//inputs
	reg              CLK_tb ;
	reg               rst_n_tb ;
    reg [XLEN_tb - 1:0]  dividend_tb ;
    reg [XLEN_tb - 1:0]  divisor_tb ;
    reg               data_valid_tb ;
    reg [1:0]         operation_tb ; 

	//outputs    
	
	wire  [XLEN_tb - 1:0]  product_o_tb ;
	wire              data_ready_tb ;

	// Clock Generator // 
		
	always #1 CLK_tb = ~CLK_tb;


 //initial block
initial 

	begin
		//test reset
			rst_n_tb = 1'b0 ;
			CLK_tb   = 1'b0;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////			    test cases of DIV Signed                    /////////////////////////////////	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
		 
		  //test  Division_signed	- / +    |dividend| > |divisor|  
		@(negedge CLK_tb)
			rst_n_tb = 1'b1 ;	
			data_valid_tb = 1'b1 ;
			dividend_tb = -'d7;
			divisor_tb = 'd3;
			operation_tb = DIV ;
			@(negedge CLK_tb)
			data_valid_tb = 1'b0 ;		
			
			//test nochange the data 
		repeat(35) @(negedge CLK_tb) ;
			dividend_tb = 'd14;
			divisor_tb = 'd2;
		
		    //test  Division_signed	+ / +	|dividend| > |divisor|   
	    repeat(35)@(negedge CLK_tb) ;
			data_valid_tb = 1'b1 ;
			dividend_tb = 'd3;
			divisor_tb = 'd2;
			operation_tb = DIV ;
			@(negedge CLK_tb)
			data_valid_tb = 1'b0 ;

			//test  Division_signed	+ / -	|dividend| > |divisor|   
	    repeat(35)@(negedge CLK_tb) ;
			data_valid_tb = 1'b1 ;
			dividend_tb = 'd149;
			divisor_tb = -'d2;
			operation_tb = DIV ;
			@(negedge CLK_tb)
			data_valid_tb = 1'b0 ;	

			//test  Division_signed	- / -	|dividend| > |divisor|   
	    repeat(35)@(negedge CLK_tb) ;
			data_valid_tb = 1'b1 ;
			dividend_tb = -'d149;
			divisor_tb = -'d5;
			operation_tb = DIV ;
			@(negedge CLK_tb)
			data_valid_tb = 1'b0 ;

			//test  Division_signed	+ / +	|dividend| < |divisor|   
	    repeat(35)@(negedge CLK_tb) ;
			data_valid_tb = 1'b1 ;
			dividend_tb = 'd5;
			divisor_tb = 'd14;
			operation_tb = DIV ;
			@(negedge CLK_tb)
			data_valid_tb = 1'b0 ;

			//test  Division_signed	- / +	|dividend| < |divisor|   
	    repeat(35)@(negedge CLK_tb) ;
			data_valid_tb = 1'b1 ;
			dividend_tb = -'d5;
			divisor_tb = 'd32;
			operation_tb = DIV ;
			@(negedge CLK_tb)
			data_valid_tb = 1'b0 ;

			//test  Division_signed	+ / -	|dividend| < |divisor|   
	    repeat(35)@(negedge CLK_tb) ;
			data_valid_tb = 1'b1 ;
			dividend_tb = 'd3;
			divisor_tb = -'d5;
			operation_tb = DIV ;
			@(negedge CLK_tb)
			data_valid_tb = 1'b0 ;

			//test  Division_signed	- / -	|dividend| < |divisor|   
	    repeat(35)@(negedge CLK_tb) ;
			data_valid_tb = 1'b1 ;
			dividend_tb = -'d2;
			divisor_tb = -'d5;
			operation_tb = DIV ;
			@(negedge CLK_tb)
			data_valid_tb = 1'b0 ;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////			    test cases of DIVU UNSigned                    ///////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		//test  Division_unsigned	+ / +	|dividend| > |divisor|  	
		repeat(35)@(negedge CLK_tb) ;
			data_valid_tb = 1'b1 ;
			dividend_tb = 'd25;
			divisor_tb = 'd3;
			operation_tb = DIVU ;
			@(negedge CLK_tb)
			data_valid_tb = 1'b0 ;

		//test  Division_unsigned	+ / +	|dividend| < |divisor|  	
		repeat(35)@(negedge CLK_tb) ;
			data_valid_tb = 1'b1 ;
			dividend_tb = 'd5;
			divisor_tb = 'd32;
			operation_tb = DIVU ;
			@(negedge CLK_tb)
			data_valid_tb = 1'b0 ;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////			    test cases of REM Signed                    /////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////			
			
	
	  //test  remaider_signed	- / +    |dividend| > |divisor|  
		repeat(35)@(negedge CLK_tb) ;	
			data_valid_tb = 1'b1 ;
			dividend_tb = -'d7;
			divisor_tb = 'd3;
			operation_tb = REM ;
			@(negedge CLK_tb)
			data_valid_tb = 1'b0 ;		
				
		    //test  remaider_signed	+ / +	|dividend| > |divisor|   
	    repeat(35)@(negedge CLK_tb) ;
			data_valid_tb = 1'b1 ;
			dividend_tb = 'd3;
			divisor_tb = 'd2;
			operation_tb = REM ;
			@(negedge CLK_tb)
			data_valid_tb = 1'b0 ;

			//test  remaider_signed	+ / -	|dividend| > |divisor|   
	    repeat(35)@(negedge CLK_tb) ;
			data_valid_tb = 1'b1 ;
			dividend_tb = 'd149;
			divisor_tb = -'d2;
			operation_tb = REM ;
			@(negedge CLK_tb)
			data_valid_tb = 1'b0 ;	

			//test remaider_signed	- / -	|dividend| > |divisor|   
	    repeat(35)@(negedge CLK_tb) ;
			data_valid_tb = 1'b1 ;
			dividend_tb = -'d149;
			divisor_tb = -'d5;
			operation_tb = REM ;
			@(negedge CLK_tb)
			data_valid_tb = 1'b0 ;

			//test  remaider_signed	+ / +	|dividend| < |divisor|   
	    repeat(35)@(negedge CLK_tb) ;
			data_valid_tb = 1'b1 ;
			dividend_tb = 'd5;
			divisor_tb = 'd14;
			operation_tb = REM ;
			@(negedge CLK_tb)
			data_valid_tb = 1'b0 ;

			//test  remaider_signed	- / +	|dividend| < |divisor|   
	    repeat(35)@(negedge CLK_tb) ;
			data_valid_tb = 1'b1 ;
			dividend_tb = -'d5;
			divisor_tb = 'd32;
			operation_tb = REM ;
			@(negedge CLK_tb)
			data_valid_tb = 1'b0 ;

			//test  remaider_signed	+ / -	|dividend| < |divisor|   
	    repeat(35)@(negedge CLK_tb) ;
			data_valid_tb = 1'b1 ;
			dividend_tb = 'd3;
			divisor_tb = -'d5;
			operation_tb = REM ;
			@(negedge CLK_tb)
			data_valid_tb = 1'b0 ;

			//test  remaider_signed	- / +	|dividend| < |divisor|   
	    repeat(35)@(negedge CLK_tb) ;
			data_valid_tb = 1'b1 ;
			dividend_tb = -'d2;
			divisor_tb = -'d5;
			operation_tb = REM ;
			@(negedge CLK_tb)
			data_valid_tb = 1'b0 ;
			


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////			    test cases of REMU UNSigned                    ///////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		//test  remaider_signed	+ / +	|dividend| > |divisor|  	
		repeat(35)@(negedge CLK_tb) ;
			data_valid_tb = 1'b1 ;
			dividend_tb = 'd25;
			divisor_tb = 'd3;
			operation_tb = REMU ;
			@(negedge CLK_tb)
			data_valid_tb = 1'b0 ;

		//test  remaider_signed	+ / +	|dividend| < |divisor|  	
		repeat(35)@(negedge CLK_tb) ;
			data_valid_tb = 1'b1 ;
			dividend_tb = 'd5;
			divisor_tb = 'd32;
			operation_tb = REMU ;
			@(negedge CLK_tb)
			data_valid_tb = 1'b0 ;


	#500 
	$stop;

	end 





	// instaniate design instance 

	Division_BLOCK dut ( 

	//inputs
		.CLK(CLK_tb),
		.rst_n(rst_n_tb),
		.dividend(dividend_tb),
		.divisor(divisor_tb),
		.data_valid(data_valid_tb),
		.operation(operation_tb),
	//outputs    
		.product_o(product_o_tb),
		.data_ready(data_ready_tb) 
		

	);

endmodule

	




			
