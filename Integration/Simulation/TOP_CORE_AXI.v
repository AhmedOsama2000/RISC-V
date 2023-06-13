/*******************************************************************


 *********************       RV32IMF CORE        ******************* 
    
 *********************           WTIH            ******************* 

 *********************          AXI BUS          *******************   


********************************************************************/

module TOP_CORE_AXI #(

	parameter XLEN   = 32,
	parameter FLEN   = 32,
	parameter IMM    = 32, 
	parameter I_WORD = 8 ,
	parameter D_WORD = 4 

)
(

	input 	wire 						rst_n,
	input	wire 						CLK,
	input 	wire 						EN_PC,

	////////////// AXI CONNECT WITH INSTRUCTION CACHE //////////////
	// input 
	input	wire							I_Cache_AXI_WVALID ,				
	input	wire	[XLEN*I_WORD-1:0]		I_Cache_AXI_WDATA ,		
	input	wire	[3:0]					I_Cache_AXI_WSTRB , 
	input	wire							I_Cache_AXI_BREADY ,
	input	wire							I_Cache_AXI_ARREADY ,

	// output
	output	wire							I_Cache_AXI_WREADY ,				
	output	wire							I_Cache_AXI_BVALID ,
	output	wire	[1:0]					I_Cache_AXI_BRESP ,		
	output	wire							I_Cache_AXI_ARVALID ,				
	output	wire	[2:0]					I_Cache_AXI_ARPROT ,		
	output	wire	[XLEN-1:0]				I_Cache_AXI_ARADDR ,		
	output	wire	[3:0]					I_Cache_AXI_ARCACHE , 

	////////////// AXI CONNECT WITH DATA CACHE //////////////
	// input
	input	wire							D_Cache_AXI_AWREADY ,
	input	wire							D_Cache_AXI_WREADY ,
	input	wire							D_Cache_AXI_BVALID ,
	input	wire	[1:0]					D_Cache_AXI_BRESP ,		
	input	wire							D_Cache_AXI_ARREADY ,
	input	wire							D_Cache_AXI_RVALID ,
	input	wire	[XLEN*D_WORD-1:0]		D_Cache_AXI_RDATA ,	
	input	wire	[1:0]					D_Cache_AXI_RRESP ,		

	// output
	output	wire							D_Cache_AXI_BYTE ,				
	output	wire							D_Cache_AXI_HWROD ,		
	output	wire							D_Cache_AXI_AWVALID ,				
	output	wire	[2:0]					D_Cache_AXI_AWPROT ,		
	output	wire	[XLEN-1:0]				D_Cache_AXI_AWADDR ,		
	output	wire	[3:0]					D_Cache_AXI_AWCACHE ,
	output	wire							D_Cache_AXI_WVALID ,				
	output	wire	[XLEN-1:0]				D_Cache_AXI_WDATA ,		
	output	wire	[3:0]					D_Cache_AXI_WSTRB ,
	output	wire							D_Cache_AXI_BREADY ,
	output	wire							D_Cache_AXI_ARVALID ,				
	output	wire	[2:0]					D_Cache_AXI_ARPROT ,		
	output	wire	[XLEN-1:0]				D_Cache_AXI_ARADDR ,		
	output	wire	[3:0]					D_Cache_AXI_ARCACHE ,
	output	wire							D_Cache_AXI_RREADY 				

);


/*******************************************************************
 INTERNAL SIGNAL
*******************************************************************/


// SIGNAL BETWEEN RV32IMF & DATA CACHE AXI
wire 						DCache_RD_Valid_MEM ;
wire 						DCache_Write_ready_MEM ;
wire 	[XLEN*D_WORD-1:0]	DCache_Data_RD_MEM ;

wire 						DCache_WR_Byte_MEM ;
wire 						DCache_WR_HWORD_MEM ;
wire 						DCache_WR_EN_MEM ;
wire 						DCache_RD_EN_MEM ;
wire 	[XLEN-1:0]			DCache_Write_ADD_MEM ;
wire 	[XLEN-1:0]			DCache_Write_Data_MEM ;

// SIGNAL BETWEEN RV32IMF & INSTRUCTION CACHE AXI
wire 	[XLEN*I_WORD-1:0]	ICache_Data_RD_MEM ;
wire 						ICache_RD_Valid_MEM ;
	
wire 						ICache_WR_EN_MEM ;
wire 	[XLEN-1:0] 			ICache_Data_ADD_AXI ;



/*******************************************************************
 RISC-V CORE
*******************************************************************/

RV32IMF #(
	 .XLEN(XLEN) ,
	 .FLEN(FLEN) ,
	 .IMM(IMM) , 
	 .I_WORD(I_WORD) ,
	 .D_WORD(D_WORD)  
)

CORE_RV32IMF(

.rst_n(rst_n),
.CLK(CLK),
.EN_PC(EN_PC),

////////////// INSTRUCATION CACHE //////////////
// input
.I_Cache_Data_RD_MEM(ICache_Data_RD_MEM),
.I_Cache_RD_Valid_MEM(ICache_RD_Valid_MEM),	
// output
.I_Cache_WR_EN_MEM(ICache_WR_EN_MEM),
.I_Cache_Data_ADD_AXI(ICache_Data_ADD_AXI),

////////////// DATA CACHE //////////////
// input

.D_Cache_RD_Valid_MEM(DCache_RD_Valid_MEM),
.D_Cache_Write_ready_MEM(DCache_Write_ready_MEM),
.D_Cache_Data_RD_MEM(DCache_Data_RD_MEM),
// output
.D_Cache_WR_Byte_MEM(DCache_WR_Byte_MEM),
.D_Cache_WR_HWORD_MEM(DCache_WR_HWORD_MEM),
.D_Cache_WR_EN_MEM(DCache_WR_EN_MEM),
.D_Cache_RD_EN_MEM(DCache_RD_EN_MEM),
.D_Cache_Write_ADD_MEM(DCache_Write_ADD_MEM),
.D_Cache_Write_Data_MEM(DCache_Write_Data_MEM) 

);



