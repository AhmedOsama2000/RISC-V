module Forward_Unit #(
	parameter WIDTH_SOURCE = 5
)
(
	// INPUT
	// Foward Decision Signals
	input  wire                    int_op_id_ex,
	input  wire                    fp_op_id_ex,
	input  wire                    i2f_op_id_ex,
	input  wire                    int_op_ex_mem,
	input  wire                    fp_op_ex_mem,

	input  wire 				   EX_MEM_Reg_Wr,
	input  wire 				   MEM_WB_Reg_Wr,
	input  wire [WIDTH_SOURCE-1:0] ID_EX_rs1,
	input  wire [WIDTH_SOURCE-1:0] ID_EX_rs2,
	input  wire [WIDTH_SOURCE-1:0] EX_MEM_rd,
	input  wire [WIDTH_SOURCE-1:0] MEM_WB_rd,

	// OUTPUT
	output reg [1:0] 			   Forward_A,
	output reg [1:0] 			   Forward_B
);

wire forw_detect;

wire EX_dest_x0;
wire MEM_dest_x0;
wire double_forward;

assign forw_detect = ((int_op_id_ex == int_op_ex_mem) || 
	                  (fp_op_id_ex == fp_op_ex_mem) || (int_op_ex_mem == i2f_op_id_ex))? 1'b1:1'b0;

assign EX_dest_x0 	  = !EX_MEM_rd? 1'b1:1'b0;
assign MEM_dest_x0 	  = !MEM_WB_rd? 1'b1:1'b0;
assign double_forward = (ID_EX_rs1 == ID_EX_rs2)? 1'b1:1'b0;

always @(*) begin
	Forward_A = 2'b00;
	Forward_B = 2'b00;
	
	// EX Forward
	if (forw_detect) begin
		if (double_forward && !EX_dest_x0 && EX_MEM_rd == ID_EX_rs1) begin		
			Forward_A = 2'b10;
			Forward_B = 2'b10;
		end
		else if (EX_MEM_Reg_Wr && !EX_dest_x0 && EX_MEM_rd == ID_EX_rs1) begin
			Forward_A = 2'b10;		
		end
		else if (EX_MEM_Reg_Wr && !EX_dest_x0 && EX_MEM_rd == ID_EX_rs2) begin
			Forward_B = 2'b10;		
		end

		// MEM Forward
		else if (double_forward && !MEM_dest_x0 && MEM_WB_rd == ID_EX_rs1) begin		
			Forward_A = 2'b01;
			Forward_B = 2'b01;
		end
		else if (MEM_WB_Reg_Wr && !MEM_dest_x0 && MEM_WB_rd == ID_EX_rs1) begin
			Forward_A = 2'b01;		
		end
		else if (MEM_WB_Reg_Wr && !MEM_dest_x0 && MEM_WB_rd == ID_EX_rs2) begin
			Forward_B = 2'b01;		
		end
		else begin
			Forward_A = 2'b00;
			Forward_B = 2'b00;
		end
	end
	else begin
		Forward_A = 2'b00;
		Forward_B = 2'b00;
	end
	
end

endmodule