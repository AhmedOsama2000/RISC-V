`define INDEX 11:5		// position of index in address
`define M_WORD 4:2		// position of offset in address


module I_Cache_control #(

parameter Width = 32 ,
parameter Width_ADD = 32 ,
parameter Size_Block = 256 ,
parameter Tag_width = 20 ,
parameter Index_width = 8 

) 

(

// input
input		wire										CLK ,
input		wire										RST ,
input		wire										RD_Hit ,		
input		wire										WR_Hit ,
input		wire										RD_EN_PC , // SIGNAL FROM PROGRAM COUNTER
input		wire										RD_Valid_MEM ,		
input		wire	[Width-1:0]				Data_cache ,

// output
output	reg											RD_EN_CACHE ,		
output	reg											WR_EN_CACHE ,				
output	reg											WR_EN_MEM ,				
output	reg		[Width-1:0]				Data ,		
output	reg											Ready ,
output	reg											STALL 

);



/*******************************************************************
 SELECT OUTPUT DATA
*******************************************************************/
always @(*) begin

	// OUTPUT WORD
	if (RD_Hit) begin
		Data = Data_cache ;
	end

	// NO OUTPUT
	else begin
		Data = 'b0 ;
	end
end


/*******************************************************************
 FINIT STATE MACHINE
*******************************************************************/
localparam	IDLE   					   = 2'b00 ,
						WRITE					  	 = 2'b01 ,
						READ					  	 = 2'b10 ,
						MISS			       	 = 2'b11 ;


reg		[1:0]			cs ; // cs = current state
reg		[1:0]			ns ; // ns = next state


//state memory
always @(posedge CLK or negedge RST) begin
	if (~RST) begin
		cs <= IDLE ;	
	end
	else  begin
		cs <= ns ;	
	end
end

// output & next Logic
always @(*) begin
	case(cs)
		IDLE: begin
			if (RD_Valid_MEM) begin
				ns = WRITE ;
				WR_EN_CACHE = 1'b1 ;
				WR_EN_MEM = 1'b1 ;
				STALL = 1'b0 ;
			end
			else if (RD_EN_PC) begin
				ns = READ ;
				RD_EN_CACHE = 1'b1 ;
				STALL = 1'b0 ;
				Ready = 1'b0 ;
			end
			else begin
				ns = IDLE ;
				Ready = 1'b0 ;
				WR_EN_CACHE = 1'b0 ;
				WR_EN_MEM = 1'b0 ;
				RD_EN_CACHE = 1'b0 ;
				STALL = 1'b0 ;
			end
		end 
		WRITE: begin
			if (WR_Hit && RD_EN_PC) begin
				ns = READ ;	
				RD_EN_CACHE = 1'b1 ;
				WR_EN_CACHE = 1'b0 ;
				STALL = 1'b0 ;
			end
			else if (WR_Hit && RD_Valid_MEM) begin
				ns = WRITE ;	
				WR_EN_CACHE = 1'b1 ;
				STALL = 1'b0 ;
			end
			else if (WR_Hit) begin
				ns = IDLE ;	
				WR_EN_CACHE = 1'b0 ;
				WR_EN_MEM = 1'b0 ;
				STALL = 1'b0 ;
			end
			else begin
				ns = WRITE ;
				WR_EN_CACHE = 1'b0 ;
				WR_EN_MEM = 1'b1 ;
				STALL = 1'b1 ;			
			end
		end
		READ: begin
			if (RD_Hit && RD_EN_PC) begin
				ns = READ ;
				RD_EN_CACHE = 1'b1 ;
				Ready = 1'b1 ;
				STALL = 1'b0 ;
			end
			else if (RD_Hit && RD_Valid_MEM && ~RD_EN_PC) begin
				ns = WRITE ;	
				WR_EN_CACHE = 1'b1 ;
				Ready = 1'b1 ;
				STALL = 1'b0 ;
			end			
			else if (RD_Hit) begin
				ns = IDLE ;	
				Ready = 1'b1 ;
				STALL = 1'b0 ;
			end
			else begin
				ns = MISS ;
				RD_EN_CACHE = 1'b0 ;
				WR_EN_CACHE = 1'b0 ;
				WR_EN_MEM = 1'b1 ;
				STALL = 1'b1 ;
			end
		end
		MISS: begin
			if (WR_Hit) begin
				ns = READ ;
				WR_EN_MEM = 1'b0 ;
				STALL = 1'b1 ;
			end
			else begin
				ns = MISS ;
				WR_EN_MEM = 1'b1 ;
				WR_EN_CACHE = 1'b0 ;
				STALL = 1'b1 ;
			end
		end
		default: begin
				ns = IDLE ;
				RD_EN_CACHE = 1'b0 ;
				WR_EN_CACHE = 1'b0 ;
				WR_EN_MEM = 1'b0 ;
				Ready = 1'b0 ;
				STALL = 1'b0 ;	
			end
	endcase
end

endmodule