/*******************************************************************
 AXI CONNECT WITH INSTRUCTION CACHE
*******************************************************************/


I_Cache_AXI #(

	.WIDTH_DATA(XLEN) ,
	.DATA(XLEN) ,
	.N_WORD(I_WORD) ,
	.WIDTH_ADD(XLEN) 

) 

INSTRUCTION_AXI (
// signal Between I_Cache & I_Cache_AXI
// input
.RD_ADD_MEM(ICache_Data_ADD_AXI) ,		
.WR_EN_MEM(ICache_WR_EN_MEM) ,		
// output
.Data_RD_MEM(ICache_Data_RD_MEM) ,		
.RD_Valid_MEM(ICache_RD_Valid_MEM) ,

// input Global signals
.AXI_CLK(CLK) ,
.AXI_RESETn(rst_n) ,

// Write data channel signals
// input
.AXI_WVALID(I_Cache_AXI_WVALID) ,				
.AXI_WDATA(I_Cache_AXI_WDATA) ,		
.AXI_WSTRB(I_Cache_AXI_WSTRB) , 
// output
.AXI_WREADY(I_Cache_AXI_WREADY) ,				

// Write response channel signals
// input
.AXI_BREADY(I_Cache_AXI_BREADY) ,
// output
.AXI_BVALID(I_Cache_AXI_BVALID) ,
.AXI_BRESP(I_Cache_AXI_BRESP) ,		

//  Read address channel signals
// input
.AXI_ARREADY(I_Cache_AXI_ARREADY) ,
// output
.AXI_ARVALID(I_Cache_AXI_ARVALID) ,				
.AXI_ARPROT(I_Cache_AXI_ARPROT) ,		
.AXI_ARADDR(I_Cache_AXI_ARADDR) ,		
.AXI_ARCACHE(I_Cache_AXI_ARCACHE)

);

/*******************************************************************
 AXI CONNECT WITH DATA CACHE
*******************************************************************/

D_Cache_AXI #(
 .N_WORD(D_WORD) ,
 .WIDTH_DATA_W(XLEN) ,		 
 .DATA(XLEN) ,
 .WIDTH_ADD(XLEN)
)
	AXI_D_Cache
(
// signal Between D_Cache & D_Cache_AXI
.Write_ADD_MEM(DCache_Write_ADD_MEM) ,		
.Write_Data_MEM(DCache_Write_Data_MEM) ,		
.WR_Byte_MEM(DCache_WR_Byte_MEM) ,		
.WR_HWORD_MEM(DCache_WR_HWORD_MEM) ,		
.WR_EN_MEM(DCache_WR_EN_MEM) ,		
.RD_EN_MEM(DCache_RD_EN_MEM) ,		

.Data_RD_MEM(DCache_Data_RD_MEM) ,		
.Write_ready_MEM(DCache_Write_ready_MEM) ,				
.RD_Valid_MEM(DCache_RD_Valid_MEM) ,

// signal Between D_Cache_AXI & MEMORY
.WR_Byte(D_Cache_AXI_BYTE) ,
.WR_HWORD(D_Cache_AXI_HWROD) ,

// input Global signals
.AXI_CLK(CLK) ,
.AXI_RESETn(rst_n) ,

// Write address channel signals
// input
.AXI_AWREADY(D_Cache_AXI_AWREADY) ,
// output
.AXI_AWVALID(D_Cache_AXI_AWVALID) ,				
.AXI_AWPROT(D_Cache_AXI_AWPROT) ,		
.AXI_AWADDR(D_Cache_AXI_AWADDR) ,		
.AXI_AWCACHE(D_Cache_AXI_AWCACHE) ,

// Write data channel signals
// input
.AXI_WREADY(D_Cache_AXI_WREADY) ,
// output
.AXI_WVALID(D_Cache_AXI_WVALID) ,				
.AXI_WDATA(D_Cache_AXI_WDATA) ,		
.AXI_WSTRB(D_Cache_AXI_WSTRB) , //

// Write response channel signals
// input
.AXI_BVALID(D_Cache_AXI_BVALID) ,
.AXI_BRESP(D_Cache_AXI_BRESP) ,		
// output
.AXI_BREADY(D_Cache_AXI_BREADY) , //

//  Read address channel signals
// input
.AXI_ARREADY(D_Cache_AXI_ARREADY) ,
// output
.AXI_ARVALID(D_Cache_AXI_ARVALID) ,				
.AXI_ARPROT(D_Cache_AXI_ARPROT) ,		
.AXI_ARADDR(D_Cache_AXI_ARADDR) ,		
.AXI_ARCACHE(D_Cache_AXI_ARCACHE) ,

//  Read data channel signals
// input
.AXI_RVALID(D_Cache_AXI_RVALID) ,
.AXI_RDATA(D_Cache_AXI_RDATA) ,	
.AXI_RRESP(D_Cache_AXI_RRESP) ,		
// output
.AXI_RREADY(D_Cache_AXI_RREADY) 			

);


endmodule