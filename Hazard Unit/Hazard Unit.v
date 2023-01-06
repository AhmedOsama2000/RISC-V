module Hazard_Unit #(
	parameter WIDTH_SOURCE = 5,
	parameter OPCODE_6_4   = 3
)
(
	// INPUT
	input  wire [WIDTH_SOURCE-1:0] IF_ID_rs1,
	input  wire [WIDTH_SOURCE-1:0] IF_ID_rs2,
	input  wire [OPCODE_6_4-1:0]   opcode,
	input  wire [WIDTH_SOURCE-1:0] ID_EX_Reg_rd,
	input  wire 				   ID_EX_MEM_Rd, // Memory Read

	// OUTPUT
	output reg PC_Stall,
	output reg IF_ID_Stall,
	output reg Mux_Sel_Flush
);

wire expc_haz_1;
wire expc_haz_2;

assign expc_haz_1 = ((IF_ID_rs1 == ID_EX_Reg_rd) && ID_EX_MEM_Rd)? 1'b1:1'b0;
assign expc_haz_2 = ((IF_ID_rs2 == ID_EX_Reg_rd) && ID_EX_MEM_Rd)? 1'b1:1'b0;


always @(*) begin

	PC_Stall 	  = 0;
	IF_ID_Stall   = 0;
	Mux_Sel_Flush = 0;

	// Stall in case of Branch
	if (opcode == 3'b110 && (expc_haz_1 || expc_haz_2)) begin
		
		PC_Stall      = 1;
		IF_ID_Stall   = 1;
		Mux_Sel_Flush = 1;

	end
	// Stall in case of Arithmatic or Mul or Div
	else if (opcode == 3'b011 && (expc_haz_1 || expc_haz_2)) begin
		
		PC_Stall      = 1;
		IF_ID_Stall   = 1;
		Mux_Sel_Flush = 1;

	end
	// Stall in case of Imm
	else if (opcode == 3'b001 && expc_haz_1) begin
		
		PC_Stall      = 1;
		IF_ID_Stall   = 1;
		Mux_Sel_Flush = 1;

	end
	else begin
		
		PC_Stall 	  = 0;
		IF_ID_Stall   = 0;
		Mux_Sel_Flush = 0;

	end
end

endmodule