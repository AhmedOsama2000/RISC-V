`define OFFSET 1:0		// position of offset in address
`define HWORD1 15:0		// position of half word in cache
`define HWORD2 31:16	// position of half word in cache
`define BYTE1 7:0		// position of byte in cache
`define BYTE2 15:8		// position of byte in cache
`define BYTE3 23:16		// position of byte in cache
`define BYTE4 31:24		// position of byte in cache


module D_Cache_control #(

parameter Width = 32 ,
parameter Size_Block = 256 ,
parameter Tag_width = 20 ,
parameter Index_width = 8 

) 

(

// input
input	wire						CLK ,
input	wire						RST ,
input	wire						WR_EN_CPU ,		
input	wire						RD_EN_CPU ,		
input	wire						RD_Hit ,		
input	wire						WR_Hit ,		
input	wire	[`OFFSET]			B_OFFSET_CACHE , // accept value of offset from CACHE
input	wire						RD_Byte_CPU , // BYTE
input	wire						RD_HWord_CPU , // HALF WORD
input	wire						RD_WAIT , 
input	wire	[Width-1:0]			Data_cache ,		

// output
output	reg							RD_EN_CACHE ,		
output	reg							WR_EN_CACHE ,				
output	reg							WR_EN_MEM ,				
output	reg							RD_EN_MEM ,		
output	reg		[Width-1:0]			Data ,		
output	reg							Ready ,
output	reg							STALL

);

/*******************************************************************
 internal registers
*******************************************************************/

reg					temp_RD_Byte_CPU ;
reg					temp_RD_HWord_CPU ;

reg					RD_Byte ;
reg					RD_HWord ;

always @(posedge CLK or negedge RST) begin
	if (~RST) begin
		RD_Byte <= 1'b0 ;
		RD_HWord <= 1'b0 ;
	end
	else if (temp_RD_Byte_CPU) begin
		RD_Byte <= 1'b1 ;
	end
	else if (temp_RD_HWord_CPU) begin
		RD_HWord <= 1'b1 ;
	end
	else if (RD_Hit) begin
		RD_Byte <= 1'b0 ;
		RD_HWord <= 1'b0 ;
	end
end

