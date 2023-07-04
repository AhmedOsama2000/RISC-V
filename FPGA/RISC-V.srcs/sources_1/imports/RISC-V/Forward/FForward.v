(* DONT_TOUCH = "TRUE" *) module FForward_Unit #(
	parameter WIDTH_SOURCE = 5
)
(
	// INPUT
	// Foward Decision Signals
	input  wire                    fp_op_id_ex,
	input  wire                    fp_op_ex_mem,
	input  wire                    fp_op_mem_wb,

	input  wire                    int_op_ex_mem,
	input  wire                    int_op_mem_wb,

	input  wire 				   EX_MEM_Reg_Wr,
	input  wire 				   MEM_WB_Reg_Wr,
	input  wire [WIDTH_SOURCE-1:0] ID_EX_rs1,
	input  wire [WIDTH_SOURCE-1:0] ID_EX_rs2,
	input  wire [WIDTH_SOURCE-1:0] EX_MEM_rd,
	input  wire [WIDTH_SOURCE-1:0] MEM_WB_rd,

	// OUTPUT
	output reg [2:0] 			   Forward_A,
	output reg [1:0] 			   Forward_B
);

reg i2fforward_detect;
reg fforward_detect;

wire EX_dest_x0;
wire MEM_dest_x0;

always @(*) begin
	if ((fp_op_id_ex == 1'b1 && fp_op_ex_mem == 1'b1) || (fp_op_id_ex == 1'b1 && fp_op_mem_wb == 1'b1)) begin
		fforward_detect = 1'b1;
	end
	else begin
		fforward_detect = 1'b0;
	end

end
always @(*) begin
	if ((fp_op_id_ex == 1'b1 && int_op_ex_mem == 1'b1) || (fp_op_id_ex == 1'b1 && int_op_mem_wb == 1'b1)) begin
		i2fforward_detect = 1'b1;
	end
	else begin
		i2fforward_detect = 1'b0;
	end

end

assign EX_dest_x0 	  = !EX_MEM_rd? 1'b1:1'b0;
assign MEM_dest_x0 	  = !MEM_WB_rd? 1'b1:1'b0;


// Src1 ==> A
always @(*) begin

	Forward_A = 3'b000;
	// EX Forward
	if (i2fforward_detect && !EX_dest_x0 && EX_MEM_rd == ID_EX_rs1) begin
		Forward_A = 3'b011;		
	end
	// MEM Forward
	else if (i2fforward_detect && !MEM_dest_x0 && MEM_WB_rd == ID_EX_rs1) begin
		Forward_A = 3'b100;		
	end

	// EX Forward
	else if (fforward_detect && EX_MEM_Reg_Wr && !EX_dest_x0 && EX_MEM_rd == ID_EX_rs1) begin
		Forward_A = 3'b010;		
	end
	// MEM Forward
	else if (fforward_detect && MEM_WB_Reg_Wr && !MEM_dest_x0 && MEM_WB_rd == ID_EX_rs1) begin
		Forward_A = 3'b001;		
	end
	else begin
		Forward_A = 3'b000;
	end
	
end

// Src1 ==> B
always @(*) begin

	Forward_B = 2'b00;
	// EX Forward
	if (fforward_detect && EX_MEM_Reg_Wr && !EX_dest_x0 && EX_MEM_rd == ID_EX_rs2) begin
		Forward_B = 2'b10;		
	end
	// MEM Forward
	else if (fforward_detect && MEM_WB_Reg_Wr && !MEM_dest_x0 && MEM_WB_rd == ID_EX_rs2) begin
		Forward_B = 2'b01;		
	end
	else begin
		Forward_B = 2'b00;
	end
	
end

endmodule