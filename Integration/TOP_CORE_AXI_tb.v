`timescale 1ns/1ps
module TOP_CORE_AXI_tb ();


parameter XLEN_tb   = 32 ;
parameter FLEN_tb   = 32 ;
parameter IMM_tb    = 32 ; 
parameter I_WORD_tb = 8  ;
parameter D_WORD_tb = 4  ;



reg 						rst_n_tb ;
reg 						CLK_tb ;
reg 						EN_PC_tb ;
	
////////////// AXI CONNECT WITH INSTRUCTION CACHE //////////////
// input 
reg								I_Cache_AXI_WVALID_tb ;				
reg		[XLEN_tb*I_WORD_tb-1:0]	I_Cache_AXI_WDATA_tb ;		
reg		[3:0]					I_Cache_AXI_WSTRB_tb ; 
reg								I_Cache_AXI_BREADY_tb ;
reg								I_Cache_AXI_ARREADY_tb ;

// output
wire						I_Cache_AXI_WREADY_tb ;				
wire						I_Cache_AXI_BVALID_tb ;
wire	[1:0]				I_Cache_AXI_BRESP_tb ;		
wire						I_Cache_AXI_ARVALID_tb ;				
wire	[2:0]				I_Cache_AXI_ARPROT_tb ;		
wire	[XLEN_tb-1:0]		I_Cache_AXI_ARADDR_tb ;		
wire	[3:0]				I_Cache_AXI_ARCACHE_tb ; 

////////////// AXI CONNECT WITH DATA CACHE //////////////
// input
reg								D_Cache_AXI_AWREADY_tb ;
reg								D_Cache_AXI_WREADY_tb ;
reg								D_Cache_AXI_BVALID_tb ;
reg		[1:0]					D_Cache_AXI_BRESP_tb ;		
reg								D_Cache_AXI_ARREADY_tb ;
reg								D_Cache_AXI_RVALID_tb ;
reg		[XLEN_tb*D_WORD_tb-1:0]	D_Cache_AXI_RDATA_tb ;	
reg		[1:0]					D_Cache_AXI_RRESP_tb ;		
	
// output
wire						D_Cache_AXI_BYTE_tb ;				
wire						D_Cache_AXI_HWROD_tb ;				
wire						D_Cache_AXI_AWVALID_tb ;				
wire	[2:0]				D_Cache_AXI_AWPROT_tb ;		
wire	[XLEN_tb-1:0]		D_Cache_AXI_AWADDR_tb ;		
wire	[3:0]				D_Cache_AXI_AWCACHE_tb ;
wire						D_Cache_AXI_WVALID_tb ;				
wire	[XLEN_tb-1:0]		D_Cache_AXI_WDATA_tb ;		
wire	[3:0]				D_Cache_AXI_WSTRB_tb ;
wire						D_Cache_AXI_BREADY_tb ;
wire						D_Cache_AXI_ARVALID_tb ;				
wire	[2:0]				D_Cache_AXI_ARPROT_tb ;		
wire	[XLEN_tb-1:0]		D_Cache_AXI_ARADDR_tb ;		
wire	[3:0]				D_Cache_AXI_ARCACHE_tb ;
wire						D_Cache_AXI_RREADY_tb ; 				







TOP_CORE_AXI #(
 	
 	.XLEN(XLEN_tb) ,
 	.FLEN(FLEN_tb) ,
	.IMM(IMM_tb) , 
	.I_WORD(I_WORD_tb) ,
	.D_WORD(D_WORD_tb)

)

RISC_V_WITH_AXI(

.rst_n(rst_n_tb) ,
.CLK(CLK_tb) ,
.EN_PC(EN_PC_tb) ,

////////////// AXI CONNECT WITH INSTRUCTION CACHE //////////////
// input 
.I_Cache_AXI_WVALID(I_Cache_AXI_WVALID_tb) ,				
.I_Cache_AXI_WDATA(I_Cache_AXI_WDATA_tb) ,		
.I_Cache_AXI_WSTRB(I_Cache_AXI_WSTRB_tb) , 
.I_Cache_AXI_BREADY(I_Cache_AXI_BREADY_tb) ,
.I_Cache_AXI_ARREADY(I_Cache_AXI_ARREADY_tb) ,

// output
.I_Cache_AXI_WREADY(I_Cache_AXI_WREADY_tb) ,				
.I_Cache_AXI_BVALID(I_Cache_AXI_BVALID_tb) ,
.I_Cache_AXI_BRESP(I_Cache_AXI_BRESP_tb) ,		
.I_Cache_AXI_ARVALID(I_Cache_AXI_ARVALID_tb) ,				
.I_Cache_AXI_ARPROT(I_Cache_AXI_ARPROT_tb) ,		
.I_Cache_AXI_ARADDR(I_Cache_AXI_ARADDR_tb) ,		
.I_Cache_AXI_ARCACHE(I_Cache_AXI_ARCACHE_tb) , 

////////////// AXI CONNECT WITH DATA CACHE //////////////
// input
.D_Cache_AXI_AWREADY(D_Cache_AXI_AWREADY_tb) ,
.D_Cache_AXI_WREADY(D_Cache_AXI_WREADY_tb) ,
.D_Cache_AXI_BVALID(D_Cache_AXI_BVALID_tb) ,
.D_Cache_AXI_BRESP(D_Cache_AXI_BRESP_tb) ,		
.D_Cache_AXI_ARREADY(D_Cache_AXI_ARREADY_tb) ,
.D_Cache_AXI_RVALID(D_Cache_AXI_RVALID_tb) ,
.D_Cache_AXI_RDATA(D_Cache_AXI_RDATA_tb) ,	
.D_Cache_AXI_RRESP(D_Cache_AXI_RRESP_tb) ,		

// output
.D_Cache_AXI_BYTE(D_Cache_AXI_BYTE_tb) ,
.D_Cache_AXI_HWROD(D_Cache_AXI_HWROD_tb) ,
.D_Cache_AXI_AWVALID(D_Cache_AXI_AWVALID_tb) ,				
.D_Cache_AXI_AWPROT(D_Cache_AXI_AWPROT_tb) ,		
.D_Cache_AXI_AWADDR(D_Cache_AXI_AWADDR_tb) ,		
.D_Cache_AXI_AWCACHE(D_Cache_AXI_AWCACHE_tb) ,
.D_Cache_AXI_WVALID(D_Cache_AXI_WVALID_tb) ,				
.D_Cache_AXI_WDATA(D_Cache_AXI_WDATA_tb) ,		
.D_Cache_AXI_WSTRB(D_Cache_AXI_WSTRB_tb) ,
.D_Cache_AXI_BREADY(D_Cache_AXI_BREADY_tb) ,
.D_Cache_AXI_ARVALID(D_Cache_AXI_ARVALID_tb) ,				
.D_Cache_AXI_ARPROT(D_Cache_AXI_ARPROT_tb) ,		
.D_Cache_AXI_ARADDR(D_Cache_AXI_ARADDR_tb) ,		
.D_Cache_AXI_ARCACHE(D_Cache_AXI_ARCACHE_tb) ,
.D_Cache_AXI_RREADY(D_Cache_AXI_ARCACHE_tb) 				

);





// Clock Genretor
initial
 begin
 	CLK_tb = 1'b0 ;
 	forever
 	#5
 	CLK_tb = ~ CLK_tb ;
 end




initial
 begin
	$display("===============================================================================");
	$display("=========================== reset & initialization ============================");

	reset ();
	initialization ();




	#20
	ON_RECIEVE_I_CACHE ();
	I_Cache_AXI_WDATA_tb = 'h88888888_77777777_66666666_55555555_44444444_33333333_22222222_11111111 ;
	#10
	OFF_RECIEVE_I_CACHE ();

	#20 ;
	ON_RECIEVE_D_CACHE ();
	D_Cache_AXI_RDATA_tb = 'heeeeffff_aaaabbbb_ccccdddd_eeeeffff ;
	
	#10
	OFF_RECIEVE_D_CACHE ();

 	#100
	$display("===============================================================================");
	$display("================================= FINISH ======================================");
	$display("===============================================================================");
	$finish;

 end


task STALL_PC ();
 begin
 	EN_PC_tb = 1'b0 ;
 end
endtask

task RUN_PC ();
 begin
 	EN_PC_tb = 1'b1 ;
 end
endtask


task reset ();
 begin 
  	$display("Alert!");
	$display ("-----RESET----");
	$display("===============================================================================");
 	rst_n_tb = 1'b1 ;
 	#10
 	rst_n_tb = 1'b0 ;
 	#10
 	rst_n_tb = 1'b1 ;
 end
endtask


task initialization ();
 begin
 	EN_PC_tb = 1'b0 ;
 	I_Cache_AXI_WVALID_tb = 1'b0 ;
	I_Cache_AXI_WDATA_tb = 'b0 ;
	I_Cache_AXI_WSTRB_tb = 'b0 ;
	I_Cache_AXI_BREADY_tb = 1'b0 ;
	I_Cache_AXI_ARREADY_tb = 1'b0 ;
	D_Cache_AXI_AWREADY_tb = 1'b0 ;
	D_Cache_AXI_WREADY_tb = 1'b0 ;
	D_Cache_AXI_BVALID_tb = 1'b0 ;
	D_Cache_AXI_BRESP_tb = 'b0 ;
	D_Cache_AXI_ARREADY_tb = 1'b0 ;
	D_Cache_AXI_RVALID_tb = 1'b0 ;
	D_Cache_AXI_RDATA_tb = 'b0 ;
	D_Cache_AXI_RRESP_tb = 'b0 ;
 end
endtask


task ON_RECIEVE_D_CACHE ();
 begin
	D_Cache_AXI_AWREADY_tb = 1'b1 ;
	D_Cache_AXI_WREADY_tb = 1'b1 ;
	D_Cache_AXI_ARREADY_tb = 1'b1 ;
	D_Cache_AXI_RVALID_tb = 1'b1 ;
 end
endtask

task OFF_RECIEVE_D_CACHE ();
 begin
	D_Cache_AXI_AWREADY_tb = 1'b0 ;
	D_Cache_AXI_WREADY_tb = 1'b0 ;
	D_Cache_AXI_ARREADY_tb = 1'b0 ;
	D_Cache_AXI_RVALID_tb = 1'b0 ;
 end
endtask

task ON_RECIEVE_I_CACHE ();
 begin
 	I_Cache_AXI_WVALID_tb = 1'b1 ;
	I_Cache_AXI_ARREADY_tb = 1'b1 ;
 end
endtask

task OFF_RECIEVE_I_CACHE ();
 begin
 	I_Cache_AXI_WVALID_tb = 1'b0 ;
	I_Cache_AXI_ARREADY_tb = 1'b0 ;
 end
endtask

endmodule