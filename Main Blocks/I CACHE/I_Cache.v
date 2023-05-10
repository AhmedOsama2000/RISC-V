`define TAG 31:12		// position of tag in address
`define INDEX 11:5		// position of index in address
`define M_WORD 4:2		// position of offset in address
`define OFFSET 1:0		// position of offset in address

`define WORD_0 31:0		// position of WORD in CACHE
`define WORD_1 63:32		// position of WORD in CACHE
`define WORD_2 95:64		// position of WORD in CACHE
`define WORD_3 127:96		// position of WORD in CACHE
`define WORD_4 159:128		// position of WORD in CACHE
`define WORD_5 191:160		// position of WORD in CACHE
`define WORD_6 223:192		// position of WORD in CACHE
`define WORD_7 255:224		// position of WORD in CACHE

module I_Cache #(

parameter Width_Data = 32 ,
parameter Width_ADD = 32 ,
parameter NUMBER_WORD = 8 ,
parameter Size_Block = 128 ,
parameter Tag_width = 20 ,
parameter Index_width = 7 ,
parameter LRU_Width = 2 

) 

(

// input
input		wire																		CLK ,
input		wire																		RST ,
input		wire																		RD_Valid_MEM ,		
input		wire																		WR_EN ,		
input		wire																		RD_EN ,		
input		wire	[Width_Data*NUMBER_WORD-1:0]			Data_RD_MEM ,		
input		wire	[Width_ADD-1:0]										Data_ADD ,		

// output
output	reg		[Width_Data-1:0]									O_Data ,		// OUTPUT DATA
output	reg		[Width_ADD-1:0]										Data_ADD_AXI ,		// OUTPUT ADDRESS TO AXI
output	reg																			RD_Hit ,
output	reg																			WR_Hit 
						
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
reg																	temp_RD_EN ;
reg																	temp_WR_EN ;

// THIS SIGNAL FOR READ FORM MEMORY IF NOT HIT IN CACHE
reg																	RD_InValidate ;

// SAVE DATA COMING FORM CACHE
reg		[Width_ADD-1:0]  							temp_Data_ADD ;

// Hiting 
wire 																miss_1 ;	
wire 																miss_2 ;	
wire 																miss_3 ;	
wire 																miss_4 ;	

// FLAG READ DONE
reg		[1:0]													RD_DN ;






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
		RD_DN <= 2'b00 ;
	end


	/*******************************************************************
	 READ DATA (HIT) 
	*******************************************************************/


	/******************************* WAY 1 *******************************/

	else if (RD_EN  && Valid_1[Data_ADD[`INDEX]] && Data_ADD[`TAG] == Tag_1[Data_ADD[`INDEX]]) begin
		RD_Hit <= 1'b1 ;
		RD_DN <= 2'b00 ;

		case(Data_ADD[`M_WORD])
		3'b000: O_Data <= cache_way_1[Data_ADD[`INDEX]][`WORD_0] ;
		3'b001: O_Data <= cache_way_1[Data_ADD[`INDEX]][`WORD_1] ;
		3'b010: O_Data <= cache_way_1[Data_ADD[`INDEX]][`WORD_2] ;
		3'b011: O_Data <= cache_way_1[Data_ADD[`INDEX]][`WORD_3] ;
		3'b100: O_Data <= cache_way_1[Data_ADD[`INDEX]][`WORD_4] ;
		3'b101: O_Data <= cache_way_1[Data_ADD[`INDEX]][`WORD_5] ;
		3'b110: O_Data <= cache_way_1[Data_ADD[`INDEX]][`WORD_6] ;
		3'b111: O_Data <= cache_way_1[Data_ADD[`INDEX]][`WORD_7] ;
		endcase

	end

	/******************************* WAY 2 *******************************/

	else if (RD_EN  && Valid_2[Data_ADD[`INDEX]] && Data_ADD[`TAG] == Tag_2[Data_ADD[`INDEX]]) begin
		RD_Hit <= 1'b1 ;
		RD_DN <= 2'b01 ;

		case(Data_ADD[`M_WORD])
		3'b000: O_Data <= cache_way_2[Data_ADD[`INDEX]][`WORD_0] ;
		3'b001: O_Data <= cache_way_2[Data_ADD[`INDEX]][`WORD_1] ;
		3'b010: O_Data <= cache_way_2[Data_ADD[`INDEX]][`WORD_2] ;
		3'b011: O_Data <= cache_way_2[Data_ADD[`INDEX]][`WORD_3] ;
		3'b100: O_Data <= cache_way_2[Data_ADD[`INDEX]][`WORD_4] ;
		3'b101: O_Data <= cache_way_2[Data_ADD[`INDEX]][`WORD_5] ;
		3'b110: O_Data <= cache_way_2[Data_ADD[`INDEX]][`WORD_6] ;
		3'b111: O_Data <= cache_way_2[Data_ADD[`INDEX]][`WORD_7] ;
		endcase

	end

	/******************************* WAY 3 *******************************/

	else if (RD_EN && Valid_3[Data_ADD[`INDEX]] && Data_ADD[`TAG] == Tag_3[Data_ADD[`INDEX]]) begin
		RD_Hit <= 1'b1 ;
		RD_DN <= 2'b10 ;
		
		case(Data_ADD[`M_WORD])
		3'b000: O_Data <= cache_way_3[Data_ADD[`INDEX]][`WORD_0] ;
		3'b001: O_Data <= cache_way_3[Data_ADD[`INDEX]][`WORD_1] ;
		3'b010: O_Data <= cache_way_3[Data_ADD[`INDEX]][`WORD_2] ;
		3'b011: O_Data <= cache_way_3[Data_ADD[`INDEX]][`WORD_3] ;
		3'b100: O_Data <= cache_way_3[Data_ADD[`INDEX]][`WORD_4] ;
		3'b101: O_Data <= cache_way_3[Data_ADD[`INDEX]][`WORD_5] ;
		3'b110: O_Data <= cache_way_3[Data_ADD[`INDEX]][`WORD_6] ;
		3'b111: O_Data <= cache_way_3[Data_ADD[`INDEX]][`WORD_7] ;
		endcase

	end

	/******************************* WAY 4 *******************************/

	else if (RD_EN  && Valid_4[Data_ADD[`INDEX]] && Data_ADD[`TAG] == Tag_4[Data_ADD[`INDEX]]) begin
		RD_Hit <= 1'b1 ;
		RD_DN <= 2'b11 ;
	
		case(Data_ADD[`M_WORD])
		3'b000: O_Data <= cache_way_4[Data_ADD[`INDEX]][`WORD_0] ;
		3'b001: O_Data <= cache_way_4[Data_ADD[`INDEX]][`WORD_1] ;
		3'b010: O_Data <= cache_way_4[Data_ADD[`INDEX]][`WORD_2] ;
		3'b011: O_Data <= cache_way_4[Data_ADD[`INDEX]][`WORD_3] ;
		3'b100: O_Data <= cache_way_4[Data_ADD[`INDEX]][`WORD_4] ;
		3'b101: O_Data <= cache_way_4[Data_ADD[`INDEX]][`WORD_5] ;
		3'b110: O_Data <= cache_way_4[Data_ADD[`INDEX]][`WORD_6] ;
		3'b111: O_Data <= cache_way_4[Data_ADD[`INDEX]][`WORD_7] ;
		endcase

	end

end


/*******************************************************************
 READ DATA (MISS)
*******************************************************************/

always @(posedge CLK or negedge RST) begin


	/******************************* WAY 1 *******************************/

	if (temp_RD_EN  && Valid_1[temp_Data_ADD[`INDEX]] && temp_Data_ADD[`TAG] == Tag_1[temp_Data_ADD[`INDEX]]) begin
		RD_Hit <= 1'b1 ;
		RD_DN <= 2'b00 ;

		case(temp_Data_ADD[`M_WORD])
		3'b000: O_Data <= cache_way_1[temp_Data_ADD[`INDEX]][`WORD_0] ;
		3'b001: O_Data <= cache_way_1[temp_Data_ADD[`INDEX]][`WORD_1] ;
		3'b010: O_Data <= cache_way_1[temp_Data_ADD[`INDEX]][`WORD_2] ;
		3'b011: O_Data <= cache_way_1[temp_Data_ADD[`INDEX]][`WORD_3] ;
		3'b100: O_Data <= cache_way_1[temp_Data_ADD[`INDEX]][`WORD_4] ;
		3'b101: O_Data <= cache_way_1[temp_Data_ADD[`INDEX]][`WORD_5] ;
		3'b110: O_Data <= cache_way_1[temp_Data_ADD[`INDEX]][`WORD_6] ;
		3'b111: O_Data <= cache_way_1[temp_Data_ADD[`INDEX]][`WORD_7] ;
		endcase

	end

	/******************************* WAY 2 *******************************/

	else if (temp_RD_EN && Valid_2[temp_Data_ADD[`INDEX]] && temp_Data_ADD[`TAG] == Tag_2[temp_Data_ADD[`INDEX]]) begin
		RD_Hit <= 1'b1 ;
		RD_DN <= 2'b01 ;

		case(temp_Data_ADD[`M_WORD])
		3'b000: O_Data <= cache_way_2[temp_Data_ADD[`INDEX]][`WORD_0] ;
		3'b001: O_Data <= cache_way_2[temp_Data_ADD[`INDEX]][`WORD_1] ;
		3'b010: O_Data <= cache_way_2[temp_Data_ADD[`INDEX]][`WORD_2] ;
		3'b011: O_Data <= cache_way_2[temp_Data_ADD[`INDEX]][`WORD_3] ;
		3'b100: O_Data <= cache_way_2[temp_Data_ADD[`INDEX]][`WORD_4] ;
		3'b101: O_Data <= cache_way_2[temp_Data_ADD[`INDEX]][`WORD_5] ;
		3'b110: O_Data <= cache_way_2[temp_Data_ADD[`INDEX]][`WORD_6] ;
		3'b111: O_Data <= cache_way_2[temp_Data_ADD[`INDEX]][`WORD_7] ;
		endcase

	end

	/******************************* WAY 3 *******************************/

	else if (temp_RD_EN && ~temp_RD_EN_HIT && Valid_3[temp_Data_ADD[`INDEX]] && temp_Data_ADD[`TAG] == Tag_3[temp_Data_ADD[`INDEX]]) begin
		RD_Hit <= 1'b1 ;
		RD_DN <= 2'b10 ;
		
		case(temp_Data_ADD[`M_WORD])
		3'b000: O_Data <= cache_way_3[temp_Data_ADD[`INDEX]][`WORD_0] ;
		3'b001: O_Data <= cache_way_3[temp_Data_ADD[`INDEX]][`WORD_1] ;
		3'b010: O_Data <= cache_way_3[temp_Data_ADD[`INDEX]][`WORD_2] ;
		3'b011: O_Data <= cache_way_3[temp_Data_ADD[`INDEX]][`WORD_3] ;
		3'b100: O_Data <= cache_way_3[temp_Data_ADD[`INDEX]][`WORD_4] ;
		3'b101: O_Data <= cache_way_3[temp_Data_ADD[`INDEX]][`WORD_5] ;
		3'b110: O_Data <= cache_way_3[temp_Data_ADD[`INDEX]][`WORD_6] ;
		3'b111: O_Data <= cache_way_3[temp_Data_ADD[`INDEX]][`WORD_7] ;
		endcase

	end

	/******************************* WAY 4 *******************************/

	else if (temp_RD_EN && Valid_4[temp_Data_ADD[`INDEX]] && temp_Data_ADD[`TAG] == Tag_4[temp_Data_ADD[`INDEX]]) begin
		RD_Hit <= 1'b1 ;
		RD_DN <= 2'b11 ;
	
		case(temp_Data_ADD[`M_WORD])
		3'b000: O_Data <= cache_way_4[temp_Data_ADD[`INDEX]][`WORD_0] ;
		3'b001: O_Data <= cache_way_4[temp_Data_ADD[`INDEX]][`WORD_1] ;
		3'b010: O_Data <= cache_way_4[temp_Data_ADD[`INDEX]][`WORD_2] ;
		3'b011: O_Data <= cache_way_4[temp_Data_ADD[`INDEX]][`WORD_3] ;
		3'b100: O_Data <= cache_way_4[temp_Data_ADD[`INDEX]][`WORD_4] ;
		3'b101: O_Data <= cache_way_4[temp_Data_ADD[`INDEX]][`WORD_5] ;
		3'b110: O_Data <= cache_way_4[temp_Data_ADD[`INDEX]][`WORD_6] ;
		3'b111: O_Data <= cache_way_4[temp_Data_ADD[`INDEX]][`WORD_7] ;
		endcase

	end

end


 
/*******************************************************************
 FLAG CONTROL
*******************************************************************/

always @(posedge CLK or negedge RST) begin
	if (~RST) begin
		temp_WR_EN <= 1'b0 ;
		temp_RD_EN <= 1'b0 ;
		temp_Data_ADD <= 'b0 ;
	end
	else if (RD_EN) begin
		temp_RD_EN <= RD_EN ;
		temp_Data_ADD <= Data_ADD ;
		temp_RD_EN_HIT <= 1'b1 ;
	end
	else if (WR_EN) begin
		temp_WR_EN <= WR_EN ;
		temp_Data_ADD <= Data_ADD ;
	end
	else if (WR_Hit && ~temp_RD_EN) begin
		temp_WR_EN <= 1'b0 ;
		temp_Data_ADD <= 'b0 ;
	end
	else if (RD_Hit) begin
		RD_Hit <= 1'b0 ;
		temp_RD_EN <= 1'b0 ;
		temp_Data_ADD <= 'b0 ;
	end
end


/*******************************************************************
 READ DATA FROM MEMORY
*******************************************************************/


assign miss_1 = (~Valid_1[Data_ADD[`INDEX]] && Data_ADD[`TAG] != Tag_1[Data_ADD[`INDEX]]) ? 1'b1:1'b0 ;
assign miss_2 = (~Valid_2[Data_ADD[`INDEX]] && Data_ADD[`TAG] != Tag_2[Data_ADD[`INDEX]]) ? 1'b1:1'b0 ;
assign miss_3 = (~Valid_3[Data_ADD[`INDEX]] && Data_ADD[`TAG] != Tag_3[Data_ADD[`INDEX]]) ? 1'b1:1'b0 ;
assign miss_4 = (~Valid_4[Data_ADD[`INDEX]] && Data_ADD[`TAG] != Tag_4[Data_ADD[`INDEX]]) ? 1'b1:1'b0 ;


always @(posedge CLK or negedge RST) begin
	if (~RST) begin
		RD_Hit <= 1'b0 ;
		WR_Hit <= 1'b0 ;
		RD_InValidate <= 1'b0 ;
		Data_ADD_AXI <= 'b0 ;
	end
	else if (WR_Hit) begin
		WR_Hit <= 1'b0 ;
	end
	
	else if ((temp_WR_EN || WR_EN) && miss_1 && miss_2 && miss_3 && miss_4) begin
		WR_Hit <= 1'b0 ;
		Data_ADD_AXI <= Data_ADD ;
	end
	
	else if ((temp_RD_EN || RD_EN) && miss_1 && miss_2 && miss_3 && miss_4 && ~RD_InValidate) begin
		RD_Hit <= 1'b0 ;
		RD_InValidate <= 1'b1 ;
		Data_ADD_AXI <= Data_ADD ;
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

		// DATA FROM MEMOREY
		cache_way_1[temp_Data_ADD[`INDEX]] <= Data_RD_MEM ;

		// UPDATE TAG & VALID
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

		// DATA FROM MEMOREY
		cache_way_2[temp_Data_ADD[`INDEX]] <= Data_RD_MEM ;
		
		// UPDATE TAG & VALID
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

		// DATA FROM MEMOREY
		cache_way_3[temp_Data_ADD[`INDEX]] <= Data_RD_MEM ;
		
		// UPDATE TAG & VALID
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

		// DATA FROM MEMOREY
		cache_way_4[temp_Data_ADD[`INDEX]] <= Data_RD_MEM ;
		
		// UPDATE TAG & VALID
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

			// DATA FROM MEMOREY
			cache_way_1[temp_Data_ADD[`INDEX]] <= Data_RD_MEM ;

			// UPDATE TAG & VALID
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
			
			// DATA FROM MEMOREY
			cache_way_2[temp_Data_ADD[`INDEX]] <= Data_RD_MEM ;

			// UPDATE TAG & VALID
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
			
			// DATA FROM MEMOREY
			cache_way_3[temp_Data_ADD[`INDEX]] <= Data_RD_MEM ;

			// UPDATE TAG & VALID
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

			// DATA FROM MEMOREY
			cache_way_4[temp_Data_ADD[`INDEX]] <= Data_RD_MEM ;

			// UPDATE TAG & VALID
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