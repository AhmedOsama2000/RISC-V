module lz_counting_right #(
	parameter width = 32, 
	parameter counter_width = $clog2(width)
) 
(
	input wire [width-1 :0] A,
	output reg [counter_width-1 :0] LZC,
	output reg    all_bits_zero 
);


always @(*) begin
	all_bits_zero = 1'b0 ;
	LZC           =  'b0 ;

	casex (A)    // case (A) is also correct 

		32'b1000_0000_0000_0000_0000_0000_0000_0000 : 
			begin 
					 LZC = 'd31 ;
			end
				
		32'bx100_0000_0000_0000_0000_0000_0000_0000  : 
			begin 
					LZC = 'd30 ;
			end
		32'bxx10_0000_0000_0000_0000_0000_0000_0000  : 
			begin 
					LZC = 'd29 ;
			end
		32'bxxx1_0000_0000_0000_0000_0000_0000_0000  : 
			begin 
					LZC = 'd28 ;
			end
		32'bxxxx_1000_0000_0000_0000_0000_0000_0000  : 
			begin 
					LZC = 'd27 ;
			end	
		32'bxxxx_x100_0000_0000_0000_0000_0000_0000 : 
			begin 
					LZC = 'd26 ;
			end			
		32'bxxxx_xx10_0000_0000_0000_0000_0000_0000  : 
			begin 
					LZC = 'd25 ;
			end	
		32'bxxxx_xxx1_0000_0000_0000_0000_0000_0000 : 
			begin 
					LZC = 'd24 ;
			end	
		32'bxxxx_xxxx_1000_0000_0000_0000_0000_0000  : 
			begin 
					LZC = 'd23 ;
			end	
		32'bxxxx_xxxx_x100_0000_0000_0000_0000_0000 : 
			begin 
					LZC = 'd22 ;
			end	
		32'bxxxx_xxxx_xx10_0000_0000_0000_0000_0000  : 
			begin 
					LZC = 'd21 ;
			end
		32'bxxxx_xxxx_xxx1_0000_0000_0000_0000_0000 : 
			begin 
					LZC = 'd20 ;
			end	
		32'bxxxx_xxxx_xxxx_1000_0000_0000_0000_0000  : 
			begin 
					LZC = 'd19 ;
			end		
		32'bxxxx_xxxx_xxxx_x100_0000_0000_0000_0000 : 
			begin 
					LZC = 'd18 ;
			end	
		32'bxxxx_xxxx_xxxx_xx10_0000_0000_0000_0000  : 
			begin 
				 	LZC = 'd17 ;
			end		
		32'bxxxx_xxxx_xxxx_xxx1_0000_0000_0000_0000 : 
			begin 
					LZC = 'd16 ;
			end	
		32'bxxxx_xxxx_xxxx_xxxx_1000_0000_0000_0000  : 
			begin 
					LZC = 'd15 ;
			end		
		32'bxxxx_xxxx_xxxx_xxxx_x100_0000_0000_0000 : 
			begin 
					LZC = 'd14 ;
			end	
		32'bxxxx_xxxx_xxxx_xxxx_xx10_0000_0000_0000  : 
			begin 
					LZC = 'd13 ;
			end		
		32'bxxxx_xxxx_xxxx_xxxx_xxx1_0000_0000_0000 : 
			begin 
					LZC = 'd12 ;
			end	
		32'bxxxx_xxxx_xxxx_xxxx_xxxx_1000_0000_0000  : 
			begin 
					LZC = 'd11 ;
			end		
		32'bxxxx_xxxx_xxxx_xxxx_xxxx_x100_0000_0000 : 
			begin 
					LZC = 'd10 ;
			end	
		32'bxxxx_xxxx_xxxx_xxxx_xxxx_xx10_0000_0000  : 
			begin 
					LZC = 'd9 ;
			end		
		32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxx1_0000_0000 : 
			begin 
					LZC = 'd8 ;
			end	
		32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_1000_0000  : 
			begin 
					LZC = 'd7 ;
			end		
		32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_x100_0000 : 
			begin 
					LZC = 'd6 ;
			end	
		32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx10_0000  : 
			begin 
					LZC = 'd5 ;
			end		
		32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxx1_0000 : 
			begin 
					LZC = 'd4 ;
			end	
		32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_1000  : 
			begin 
					LZC = 'd3 ;
			end		
		32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_x100 : 
			begin 
					LZC = 'd2 ;
			end	
		32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx10  : 
			begin 
					LZC = 'd1 ;
			end		
		32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxx1 : 
			begin 
					LZC = 'd0 ;
			end	
		32'b0000_0000_0000_0000_0000_0000_0000_0000  : 
			begin 
					all_bits_zero = 1'b1 ;

			end
						
		default:
			begin
				LZC           = 'd0 ;
				all_bits_zero = 1'b0 ;
			end
	endcase
end


endmodule 