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
	output wire PC_Stall,
	output wire IF_ID_Stall,
	output wire Mux_Sel_Flush
);

localparam BRANCH = 3'b110;
localparam ARITHM = 3'b011;
localparam IMM    = 3'b001;

wire expc_haz_1;
wire expc_haz_2;
reg [2:0] stall_flags;

assign expc_haz_1 = ((IF_ID_rs1 == ID_EX_Reg_rd) && ID_EX_MEM_Rd)? 1'b1:1'b0;
assign expc_haz_2 = ((IF_ID_rs2 == ID_EX_Reg_rd) && ID_EX_MEM_Rd)? 1'b1:1'b0;

assign {PC_Stall,IF_ID_Stall,Mux_Sel_Flush} = stall_flags;

always @(*) begin

	stall_flags = 3'b000;

	// Stall in case of Branch
	if (opcode == BRANCH && (expc_haz_1 || expc_haz_2)) begin
		
		stall_flags = 3'b111;

	end
	// Stall in case of Arithmatic or Mul or Div
	else if (opcode == ARITHM && (expc_haz_1 || expc_haz_2)) begin
		
		stall_flags = 3'b111;

	end
	// Stall in case of Imm
	else if (opcode == IMM && expc_haz_1) begin
		
		stall_flags = 3'b111;

	end
	else begin
		
		stall_flags = 3'b000;

	end
end

endmodule
