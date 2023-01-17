module Shift_Unit #(
	parameter XLEN   = 32
)
(
	// INPUT
	input  wire signed [XLEN-1:0] Src1,
	input  wire  	   [4:0] 	  Src2,
	input  wire  			 	  funct3_2, 
	input  wire              	  funct7_5,
	input  wire              	  En,

	// OUTPUT
	output reg         [XLEN-1:0] Result
);

reg [XLEN-1:0] temp_result;
wire           sign_bit;

integer i;

assign sign_bit = (funct7_5)? Src1[XLEN-1]:1'b0;

always @(*) begin

	if (En && {funct7_5,funct3_2} != 2'b10) begin
		
		if (!funct3_2) begin
			
			for (i = 0;i < XLEN;i = i + 1) begin
				
				temp_result[XLEN-i-1] = Src1[i];

			end

		end
		else begin
			
			temp_result = Src1;

		end
		temp_result = (Src2[0])? {{sign_bit},temp_result[XLEN-1:1]}:temp_result;
		temp_result = (Src2[1])? {{2{sign_bit}},temp_result[XLEN-1:2]}:temp_result;
		temp_result = (Src2[2])? {{4{sign_bit}},temp_result[XLEN-1:4]}:temp_result;
		temp_result = (Src2[3])? {{8{sign_bit}},temp_result[XLEN-1:8]}:temp_result;
		temp_result = (Src2[4])? {{16{sign_bit}},temp_result[XLEN-1:16]}:temp_result;
		if (!funct3_2) begin
			
			for (i = 0;i < XLEN;i = i + 1) begin
				
				Result[XLEN-i-1] = temp_result[i];

			end

		end
		else begin
			
			Result = temp_result;

		end

	end
	else begin
		
		temp_result = 'b0;
		Result = temp_result;

	end

end


endmodule
