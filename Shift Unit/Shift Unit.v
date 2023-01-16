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

reg sign_bit; // In case of SRA
reg [XLEN-1:0] temp_result;

localparam SLL = 2'b00;
localparam SRL = 2'b01;
localparam SRA = 2'b11;

always @(*) begin
	sign_bit = 1'b0;
	temp_result = 'b0;
	if (En) begin
		
		case ({funct7_5,funct3_2})
		SLL: begin
			temp_result = (Src2[0])? {Src1[XLEN-2:0],1'b0}:Src1;
			temp_result = (Src2[1])? {temp_result[XLEN-3:0],2'b00}:temp_result;
			temp_result = (Src2[2])? {temp_result[XLEN-5:0],4'b0000}:temp_result;
			temp_result = (Src2[3])? {temp_result[XLEN-9:0],8'b00000000}:temp_result;
			temp_result = (Src2[4])? {temp_result[XLEN-17:0],16'b00000000}:temp_result;
			Result = temp_result;
		end
		SRL: begin
			temp_result = (Src2[0])? {1'b0,Src1[XLEN-1:1]}:Src1;
			temp_result = (Src2[1])? {2'b00,temp_result[XLEN-1:2]}:temp_result;
			temp_result = (Src2[2])? {4'b0000,temp_result[XLEN-1:4]}:temp_result;
			temp_result = (Src2[3])? {8'b00000000,temp_result[XLEN-1:8]}:temp_result;
			temp_result = (Src2[4])? {16'b00000000,temp_result[XLEN-1:16]}:temp_result;
			Result = temp_result;
		end
		SRA: begin
			sign_bit =  Src1[XLEN-1];
			temp_result = (Src2[0])? {{sign_bit},Src1[XLEN-1:1]}:Src1;
			temp_result = (Src2[1])? {{2{sign_bit}},temp_result[XLEN-1:2]}:temp_result;
			temp_result = (Src2[2])? {{4{sign_bit}},temp_result[XLEN-1:4]}:temp_result;
			temp_result = (Src2[3])? {{8{sign_bit}},temp_result[XLEN-1:8]}:temp_result;
			temp_result = (Src2[4])? {{16{sign_bit}},temp_result[XLEN-1:16]}:temp_result;
			Result = temp_result;
		end

		default: begin 
			temp_result = 'b0;
			Result = temp_result;
		end
		endcase

	end
	else begin	
		Result = 'b0;
		sign_bit = 1'b0;
	end
	
end


endmodule
