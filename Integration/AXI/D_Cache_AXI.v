`define OFFSET 1:0		// position of offset in address

module D_Cache_AXI #(

parameter N_WORD = 4 ,
parameter WIDTH_DATA_W = 32 ,
parameter DATA = 32 ,
parameter WIDTH_ADD = 32 

) 

(
// signal Between D_Cache & D_Cache_AXI
input	wire	[WIDTH_DATA_W-1:0]		Write_ADD_MEM ,		
input	wire	[WIDTH_DATA_W-1:0]		Write_Data_MEM ,		
input	wire							WR_Byte_MEM ,		
input	wire							WR_HWORD_MEM ,		
input	wire							WR_EN_MEM ,		
input	wire							RD_EN_MEM ,		

output	reg		[DATA*N_WORD-1:0]		Data_RD_MEM ,	//	
output	reg								Write_ready_MEM ,				
output	reg								RD_Valid_MEM ,

// signal Between D_Cache_AXI & MEMORY
output	reg								WR_Byte ,
output	reg								WR_HWORD ,

// input Global signals
input	wire							AXI_CLK ,
input	wire							AXI_RESETn ,

// Write address channel signals
// input
input	wire							AXI_AWREADY ,
// output
output	reg								AXI_AWVALID ,				
output	reg		[2:0]					AXI_AWPROT ,		
output	reg		[WIDTH_ADD-1:0]			AXI_AWADDR ,		
output	reg		[3:0]					AXI_AWCACHE ,

// Write data channel signals
// input
input	wire							AXI_WREADY ,
// output
output	reg								AXI_WVALID ,				
output	reg		[WIDTH_DATA_W-1:0]		AXI_WDATA ,		
output	reg		[3:0]					AXI_WSTRB , //


// Write response channel signals
// input
input	wire							AXI_BVALID ,
input	wire	[1:0]					AXI_BRESP ,		
// output
output	reg								AXI_BREADY , //

//  Read address channel signals
// input
input	wire							AXI_ARREADY ,
// output
output	reg								AXI_ARVALID ,				
output	reg		[2:0]					AXI_ARPROT ,		
output	reg		[WIDTH_ADD-1:0]			AXI_ARADDR ,		
output	reg		[3:0]					AXI_ARCACHE ,

//  Read data channel signals
// input
input	wire							AXI_RVALID ,
input	wire	[DATA*N_WORD-1:0]		AXI_RDATA ,	
input	wire	[1:0]					AXI_RRESP ,		
// output
output	reg								AXI_RREADY 	//			

);


// Write address channel signals

always @(posedge AXI_CLK or negedge AXI_RESETn) begin
	if (~AXI_RESETn) begin
		AXI_AWPROT <= 3'b000 ;
		AXI_AWADDR <= 'b0 ;
		AXI_AWCACHE <= 4'b0000 ;
		AXI_AWVALID <= 1'b0 ;		
	end
	else if (WR_EN_MEM && AXI_AWREADY) begin
		AXI_AWADDR <= Write_ADD_MEM ;
		AXI_AWCACHE <= 4'b1010 ;
		AXI_AWPROT <= 3'b000 ; // normal mode , data access
		AXI_AWVALID <= WR_EN_MEM ;
		Write_ready_MEM <= AXI_WREADY && AXI_AWREADY ;
	end
	else begin
		AXI_AWPROT <= 3'b000 ;
		AXI_AWADDR <= 'b0 ;
		AXI_AWCACHE <= 4'b0000 ;
		AXI_AWVALID <= 1'b0 ;	
	end
end


// Write data channel signals

always @(posedge AXI_CLK or negedge AXI_RESETn) begin
	if (~AXI_RESETn) begin
		AXI_WSTRB <= 4'b0000 ;
		AXI_WDATA <= 'b0 ;
		AXI_WDATA <= 'b0 ;
		AXI_WVALID <= 1'b0 ;	
		WR_Byte <= 1'b0 ;	
		WR_HWORD <= 1'b0 ;	
	end	
	else if (WR_EN_MEM && AXI_WREADY) begin

		AXI_WDATA <= Write_Data_MEM ;
		AXI_WDATA <= Write_Data_MEM ;	
		WR_Byte <= WR_Byte_MEM ;	
		WR_HWORD <= WR_HWORD_MEM ;	
		AXI_WVALID <= 1'b1 ;	

		if (WR_Byte_MEM) begin
			case(Write_Data_MEM[`OFFSET])
			2'b00: AXI_WSTRB <= 4'b0001 ;
			2'b01: AXI_WSTRB <= 4'b0010 ;
			2'b10: AXI_WSTRB <= 4'b0100 ;
			2'b11: AXI_WSTRB <= 4'b1000 ;
			endcase
		end
		else if (WR_HWORD_MEM) begin
			case(Write_Data_MEM[1])
			1'b0: AXI_WSTRB <= 4'b0011 ;
			1'b1: AXI_WSTRB <= 4'b1100 ;
			endcase
		end
		else begin
			AXI_WSTRB <= 4'b1111 ;
		end
	end
	else begin
		AXI_WVALID <= 1'b0 ;
		AXI_WSTRB <= 4'b0000 ;
		AXI_WDATA <= 'b0 ;
		AXI_WDATA <= 'b0 ;
		WR_Byte <= 1'b0 ;	
		WR_HWORD <= 1'b0 ;	
	end
end


// Write response channel signals

always @(posedge AXI_CLK or negedge AXI_RESETn) begin
	if (~AXI_RESETn) begin
		AXI_BREADY <= 1'b0 ;	
	end
	else if (~AXI_BVALID && AXI_BRESP == 2'b00) begin
		AXI_BREADY <= 1'b0 ;
	end
	else begin
		AXI_BREADY <= WR_EN_MEM ;
	end
end

//  Read address channel signals

always @(posedge AXI_CLK or negedge AXI_RESETn) begin
	if (~AXI_RESETn) begin
		AXI_ARVALID <= 1'b0 ;
		AXI_ARPROT <= 3'b000 ;
		AXI_ARADDR <= 'b0 ;
		AXI_ARCACHE <= 4'b0000 ;
		RD_Valid_MEM <= 1'b0 ;		
	end
	else if (RD_EN_MEM) begin
		AXI_ARVALID <= RD_EN_MEM ;
		AXI_ARPROT <= 3'b000 ; // normal mode , data access
		AXI_ARADDR <= Write_ADD_MEM ;
		AXI_ARCACHE <= 4'b0110 ;
		RD_Valid_MEM <= AXI_ARREADY && AXI_RVALID ;
	end
	else begin
		AXI_ARVALID <= 1'b0 ;
		AXI_ARPROT <= 3'b000 ;
		AXI_ARADDR <= 'b0 ;
		AXI_ARCACHE <= 4'b0000 ;
		RD_Valid_MEM <= 1'b0 ;			
	end
end

//  Read data channel signals
always @(posedge AXI_CLK or negedge AXI_RESETn) begin
	if (~AXI_RESETn) begin
		AXI_RREADY <= 1'b0 ;
		Data_RD_MEM <= 'b0 ;		
	end
	else if (RD_EN_MEM && AXI_RRESP == 2'b00) begin
		AXI_RREADY <= RD_EN_MEM ;
		Data_RD_MEM <= AXI_RDATA ;		
	end
	else begin
		AXI_RREADY <= 1'b0 ;
		Data_RD_MEM <= 'b0 ;		
	end
end

endmodule