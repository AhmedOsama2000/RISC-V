module lz_counting #(
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

		32'b1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
			begin 
					 LZC = 'd0 ;
			end
				
		32'b01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx  : 
			begin 
					LZC = 'd1 ;
			end
		32'b001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx  : 
			begin 
					LZC = 'd2 ;
			end
		32'b0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx  : 
			begin 
					LZC = 'd3 ;
			end
		32'b0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx  : 
			begin 
					LZC = 'd4 ;
			end	
		32'b0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
			begin 
					LZC = 'd5 ;
			end			
		32'b0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx  : 
			begin 
					LZC = 'd6 ;
			end	
		32'b0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
			begin 
					LZC = 'd7 ;
			end	
		32'b0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx  : 
			begin 
					LZC = 'd8 ;
			end	
		32'b0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx : 
			begin 
					LZC = 'd9 ;
			end	
		32'b0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx  : 
			begin 
					LZC = 'd10 ;
			end
		32'b0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx : 
			begin 
					LZC = 'd11 ;
			end	
		32'b0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx  : 
			begin 
					LZC = 'd12 ;
			end		
		32'b0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx : 
			begin 
					LZC = 'd13 ;
			end	
		32'b0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx  : 
			begin 
				 	LZC = 'd14 ;
			end		
		32'b0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx : 
			begin 
					LZC = 'd15 ;
			end	
		32'b0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx  : 
			begin 
					LZC = 'd16 ;
			end		
		32'b0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx : 
			begin 
					LZC = 'd17 ;
			end	
		32'b0000_0000_0000_0000_001x_xxxx_xxxx_xxxx  : 
			begin 
					LZC = 'd18 ;
			end		
		32'b0000_0000_0000_0000_0001_xxxx_xxxx_xxxx : 
			begin 
					LZC = 'd19 ;
			end	
		32'b0000_0000_0000_0000_0000_1xxx_xxxx_xxxx  : 
			begin 
					LZC = 'd20 ;
			end		
		32'b0000_0000_0000_0000_0000_01xx_xxxx_xxxx : 
			begin 
					LZC = 'd21 ;
			end	
		32'b0000_0000_0000_0000_0000_001x_xxxx_xxxx  : 
			begin 
					LZC = 'd22 ;
			end		
		32'b0000_0000_0000_0000_0000_0001_xxxx_xxxx : 
			begin 
					LZC = 'd23 ;
			end	
		32'b0000_0000_0000_0000_0000_0000_1xxx_xxxx  : 
			begin 
					LZC = 'd24 ;
			end		
		32'b0000_0000_0000_0000_0000_0000_01xx_xxxx : 
			begin 
					LZC = 'd25 ;
			end	
		32'b0000_0000_0000_0000_0000_0000_001x_xxxx  : 
			begin 
					LZC = 'd26 ;
			end		
		32'b0000_0000_0000_0000_0000_0000_0001_xxxx : 
			begin 
					LZC = 'd27 ;
			end	
		32'b0000_0000_0000_0000_0000_0000_0000_1xxx  : 
			begin 
					LZC = 'd28 ;
			end		
		32'b0000_0000_0000_0000_0000_0000_0000_01xx : 
			begin 
					LZC = 'd29 ;
			end	
		32'b0000_0000_0000_0000_0000_0000_0000_001x  : 
			begin 
					LZC = 'd30 ;
			end		
		32'b0000_0000_0000_0000_0000_0000_0000_0001 : 
			begin 
					LZC = 'd31 ;
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