module D_Cache_TOP #(

parameter Width_Data = 32 ,
parameter NUMBER_WORD = 4 ,
parameter Width_ADD = 32 

)

(
// input
input	wire									CLK ,
input	wire									RST ,
input	wire									D_Cache_WR_Byte_CPU ,		
input	wire									D_Cache_WR_HWORD_CPU ,		
input	wire									D_Cache_WR_EN_CORE ,		
input	wire									D_Cache_RD_EN_CORE ,		
input	wire									D_Cache_RD_Byte_CPU , // BYTE
input	wire									D_Cache_RD_HWord_CPU , // HALF WORD
input	wire									D_Cache_RD_Valid_MEM , 
input	wire									D_Cache_Write_ready_MEM , 
input	wire	[Width_Data-1:0]				D_Cache_Data_ADD ,		
input	wire	[Width_Data-1:0]				D_Cache_Data_Wr ,		
input	wire	[Width_Data*NUMBER_WORD-1:0]	D_Cache_Data_RD_MEM ,		

// output
output	wire	[Width_Data-1:0]				D_Cache_Data ,		
output	wire									D_Cache_Ready ,
output	wire									D_Cache_STALL ,
output	wire									D_Cache_WR_Byte_MEM ,  // BYTE			
output	wire									D_Cache_WR_HWORD_MEM , // HALF WORD				
output	wire									D_Cache_WR_EN_MEM ,				
output	wire									D_Cache_RD_EN_MEM ,		
output	wire	[Width_Data-1:0]				D_Cache_Write_ADD_MEM ,				
output	wire	[Width_Data-1:0]				D_Cache_Write_Data_MEM 	

);


wire 									RD_ENABLE ;
wire 									WR_ENABLE ;
wire 	[1:0]							B_OFFSET_cache_to_control ;
wire 	[Width_Data-1:0]				Data_cache_to_control ;



D_Cache Cache (

.CLK(CLK),
.RST(RST),
.Write_ready_MEM(D_Cache_Write_ready_MEM),
.RD_Valid_MEM(D_Cache_RD_Valid_MEM),
.WR_Byte_CPU(D_Cache_WR_Byte_CPU),
.WR_HWORD_CPU(D_Cache_WR_HWORD_CPU),
.WR_EN(WR_ENABLE),
.RD_EN(RD_ENABLE),
.Data_RD_MEM(D_Cache_Data_RD_MEM),
.Data_ADD(D_Cache_Data_ADD),
.Data_Wr(D_Cache_Data_Wr),
.Write_ADD_MEM(D_Cache_Write_ADD_MEM),
.Write_Data_MEM(D_Cache_Write_Data_MEM),
.O_Data(Data_cache_to_control),
.B_OFFSET(B_OFFSET_cache_to_control),
.RD_WAIT(RD_WAIT),
// .WR_Byte_MEM(D_Cache_WR_Byte_MEM),
// .WR_HWORD_MEM(D_Cache_WR_HWORD_MEM),
.RD_Hit(RD_Hit),
.WR_Hit(WR_Hit)

);


D_Cache_control control (

.CLK(CLK),
.RST(RST),
.WR_EN_CPU(D_Cache_WR_EN_CORE),
.RD_EN_CPU(D_Cache_RD_EN_CORE),
.RD_Hit(RD_Hit),
.WR_Hit(WR_Hit),
.B_OFFSET_CACHE(B_OFFSET_cache_to_control),
.RD_Byte_CPU(D_Cache_RD_Byte_CPU),
.RD_HWord_CPU(D_Cache_RD_HWord_CPU),
.RD_WAIT(RD_WAIT),
.Data_cache(Data_cache_to_control),
.RD_EN_CACHE(RD_ENABLE),
.WR_EN_CACHE(WR_ENABLE),
.WR_EN_MEM(D_Cache_WR_EN_MEM),
.RD_EN_MEM(D_Cache_RD_EN_MEM),
.Data(D_Cache_Data),
.Ready(D_Cache_Ready),
.STALL(D_Cache_STALL)
);





endmodule