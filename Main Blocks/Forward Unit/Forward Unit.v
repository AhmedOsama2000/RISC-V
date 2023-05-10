module Forward_Unit #(
	parameter WIDTH_SOURCE = 5
)
(
	// INPUT
	input  wire 				   EX_MEM_Reg_Wr,
	input  wire 				   MEM_WB_Reg_Wr,
	input  wire [WIDTH_SOURCE-1:0] 		   ID_EX_Rs1,
	input  wire [WIDTH_SOURCE-1:0] 		   ID_EX_Rs2,
	input  wire [WIDTH_SOURCE-1:0] 		   EX_MEM_Rd,
	input  wire [WIDTH_SOURCE-1:0] 	   	   MEM_WB_Rd,

	// OUTPUT
	output reg [1:0] 			   Forward_A,
	output reg [1:0] 			   Forward_B
);

wire EX_dest_x0;
wire MEM_dest_x0;
wire double_forward;

assign EX_dest_x0 	  = !EX_MEM_Rd? 1'b1:1'b0;
assign MEM_dest_x0 	  = !MEM_WB_Rd? 1'b1:1'b0;
assign double_forward = (ID_EX_Rs1 == ID_EX_Rs2)? 1'b1:1'b0;

always @(*) begin
	Forward_A = 2'b00;
	Forward_B = 2'b00;
	
	// EX Forward
	if (double_forward && !EX_dest_x0 && EX_MEM_Rd == ID_EX_Rs1) begin
		
		Forward_A = 2'b10;
		Forward_B = 2'b10;

	end
	if (EX_MEM_Reg_Wr && !EX_dest_x0 && EX_MEM_Rd == ID_EX_Rs1) begin

		Forward_A = 2'b10;
		
	end
	else if (EX_MEM_Reg_Wr && !EX_dest_x0 && EX_MEM_Rd == ID_EX_Rs2) begin

		Forward_B = 2'b10;
		
	end

	// MEM Forward
	else if (double_forward && !MEM_dest_x0 && MEM_WB_Rd == ID_EX_Rs1) begin
		
		Forward_A = 2'b01;
		Forward_B = 2'b01;

	end
	else if (MEM_WB_Reg_Wr && !MEM_dest_x0 && MEM_WB_Rd == ID_EX_Rs1) begin

		Forward_A = 2'b01;
		
	end
	else if (MEM_WB_Reg_Wr && !MEM_dest_x0 && MEM_WB_Rd == ID_EX_Rs2) begin

		Forward_B = 2'b01;
		
	end

	else begin
		
		Forward_A = 2'b00;
		Forward_B = 2'b00;

	end

end

endmodule
