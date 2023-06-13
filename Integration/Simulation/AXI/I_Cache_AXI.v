`define OFFSET 1:0		// position of offset in address

module I_Cache_AXI #(

parameter WIDTH_DATA = 32,
parameter DATA = 32 ,
parameter N_WORD = 8 ,
parameter WIDTH_ADD = 32 

) 

(
// signal Between D_Cache & D_Cache_AXI
input	wire	[WIDTH_ADD-1:0]			RD_ADD_MEM ,		
input	wire							WR_EN_MEM ,		

output	reg		[DATA*N_WORD-1:0]		Data_RD_MEM ,		
output	reg								RD_Valid_MEM ,				


// input Global signals
input	wire							AXI_CLK ,
input	wire							AXI_RESETn ,

// Write data channel signals
// input
input	wire							AXI_WVALID ,				
input	wire	[WIDTH_DATA*N_WORD-1:0] AXI_WDATA ,		
input	wire	[3:0]					AXI_WSTRB , 
// output
output	reg								AXI_WREADY ,				


// Write response channel signals
// input
input	wire							AXI_BREADY ,
// output
output	reg								AXI_BVALID ,
output	reg		[1:0]					AXI_BRESP ,		


//  Read address channel signals
// input
input	wire							AXI_ARREADY ,
// output
output	reg								AXI_ARVALID ,				
output	reg		[2:0]					AXI_ARPROT ,		
output	reg		[WIDTH_ADD-1:0]			AXI_ARADDR ,		
output	reg		[3:0]					AXI_ARCACHE 


);


// Write data channel signals

always @(posedge AXI_CLK or negedge AXI_RESETn) begin
	if (~AXI_RESETn) begin
		Data_RD_MEM <= 'b0 ;
		RD_Valid_MEM <= 1'b0 ;	
	end	
	else if (WR_EN_MEM && AXI_WVALID) begin
		Data_RD_MEM <= AXI_WDATA ;
		RD_Valid_MEM <= 1'b1 ;			
	end
	else begin
		Data_RD_MEM <= 'b0 ;
		RD_Valid_MEM <= 1'b0 ;	
	end
end

always @(posedge AXI_CLK or negedge AXI_RESETn) begin
	if (~AXI_RESETn) begin
		AXI_WREADY <= 1'b0 ;
	end	
	else if (WR_EN_MEM) begin
		AXI_WREADY <= 1'b1 ;			
	end
	else begin
		AXI_WREADY <= 1'b0 ;
	end
end


// Write response channel signals

always @(posedge AXI_CLK or negedge AXI_RESETn) begin
	if (~AXI_RESETn) begin
		AXI_BVALID <= 1'b0 ;
		AXI_BRESP <= 'b0 ;
	end
	else if (WR_EN_MEM) begin
		AXI_BVALID <= 1'b1 ;
		AXI_BRESP <= 2'b00 ;
	end
	else begin
		AXI_BVALID <= 1'b0 ;
		AXI_BRESP <= 'b0 ;
	end
end

//  Read address channel signals

always @(posedge AXI_CLK or negedge AXI_RESETn) begin
	if (~AXI_RESETn) begin
		AXI_ARVALID <= 1'b0 ;
		AXI_ARPROT <= 3'b000 ;
		AXI_ARADDR <= 'b0 ;
		AXI_ARCACHE <= 4'b0000 ;
	end
	else if (WR_EN_MEM && AXI_ARREADY) begin
		AXI_ARVALID <= WR_EN_MEM ;
		AXI_ARPROT <= 3'b000 ; // normal mode , data access
		AXI_ARADDR <= RD_ADD_MEM ;
		AXI_ARCACHE <= 4'b0110 ;
	end
	else begin
		AXI_ARVALID <= 1'b0 ;
		AXI_ARPROT <= 3'b000 ;
		AXI_ARADDR <= 'b0 ;
		AXI_ARCACHE <= 4'b0000 ;
	end
end


endmodule