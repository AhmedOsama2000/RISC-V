//////////////////////////////////////////////////////////////////////////////////
// univeristy: 
// Engineer: 
// 
// Create Date:    4:05 PM 02/02/2023 
// Design Name: 
// Module Name:    non_restoring_division
// Project Name:   Risc_V
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//   
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: improve number of cycles  
//
//////////////////////////////////////////////////////////////////////////////////


module non_restoring_division #(

	parameter Data_width = 32  
) (
	//inputs
		input  wire                    clk_i,
    	input  wire                    clk_en_i,
    	input  wire                    rst_n_i,
   	    input  wire [Data_width - 1:0] dividend_i,
        input  wire [Data_width - 1:0] divisor_i,
        input  wire                    data_valid_i,

    //outputs    
    	output wire [Data_width - 1:0] quotient_o,
   	 	output wire [Data_width - 1:0] remainder_o,
    	output wire                    divide_by_zero_o,
    	output wire                    data_valid_o,
   	 	output wire                   idle_o

	);


//--------------//
//  PARAMETERS  //
//--------------//

    localparam counter_width = $clog2(Data_width);  
      
	 localparam [1:0]  IDLE = 2'b00, DIVDE = 2'b01, RESTORE = 2'b10;

	 reg [1:0] current_state, next_state;

	reg [counter_width :0] N  ; // N is number of bits in the dividend


//-----------------------//
// number of iteration  //
//----------------------//

always @(*) begin
	case (dividend_i)

		32'b1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
			begin 
					 N = 'd32 ;
			end
				
		32'b01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx  : 
			begin 
					N = 'd31 ;
			end
		32'b001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx  : 
			begin 
					N = 'd30 ;
			end
		32'b0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx  : 
			begin 
					N = 'd29 ;
			end
		32'b0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx  : 
			begin 
					N = 'd28 ;
			end	
		32'b0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
			begin 
					N = 'd27 ;
			end			
		32'b0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx  : 
			begin 
					N = 'd26 ;
			end	
		32'b0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
			begin 
					N = 'd25 ;
			end	
		32'b0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx  : 
			begin 
					N = 'd24 ;
			end	
		32'b0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx : 
			begin 
					N = 'd23 ;
			end	
		32'b0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx  : 
			begin 
					N = 'd22 ;
			end
		32'b0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx : 
			begin 
					N = 'd21 ;
			end	
		32'b0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx  : 
			begin 
					N = 'd20 ;
			end		
		32'b0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx : 
			begin 
					N = 'd19 ;
			end	
		32'b0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx  : 
			begin 
				 	N = 'd18 ;
			end		
		32'b0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx : 
			begin 
					N = 'd17 ;
			end	
		32'b0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx  : 
			begin 
					N = 'd16 ;
			end		
		32'b0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx : 
			begin 
					N = 'd15 ;
			end	
		32'b0000_0000_0000_0000_001x_xxxx_xxxx_xxxx  : 
			begin 
					N = 'd14 ;
			end		
		32'b0000_0000_0000_0000_0001_xxxx_xxxx_xxxx : 
			begin 
					N = 'd13 ;
			end	
		32'b0000_0000_0000_0000_0000_1xxx_xxxx_xxxx  : 
			begin 
					N = 'd12 ;
			end		
		32'b0000_0000_0000_0000_0000_01xx_xxxx_xxxx : 
			begin 
					N = 'd11 ;
			end	
		32'b0000_0000_0000_0000_0000_001x_xxxx_xxxx  : 
			begin 
					N = 'd10 ;
			end		
		32'b0000_0000_0000_0000_0000_0001_xxxx_xxxx : 
			begin 
					N = 'd9 ;
			end	
		32'b0000_0000_0000_0000_0000_0000_1xxx_xxxx  : 
			begin 
					N = 'd8 ;
			end		
		32'b0000_0000_0000_0000_0000_0000_01xx_xxxx : 
			begin 
					N = 'd7 ;
			end	
		32'b0000_0000_0000_0000_0000_0000_001x_xxxx  : 
			begin 
					N = 'd6 ;
			end		
		32'b0000_0000_0000_0000_0000_0000_0001_xxxx : 
			begin 
					N = 'd5 ;
			end	
		32'b0000_0000_0000_0000_0000_0000_0000_1xxx  : 
			begin 
					N = 'd4 ;
			end		
		32'b0000_0000_0000_0000_0000_0000_0000_01xx : 
			begin 
					N = 'd3 ;
			end	
		32'b0000_0000_0000_0000_0000_0000_0000_001x  : 
			begin 
					N = 'd2 ;
			end		
		32'b0000_0000_0000_0000_0000_0000_0000_0001 : 
			begin 
					N = 'd1 ;
			end	
		32'b0000_0000_0000_0000_0000_0000_0000_0000  : 
			begin 
					N = 'd0 ;
			end
						
		default:
			begin
				N = 'd0 ;
			end
	endcase
end


	


