module Hazard_Unit #(
	parameter WIDTH_SOURCE = 5
	parameter INSTR_WIDTH  = 32
)
(
	// INPUT
	input  wire 				   ID_EX_MEM_Rd,
	input  wire [WIDTH_SOURCE-1:0] Instr,
	input  wire [WIDTH_SOURCE-1:0] ID_EX_Reg_Rd,

	// OUTPUT
	output reg PC_Stall,
	output reg IF_ID_Stall,
	output reg Mux_Sel_Flush
);


assign dest_x0 = (EX_MEM_rd == 0)? 1'b1:1'b0;

always @(*) begin
	Forward_A = 2'b00;
	Forward_B = 2'b00;
	
	// EX Forward
	if (EX_MEM_Reg_Wr && !dest_x0 && EX_MEM_rd = ID_EX_src_1) begin

		Forward_A = 2'b10;
		
	end
	else if (EX_MEM_Reg_Wr && !dest_x0 && EX_MEM_rd = ID_EX_src_2) begin

		Forward_B = 2'b10;
		
	end

	// MEM Forward
	else if (MEM_WB_Reg_Wr && !dest_x0 && EX_MEM_rd = ID_EX_src_1) begin

		Forward_A = 2'b01;
		
	end
	else if (MEM_WB_Reg_Wr && !dest_x0 && EX_MEM_rd = ID_EX_src_2) begin

		Forward_B = 2'b01;
		
	end

	else begin
		
		Forward_A = 2'b00;
		Forward_B = 2'b00;

	end

end


endmodule