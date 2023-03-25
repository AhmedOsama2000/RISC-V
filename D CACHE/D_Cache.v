`define TAG 31:12		// position of tag in address
`define INDEX 11:4		// position of index in address
`define M_WORD 3:2		// position of offset in address
`define OFFSET 1:0		// position of offset in address

module D_Cache #(

parameter Width_Data = 32 ,
parameter Width_ADD = 32 ,
parameter NUMBER_WORD = 4 ,
parameter Size_Block = 256 ,
parameter Tag_width = 20 ,
parameter Index_width = 8 ,
parameter LRU_Width = 2 

) 

(

// input
input		wire							CLK ,
input		wire							RST ,
input		wire							Write_ready_MEM ,		
input		wire							RD_Valid_MEM ,		
input		wire							RD_EN_MEM ,		
input		wire							WR_Byte_CPU ,		
input		wire							WR_HWORD_CPU ,
input		wire							WR_EN ,		
input		wire							RD_EN ,		
input		wire	[Width_Data*NUMBER_WORD-1:0]			Data_RD_MEM ,		
input		wire	[Width_Data-1:0]				Data_ADD ,		
input		wire	[Width_Data-1:0]				Data_Wr ,		

// output
output	reg		[Width_ADD-1:0]					Write_ADD_MEM ,		
output	reg		[Width_Data-1:0]				Write_Data_MEM ,		
output	reg		[Width_Data-1:0]				O_Data ,		
output	reg		[`OFFSET]					B_OFFSET , // send to cache control to select byte
output	reg								RD_WAIT ,  // send to cache control to WAIT RD_Hit
output	reg								RD_Hit ,
output	reg								WR_Hit 
						
);

/*******************************************************************
 internal registers
*******************************************************************/

// 4 - Way Cache
reg		[NUMBER_WORD*Width_Data-1:0] cache_way_1 [Size_Block-1:0] ;
reg		[NUMBER_WORD*Width_Data-1:0] cache_way_2 [Size_Block-1:0] ;
reg		[NUMBER_WORD*Width_Data-1:0] cache_way_3 [Size_Block-1:0] ;
reg		[NUMBER_WORD*Width_Data-1:0] cache_way_4 [Size_Block-1:0] ;

// Valid Bit for 4 - Way Cache
reg		Valid_1 [Size_Block-1:0] ;
reg		Valid_2 [Size_Block-1:0] ;
reg		Valid_3 [Size_Block-1:0] ;
reg		Valid_4 [Size_Block-1:0] ;

// TAG for Index In Cache  
reg		[Tag_width-1:0]	Tag_1 [Size_Block-1:0] ;
reg		[Tag_width-1:0]	Tag_2 [Size_Block-1:0] ;
reg		[Tag_width-1:0]	Tag_3 [Size_Block-1:0] ;
reg		[Tag_width-1:0]	Tag_4 [Size_Block-1:0] ;

// counter for LRU In Cache  
reg		[LRU_Width-1:0]	LRU_1 [Size_Block-1:0] ;
reg		[LRU_Width-1:0]	LRU_2 [Size_Block-1:0] ;
reg		[LRU_Width-1:0]	LRU_3 [Size_Block-1:0] ;
reg		[LRU_Width-1:0]	LRU_4 [Size_Block-1:0] ;

// READ FORM CONTROL
reg						temp_RD_EN ;
reg						temp_WR_EN ;

// THIS SIGNAL FOR READ FORM MEMORY IF NOT HIT IN CACHE
reg						RD_InValidate ;

// WRITE DATA TEMPORARY SAVE SELECT BYTE OR HALF WORD FORM CONTROL UNIT
reg						temp_WR_Byte_CPU ;
reg						temp_WR_HWORD_CPU ;


// SAVE DATA COMING FORM CACHE
reg		[Width_Data-1:0]  		temp_Data_ADD ;
reg		[Width_Data-1:0]  		temp_Data_Wr ;

// missing 
wire 						miss_1 ;	
wire 						miss_2 ;	
wire 						miss_3 ;	
wire 						miss_4 ;	

// FLAG READ DONE
reg		[1:0]				RD_DN ;

/*******************************************************************
 Initializations
*******************************************************************/
integer i ;

always @(posedge CLK or negedge RST) begin
	if (~RST) begin
		for (i = 0 ; i < Size_Block ; i = i + 1) begin

			// Cache
			cache_way_1 [i] <= 'b0 ;
			cache_way_2 [i] <= 'b0 ;
			cache_way_3 [i] <= 'b0 ;
			cache_way_4 [i] <= 'b0 ;
			
			// Valid
			Valid_1 [i] <= 'b0 ;
			Valid_2 [i] <= 'b0 ;
			Valid_3 [i] <= 'b0 ;
			Valid_4 [i] <= 'b0 ;
			
			// TAG
			Tag_1 [i] <= 'b0 ;
			Tag_2 [i] <= 'b0 ;
			Tag_3 [i] <= 'b0 ;
			Tag_4 [i] <= 'b0 ;
		end 

		O_Data <= 'b0 ;
		B_OFFSET <= 'b0 ;	
		RD_DN <= 2'b00 ;
	end

	/*******************************************************************
	 WRITE DATA FROM CPU 
	*******************************************************************/
	

	/******************************* WAY 1 *******************************/

	else if (~WR_Hit && WR_EN && Valid_1[Data_ADD[`INDEX]] && Data_ADD[`TAG] == Tag_1[Data_ADD[`INDEX]]) begin
		
		// CHANGE ONLY BYTE IN WORD
		if (WR_Byte_CPU) begin
			case(Data_ADD[`M_WORD])
			
			// CHANGE IN WORD 1
			2'b00: begin
				case(Data_ADD[`OFFSET])
				2'b00: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:8] , Data_Wr[7:0]}  ;
				2'b01: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:16] , Data_Wr[15:8] , cache_way_1[Data_ADD[`INDEX]][7:0]} ;
				2'b10: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:24] , Data_Wr[23:16] , cache_way_1[Data_ADD[`INDEX]][15:0]} ;
				2'b11: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:32] , Data_Wr[31:24] , cache_way_1[Data_ADD[`INDEX]][23:0]} ;			
				endcase
			end

			// CHANGE IN WORD 2
			2'b01: begin
				case(Data_ADD[`OFFSET])
				2'b00: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:40] , Data_Wr[7:0] , cache_way_1[Data_ADD[`INDEX]][31:0]} ;
				2'b01: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:48] , Data_Wr[15:8] , cache_way_1[Data_ADD[`INDEX]][39:0]} ;
				2'b10: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:56] , Data_Wr[23:16] , cache_way_1[Data_ADD[`INDEX]][47:0]} ;
				2'b11: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:64] , Data_Wr[31:24] , cache_way_1[Data_ADD[`INDEX]][55:0]} ;			
				endcase
			end

			// CHANGE IN WORD 3
			2'b10: begin
				case(Data_ADD[`OFFSET])
				2'b00: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:72] , Data_Wr[7:0] , cache_way_1[Data_ADD[`INDEX]][63:0]} ;
				2'b01: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:80] , Data_Wr[15:8] , cache_way_1[Data_ADD[`INDEX]][71:0]} ;
				2'b10: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:88] , Data_Wr[23:16] , cache_way_1[Data_ADD[`INDEX]][79:0]} ;
				2'b11: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:96] , Data_Wr[31:24] , cache_way_1[Data_ADD[`INDEX]][87:0]} ;			
				endcase
			end

			// CHANGE IN WORD 4
			2'b11: begin
				case(Data_ADD[`OFFSET])
				2'b00: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:104] , Data_Wr[7:0] , cache_way_1[Data_ADD[`INDEX]][95:0]} ;
				2'b01: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:112] , Data_Wr[15:8] , cache_way_1[Data_ADD[`INDEX]][103:0]} ;
				2'b10: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:120] , Data_Wr[23:16] , cache_way_1[Data_ADD[`INDEX]][111:0]} ;
				2'b11: cache_way_1[Data_ADD[`INDEX]] <= {Data_Wr[31:24] , cache_way_1[Data_ADD[`INDEX]][119:0]} ;			
				endcase
			end		

			endcase
		end
		// CHANGE ONLY HALF WORD
		else if (WR_HWORD_CPU) begin

			case(Data_ADD[`M_WORD])
			
			// CHANGE IN WORD 1
			2'b00: begin
				case(Data_ADD[1])
				1'b0: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:8] , Data_Wr[15:0]}  ;
				1'b1: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:32] , Data_Wr[31:16] , cache_way_1[Data_ADD[`INDEX]][15:0]} ;
				endcase
			end

			// CHANGE IN WORD 2
			2'b01: begin
				case(Data_ADD[1])
				1'b0: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:48] , Data_Wr[15:0] , cache_way_1[Data_ADD[`INDEX]][31:0]} ;
				1'b1: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:64] , Data_Wr[31:16] , cache_way_1[Data_ADD[`INDEX]][47:0]} ;
				endcase
			end

			// CHANGE IN WORD 3
			2'b10: begin
				case(Data_ADD[1])
				1'b0: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:80] , Data_Wr[15:0] , cache_way_1[Data_ADD[`INDEX]][63:0]} ;
				1'b1: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:96] , Data_Wr[31:16] , cache_way_1[Data_ADD[`INDEX]][79:0]} ;
				endcase
			end

			// CHANGE IN WORD 4
			2'b11: begin
				case(Data_ADD[1])
				1'b0: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:112] , Data_Wr[15:0] , cache_way_1[Data_ADD[`INDEX]][95:0]} ;
				1'b1: cache_way_1[Data_ADD[`INDEX]] <= { Data_Wr[31:16] , cache_way_1[Data_ADD[`INDEX]][111:0]} ;
				endcase
			end		
		
		endcase
		end

		// CHANGE ALL WORD
		else begin
			case(Data_ADD[`M_WORD])
			2'b00: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:32] , Data_Wr} ;
			2'b01: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:64] , Data_Wr , cache_way_1[Data_ADD[`INDEX]][31:0]} ;
			2'b10: cache_way_1[Data_ADD[`INDEX]] <= {cache_way_1[Data_ADD[`INDEX]][127:96] , Data_Wr , cache_way_1[Data_ADD[`INDEX]][63:0]} ;
			2'b11: cache_way_1[Data_ADD[`INDEX]] <= {Data_Wr , cache_way_1[Data_ADD[`INDEX]][95:0]} ;
			endcase
		end

		WR_Hit <= 1'b1 ;
	end
	
	/******************************* WAY 2 *******************************/

	else if (~WR_Hit && WR_EN && Valid_2[Data_ADD[`INDEX]] && Data_ADD[`TAG] == Tag_2[Data_ADD[`INDEX]]) begin
		
		// CHANGE ONLY BYTE IN WORD
		if (WR_Byte_CPU) begin
			case(Data_ADD[`M_WORD])
			
			// CHANGE IN WORD 1
			2'b00: begin
				case(Data_ADD[`OFFSET])
				2'b00: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:8] , Data_Wr[7:0]}  ;
				2'b01: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:16] , Data_Wr[15:8] , cache_way_2[Data_ADD[`INDEX]][7:0]} ;
				2'b10: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:24] , Data_Wr[23:16] , cache_way_2[Data_ADD[`INDEX]][15:0]} ;
				2'b11: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:32] , Data_Wr[31:24] , cache_way_2[Data_ADD[`INDEX]][23:0]} ;			
				endcase
			end

			// CHANGE IN WORD 2
			2'b01: begin
				case(Data_ADD[`OFFSET])
				2'b00: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:40] , Data_Wr[7:0] , cache_way_2[Data_ADD[`INDEX]][31:0]} ;
				2'b01: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:48] , Data_Wr[15:8] , cache_way_2[Data_ADD[`INDEX]][39:0]} ;
				2'b10: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:56] , Data_Wr[23:16] , cache_way_2[Data_ADD[`INDEX]][47:0]} ;
				2'b11: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:64] , Data_Wr[31:24] , cache_way_2[Data_ADD[`INDEX]][55:0]} ;			
				endcase
			end

			// CHANGE IN WORD 3
			2'b10: begin
				case(Data_ADD[`OFFSET])
				2'b00: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:72] , Data_Wr[7:0] , cache_way_2[Data_ADD[`INDEX]][63:0]} ;
				2'b01: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:80] , Data_Wr[15:8] , cache_way_2[Data_ADD[`INDEX]][71:0]} ;
				2'b10: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:88] , Data_Wr[23:16] , cache_way_2[Data_ADD[`INDEX]][79:0]} ;
				2'b11: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:96] , Data_Wr[31:24] , cache_way_2[Data_ADD[`INDEX]][87:0]} ;			
				endcase
			end

			// CHANGE IN WORD 4
			2'b11: begin
				case(Data_ADD[`OFFSET])
				2'b00: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:104] , Data_Wr[7:0] , cache_way_2[Data_ADD[`INDEX]][95:0]} ;
				2'b01: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:112] , Data_Wr[15:8] , cache_way_2[Data_ADD[`INDEX]][103:0]} ;
				2'b10: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:120] , Data_Wr[23:16] , cache_way_2[Data_ADD[`INDEX]][111:0]} ;
				2'b11: cache_way_2[Data_ADD[`INDEX]] <= {Data_Wr[31:24] , cache_way_2[Data_ADD[`INDEX]][119:0]} ;			
				endcase
			end		

			endcase
		end

		// CHANGE ONLY HALF WORD
		else if (WR_HWORD_CPU) begin

			case(Data_ADD[`M_WORD])
			
			// CHANGE IN WORD 1
			2'b00: begin
				case(Data_ADD[1])
				1'b0: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:8] , Data_Wr[15:0]}  ;
				1'b1: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:32] , Data_Wr[31:16] , cache_way_2[Data_ADD[`INDEX]][15:0]} ;
				endcase
			end

			// CHANGE IN WORD 2
			2'b01: begin
				case(Data_ADD[1])
				1'b0: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:48] , Data_Wr[15:0] , cache_way_2[Data_ADD[`INDEX]][31:0]} ;
				1'b1: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:64] , Data_Wr[31:16] , cache_way_2[Data_ADD[`INDEX]][47:0]} ;
				endcase
			end

			// CHANGE IN WORD 3
			2'b10: begin
				case(Data_ADD[1])
				1'b0: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:80] , Data_Wr[15:0] , cache_way_2[Data_ADD[`INDEX]][63:0]} ;
				1'b1: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:96] , Data_Wr[31:16] , cache_way_2[Data_ADD[`INDEX]][79:0]} ;
				endcase
			end

			// CHANGE IN WORD 4
			2'b11: begin
				case(Data_ADD[1])
				1'b0: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:112] , Data_Wr[15:0] , cache_way_2[Data_ADD[`INDEX]][95:0]} ;
				1'b1: cache_way_2[Data_ADD[`INDEX]] <= { Data_Wr[31:16] , cache_way_2[Data_ADD[`INDEX]][111:0]} ;
				endcase
			end		

		endcase	
		end

		// CHANGE ALL WORD
		else begin
			case(Data_ADD[`M_WORD])
			2'b00: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:32] , Data_Wr} ;
			2'b01: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:64] , Data_Wr , cache_way_2[Data_ADD[`INDEX]][31:0]} ;
			2'b10: cache_way_2[Data_ADD[`INDEX]] <= {cache_way_2[Data_ADD[`INDEX]][127:96] , Data_Wr , cache_way_2[Data_ADD[`INDEX]][63:0]} ;
			2'b11: cache_way_2[Data_ADD[`INDEX]] <= {Data_Wr , cache_way_2[Data_ADD[`INDEX]][95:0]} ;
		endcase
		end

		WR_Hit <= 1'b1 ;
	end
	
	/******************************* WAY 3 *******************************/

	else if (~WR_Hit && WR_EN && Valid_3[Data_ADD[`INDEX]] && Data_ADD[`TAG] == Tag_3[Data_ADD[`INDEX]]) begin
		
		// CHANGE ONLY BYTE IN WORD
		if (WR_Byte_CPU) begin
			case(Data_ADD[`M_WORD])
			
			// CHANGE IN WORD 1
			2'b00: begin
				case(Data_ADD[`OFFSET])
				2'b00: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:8] , Data_Wr[7:0]} ;
				2'b01: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:16] , Data_Wr[15:8] , cache_way_3[Data_ADD[`INDEX]][7:0]} ;
				2'b10: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:24] , Data_Wr[23:16] , cache_way_3[Data_ADD[`INDEX]][15:0]} ;
				2'b11: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:32] , Data_Wr[31:24] , cache_way_3[Data_ADD[`INDEX]][23:0]} ;			
				endcase
			end

			// CHANGE IN WORD 2
			2'b01: begin
				case(Data_ADD[`OFFSET])
				2'b00: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:40] , Data_Wr[7:0] , cache_way_3[Data_ADD[`INDEX]][31:0]} ;
				2'b01: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:48] , Data_Wr[15:8] , cache_way_3[Data_ADD[`INDEX]][39:0]} ;
				2'b10: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:56] , Data_Wr[23:16] , cache_way_3[Data_ADD[`INDEX]][47:0]} ;
				2'b11: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:64] , Data_Wr[31:24] , cache_way_3[Data_ADD[`INDEX]][55:0]} ;			
				endcase
			end

			// CHANGE IN WORD 3
			2'b10: begin
				case(Data_ADD[`OFFSET])
				2'b00: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:72] , Data_Wr[7:0] , cache_way_3[Data_ADD[`INDEX]][63:0]} ;
				2'b01: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:80] , Data_Wr[15:8] , cache_way_3[Data_ADD[`INDEX]][71:0]} ;
				2'b10: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:88] , Data_Wr[23:16] , cache_way_3[Data_ADD[`INDEX]][79:0]} ;
				2'b11: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:96] , Data_Wr[31:24] , cache_way_3[Data_ADD[`INDEX]][87:0]} ;			
				endcase
			end

			// CHANGE IN WORD 4
			2'b11: begin
				case(Data_ADD[`OFFSET])
				2'b00: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:104] , Data_Wr[7:0] , cache_way_3[Data_ADD[`INDEX]][95:0]} ;
				2'b01: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:112] , Data_Wr[15:8] , cache_way_3[Data_ADD[`INDEX]][103:0]} ;
				2'b10: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:120] , Data_Wr[23:16] , cache_way_3[Data_ADD[`INDEX]][111:0]} ;
				2'b11: cache_way_3[Data_ADD[`INDEX]] <= {Data_Wr[31:24] , cache_way_3[Data_ADD[`INDEX]][119:0]} ;			
				endcase
			end		

		endcase	
		end

		// CHANGE ONLY HALF WORD
		else if (WR_HWORD_CPU) begin

			case(Data_ADD[`M_WORD])
			
			// CHANGE IN WORD 1
			2'b00: begin
				case(Data_ADD[1])
				1'b0: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:8] , Data_Wr[15:0]} ;
				1'b1: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:32] , Data_Wr[31:16] , cache_way_3[Data_ADD[`INDEX]][15:0]} ;
				endcase
			end

			// CHANGE IN WORD 2
			2'b01: begin
				case(Data_ADD[1])
				1'b0: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:48] , Data_Wr[15:0] , cache_way_3[Data_ADD[`INDEX]][31:0]} ;
				1'b1: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:64] , Data_Wr[31:16] , cache_way_3[Data_ADD[`INDEX]][47:0]} ;
				endcase
			end

			// CHANGE IN WORD 3
			2'b10: begin
				case(Data_ADD[1])
				1'b0: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:80] , Data_Wr[15:0] , cache_way_3[Data_ADD[`INDEX]][63:0]} ;
				1'b1: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:96] , Data_Wr[31:16] , cache_way_3[Data_ADD[`INDEX]][79:0]} ;
				endcase
			end

			// CHANGE IN WORD 4
			2'b11: begin
				case(Data_ADD[1])
				1'b0: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:112] , Data_Wr[15:0] , cache_way_3[Data_ADD[`INDEX]][95:0]} ;
				1'b1: cache_way_3[Data_ADD[`INDEX]] <= { Data_Wr[31:16] , cache_way_3[Data_ADD[`INDEX]][111:0]} ;
				endcase
			end		

		endcase	
		end

		// CHANGE ALL WORD
		else begin
			case(Data_ADD[`M_WORD])
			2'b00: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:32] , Data_Wr} ;
			2'b01: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:64] , Data_Wr , cache_way_3[Data_ADD[`INDEX]][31:0]} ;
			2'b10: cache_way_3[Data_ADD[`INDEX]] <= {cache_way_3[Data_ADD[`INDEX]][127:96] , Data_Wr , cache_way_3[Data_ADD[`INDEX]][63:0]} ;
			2'b11: cache_way_3[Data_ADD[`INDEX]] <= {Data_Wr , cache_way_3[Data_ADD[`INDEX]][95:0]} ;
			endcase
		end

		WR_Hit <= 1'b1 ;
	end
	
	/******************************* WAY 4 *******************************/

	else if (~WR_Hit && (WR_EN || temp_WR_EN) && Valid_4[Data_ADD[`INDEX]] && Data_ADD[`TAG] == Tag_4[Data_ADD[`INDEX]]) begin

		// CHANGE ONLY BYTE IN WORD
		if (WR_Byte_CPU) begin
			case(Data_ADD[`M_WORD])
			
			// CHANGE IN WORD 1
			2'b00: begin
				case(Data_ADD[`OFFSET])
				2'b00: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:8] , Data_Wr[7:0]} ;
				2'b01: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:16] , Data_Wr[15:8] , cache_way_4[Data_ADD[`INDEX]][7:0]} ;
				2'b10: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:24] , Data_Wr[23:16] , cache_way_4[Data_ADD[`INDEX]][15:0]} ;
				2'b11: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:32] , Data_Wr[31:24] , cache_way_4[Data_ADD[`INDEX]][23:0]} ;			
				endcase
			end

			// CHANGE IN WORD 2
			2'b01: begin
				case(Data_ADD[`OFFSET])
				2'b00: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:40] , Data_Wr[7:0] , cache_way_4[Data_ADD[`INDEX]][31:0]} ;
				2'b01: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:48] , Data_Wr[15:8] , cache_way_4[Data_ADD[`INDEX]][39:0]} ;
				2'b10: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:56] , Data_Wr[23:16] , cache_way_4[Data_ADD[`INDEX]][47:0]} ;
				2'b11: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:64] , Data_Wr[31:24] , cache_way_4[Data_ADD[`INDEX]][55:0]} ;			
				endcase
			end

			// CHANGE IN WORD 3
			2'b10: begin
				case(Data_ADD[`OFFSET])
				2'b00: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:72] , Data_Wr[7:0] , cache_way_4[Data_ADD[`INDEX]][63:0]} ;
				2'b01: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:80] , Data_Wr[15:8] , cache_way_4[Data_ADD[`INDEX]][71:0]} ;
				2'b10: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:88] , Data_Wr[23:16] , cache_way_4[Data_ADD[`INDEX]][79:0]} ;
				2'b11: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:96] , Data_Wr[31:24] , cache_way_4[Data_ADD[`INDEX]][87:0]} ;			
				endcase
			end

			// CHANGE IN WORD 4
			2'b11: begin
				case(Data_ADD[`OFFSET])
				2'b00: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:104] , Data_Wr[7:0] , cache_way_4[Data_ADD[`INDEX]][95:0]} ;
				2'b01: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:112] , Data_Wr[15:8] , cache_way_4[Data_ADD[`INDEX]][103:0]} ;
				2'b10: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:120] , Data_Wr[23:16] , cache_way_4[Data_ADD[`INDEX]][111:0]} ;
				2'b11: cache_way_4[Data_ADD[`INDEX]] <= {Data_Wr[31:24] , cache_way_4[Data_ADD[`INDEX]][119:0]} ;			
				endcase
			end		

		endcase	
		end

		// CHANGE ONLY HALF WORD
		else if (WR_HWORD_CPU) begin

			case(Data_ADD[`M_WORD])
			
			// CHANGE IN WORD 1
			2'b00: begin
				case(Data_ADD[1])
				1'b0: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:8] , Data_Wr[15:0]}  ;
				1'b1: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:32] , Data_Wr[31:16] , cache_way_4[Data_ADD[`INDEX]][15:0]} ;
				endcase
			end

			// CHANGE IN WORD 2
			2'b01: begin
				case(Data_ADD[1])
				1'b0: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:48] , Data_Wr[15:0] , cache_way_4[Data_ADD[`INDEX]][31:0]} ;
				1'b1: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:64] , Data_Wr[31:16] , cache_way_4[Data_ADD[`INDEX]][47:0]} ;
				endcase
			end

			// CHANGE IN WORD 3
			2'b10: begin
				case(Data_ADD[1])
				1'b0: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:80] , Data_Wr[15:0] , cache_way_4[Data_ADD[`INDEX]][63:0]} ;
				1'b1: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:96] , Data_Wr[31:16] , cache_way_4[Data_ADD[`INDEX]][79:0]} ;
				endcase
			end

			// CHANGE IN WORD 4
			2'b11: begin
				case(Data_ADD[1])
				1'b0: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:112] , Data_Wr[15:0] , cache_way_4[Data_ADD[`INDEX]][95:0]} ;
				1'b1: cache_way_4[Data_ADD[`INDEX]] <= { Data_Wr[31:16] , cache_way_4[Data_ADD[`INDEX]][111:0]} ;
				endcase
			end		

		endcase	
		end

		// CHANGE ALL WORD
		else begin
			case(Data_ADD[`M_WORD])
			2'b00: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:32] , Data_Wr} ;
			2'b01: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:64] , Data_Wr , cache_way_4[Data_ADD[`INDEX]][31:0]} ;
			2'b10: cache_way_4[Data_ADD[`INDEX]] <= {cache_way_4[Data_ADD[`INDEX]][127:96] , Data_Wr , cache_way_4[Data_ADD[`INDEX]][63:0]} ;
			2'b11: cache_way_4[Data_ADD[`INDEX]] <= {Data_Wr , cache_way_4[Data_ADD[`INDEX]][95:0]} ;
			endcase
		end

		WR_Hit <= 1'b1 ;
	end

	/*******************************************************************
	 READ DATA (HIT)
	*******************************************************************/


	/******************************* WAY 1 *******************************/

	else if (RD_EN && Valid_1[Data_ADD[`INDEX]] && Data_ADD[`TAG] == Tag_1[Data_ADD[`INDEX]]) begin
		RD_Hit <= 1'b1 ;
		RD_DN <= 2'b00 ;
		B_OFFSET <= Data_ADD[`OFFSET] ;

		case(Data_ADD[`M_WORD])
		2'b00: O_Data <= cache_way_1[Data_ADD[`INDEX]][31:0] ;
		2'b01: O_Data <= cache_way_1[Data_ADD[`INDEX]][63:32];
		2'b10: O_Data <= cache_way_1[Data_ADD[`INDEX]][95:64] ;
		2'b11: O_Data <= cache_way_1[Data_ADD[`INDEX]][127:96] ;
		endcase

	end

	/******************************* WAY 2 *******************************/

	else if (RD_EN && Valid_2[Data_ADD[`INDEX]] && Data_ADD[`TAG] == Tag_2[Data_ADD[`INDEX]]) begin
		RD_Hit <= 1'b1 ;
		RD_DN <= 2'b01 ;
		B_OFFSET <= Data_ADD[`OFFSET] ;

		case(Data_ADD[`M_WORD])
		2'b00: O_Data <= cache_way_2[Data_ADD[`INDEX]][31:0] ;
		2'b01: O_Data <= cache_way_2[Data_ADD[`INDEX]][63:32] ;
		2'b10: O_Data <= cache_way_2[Data_ADD[`INDEX]][95:64] ;
		2'b11: O_Data <= cache_way_2[Data_ADD[`INDEX]][127:96] ;
		endcase

	end

	/******************************* WAY 3 *******************************/

	else if (RD_EN && Valid_3[Data_ADD[`INDEX]] && Data_ADD[`TAG] == Tag_3[Data_ADD[`INDEX]]) begin
		RD_Hit <= 1'b1 ;
		RD_DN <= 2'b10 ;
		B_OFFSET <= Data_ADD[`OFFSET] ;

		case(Data_ADD[`M_WORD])
		2'b00: O_Data <= cache_way_3[Data_ADD[`INDEX]][31:0] ;
		2'b01: O_Data <= cache_way_3[Data_ADD[`INDEX]][63:32] ;
		2'b10: O_Data <= cache_way_3[Data_ADD[`INDEX]][95:64] ;
		2'b11: O_Data <= cache_way_3[Data_ADD[`INDEX]][127:96] ;
		endcase

	end

	/******************************* WAY 4 *******************************/

	else if (RD_EN && Valid_4[Data_ADD[`INDEX]] && Data_ADD[`TAG] == Tag_4[Data_ADD[`INDEX]]) begin
		RD_Hit <= 1'b1 ;
		RD_DN <= 2'b11 ;
		B_OFFSET <= Data_ADD[`OFFSET] ;

		case(Data_ADD[`M_WORD])
		2'b00: O_Data <= cache_way_4[Data_ADD[`INDEX]][31:0] ;
		2'b01: O_Data <= cache_way_4[Data_ADD[`INDEX]][63:32] ;
		2'b10: O_Data <= cache_way_4[Data_ADD[`INDEX]][95:64] ;
		2'b11: O_Data <= cache_way_4[Data_ADD[`INDEX]][127:96] ;
		endcase

	end

end
 


/*******************************************************************
	READ DATA (MISS) 
*******************************************************************/


always @(posedge CLK or negedge RST) begin

	if (~RST) begin
		O_Data <= 'b0 ;
	end
	/******************************* WAY 1 *******************************/

	else if (temp_RD_EN && Valid_1[temp_Data_ADD[`INDEX]] && temp_Data_ADD[`TAG] == Tag_1[temp_Data_ADD[`INDEX]]) begin
		RD_Hit <= 1'b1 ;
		RD_DN <= 2'b00 ;
		B_OFFSET <= temp_Data_ADD[`OFFSET] ;

		case(temp_Data_ADD[`M_WORD])
		2'b00: O_Data <= cache_way_1[temp_Data_ADD[`INDEX]][31:0] ;
		2'b01: O_Data <= cache_way_1[temp_Data_ADD[`INDEX]][63:32];
		2'b10: O_Data <= cache_way_1[temp_Data_ADD[`INDEX]][95:64] ;
		2'b11: O_Data <= cache_way_1[temp_Data_ADD[`INDEX]][127:96] ;
		endcase

	end

	/******************************* WAY 2 *******************************/

	else if (temp_RD_EN && Valid_2[temp_Data_ADD[`INDEX]] && temp_Data_ADD[`TAG] == Tag_2[temp_Data_ADD[`INDEX]]) begin
		RD_Hit <= 1'b1 ;
		RD_DN <= 2'b01 ;
		B_OFFSET <= temp_Data_ADD[`OFFSET] ;

		case(temp_Data_ADD[`M_WORD])
		2'b00: O_Data <= cache_way_2[temp_Data_ADD[`INDEX]][31:0] ;
		2'b01: O_Data <= cache_way_2[temp_Data_ADD[`INDEX]][63:32] ;
		2'b10: O_Data <= cache_way_2[temp_Data_ADD[`INDEX]][95:64] ;
		2'b11: O_Data <= cache_way_2[temp_Data_ADD[`INDEX]][127:96] ;
		endcase

	end

	/******************************* WAY 3 *******************************/

	else if (temp_RD_EN && Valid_3[temp_Data_ADD[`INDEX]] && temp_Data_ADD[`TAG] == Tag_3[temp_Data_ADD[`INDEX]]) begin
		RD_Hit <= 1'b1 ;
		RD_DN <= 2'b10 ;
		B_OFFSET <= temp_Data_ADD[`OFFSET] ;

		case(temp_Data_ADD[`M_WORD])
		2'b00: O_Data <= cache_way_3[temp_Data_ADD[`INDEX]][31:0] ;
		2'b01: O_Data <= cache_way_3[temp_Data_ADD[`INDEX]][63:32] ;
		2'b10: O_Data <= cache_way_3[temp_Data_ADD[`INDEX]][95:64] ;
		2'b11: O_Data <= cache_way_3[temp_Data_ADD[`INDEX]][127:96] ;
		endcase

	end

	/******************************* WAY 4 *******************************/

	else if (temp_RD_EN && Valid_4[temp_Data_ADD[`INDEX]] && temp_Data_ADD[`TAG] == Tag_4[temp_Data_ADD[`INDEX]]) begin
		RD_Hit <= 1'b1 ;
		RD_DN <= 2'b11 ;
		B_OFFSET <= temp_Data_ADD[`OFFSET] ;

		case(temp_Data_ADD[`M_WORD])
		2'b00: O_Data <= cache_way_4[temp_Data_ADD[`INDEX]][31:0] ;
		2'b01: O_Data <= cache_way_4[temp_Data_ADD[`INDEX]][63:32] ;
		2'b10: O_Data <= cache_way_4[temp_Data_ADD[`INDEX]][95:64] ;
		2'b11: O_Data <= cache_way_4[temp_Data_ADD[`INDEX]][127:96] ;
		endcase

	end
	
end

/*******************************************************************
 WRITE THROUGH
*******************************************************************/

always @(posedge CLK or negedge RST) begin
	if (~RST) begin
		Write_ADD_MEM <= 'b0 ;
		Write_Data_MEM <= 'b0 ;
	end
	if (WR_EN && Write_ready_MEM) begin
		Write_ADD_MEM <= temp_Data_ADD ;
		Write_Data_MEM <= temp_Data_Wr ;
	end
	else if (RD_EN_MEM && Write_ready_MEM) begin
		Write_ADD_MEM <= temp_Data_ADD ;
	end
	else begin
		Write_ADD_MEM <= 'b0 ;
		Write_Data_MEM <= 'b0 ;
	end
end

/*******************************************************************
 TEMPORARY SAVE REGISTER (FLAG CONTROL)
*******************************************************************/

always @(posedge CLK or negedge RST) begin
	if (~RST) begin

		// ENABLE WRITE OR READ
		temp_WR_EN <= 1'b0 ;
		temp_RD_EN <= 1'b0 ;

		// Data & ADDRESS FROM CPU
		temp_Data_ADD <= 'b0 ;
		temp_Data_Wr <= 'b0 ;

		// WRITE BYTE OR HALF WORD SIGNAL FROM CONTROL UNIT
		temp_WR_Byte_CPU <= 1'b0 ;
		temp_WR_HWORD_CPU <= 1'b0 ;
		
		// READ OPREATION SIGNAL IS NOT COMPLET SEND TO CACHE CONTROL 
		RD_WAIT <= 1'b0 ;
	end

	else if (RD_EN) begin
		temp_RD_EN <= RD_EN ;
		temp_Data_ADD <= Data_ADD ;
		temp_Data_Wr <= Data_Wr ;
		RD_WAIT <= 1'b1 ;
	end

	else if (WR_EN) begin
		temp_WR_Byte_CPU <= WR_Byte_CPU ;
		temp_WR_HWORD_CPU <= WR_HWORD_CPU ;
		temp_WR_EN <= WR_EN ;
		temp_Data_ADD <= Data_ADD ;
		temp_Data_Wr <= Data_Wr ;
	end

	else if (WR_Hit && (~RD_EN || ~temp_RD_EN)) begin
		temp_WR_Byte_CPU <= 1'b0 ;
		temp_WR_HWORD_CPU <= 1'b0 ;
		temp_WR_EN <= 1'b0 ;
		temp_Data_ADD <= 'b0 ;
		temp_Data_Wr <= 'b0 ;
	end

	else if (RD_Hit) begin
		RD_Hit <= 1'b0 ;
		temp_RD_EN <= 1'b0 ;
		temp_Data_ADD <= 'b0 ;
		temp_Data_Wr <= 'b0 ;
		RD_WAIT <= 1'b0 ;	
	end
end


/*******************************************************************
 READ DATA FROM MEMORY
*******************************************************************/

always @(posedge CLK or negedge RST) begin
	if (~RST) begin
		RD_Hit <= 1'b0 ;
		WR_Hit <= 1'b0 ;
		RD_InValidate <= 1'b0 ;
	end
	else if (WR_Hit) begin
		WR_Hit <= 1'b0 ;
	end
end

assign miss_1 = (~Valid_1[Data_ADD[`INDEX]] || Data_ADD[`TAG] != Tag_1[Data_ADD[`INDEX]]) ? 1'b1:1'b0 ;
assign miss_2 = (~Valid_2[Data_ADD[`INDEX]] || Data_ADD[`TAG] != Tag_2[Data_ADD[`INDEX]]) ? 1'b1:1'b0 ;
assign miss_3 = (~Valid_3[Data_ADD[`INDEX]] || Data_ADD[`TAG] != Tag_3[Data_ADD[`INDEX]]) ? 1'b1:1'b0 ;
assign miss_4 = (~Valid_4[Data_ADD[`INDEX]] || Data_ADD[`TAG] != Tag_4[Data_ADD[`INDEX]]) ? 1'b1:1'b0 ;

always @(posedge CLK or negedge RST) begin
	if ((temp_RD_EN || RD_EN) && miss_1 && miss_2 && miss_3 && miss_4) begin
		RD_Hit <= 1'b0 ;
		RD_InValidate <= 1'b1 ;
	end
	else if ((temp_WR_EN || WR_EN) && miss_1 && miss_2 && miss_3 && miss_4) begin
		WR_Hit <= 1'b0 ;
	end
end

/*******************************************************************
  Least Recently Used (LRU)
*******************************************************************/

always @(posedge CLK or negedge RST) begin
	if (~RST) begin
		for (i = 0 ; i < Size_Block ; i = i + 1) begin
			LRU_1 [i] <= 'b00 ;
			LRU_2 [i] <= 'b01 ;
			LRU_3 [i] <= 'b10 ;
			LRU_4 [i] <= 'b11 ;
		end	
	end

	/*******************************************************************
  	  USED LRU IN WRITE
	*******************************************************************/



	/******************************* WAY 1 *******************************/

	else if (~WR_Hit && (temp_WR_EN || RD_InValidate) && RD_Valid_MEM && ~Valid_1[temp_Data_ADD[`INDEX]] && ~Valid_2[temp_Data_ADD[`INDEX]] && ~Valid_3[temp_Data_ADD[`INDEX]] && ~Valid_4[temp_Data_ADD[`INDEX]]) begin
		LRU_1 [temp_Data_ADD[`INDEX]] <= 'b11 ;
		LRU_2 [temp_Data_ADD[`INDEX]] <= 'b00 ;
		LRU_3 [temp_Data_ADD[`INDEX]] <= 'b01 ;
		LRU_4 [temp_Data_ADD[`INDEX]] <= 'b10 ;

		// THIS FOR OPREATION READ 
		RD_InValidate <= 1'b0 ;

		// CHANGE ONLY BYTE IN WORD
		if (temp_WR_Byte_CPU) begin
			case(temp_Data_ADD[`M_WORD])
			
			// CHANGE IN WORD 1
			2'b00: begin
				case(temp_Data_ADD[`OFFSET])
				2'b00: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:8] , temp_Data_Wr[7:0]} ;
				2'b01: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:16] , temp_Data_Wr[15:8] , Data_RD_MEM[7:0]} ;
				2'b10: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:24] , temp_Data_Wr[23:16] , Data_RD_MEM[15:0]} ;
				2'b11: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr[31:24] , Data_RD_MEM[23:0]} ;			
				endcase
			end

			// CHANGE IN WORD 2
			2'b01: begin
				case(temp_Data_ADD[`OFFSET])
				2'b00: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:40] , temp_Data_Wr[7:0] , Data_RD_MEM[31:0]} ;
				2'b01: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:48] , temp_Data_Wr[15:8] , Data_RD_MEM[39:0]} ;
				2'b10: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:56] , temp_Data_Wr[23:16] , Data_RD_MEM[47:0]} ;
				2'b11: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr[31:24] , Data_RD_MEM[55:0]} ;			
				endcase
			end

			// CHANGE IN WORD 3
			2'b10: begin
				case(temp_Data_ADD[`OFFSET])
				2'b00: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:72] , temp_Data_Wr[7:0] , Data_RD_MEM[63:0]} ;
				2'b01: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:80] , temp_Data_Wr[15:8] , Data_RD_MEM[71:0]} ;
				2'b10: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:88] , temp_Data_Wr[23:16] , Data_RD_MEM[79:0]} ;
				2'b11: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr[31:24] , Data_RD_MEM[87:0]} ;			
				endcase
			end

			// CHANGE IN WORD 4
			2'b11: begin
				case(temp_Data_ADD[`OFFSET])
				2'b00: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:104] , temp_Data_Wr[7:0] , Data_RD_MEM[95:0]} ;
				2'b01: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:112] , temp_Data_Wr[15:8] , Data_RD_MEM[103:0]} ;
				2'b10: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:120] , temp_Data_Wr[23:16] , Data_RD_MEM[111:0]} ;
				2'b11: cache_way_1[temp_Data_ADD[`INDEX]] <= {temp_Data_Wr[31:24] , Data_RD_MEM[119:0]} ;			
				endcase
			end	

		endcase	
		end

		// CHANGE ONLY HALF WORD
		else if (temp_WR_HWORD_CPU) begin

			case(temp_Data_ADD[`M_WORD])
			
			// CHANGE IN WORD 1
			2'b00: begin
				case(temp_Data_ADD[1])
				1'b0: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:8] , temp_Data_Wr[15:0]}  ;
				1'b1: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr[31:16] , Data_RD_MEM[15:0]} ;
				endcase
			end

			// CHANGE IN WORD 2
			2'b01: begin
				case(temp_Data_ADD[1])
				1'b0: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:48] , temp_Data_Wr[15:0] , Data_RD_MEM[31:0]} ;
				1'b1: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr[31:16] , Data_RD_MEM[47:0]} ;
				endcase
			end

			// CHANGE IN WORD 3
			2'b10: begin
				case(temp_Data_ADD[1])
				1'b0: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:80] , temp_Data_Wr[15:0] , Data_RD_MEM[63:0]} ;
				1'b1: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr[31:16] , Data_RD_MEM[79:0]} ;
				endcase
			end

			// CHANGE IN WORD 4
			2'b11: begin
				case(temp_Data_ADD[1])
				1'b0: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:112] , temp_Data_Wr[15:0] , Data_RD_MEM[95:0]} ;
				1'b1: cache_way_1[temp_Data_ADD[`INDEX]] <= {temp_Data_Wr[31:16] , Data_RD_MEM[111:0]} ;
				endcase
			end	

		endcase		
		end

		// CHANGE ALL WORD
		else begin
			case(temp_Data_ADD[`M_WORD])
			2'b00: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr} ;
			2'b01: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr , Data_RD_MEM[31:0]} ;
			2'b10: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr , Data_RD_MEM[63:0]} ;
			2'b11: cache_way_1[temp_Data_ADD[`INDEX]] <= {temp_Data_Wr , Data_RD_MEM[95:0]} ;
			endcase
		end

		Tag_1[temp_Data_ADD[`INDEX]] <= temp_Data_ADD[`TAG] ;
		Valid_1[temp_Data_ADD[`INDEX]] <= 1'b1 ;
		WR_Hit <= 1'b1 ;
	end



	/******************************* WAY 2 *******************************/

	else if (~WR_Hit && (temp_WR_EN || RD_InValidate) && RD_Valid_MEM && ~Valid_2[temp_Data_ADD[`INDEX]] && ~Valid_3[temp_Data_ADD[`INDEX]] && ~Valid_4[temp_Data_ADD[`INDEX]]) begin
		LRU_1 [temp_Data_ADD[`INDEX]] <= 'b10 ;
		LRU_2 [temp_Data_ADD[`INDEX]] <= 'b11 ;
		LRU_3 [temp_Data_ADD[`INDEX]] <= 'b00 ;
		LRU_4 [temp_Data_ADD[`INDEX]] <= 'b01 ;

		// THIS FOR OPREATION READ 
		RD_InValidate <= 1'b0 ;

		// CHANGE ONLY BYTE IN WORD
		if (temp_WR_Byte_CPU) begin
			case(temp_Data_ADD[`M_WORD])
			
			// CHANGE IN WORD 1
			2'b00: begin
				case(temp_Data_ADD[`OFFSET])
				2'b00: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:8] , temp_Data_Wr[7:0]} ;
				2'b01: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:16] , temp_Data_Wr[15:8] , Data_RD_MEM[7:0]} ;
				2'b10: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:24] , temp_Data_Wr[23:16] , Data_RD_MEM[15:0]} ;
				2'b11: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr[31:24] , Data_RD_MEM[23:0]} ;			
				endcase
			end

			// CHANGE IN WORD 2
			2'b01: begin
				case(temp_Data_ADD[`OFFSET])
				2'b00: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:40] , temp_Data_Wr[7:0] , Data_RD_MEM[31:0]} ;
				2'b01: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:48] , temp_Data_Wr[15:8] , Data_RD_MEM[39:0]} ;
				2'b10: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:56] , temp_Data_Wr[23:16] , Data_RD_MEM[47:0]} ;
				2'b11: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr[31:24] , Data_RD_MEM[55:0]} ;			
				endcase
			end

			// CHANGE IN WORD 3
			2'b10: begin
				case(temp_Data_ADD[`OFFSET])
				2'b00: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:72] , temp_Data_Wr[7:0] , Data_RD_MEM[63:0]} ;
				2'b01: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:80] , temp_Data_Wr[15:8] , Data_RD_MEM[71:0]} ;
				2'b10: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:88] , temp_Data_Wr[23:16] , Data_RD_MEM[79:0]} ;
				2'b11: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr[31:24] , Data_RD_MEM[87:0]} ;			
				endcase
			end

			// CHANGE IN WORD 4
			2'b11: begin
				case(temp_Data_ADD[`OFFSET])
				2'b00: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:104] , temp_Data_Wr[7:0] , Data_RD_MEM[95:0]} ;
				2'b01: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:112] , temp_Data_Wr[15:8] , Data_RD_MEM[103:0]} ;
				2'b10: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:120] , temp_Data_Wr[23:16] , Data_RD_MEM[111:0]} ;
				2'b11: cache_way_2[temp_Data_ADD[`INDEX]] <= {temp_Data_Wr[31:24] , Data_RD_MEM[119:0]} ;			
				endcase
			end		

		endcase
		end

		// CHANGE ONLY HALF WORD
		else if (temp_WR_HWORD_CPU) begin

			case(temp_Data_ADD[`M_WORD])
			
			// CHANGE IN WORD 1
			2'b00: begin
				case(temp_Data_ADD[1])
				1'b0: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:8] , temp_Data_Wr[15:0]}  ;
				1'b1: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr[31:16] , Data_RD_MEM[15:0]} ;
				endcase
			end

			// CHANGE IN WORD 2
			2'b01: begin
				case(temp_Data_ADD[1])
				1'b0: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:48] , temp_Data_Wr[15:0] , Data_RD_MEM[31:0]} ;
				1'b1: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr[31:16] , Data_RD_MEM[47:0]} ;
				endcase
			end

			// CHANGE IN WORD 3
			2'b10: begin
				case(temp_Data_ADD[1])
				1'b0: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:80] , temp_Data_Wr[15:0] , Data_RD_MEM[63:0]} ;
				1'b1: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr[31:16] , Data_RD_MEM[79:0]} ;
				endcase
			end

			// CHANGE IN WORD 4
			2'b11: begin
				case(temp_Data_ADD[1])
				1'b0: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:112] , temp_Data_Wr[15:0] , Data_RD_MEM[95:0]} ;
				1'b1: cache_way_2[temp_Data_ADD[`INDEX]] <= {temp_Data_Wr[31:16] , Data_RD_MEM[111:0]} ;
				endcase
			end		

		endcase	
		end

		// CHANGE ALL WORD
		else begin
			case(temp_Data_ADD[`M_WORD])
			2'b00: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr} ;
			2'b01: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr , Data_RD_MEM[31:0]} ;
			2'b10: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr , Data_RD_MEM[63:0]} ;
			2'b11: cache_way_2[temp_Data_ADD[`INDEX]] <= {temp_Data_Wr , Data_RD_MEM[95:0]} ;
			endcase
		end

		Tag_2[temp_Data_ADD[`INDEX]] <= temp_Data_ADD[`TAG] ;
		Valid_2[temp_Data_ADD[`INDEX]] <= 1'b1 ; 
		WR_Hit <= 1'b1 ;
	end



	/******************************* WAY 3 *******************************/

	else if (~WR_Hit && (temp_WR_EN || RD_InValidate) && RD_Valid_MEM && ~Valid_3[temp_Data_ADD[`INDEX]] && ~Valid_4[temp_Data_ADD[`INDEX]]) begin
		LRU_1 [temp_Data_ADD[`INDEX]] <= LRU_1 [temp_Data_ADD[`INDEX]] - 1 ;
		LRU_2 [temp_Data_ADD[`INDEX]] <= LRU_2 [temp_Data_ADD[`INDEX]] - 1 ;
		LRU_3 [temp_Data_ADD[`INDEX]] <= 'b11 ;
		LRU_4 [temp_Data_ADD[`INDEX]] <= 'b00 ;

		// THIS FOR OPREATION READ 
		RD_InValidate <= 1'b0 ;

		// CHANGE ONLY BYTE IN WORD
		if (temp_WR_Byte_CPU) begin
			case(temp_Data_ADD[`M_WORD])
			
			// CHANGE IN WORD 1
			2'b00: begin
				case(temp_Data_ADD[`OFFSET])
				2'b00: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:8] , temp_Data_Wr[7:0]} ;
				2'b01: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:16] , temp_Data_Wr[15:8] , Data_RD_MEM[7:0]} ;
				2'b10: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:24] , temp_Data_Wr[23:16] , Data_RD_MEM[15:0]} ;
				2'b11: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr[31:24] , Data_RD_MEM[23:0]} ;			
				endcase
			end

			// CHANGE IN WORD 2
			2'b01: begin
				case(temp_Data_ADD[`OFFSET])
				2'b00: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:40] , temp_Data_Wr[7:0] , Data_RD_MEM[31:0]} ;
				2'b01: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:48] , temp_Data_Wr[15:8] , Data_RD_MEM[39:0]} ;
				2'b10: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:56] , temp_Data_Wr[23:16] , Data_RD_MEM[47:0]} ;
				2'b11: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr[31:24] , Data_RD_MEM[55:0]} ;			
				endcase
			end

			// CHANGE IN WORD 3
			2'b10: begin
				case(temp_Data_ADD[`OFFSET])
				2'b00: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:72] , temp_Data_Wr[7:0] , Data_RD_MEM[63:0]} ;
				2'b01: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:80] , temp_Data_Wr[15:8] , Data_RD_MEM[71:0]} ;
				2'b10: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:88] , temp_Data_Wr[23:16] , Data_RD_MEM[79:0]} ;
				2'b11: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr[31:24] , Data_RD_MEM[87:0]} ;			
				endcase
			end

			// CHANGE IN WORD 4
			2'b11: begin
				case(temp_Data_ADD[`OFFSET])
				2'b00: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:104] , temp_Data_Wr[7:0] , Data_RD_MEM[95:0]} ;
				2'b01: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:112] , temp_Data_Wr[15:8] , Data_RD_MEM[103:0]} ;
				2'b10: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:120] , temp_Data_Wr[23:16] , Data_RD_MEM[111:0]} ;
				2'b11: cache_way_3[temp_Data_ADD[`INDEX]] <= {temp_Data_Wr[31:24] , Data_RD_MEM[119:0]} ;			
				endcase
			end		

		endcase	
		end

		// CHANGE ONLY HALF WORD
		else if (temp_WR_HWORD_CPU) begin

			case(temp_Data_ADD[`M_WORD])
			
			// CHANGE IN WORD 1
			2'b00: begin
				case(temp_Data_ADD[1])
				1'b0: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:8] , temp_Data_Wr[15:0]} ;
				1'b1: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr[31:16] , Data_RD_MEM[15:0]} ;
				endcase
			end

			// CHANGE IN WORD 2
			2'b01: begin
				case(temp_Data_ADD[1])
				1'b0: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:48] , temp_Data_Wr[15:0] , Data_RD_MEM[31:0]} ;
				1'b1: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr[31:16] , Data_RD_MEM[47:0]} ;
				endcase
			end

			// CHANGE IN WORD 3
			2'b10: begin
				case(temp_Data_ADD[1])
				1'b0: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:80] , temp_Data_Wr[15:0] , Data_RD_MEM[63:0]} ;
				1'b1: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr[31:16] , Data_RD_MEM[79:0]} ;
				endcase
			end

			// CHANGE IN WORD 4
			2'b11: begin
				case(temp_Data_ADD[1])
				1'b0: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:112] , temp_Data_Wr[15:0] , Data_RD_MEM[95:0]} ;
				1'b1: cache_way_3[temp_Data_ADD[`INDEX]] <= {temp_Data_Wr[31:16] , Data_RD_MEM[111:0]} ;
				endcase
			end	

		endcase		
		end

		// CHANGE ALL WORD
		else begin
			case(temp_Data_ADD[`M_WORD])
			2'b00: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr} ;
			2'b01: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr , Data_RD_MEM[31:0]} ;
			2'b10: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr , Data_RD_MEM[63:0]} ;
			2'b11: cache_way_3[temp_Data_ADD[`INDEX]] <= {temp_Data_Wr , Data_RD_MEM[95:0]} ;
			endcase
		end

		Tag_3[temp_Data_ADD[`INDEX]] <= temp_Data_ADD[`TAG] ;
		Valid_3[temp_Data_ADD[`INDEX]] <= 1'b1 ;
		WR_Hit <= 1'b1 ;
	end



	/******************************* WAY 4 *******************************/

	else if (~WR_Hit && (temp_WR_EN || RD_InValidate) && RD_Valid_MEM && ~Valid_4[temp_Data_ADD[`INDEX]]) begin
		LRU_1 [temp_Data_ADD[`INDEX]] <= LRU_1 [temp_Data_ADD[`INDEX]] - 1 ;
		LRU_2 [temp_Data_ADD[`INDEX]] <= LRU_2 [temp_Data_ADD[`INDEX]] - 1 ;
		LRU_3 [temp_Data_ADD[`INDEX]] <= LRU_3 [temp_Data_ADD[`INDEX]] - 1 ;
		LRU_4 [temp_Data_ADD[`INDEX]] <= 'b11 ;

		// THIS FOR OPREATION READ 
		RD_InValidate <= 1'b0 ;

		// CHANGE ONLY BYTE IN WORD
		if (temp_WR_Byte_CPU) begin
			case(temp_Data_ADD[`M_WORD])
			
			// CHANGE IN WORD 1
			2'b00: begin
				case(temp_Data_ADD[`OFFSET])
				2'b00: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:8] , temp_Data_Wr[7:0]} ;
				2'b01: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:16] , temp_Data_Wr[15:8] , Data_RD_MEM[7:0]} ;
				2'b10: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:24] , temp_Data_Wr[23:16] , Data_RD_MEM[15:0]} ;
				2'b11: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr[31:24] , Data_RD_MEM[23:0]} ;			
				endcase
			end

			// CHANGE IN WORD 2
			2'b01: begin
				case(temp_Data_ADD[`OFFSET])
				2'b00: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:40] , temp_Data_Wr[7:0] , Data_RD_MEM[31:0]} ;
				2'b01: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:48] , temp_Data_Wr[15:8] , Data_RD_MEM[39:0]} ;
				2'b10: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:56] , temp_Data_Wr[23:16] , Data_RD_MEM[47:0]} ;
				2'b11: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr[31:24] , Data_RD_MEM[55:0]} ;			
				endcase
			end

			// CHANGE IN WORD 3
			2'b10: begin
				case(temp_Data_ADD[`OFFSET])
				2'b00: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:72] , temp_Data_Wr[7:0] , Data_RD_MEM[63:0]} ;
				2'b01: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:80] , temp_Data_Wr[15:8] , Data_RD_MEM[71:0]} ;
				2'b10: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:88] , temp_Data_Wr[23:16] , Data_RD_MEM[79:0]} ;
				2'b11: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr[31:24] , Data_RD_MEM[87:0]} ;			
				endcase
			end

			// CHANGE IN WORD 4
			2'b11: begin
				case(temp_Data_ADD[`OFFSET])
				2'b00: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:104] , temp_Data_Wr[7:0] , Data_RD_MEM[95:0]} ;
				2'b01: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:112] , temp_Data_Wr[15:8] , Data_RD_MEM[103:0]} ;
				2'b10: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:120] , temp_Data_Wr[23:16] , Data_RD_MEM[111:0]} ;
				2'b11: cache_way_4[temp_Data_ADD[`INDEX]] <= {temp_Data_Wr[31:24] , Data_RD_MEM[119:0]} ;			
				endcase
			end		

		endcase	
		end

		// CHANGE ONLY HALF WORD
		else if (temp_WR_HWORD_CPU) begin

			case(temp_Data_ADD[`M_WORD])
			
			// CHANGE IN WORD 1
			2'b00: begin
				case(temp_Data_ADD[1])
				1'b0: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:8] , temp_Data_Wr[15:0]} ;
				1'b1: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr[31:16] , Data_RD_MEM[15:0]} ;
				endcase
			end

			// CHANGE IN WORD 2
			2'b01: begin
				case(temp_Data_ADD[1])
				1'b0: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:48] , temp_Data_Wr[15:0] , Data_RD_MEM[31:0]} ;
				1'b1: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr[31:16] , Data_RD_MEM[47:0]} ;
				endcase
			end

			// CHANGE IN WORD 3
			2'b10: begin
				case(temp_Data_ADD[1])
				1'b0: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:80] , temp_Data_Wr[15:0] , Data_RD_MEM[63:0]} ;
				1'b1: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr[31:16] , Data_RD_MEM[79:0]} ;
				endcase
			end

			// CHANGE IN WORD 4
			2'b11: begin
				case(temp_Data_ADD[1])
				1'b0: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:112] , temp_Data_Wr[15:0] , Data_RD_MEM[95:0]} ;
				1'b1: cache_way_4[temp_Data_ADD[`INDEX]] <= {temp_Data_Wr[31:16] , Data_RD_MEM[111:0]} ;
				endcase
			end	

		endcase		
		end

		// CHANGE ALL WORD
		else begin
			case(temp_Data_ADD[`M_WORD])
			2'b00: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr} ;
			2'b01: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr , Data_RD_MEM[31:0]} ;
			2'b10: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr , Data_RD_MEM[63:0]} ;
			2'b11: cache_way_4[temp_Data_ADD[`INDEX]] <= {temp_Data_Wr , Data_RD_MEM[95:0]} ;
			endcase
		end

		Tag_4[temp_Data_ADD[`INDEX]] <= temp_Data_ADD[`TAG] ;
		Valid_4[temp_Data_ADD[`INDEX]] <= 1'b1 ;
		WR_Hit <= 1'b1 ;
	end


/*******************************************************************
 ALL VALID IS ENABLE
*******************************************************************/


	/******************************* WAY 1 *******************************/

	else if (~WR_Hit && (temp_WR_EN || RD_InValidate) && RD_Valid_MEM) begin

		if (LRU_1 [temp_Data_ADD[`INDEX]] == 'b00) begin
			LRU_1 [temp_Data_ADD[`INDEX]] <= 'b11 ;
			LRU_2 [temp_Data_ADD[`INDEX]] <= LRU_2 [temp_Data_ADD[`INDEX]] - 1 ;
			LRU_3 [temp_Data_ADD[`INDEX]] <= LRU_3 [temp_Data_ADD[`INDEX]] - 1 ;
			LRU_4 [temp_Data_ADD[`INDEX]] <= LRU_4 [temp_Data_ADD[`INDEX]] - 1 ;
			
			// THIS FOR OPREATION READ 
			RD_InValidate <= 1'b0 ;

			// CHANGE ONLY BYTE IN WORD
			if (temp_WR_Byte_CPU) begin
				case(temp_Data_ADD[`M_WORD])
				
				// CHANGE IN WORD 1
				2'b00: begin
					case(temp_Data_ADD[`OFFSET])
					2'b00: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:8] , temp_Data_Wr[7:0]} ;
					2'b01: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:16] , temp_Data_Wr[15:8] , Data_RD_MEM[7:0]} ;
					2'b10: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:24] , temp_Data_Wr[23:16] , Data_RD_MEM[15:0]} ;
					2'b11: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr[31:24] , Data_RD_MEM[23:0]} ;			
					endcase
				end

				// CHANGE IN WORD 2
				2'b01: begin
					case(temp_Data_ADD[`OFFSET])
					2'b00: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:40] , temp_Data_Wr[7:0] , Data_RD_MEM[31:0]} ;
					2'b01: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:48] , temp_Data_Wr[15:8] , Data_RD_MEM[39:0]} ;
					2'b10: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:56] , temp_Data_Wr[23:16] , Data_RD_MEM[47:0]} ;
					2'b11: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr[31:24] , Data_RD_MEM[55:0]} ;			
					endcase
				end

				// CHANGE IN WORD 3
				2'b10: begin
					case(temp_Data_ADD[`OFFSET])
					2'b00: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:72] , temp_Data_Wr[7:0] , Data_RD_MEM[63:0]} ;
					2'b01: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:80] , temp_Data_Wr[15:8] , Data_RD_MEM[71:0]} ;
					2'b10: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:88] , temp_Data_Wr[23:16] , Data_RD_MEM[79:0]} ;
					2'b11: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr[31:24] , Data_RD_MEM[87:0]} ;			
					endcase
				end

				// CHANGE IN WORD 4
				2'b11: begin
					case(temp_Data_ADD[`OFFSET])
					2'b00: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:104] , temp_Data_Wr[7:0] , Data_RD_MEM[95:0]} ;
					2'b01: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:112] , temp_Data_Wr[15:8] , Data_RD_MEM[103:0]} ;
					2'b10: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:120] , temp_Data_Wr[23:16] , Data_RD_MEM[111:0]} ;
					2'b11: cache_way_1[temp_Data_ADD[`INDEX]] <= {temp_Data_Wr[31:24] , Data_RD_MEM[119:0]} ;			
					endcase
				end	

			endcase	
			end

			// CHANGE ONLY HALF WORD
			else if (temp_WR_HWORD_CPU) begin

				case(temp_Data_ADD[`M_WORD])
				
				// CHANGE IN WORD 1
				2'b00: begin
					case(temp_Data_ADD[1])
					1'b0: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:8] , temp_Data_Wr[15:0]}  ;
					1'b1: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr[31:16] , Data_RD_MEM[15:0]} ;
					endcase
				end

				// CHANGE IN WORD 2
				2'b01: begin
					case(temp_Data_ADD[1])
					1'b0: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:48] , temp_Data_Wr[15:0] , Data_RD_MEM[31:0]} ;
					1'b1: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr[31:16] , Data_RD_MEM[47:0]} ;
					endcase
				end

				// CHANGE IN WORD 3
				2'b10: begin
					case(temp_Data_ADD[1])
					1'b0: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:80] , temp_Data_Wr[15:0] , Data_RD_MEM[63:0]} ;
					1'b1: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr[31:16] , Data_RD_MEM[79:0]} ;
					endcase
				end

				// CHANGE IN WORD 4
				2'b11: begin
					case(temp_Data_ADD[1])
					1'b0: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:112] , temp_Data_Wr[15:0] , Data_RD_MEM[95:0]} ;
					1'b1: cache_way_1[temp_Data_ADD[`INDEX]] <= { temp_Data_Wr[31:16] , Data_RD_MEM[111:0]} ;
					endcase
				end	

			endcase		
			end

			// CHANGE ALL WORD
			else begin
				case(temp_Data_ADD[`M_WORD])
				2'b00: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr} ;
				2'b01: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr , Data_RD_MEM[31:0]} ;
				2'b10: cache_way_1[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr , Data_RD_MEM[63:0]} ;
				2'b11: cache_way_1[temp_Data_ADD[`INDEX]] <= {temp_Data_Wr , Data_RD_MEM[95:0]} ;
				endcase
			end

			Tag_1[temp_Data_ADD[`INDEX]] <= temp_Data_ADD[`TAG] ;
			Valid_1[temp_Data_ADD[`INDEX]] <= 1'b1 ;	
			WR_Hit <= 1'b1 ;
		end



		/******************************* WAY 2 *******************************/

		else if (LRU_2 [temp_Data_ADD[`INDEX]] == 'b00) begin
			LRU_1 [temp_Data_ADD[`INDEX]] <= LRU_1 [temp_Data_ADD[`INDEX]] - 1 ;
			LRU_2 [temp_Data_ADD[`INDEX]] <= 'b11 ;
			LRU_3 [temp_Data_ADD[`INDEX]] <= LRU_3 [temp_Data_ADD[`INDEX]] - 1 ;
			LRU_4 [temp_Data_ADD[`INDEX]] <= LRU_4 [temp_Data_ADD[`INDEX]] - 1 ;

			// THIS FOR OPREATION READ 
			RD_InValidate <= 1'b0 ;
			
			// CHANGE ONLY BYTE IN WORD
			if (temp_WR_Byte_CPU) begin
				case(temp_Data_ADD[`M_WORD])
				
				// CHANGE IN WORD 1
				2'b00: begin
					case(temp_Data_ADD[`OFFSET])
					2'b00: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:8] , temp_Data_Wr[7:0]} ;
					2'b01: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:16] , temp_Data_Wr[15:8] , Data_RD_MEM[7:0]} ;
					2'b10: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:24] , temp_Data_Wr[23:16] , Data_RD_MEM[15:0]} ;
					2'b11: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr[31:24] , Data_RD_MEM[23:0]} ;			
					endcase
				end

				// CHANGE IN WORD 2
				2'b01: begin
					case(temp_Data_ADD[`OFFSET])
					2'b00: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:40] , temp_Data_Wr[7:0] , Data_RD_MEM[31:0]} ;
					2'b01: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:48] , temp_Data_Wr[15:8] , Data_RD_MEM[39:0]} ;
					2'b10: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:56] , temp_Data_Wr[23:16] , Data_RD_MEM[47:0]} ;
					2'b11: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr[31:24] , Data_RD_MEM[55:0]} ;			
					endcase
				end

				// CHANGE IN WORD 3
				2'b10: begin
					case(temp_Data_ADD[`OFFSET])
					2'b00: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:72] , temp_Data_Wr[7:0] , Data_RD_MEM[63:0]} ;
					2'b01: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:80] , temp_Data_Wr[15:8] , Data_RD_MEM[71:0]} ;
					2'b10: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:88] , temp_Data_Wr[23:16] , Data_RD_MEM[79:0]} ;
					2'b11: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr[31:24] , Data_RD_MEM[87:0]} ;			
					endcase
				end

				// CHANGE IN WORD 4
				2'b11: begin
					case(temp_Data_ADD[`OFFSET])
					2'b00: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:104] , temp_Data_Wr[7:0] , Data_RD_MEM[95:0]} ;
					2'b01: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:112] , temp_Data_Wr[15:8] , Data_RD_MEM[103:0]} ;
					2'b10: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:120] , temp_Data_Wr[23:16] , Data_RD_MEM[111:0]} ;
					2'b11: cache_way_2[temp_Data_ADD[`INDEX]] <= {temp_Data_Wr[31:24] , Data_RD_MEM[119:0]} ;			
					endcase
				end		

			endcase
			end

			// CHANGE ONLY HALF WORD
			else if (temp_WR_HWORD_CPU) begin

				case(temp_Data_ADD[`M_WORD])
				
				// CHANGE IN WORD 1
				2'b00: begin
					case(temp_Data_ADD[1])
					1'b0: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:8] , temp_Data_Wr[15:0]}  ;
					1'b1: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr[31:16] , Data_RD_MEM[15:0]} ;
					endcase
				end

				// CHANGE IN WORD 2
				2'b01: begin
					case(temp_Data_ADD[1])
					1'b0: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:48] , temp_Data_Wr[15:0] , Data_RD_MEM[31:0]} ;
					1'b1: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr[31:16] , Data_RD_MEM[47:0]} ;
					endcase
				end

				// CHANGE IN WORD 3
				2'b10: begin
					case(temp_Data_ADD[1])
					1'b0: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:80] , temp_Data_Wr[15:0] , Data_RD_MEM[63:0]} ;
					1'b1: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr[31:16] , Data_RD_MEM[79:0]} ;
					endcase
				end

				// CHANGE IN WORD 4
				2'b11: begin
					case(temp_Data_ADD[1])
					1'b0: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:112] , temp_Data_Wr[15:0] , Data_RD_MEM[95:0]} ;
					1'b1: cache_way_2[temp_Data_ADD[`INDEX]] <= { temp_Data_Wr[31:16] , Data_RD_MEM[111:0]} ;
					endcase
				end		

			endcase	
			end

			// CHANGE ALL WORD
			else begin
				case(temp_Data_ADD[`M_WORD])
				2'b00: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr} ;
				2'b01: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr , Data_RD_MEM[31:0]} ;
				2'b10: cache_way_2[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr , Data_RD_MEM[63:0]} ;
				2'b11: cache_way_2[temp_Data_ADD[`INDEX]] <= {temp_Data_Wr , Data_RD_MEM[95:0]} ;
				endcase
			end

			Tag_2[temp_Data_ADD[`INDEX]] <= temp_Data_ADD[`TAG] ;
			Valid_2[temp_Data_ADD[`INDEX]] <= 1'b1 ;	
			WR_Hit <= 1'b1 ;
		end



		/******************************* WAY 3 *******************************/
	
		else if (LRU_3 [temp_Data_ADD[`INDEX]] == 'b00) begin
			LRU_1 [temp_Data_ADD[`INDEX]] <= LRU_1 [temp_Data_ADD[`INDEX]] - 1 ;
			LRU_2 [temp_Data_ADD[`INDEX]] <= LRU_2 [temp_Data_ADD[`INDEX]] - 1 ;
			LRU_3 [temp_Data_ADD[`INDEX]] <= 'b11 ;
			LRU_4 [temp_Data_ADD[`INDEX]] <= LRU_4 [temp_Data_ADD[`INDEX]] - 1 ;

			// THIS FOR OPREATION READ 
			RD_InValidate <= 1'b0 ;
			
			// CHANGE ONLY BYTE IN WORD
			if (temp_WR_Byte_CPU) begin
				case(temp_Data_ADD[`M_WORD])
				
				// CHANGE IN WORD 1
				2'b00: begin
					case(temp_Data_ADD[`OFFSET])
					2'b00: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:8] , temp_Data_Wr[7:0]} ;
					2'b01: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:16] , temp_Data_Wr[15:8] , Data_RD_MEM[7:0]} ;
					2'b10: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:24] , temp_Data_Wr[23:16] , Data_RD_MEM[15:0]} ;
					2'b11: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr[31:24] , Data_RD_MEM[23:0]} ;			
					endcase
				end

				// CHANGE IN WORD 2
				2'b01: begin
					case(temp_Data_ADD[`OFFSET])
					2'b00: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:40] , temp_Data_Wr[7:0] , Data_RD_MEM[31:0]} ;
					2'b01: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:48] , temp_Data_Wr[15:8] , Data_RD_MEM[39:0]} ;
					2'b10: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:56] , temp_Data_Wr[23:16] , Data_RD_MEM[47:0]} ;
					2'b11: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr[31:24] , Data_RD_MEM[55:0]} ;			
					endcase
				end

				// CHANGE IN WORD 3
				2'b10: begin
					case(temp_Data_ADD[`OFFSET])
					2'b00: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:72] , temp_Data_Wr[7:0] , Data_RD_MEM[63:0]} ;
					2'b01: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:80] , temp_Data_Wr[15:8] , Data_RD_MEM[71:0]} ;
					2'b10: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:88] , temp_Data_Wr[23:16] , Data_RD_MEM[79:0]} ;
					2'b11: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr[31:24] , Data_RD_MEM[87:0]} ;			
					endcase
				end

				// CHANGE IN WORD 4
				2'b11: begin
					case(temp_Data_ADD[`OFFSET])
					2'b00: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:104] , temp_Data_Wr[7:0] , Data_RD_MEM[95:0]} ;
					2'b01: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:112] , temp_Data_Wr[15:8] , Data_RD_MEM[103:0]} ;
					2'b10: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:120] , temp_Data_Wr[23:16] , Data_RD_MEM[111:0]} ;
					2'b11: cache_way_3[temp_Data_ADD[`INDEX]] <= {temp_Data_Wr[31:24] , Data_RD_MEM[119:0]} ;			
					endcase
				end		

			endcase	
			end

			// CHANGE ONLY HALF WORD
			else if (temp_WR_HWORD_CPU) begin

				case(temp_Data_ADD[`M_WORD])
				
				// CHANGE IN WORD 1
				2'b00: begin
					case(temp_Data_ADD[1])
					1'b0: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:8] , temp_Data_Wr[15:0]}  ;
					1'b1: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr[31:16] , Data_RD_MEM[15:0]} ;
					endcase
				end

				// CHANGE IN WORD 2
				2'b01: begin
					case(temp_Data_ADD[1])
					1'b0: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:48] , temp_Data_Wr[15:0] , Data_RD_MEM[31:0]} ;
					1'b1: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr[31:16] , Data_RD_MEM[47:0]} ;
					endcase
				end

				// CHANGE IN WORD 3
				2'b10: begin
					case(temp_Data_ADD[1])
					1'b0: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:80] , temp_Data_Wr[15:0] , Data_RD_MEM[63:0]} ;
					1'b1: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr[31:16] , Data_RD_MEM[79:0]} ;
					endcase
				end

				// CHANGE IN WORD 4
				2'b11: begin
					case(temp_Data_ADD[1])
					1'b0: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:112] , temp_Data_Wr[15:0] , Data_RD_MEM[95:0]} ;
					1'b1: cache_way_3[temp_Data_ADD[`INDEX]] <= { temp_Data_Wr[31:16] , Data_RD_MEM[111:0]} ;
					endcase
				end	

			endcase		
			end

			// CHANGE ALL WORD
			else begin
				case(temp_Data_ADD[`M_WORD])
				2'b00: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr} ;
				2'b01: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr , Data_RD_MEM[31:0]} ;
				2'b10: cache_way_3[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr , Data_RD_MEM[63:0]} ;
				2'b11: cache_way_3[temp_Data_ADD[`INDEX]] <= {temp_Data_Wr , Data_RD_MEM[95:0]} ;
				endcase
			end

			Tag_3[temp_Data_ADD[`INDEX]] <= temp_Data_ADD[`TAG] ;
			Valid_3[temp_Data_ADD[`INDEX]] <= 1'b1 ;	
			WR_Hit <= 1'b1 ;
		end



		/******************************* WAY 4 *******************************/

		else if (LRU_4 [temp_Data_ADD[`INDEX]] == 'b00) begin
			LRU_1 [temp_Data_ADD[`INDEX]] <= LRU_1 [temp_Data_ADD[`INDEX]] - 1 ;
			LRU_2 [temp_Data_ADD[`INDEX]] <= LRU_2 [temp_Data_ADD[`INDEX]] - 1 ;
			LRU_3 [temp_Data_ADD[`INDEX]] <= LRU_3 [temp_Data_ADD[`INDEX]] - 1 ;
			LRU_4 [temp_Data_ADD[`INDEX]] <= 'b11 ;

			// THIS FOR OPREATION READ 
			RD_InValidate <= 1'b0 ;
			
			// CHANGE ONLY BYTE IN WORD
			if (temp_WR_Byte_CPU) begin
				case(temp_Data_ADD[`M_WORD])
				
				// CHANGE IN WORD 1
				2'b00: begin
					case(temp_Data_ADD[`OFFSET])
					2'b00: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:8] , temp_Data_Wr[7:0]} ;
					2'b01: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:16] , temp_Data_Wr[15:8] , Data_RD_MEM[7:0]} ;
					2'b10: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:24] , temp_Data_Wr[23:16] , Data_RD_MEM[15:0]} ;
					2'b11: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr[31:24] , Data_RD_MEM[23:0]} ;			
					endcase
				end

				// CHANGE IN WORD 2
				2'b01: begin
					case(temp_Data_ADD[`OFFSET])
					2'b00: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:40] , temp_Data_Wr[7:0] , Data_RD_MEM[31:0]} ;
					2'b01: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:48] , temp_Data_Wr[15:8] , Data_RD_MEM[39:0]} ;
					2'b10: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:56] , temp_Data_Wr[23:16] , Data_RD_MEM[47:0]} ;
					2'b11: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr[31:24] , Data_RD_MEM[55:0]} ;			
					endcase
				end

				// CHANGE IN WORD 3
				2'b10: begin
					case(temp_Data_ADD[`OFFSET])
					2'b00: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:72] , temp_Data_Wr[7:0] , Data_RD_MEM[63:0]} ;
					2'b01: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:80] , temp_Data_Wr[15:8] , Data_RD_MEM[71:0]} ;
					2'b10: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:88] , temp_Data_Wr[23:16] , Data_RD_MEM[79:0]} ;
					2'b11: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr[31:24] , Data_RD_MEM[87:0]} ;			
					endcase
				end

				// CHANGE IN WORD 4
				2'b11: begin
					case(temp_Data_ADD[`OFFSET])
					2'b00: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:104] , temp_Data_Wr[7:0] , Data_RD_MEM[95:0]} ;
					2'b01: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:112] , temp_Data_Wr[15:8] , Data_RD_MEM[103:0]} ;
					2'b10: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:120] , temp_Data_Wr[23:16] , Data_RD_MEM[111:0]} ;
					2'b11: cache_way_4[temp_Data_ADD[`INDEX]] <= {temp_Data_Wr[31:24] , Data_RD_MEM[119:0]} ;			
					endcase
				end		

			endcase	
			end

			// CHANGE ONLY HALF WORD
			else if (temp_WR_HWORD_CPU) begin

				case(temp_Data_ADD[`M_WORD])
				
				// CHANGE IN WORD 1
				2'b00: begin
					case(temp_Data_ADD[1])
					1'b0: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:8] , temp_Data_Wr[15:0]}  ;
					1'b1: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr[31:16] , Data_RD_MEM[15:0]} ;
					endcase
				end

				// CHANGE IN WORD 2
				2'b01: begin
					case(temp_Data_ADD[1])
					1'b0: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:48] , temp_Data_Wr[15:0] , Data_RD_MEM[31:0]} ;
					1'b1: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr[31:16] , Data_RD_MEM[47:0]} ;
					endcase
				end

				// CHANGE IN WORD 3
				2'b10: begin
					case(temp_Data_ADD[1])
					1'b0: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:80] , temp_Data_Wr[15:0] , Data_RD_MEM[63:0]} ;
					1'b1: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr[31:16] , Data_RD_MEM[79:0]} ;
					endcase
				end

				// CHANGE IN WORD 4
				2'b11: begin
					case(temp_Data_ADD[1])
					1'b0: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:112] , temp_Data_Wr[15:0] , Data_RD_MEM[95:0]} ;
					1'b1: cache_way_4[temp_Data_ADD[`INDEX]] <= { temp_Data_Wr[31:16] , Data_RD_MEM[111:0]} ;
					endcase
				end	

			endcase		
			end

			// CHANGE ALL WORD
			else begin
				case(temp_Data_ADD[`M_WORD])
				2'b00: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:32] , temp_Data_Wr} ;
				2'b01: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:64] , temp_Data_Wr , Data_RD_MEM[31:0]} ;
				2'b10: cache_way_4[temp_Data_ADD[`INDEX]] <= {Data_RD_MEM[127:96] , temp_Data_Wr , Data_RD_MEM[63:0]} ;
				2'b11: cache_way_4[temp_Data_ADD[`INDEX]] <= {temp_Data_Wr , Data_RD_MEM[95:0]} ;
				endcase
			end

			Tag_4[temp_Data_ADD[`INDEX]] <= temp_Data_ADD[`TAG] ;
			Valid_4[temp_Data_ADD[`INDEX]] <= 1'b1 ;	
			WR_Hit <= 1'b1 ;
		end
	end

	/*******************************************************************
  	  USED LRU IN READ
	*******************************************************************/



	/*******************************************************************
  	  READ (HIT)
	*******************************************************************/

	else if (RD_EN && RD_Hit) begin
		
		case(RD_DN)


		/******************************* WAY 1 *******************************/

		2'b00: begin
			if (Valid_1[Data_ADD[`INDEX]] && ~Valid_2[Data_ADD[`INDEX]] && ~Valid_3[Data_ADD[`INDEX]] && ~Valid_4[Data_ADD[`INDEX]]) begin
				LRU_1 [Data_ADD[`INDEX]] <= 'b11 ;
				LRU_2 [Data_ADD[`INDEX]] <= 'b00 ;
				LRU_3 [Data_ADD[`INDEX]] <= 'b01 ;
				LRU_4 [Data_ADD[`INDEX]] <= 'b10 ;
			end

			else if ((LRU_1 [Data_ADD[`INDEX]] != 'b11) && Valid_1[Data_ADD[`INDEX]] && Valid_2[Data_ADD[`INDEX]] && ~Valid_3[Data_ADD[`INDEX]] && ~Valid_4[Data_ADD[`INDEX]]) begin
				LRU_1 [Data_ADD[`INDEX]] <= 'b11 ;
				LRU_2 [Data_ADD[`INDEX]] <= 'b10 ;
				LRU_3 [Data_ADD[`INDEX]] <= 'b00 ;
				LRU_4 [Data_ADD[`INDEX]] <= 'b01 ;
			end
			
			else if ((LRU_1 [Data_ADD[`INDEX]] != 'b11) && Valid_1[Data_ADD[`INDEX]] && Valid_2[Data_ADD[`INDEX]] && Valid_3[Data_ADD[`INDEX]] && ~Valid_4[Data_ADD[`INDEX]]) begin
				LRU_1 [Data_ADD[`INDEX]] <= 'b11 ;
				LRU_2 [Data_ADD[`INDEX]] <= LRU_2 [Data_ADD[`INDEX]] - 1 ;
				LRU_3 [Data_ADD[`INDEX]] <= LRU_3 [Data_ADD[`INDEX]] - 1 ;
				LRU_4 [Data_ADD[`INDEX]] <= 'b00 ;
			end

			else if (LRU_1 [Data_ADD[`INDEX]] == 'b00) begin
				LRU_1 [Data_ADD[`INDEX]] <= 'b11 ;
				LRU_2 [Data_ADD[`INDEX]] <= LRU_2 [Data_ADD[`INDEX]] - 1 ;
				LRU_3 [Data_ADD[`INDEX]] <= LRU_3 [Data_ADD[`INDEX]] - 1 ;
				LRU_4 [Data_ADD[`INDEX]] <= LRU_4 [Data_ADD[`INDEX]] - 1 ;
			end
		
			else if ((LRU_1 [Data_ADD[`INDEX]] != 'b11) && (LRU_2 [Data_ADD[`INDEX]] == 'b00)) begin
				LRU_1 [Data_ADD[`INDEX]] <= 'b11 ;
				LRU_3 [Data_ADD[`INDEX]] <= LRU_3 [Data_ADD[`INDEX]] - 1 ;
				LRU_4 [Data_ADD[`INDEX]] <= LRU_4 [Data_ADD[`INDEX]] - 1 ;
			end
		
			else if ((LRU_1 [Data_ADD[`INDEX]] != 'b11) && (LRU_3 [Data_ADD[`INDEX]] == 'b00)) begin
				LRU_1 [Data_ADD[`INDEX]] <= 'b11 ;
				LRU_2 [Data_ADD[`INDEX]] <= LRU_2 [Data_ADD[`INDEX]] - 1 ;
				LRU_4 [Data_ADD[`INDEX]] <= LRU_4 [Data_ADD[`INDEX]] - 1 ;
			end
		
			else if ((LRU_1 [Data_ADD[`INDEX]] != 'b11) && (LRU_4 [Data_ADD[`INDEX]] == 'b00)) begin
				LRU_1 [Data_ADD[`INDEX]] <= 'b11 ;
				LRU_2 [Data_ADD[`INDEX]] <= LRU_2 [Data_ADD[`INDEX]] - 1 ;
				LRU_3 [Data_ADD[`INDEX]] <= LRU_3 [Data_ADD[`INDEX]] - 1 ;
			end
		end



		/******************************* WAY 2 *******************************/

		2'b01: begin
			if ((LRU_2 [Data_ADD[`INDEX]] != 'b11) && Valid_1[Data_ADD[`INDEX]] && Valid_2[Data_ADD[`INDEX]] && ~Valid_3[Data_ADD[`INDEX]] && ~Valid_4[Data_ADD[`INDEX]]) begin
				LRU_1 [Data_ADD[`INDEX]] <= 'b10 ;
				LRU_2 [Data_ADD[`INDEX]] <= 'b11 ;
				LRU_3 [Data_ADD[`INDEX]] <= 'b00 ;
				LRU_4 [Data_ADD[`INDEX]] <= 'b01 ;
			end
			
			else if ((LRU_2 [Data_ADD[`INDEX]] != 'b11) && Valid_1[Data_ADD[`INDEX]] && Valid_2[Data_ADD[`INDEX]] && Valid_3[Data_ADD[`INDEX]] && ~Valid_4[Data_ADD[`INDEX]]) begin
				LRU_1 [Data_ADD[`INDEX]] <= LRU_1 [Data_ADD[`INDEX]] - 1 ;
				LRU_2 [Data_ADD[`INDEX]] <= 'b11 ;
				LRU_3 [Data_ADD[`INDEX]] <= LRU_3 [Data_ADD[`INDEX]] - 1 ;
				LRU_4 [Data_ADD[`INDEX]] <= 'b00 ;
			end

			else if (LRU_2 [Data_ADD[`INDEX]] == 'b00) begin
				LRU_1 [Data_ADD[`INDEX]] <= LRU_1 [Data_ADD[`INDEX]] - 1 ;
				LRU_2 [Data_ADD[`INDEX]] <= 'b11 ;
				LRU_3 [Data_ADD[`INDEX]] <= LRU_3 [Data_ADD[`INDEX]] - 1 ;
				LRU_4 [Data_ADD[`INDEX]] <= LRU_4 [Data_ADD[`INDEX]] - 1 ;
			end

			else if ((LRU_2 [Data_ADD[`INDEX]] != 'b11) && (LRU_1 [Data_ADD[`INDEX]] == 'b00)) begin
				LRU_2 [Data_ADD[`INDEX]] <= 'b11 ;
				LRU_3 [Data_ADD[`INDEX]] <= LRU_3 [Data_ADD[`INDEX]] - 1 ;
				LRU_4 [Data_ADD[`INDEX]] <= LRU_4 [Data_ADD[`INDEX]] - 1 ;
			end
		
			else if ((LRU_2 [Data_ADD[`INDEX]] != 'b11) && (LRU_3 [Data_ADD[`INDEX]] == 'b00)) begin
				LRU_1 [Data_ADD[`INDEX]] <= LRU_1 [Data_ADD[`INDEX]] - 1 ;
				LRU_2 [Data_ADD[`INDEX]] <= 'b11 ;
				LRU_4 [Data_ADD[`INDEX]] <= LRU_4 [Data_ADD[`INDEX]] - 1 ;
			end
			
			else if ((LRU_2 [Data_ADD[`INDEX]] != 'b11) && (LRU_4 [Data_ADD[`INDEX]] == 'b00)) begin
				LRU_1 [Data_ADD[`INDEX]] <= LRU_1 [Data_ADD[`INDEX]] - 1 ;
				LRU_2 [Data_ADD[`INDEX]] <= 'b11 ;
				LRU_3 [Data_ADD[`INDEX]] <= LRU_3 [Data_ADD[`INDEX]] - 1 ;
			end
		end



		/******************************* WAY 3 *******************************/

		2'b10: begin
			if ((LRU_3 [Data_ADD[`INDEX]] != 'b11) && Valid_1[Data_ADD[`INDEX]] && Valid_2[Data_ADD[`INDEX]] && Valid_3[Data_ADD[`INDEX]] && ~Valid_4[Data_ADD[`INDEX]]) begin
				LRU_1 [Data_ADD[`INDEX]] <= LRU_1 [Data_ADD[`INDEX]] - 1 ;
				LRU_2 [Data_ADD[`INDEX]] <= LRU_2 [Data_ADD[`INDEX]] - 1 ;
				LRU_3 [Data_ADD[`INDEX]] <= 'b11 ;
				LRU_4 [Data_ADD[`INDEX]] <= 'b00 ;
			end

			else if (LRU_3 [Data_ADD[`INDEX]] == 'b00) begin
				LRU_1 [Data_ADD[`INDEX]] <= LRU_1 [Data_ADD[`INDEX]] - 1 ;
				LRU_2 [Data_ADD[`INDEX]] <= LRU_2 [Data_ADD[`INDEX]] - 1 ;
				LRU_3 [Data_ADD[`INDEX]] <= 'b11 ;
				LRU_4 [Data_ADD[`INDEX]] <= LRU_4 [Data_ADD[`INDEX]] - 1 ;
			end

			else if ((LRU_3 [Data_ADD[`INDEX]] != 'b11) && (LRU_1 [Data_ADD[`INDEX]] == 'b00)) begin
				LRU_2 [Data_ADD[`INDEX]] <= LRU_2 [Data_ADD[`INDEX]] - 1 ;
				LRU_3 [Data_ADD[`INDEX]] <= 'b11 ;
				LRU_4 [Data_ADD[`INDEX]] <= LRU_4 [Data_ADD[`INDEX]] - 1 ;
			end
			
			else if ((LRU_3 [Data_ADD[`INDEX]] != 'b11) && (LRU_2 [Data_ADD[`INDEX]] == 'b00)) begin
				LRU_1 [Data_ADD[`INDEX]] <= LRU_1 [Data_ADD[`INDEX]] - 1 ;
				LRU_3 [Data_ADD[`INDEX]] <= 'b11 ;
				LRU_4 [Data_ADD[`INDEX]] <= LRU_4 [Data_ADD[`INDEX]] - 1 ;
			end
			
			else if ((LRU_3 [Data_ADD[`INDEX]] != 'b11) && (LRU_4 [Data_ADD[`INDEX]] == 'b00)) begin
				LRU_1 [Data_ADD[`INDEX]] <= LRU_1 [Data_ADD[`INDEX]] - 1 ;
				LRU_2 [Data_ADD[`INDEX]] <= LRU_2 [Data_ADD[`INDEX]] - 1 ;
				LRU_3 [Data_ADD[`INDEX]] <= 'b11 ;
			end
		end



		/******************************* WAY 4 *******************************/

		2'b11: begin
			if (LRU_4 [Data_ADD[`INDEX]] == 'b00) begin
				LRU_1 [Data_ADD[`INDEX]] <= LRU_1 [Data_ADD[`INDEX]] - 1 ;
				LRU_2 [Data_ADD[`INDEX]] <= LRU_2 [Data_ADD[`INDEX]] - 1 ;
				LRU_3 [Data_ADD[`INDEX]] <= LRU_3 [Data_ADD[`INDEX]] - 1 ;
				LRU_4 [Data_ADD[`INDEX]] <= 'b11 ;
			end

			else if ((LRU_4 [Data_ADD[`INDEX]] != 'b11) && (LRU_1 [Data_ADD[`INDEX]] == 'b00)) begin
				LRU_2 [Data_ADD[`INDEX]] <= LRU_2 [Data_ADD[`INDEX]] - 1 ;
				LRU_3 [Data_ADD[`INDEX]] <= LRU_3 [Data_ADD[`INDEX]] - 1 ;
				LRU_4 [Data_ADD[`INDEX]] <= 'b11 ;
			end
		
			else if ((LRU_4 [Data_ADD[`INDEX]] != 'b11) && (LRU_2 [Data_ADD[`INDEX]] == 'b00)) begin
				LRU_1 [Data_ADD[`INDEX]] <= LRU_1 [Data_ADD[`INDEX]] - 1 ;
				LRU_3 [Data_ADD[`INDEX]] <= LRU_3 [Data_ADD[`INDEX]] - 1 ;
				LRU_4 [Data_ADD[`INDEX]] <= 'b11 ;
			end
		
			else if ((LRU_4 [Data_ADD[`INDEX]] != 'b11) && (LRU_3 [Data_ADD[`INDEX]] == 'b00)) begin
				LRU_1 [Data_ADD[`INDEX]] <= LRU_1 [Data_ADD[`INDEX]] - 1 ;
				LRU_2 [Data_ADD[`INDEX]] <= LRU_2 [Data_ADD[`INDEX]] - 1 ;
				LRU_4 [Data_ADD[`INDEX]] <= 'b11 ;
			end
		end

		endcase
		RD_DN <= 2'b00 ;
	end




	/*******************************************************************
  	  READ (MISS)
	*******************************************************************/

	else if (temp_RD_EN && RD_Hit) begin
		
		case(RD_DN)


		/******************************* WAY 1 *******************************/

		2'b00: begin
			if (Valid_1[temp_Data_ADD[`INDEX]] && ~Valid_2[temp_Data_ADD[`INDEX]] && ~Valid_3[temp_Data_ADD[`INDEX]] && ~Valid_4[temp_Data_ADD[`INDEX]]) begin
				LRU_1 [temp_Data_ADD[`INDEX]] <= 'b11 ;
				LRU_2 [temp_Data_ADD[`INDEX]] <= 'b00 ;
				LRU_3 [temp_Data_ADD[`INDEX]] <= 'b01 ;
				LRU_4 [temp_Data_ADD[`INDEX]] <= 'b10 ;
			end

			else if ((LRU_1 [temp_Data_ADD[`INDEX]] != 'b11) && Valid_1[temp_Data_ADD[`INDEX]] && Valid_2[temp_Data_ADD[`INDEX]] && ~Valid_3[temp_Data_ADD[`INDEX]] && ~Valid_4[temp_Data_ADD[`INDEX]]) begin
				LRU_1 [temp_Data_ADD[`INDEX]] <= 'b11 ;
				LRU_2 [temp_Data_ADD[`INDEX]] <= 'b10 ;
				LRU_3 [temp_Data_ADD[`INDEX]] <= 'b00 ;
				LRU_4 [temp_Data_ADD[`INDEX]] <= 'b01 ;
			end
			
			else if ((LRU_1 [temp_Data_ADD[`INDEX]] != 'b11) && Valid_1[temp_Data_ADD[`INDEX]] && Valid_2[temp_Data_ADD[`INDEX]] && Valid_3[temp_Data_ADD[`INDEX]] && ~Valid_4[temp_Data_ADD[`INDEX]]) begin
				LRU_1 [temp_Data_ADD[`INDEX]] <= 'b11 ;
				LRU_2 [temp_Data_ADD[`INDEX]] <= LRU_2 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_3 [temp_Data_ADD[`INDEX]] <= LRU_3 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_4 [temp_Data_ADD[`INDEX]] <= 'b00 ;
			end

			else if (LRU_1 [temp_Data_ADD[`INDEX]] == 'b00) begin
				LRU_1 [temp_Data_ADD[`INDEX]] <= 'b11 ;
				LRU_2 [temp_Data_ADD[`INDEX]] <= LRU_2 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_3 [temp_Data_ADD[`INDEX]] <= LRU_3 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_4 [temp_Data_ADD[`INDEX]] <= LRU_4 [temp_Data_ADD[`INDEX]] - 1 ;
			end
		
			else if ((LRU_1 [temp_Data_ADD[`INDEX]] != 'b11) && (LRU_2 [temp_Data_ADD[`INDEX]] == 'b00)) begin
				LRU_1 [temp_Data_ADD[`INDEX]] <= 'b11 ;
				LRU_3 [temp_Data_ADD[`INDEX]] <= LRU_3 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_4 [temp_Data_ADD[`INDEX]] <= LRU_4 [temp_Data_ADD[`INDEX]] - 1 ;
			end
		
			else if ((LRU_1 [temp_Data_ADD[`INDEX]] != 'b11) && (LRU_3 [temp_Data_ADD[`INDEX]] == 'b00)) begin
				LRU_1 [temp_Data_ADD[`INDEX]] <= 'b11 ;
				LRU_2 [temp_Data_ADD[`INDEX]] <= LRU_2 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_4 [temp_Data_ADD[`INDEX]] <= LRU_4 [temp_Data_ADD[`INDEX]] - 1 ;
			end
		
			else if ((LRU_1 [temp_Data_ADD[`INDEX]] != 'b11) && (LRU_4 [temp_Data_ADD[`INDEX]] == 'b00)) begin
				LRU_1 [temp_Data_ADD[`INDEX]] <= 'b11 ;
				LRU_2 [temp_Data_ADD[`INDEX]] <= LRU_2 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_3 [temp_Data_ADD[`INDEX]] <= LRU_3 [temp_Data_ADD[`INDEX]] - 1 ;
			end
		end



		/******************************* WAY 2 *******************************/

		2'b01: begin
			if ((LRU_2 [temp_Data_ADD[`INDEX]] != 'b11) && Valid_1[temp_Data_ADD[`INDEX]] && Valid_2[temp_Data_ADD[`INDEX]] && ~Valid_3[temp_Data_ADD[`INDEX]] && ~Valid_4[temp_Data_ADD[`INDEX]]) begin
				LRU_1 [temp_Data_ADD[`INDEX]] <= 'b10 ;
				LRU_2 [temp_Data_ADD[`INDEX]] <= 'b11 ;
				LRU_3 [temp_Data_ADD[`INDEX]] <= 'b00 ;
				LRU_4 [temp_Data_ADD[`INDEX]] <= 'b01 ;
			end
			
			else if ((LRU_2 [temp_Data_ADD[`INDEX]] != 'b11) && Valid_1[temp_Data_ADD[`INDEX]] && Valid_2[temp_Data_ADD[`INDEX]] && Valid_3[temp_Data_ADD[`INDEX]] && ~Valid_4[temp_Data_ADD[`INDEX]]) begin
				LRU_1 [temp_Data_ADD[`INDEX]] <= LRU_1 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_2 [temp_Data_ADD[`INDEX]] <= 'b11 ;
				LRU_3 [temp_Data_ADD[`INDEX]] <= LRU_3 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_4 [temp_Data_ADD[`INDEX]] <= 'b00 ;
			end

			else if (LRU_2 [temp_Data_ADD[`INDEX]] == 'b00) begin
				LRU_1 [temp_Data_ADD[`INDEX]] <= LRU_1 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_2 [temp_Data_ADD[`INDEX]] <= 'b11 ;
				LRU_3 [temp_Data_ADD[`INDEX]] <= LRU_3 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_4 [temp_Data_ADD[`INDEX]] <= LRU_4 [temp_Data_ADD[`INDEX]] - 1 ;
			end

			else if ((LRU_2 [temp_Data_ADD[`INDEX]] != 'b11) && (LRU_1 [temp_Data_ADD[`INDEX]] == 'b00)) begin
				LRU_2 [temp_Data_ADD[`INDEX]] <= 'b11 ;
				LRU_3 [temp_Data_ADD[`INDEX]] <= LRU_3 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_4 [temp_Data_ADD[`INDEX]] <= LRU_4 [temp_Data_ADD[`INDEX]] - 1 ;
			end
		
			else if ((LRU_2 [temp_Data_ADD[`INDEX]] != 'b11) && (LRU_3 [temp_Data_ADD[`INDEX]] == 'b00)) begin
				LRU_1 [temp_Data_ADD[`INDEX]] <= LRU_1 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_2 [temp_Data_ADD[`INDEX]] <= 'b11 ;
				LRU_4 [temp_Data_ADD[`INDEX]] <= LRU_4 [temp_Data_ADD[`INDEX]] - 1 ;
			end
			
			else if ((LRU_2 [temp_Data_ADD[`INDEX]] != 'b11) && (LRU_4 [temp_Data_ADD[`INDEX]] == 'b00)) begin
				LRU_1 [temp_Data_ADD[`INDEX]] <= LRU_1 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_2 [temp_Data_ADD[`INDEX]] <= 'b11 ;
				LRU_3 [temp_Data_ADD[`INDEX]] <= LRU_3 [temp_Data_ADD[`INDEX]] - 1 ;
			end
		end



		/******************************* WAY 3 *******************************/

		2'b10: begin
			if ((LRU_3 [temp_Data_ADD[`INDEX]] != 'b11) && Valid_1[temp_Data_ADD[`INDEX]] && Valid_2[temp_Data_ADD[`INDEX]] && Valid_3[temp_Data_ADD[`INDEX]] && ~Valid_4[temp_Data_ADD[`INDEX]]) begin
				LRU_1 [temp_Data_ADD[`INDEX]] <= LRU_1 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_2 [temp_Data_ADD[`INDEX]] <= LRU_2 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_3 [temp_Data_ADD[`INDEX]] <= 'b11 ;
				LRU_4 [temp_Data_ADD[`INDEX]] <= 'b00 ;
			end

			else if (LRU_3 [temp_Data_ADD[`INDEX]] == 'b00) begin
				LRU_1 [temp_Data_ADD[`INDEX]] <= LRU_1 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_2 [temp_Data_ADD[`INDEX]] <= LRU_2 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_3 [temp_Data_ADD[`INDEX]] <= 'b11 ;
				LRU_4 [temp_Data_ADD[`INDEX]] <= LRU_4 [temp_Data_ADD[`INDEX]] - 1 ;
			end

			else if ((LRU_3 [temp_Data_ADD[`INDEX]] != 'b11) && (LRU_1 [temp_Data_ADD[`INDEX]] == 'b00)) begin
				LRU_2 [temp_Data_ADD[`INDEX]] <= LRU_2 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_3 [temp_Data_ADD[`INDEX]] <= 'b11 ;
				LRU_4 [temp_Data_ADD[`INDEX]] <= LRU_4 [temp_Data_ADD[`INDEX]] - 1 ;
			end
			
			else if ((LRU_3 [temp_Data_ADD[`INDEX]] != 'b11) && (LRU_2 [temp_Data_ADD[`INDEX]] == 'b00)) begin
				LRU_1 [temp_Data_ADD[`INDEX]] <= LRU_1 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_3 [temp_Data_ADD[`INDEX]] <= 'b11 ;
				LRU_4 [temp_Data_ADD[`INDEX]] <= LRU_4 [temp_Data_ADD[`INDEX]] - 1 ;
			end
			
			else if ((LRU_3 [temp_Data_ADD[`INDEX]] != 'b11) && (LRU_4 [temp_Data_ADD[`INDEX]] == 'b00)) begin
				LRU_1 [temp_Data_ADD[`INDEX]] <= LRU_1 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_2 [temp_Data_ADD[`INDEX]] <= LRU_2 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_3 [temp_Data_ADD[`INDEX]] <= 'b11 ;
			end
		end



		/******************************* WAY 4 *******************************/

		2'b11: begin
			if (LRU_4 [temp_Data_ADD[`INDEX]] == 'b00) begin
				LRU_1 [temp_Data_ADD[`INDEX]] <= LRU_1 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_2 [temp_Data_ADD[`INDEX]] <= LRU_2 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_3 [temp_Data_ADD[`INDEX]] <= LRU_3 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_4 [temp_Data_ADD[`INDEX]] <= 'b11 ;
			end

			else if ((LRU_4 [temp_Data_ADD[`INDEX]] != 'b11) && (LRU_1 [temp_Data_ADD[`INDEX]] == 'b00)) begin
				LRU_2 [temp_Data_ADD[`INDEX]] <= LRU_2 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_3 [temp_Data_ADD[`INDEX]] <= LRU_3 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_4 [temp_Data_ADD[`INDEX]] <= 'b11 ;
			end
		
			else if ((LRU_4 [temp_Data_ADD[`INDEX]] != 'b11) && (LRU_2 [temp_Data_ADD[`INDEX]] == 'b00)) begin
				LRU_1 [temp_Data_ADD[`INDEX]] <= LRU_1 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_3 [temp_Data_ADD[`INDEX]] <= LRU_3 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_4 [temp_Data_ADD[`INDEX]] <= 'b11 ;
			end
		
			else if ((LRU_4 [temp_Data_ADD[`INDEX]] != 'b11) && (LRU_3 [temp_Data_ADD[`INDEX]] == 'b00)) begin
				LRU_1 [temp_Data_ADD[`INDEX]] <= LRU_1 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_2 [temp_Data_ADD[`INDEX]] <= LRU_2 [temp_Data_ADD[`INDEX]] - 1 ;
				LRU_4 [temp_Data_ADD[`INDEX]] <= 'b11 ;
			end
		end

		endcase
		RD_DN <= 2'b00 ;
	end
end


endmodule
