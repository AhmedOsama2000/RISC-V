module I_Cache_TOP #(

parameter WIDTH_DATA = 32 ,
parameter NUMBER_WORD = 8 ,
parameter WIDTH_ADD = 32 

)

(
// input
input	wire									CLK ,
input	wire									RST ,
input	wire									I_Cache_RD_EN_PC , 
input	wire	[WIDTH_DATA-1:0]				I_Cache_Data_Wr ,		
input	wire									I_Cache_AXI_WVALID ,				
input	wire	[WIDTH_DATA*NUMBER_WORD-1:0]	I_Cache_Data_RD_MEM ,		
input	wire	[3:0]							I_Cache_AXI_WSTRB , 
input	wire									I_Cache_AXI_BREADY ,
input	wire									I_Cache_AXI_ARREADY ,


// output
output	wire	[WIDTH_DATA-1:0]				I_Cache_Data ,		
output	wire									I_Cache_Ready ,
output	wire									I_Cache_STALL ,
output	wire	[WIDTH_ADD-1:0]					I_Cache_Data_ADD_AXI 				

);


wire 									RD_ENABLE ;
wire 									WR_ENABLE ;
wire 	[WIDTH_DATA-1:0]				Instrucation_to_control ;



I_Cache Cache (

.CLK(CLK),
.RST(RST),
.RD_Valid_MEM(RD_Valid_MEM),
.WR_EN(WR_ENABLE),
.RD_EN(RD_ENABLE),
.Data_RD_MEM(I_Cache_Data_RD_MEM), 
.Data_ADD_AXI(I_Cache_Data_ADD_AXI),
.Data_ADD(I_Cache_Data_Wr),
.O_Data(Instrucation_to_control),
.RD_Hit(RD_Hit),
.WR_Hit(WR_Hit)

);


I_Cache_control control (

.CLK(CLK),
.RST(RST),
.RD_Hit(RD_Hit),
.WR_Hit(WR_Hit),
.RD_EN_PC(I_Cache_RD_EN_PC),
.RD_Valid_MEM(RD_Valid_MEM),
.Data_cache(Instrucation_to_control),
.RD_EN_CACHE(RD_ENABLE),
.WR_EN_CACHE(WR_ENABLE),
.WR_EN_MEM(WR_EN_MEM),
.Data(I_Cache_Data),
.Ready(I_Cache_Ready),
.STALL(I_Cache_STALL)

);





endmodule