//--------------------//
//  internal signals  //
//--------------------//
		
        reg                   rem_sign_current, rem_sign_next, rem_sign_pair_shifted ;
        reg [Data_width - 1:0] remainder_current,  remainder_next,  remainder_pair_shifted ;
        reg [Data_width - 1:0] quotient_current, quotient_next, quotient_pair_shifted ;

        /* Hold divisor value until the end of the division */

        reg [Data_width - 1:0] divisor_current, divisor_next ; 

        /* Count the number of iteration */

        reg [counter_width - 1:0] iter_count_current, iter_count_next ;
      
        reg data_valid_current, data_valid_next;                                         
   		reg idle_current, idle_next;
    	reg divide_by_zero_current, divide_by_zero_next;



//------------//
//  DATAPATH  //
//------------//



	 //state_register
	always @(posedge clk_i or negedge rst_n_i) begin : state_register
			if(~rst_n_i) begin
				current_state <= IDLE;
			end else if (clk_en_i) begin
				current_state <= next_state;
		    end	
    end  

    //datapath_register
	always @(posedge clk_i) begin : datapath_register
			if(clk_en_i) begin
				{rem_sign_current,remainder_current,quotient_current} <= {rem_sign_next,remainder_next,quotient_next};
				divisor_current <= divisor_next;
			end 
	end	

	 //counter_register
	always @(posedge clk_i) begin : counter_register
			if(clk_en_i) begin
				iter_count_current <= iter_count_next;
			end 
	end	

	 //status_register
	always @(posedge clk_i or negedge rst_n_i) begin : status_register
			if(~rst_n_i) begin
				data_valid_current <= 1'b0;
				divide_by_zero_current <= 1'b0;
				idle_current <= 1'b1;
			end else if (clk_en_i) begin
				data_valid_current <= data_valid_next;
				divide_by_zero_current <= divide_by_zero_next;
				idle_current <= idle_next;
		    end	 
	end	

	//fsm_logic
	always @(*) begin : fsm_logic 

		// Default values 
            divide_by_zero_next = divide_by_zero_current;
            iter_count_next = iter_count_current ;
            idle_next = idle_current ;
            data_valid_next = data_valid_current;
            {rem_sign_pair_shifted,remainder_pair_shifted,quotient_pair_shifted}  = 'b0 ;
            data_valid_next = 1'b0 ;

            

            	case (current_state)

            			IDLE : begin 

            					if(data_valid_i) begin
            						next_state = DIVDE ;
            						idle_next = 1'b0 ;
            						divide_by_zero_next = (divisor_i == 'b0) ;

            						rem_sign_next = 1'b0;
                   					 quotient_next = dividend_i;
                    				remainder_next = 'b0;

                   					 data_valid_next = 1'b0;
                   					 divisor_next = divisor_i;
                    				iter_count_next= 'b0;
            					end
            					else 
            					begin
            							 divide_by_zero_next = divide_by_zero_current;
           								 iter_count_next = iter_count_current ;
           								 idle_next = idle_current ;
           								 data_valid_next = data_valid_current;
            							{rem_sign_pair_shifted,remainder_pair_shifted,quotient_pair_shifted}  = 'b0 ;
            							data_valid_next = 1'b0 ;

            						end
            					

            			end

            			DIVDE : begin

            				 	 next_state = (iter_count_current == ( 4- 1)) ? RESTORE : current_state; 
                    				iter_count_next = iter_count_current + 1;

                   						 // In every case shift by one 
                   						 {rem_sign_pair_shifted,remainder_pair_shifted[3:0],quotient_pair_shifted[3:0]}  = {rem_sign_current,remainder_current,quotient_current[3:0]} << 1 ; 

                   						 // If remainder is negative 
                    					if (rem_sign_current) begin
                       						 // Add the divisor to the new remainder 
                       						 {rem_sign_next, remainder_next[3:0]} = {rem_sign_pair_shifted, remainder_pair_shifted[3:0]} + divisor_current[3:0];
                   						 end else begin
                      						  // Subtract the divisor from the new remainder 
                       						 {rem_sign_next, remainder_next[3:0]} = {rem_sign_pair_shifted, remainder_pair_shifted[3:0]} - divisor_current[3:0];
                    						end

                   							 // If the next remainder is negative set the low order bit to zero else set to one
                  							  quotient_next[3:0] = {quotient_pair_shifted[3:0], ~rem_sign_next};

            			end	

            			RESTORE : begin

            					next_state = IDLE;
                    			data_valid_next = 1'b1;
                   				 idle_next = 1'b1;

                   				 // If the remainder is negative, restore by adding the divisor 
                    			if (rem_sign_current) begin
                       			 {rem_sign_next, remainder_next[3:0]} = {rem_sign_current, remainder_current[3:0]} + divisor_current[3:0];

                    			end
                    			else begin
                    				
                    			end

            			end	

            	
            		
            	endcase

	end

    assign quotient_o = quotient_current;
    assign remainder_o = remainder_current;

    assign data_valid_o = data_valid_current;

    assign divide_by_zero_o = divide_by_zero_current;

    assign idle_o = idle_current;

endmodule 


