/*******************************************************************
 SELECT OUTPUT DATA
*******************************************************************/
always @(*) begin

	// OUTPUT BYTE
	if (RD_Byte && RD_Hit) begin
		case(B_OFFSET_CACHE)
		2'b00: Data = {24'h000000 , Data_cache[`BYTE1]} ;
		2'b01: Data = {24'h000000 , Data_cache[`BYTE2]} ;
		2'b10: Data = {24'h000000 , Data_cache[`BYTE3]} ;
		2'b11: Data = {24'h000000 , Data_cache[`BYTE4]} ;
		endcase
	end

	// OUTPUT HALF WORD
	else if (RD_HWord && RD_Hit) begin
		case(B_OFFSET_CACHE[1])
		1'b0: Data = {16'h0000 , Data_cache[`HWORD1]} ;
		1'b1: Data = {16'h0000 , Data_cache[`HWORD2]} ;
		endcase
	end

	// OUTPUT WORD
	else if (RD_Hit) begin
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
			WRITE					   = 2'b01 ,
			READ					   = 2'b10 ,
			MISS			       	   = 2'b11 ;


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
			if (WR_EN_CPU) begin
				ns = WRITE ;
				WR_EN_CACHE = 1'b1 ;
				WR_EN_MEM = 1'b0 ;
				STALL = 1'b0 ;
				Ready = 1'b0 ;	
			end
			else if (RD_EN_CPU) begin
				ns = READ ;
				RD_EN_CACHE = 1'b1 ;
				STALL = 1'b1 ;
				Ready = 1'b0 ;
				if (RD_Byte_CPU) begin
					temp_RD_Byte_CPU = 1'b1 ;
				end
				else if (RD_HWord_CPU) begin
					temp_RD_HWord_CPU = 1'b1 ;
				end
				else begin
				temp_RD_Byte_CPU = 1'b0 ;
				temp_RD_HWord_CPU = 1'b0 ;							
				end
			end
			else begin
				ns = IDLE ;
				Ready = 1'b0 ;
				WR_EN_CACHE = 1'b0 ;
				WR_EN_MEM = 1'b0 ;
				RD_EN_CACHE = 1'b0 ;
				RD_EN_MEM = 1'b0 ;
				STALL = 1'b0 ;
				temp_RD_Byte_CPU = 1'b0 ;
				temp_RD_HWord_CPU = 1'b0 ;		
			end
		end 
		WRITE: begin
			if (WR_Hit && RD_EN_CPU) begin
				ns = READ ;	
				WR_EN_CACHE = 1'b0 ;
				RD_EN_CACHE = 1'b1 ;
				RD_EN_MEM = 1'b0 ;
				STALL = 1'b0 ;
			end
			else if (WR_Hit && WR_EN_CPU) begin
				ns = WRITE ;	
				WR_EN_CACHE = 1'b1 ;
				RD_EN_MEM = 1'b0 ;
				STALL = 1'b0 ;
			end
			else if (WR_Hit) begin
				ns = IDLE ;	
				WR_EN_CACHE = 1'b0 ;
				STALL = 1'b0 ;
			end
			else begin
				ns = MISS ;
				WR_EN_CACHE = 1'b0 ;
				WR_EN_MEM = 1'b1 ;
				RD_EN_MEM = 1'b1 ;
				STALL = 1'b1 ;			
			end
		end
		READ: begin
			if (RD_Hit && WR_EN_CPU) begin
				ns = WRITE ;	
				Ready = 1'b1 ;
				STALL = 1'b0 ;
				temp_RD_Byte_CPU = 1'b0 ;
				temp_RD_HWord_CPU = 1'b0 ;														
			end
			else if (RD_Hit) begin
				ns = IDLE ;	
				Ready = 1'b1 ;
				temp_RD_Byte_CPU = 1'b0 ;
				temp_RD_HWord_CPU = 1'b0 ;										
			end
			else begin
				ns = MISS ;
				RD_EN_CACHE = 1'b0 ;
				RD_EN_MEM = 1'b1 ;
				STALL = 1'b1 ;
				temp_RD_Byte_CPU = 1'b0 ;
				temp_RD_HWord_CPU = 1'b0 ;														
			end
		end
		MISS: begin
			if (WR_Hit && RD_EN_CPU && ~RD_WAIT) begin
				ns = READ ;
				RD_EN_CACHE = 1'b1 ;
				WR_EN_CACHE = 1'b0 ;
				WR_EN_MEM = 1'b0 ;
				STALL = 1'b1 ;
			end
			else if (WR_Hit && RD_WAIT) begin
				ns = READ ;
				STALL = 1'b1 ;
				temp_RD_Byte_CPU = 1'b0 ;
				temp_RD_HWord_CPU = 1'b0 ;														
			end
			else if (WR_Hit) begin
				ns = IDLE ;
				RD_EN_MEM = 1'b0 ;
				WR_EN_MEM = 1'b0 ;
				STALL = 1'b0 ;
			end
			else if (RD_Hit) begin
				ns = READ ;
				RD_EN_MEM = 1'b0 ;
				STALL = 1'b1 ;
				temp_RD_Byte_CPU = 1'b0 ;
				temp_RD_HWord_CPU = 1'b0 ;														
			end
			else begin
				ns = MISS ;
				RD_EN_MEM = 1'b1 ;
				WR_EN_MEM = 1'b1 ;
				STALL = 1'b1 ;
				temp_RD_Byte_CPU = 1'b0 ;
				temp_RD_HWord_CPU = 1'b0 ;														
			end
		end
		default: begin
				ns = IDLE ;
				RD_EN_CACHE = 1'b0 ;
				WR_EN_CACHE = 1'b0 ;
				WR_EN_MEM = 1'b0 ;
				RD_EN_MEM = 1'b0 ;
				Ready = 1'b0 ;
				STALL = 1'b0 ;	
				temp_RD_Byte_CPU = 1'b0 ;
				temp_RD_HWord_CPU = 1'b0 ;														
			end
	endcase
end

endmodule