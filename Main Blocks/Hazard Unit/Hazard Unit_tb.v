module Hazard_Unit_tb;

	parameter OPCODE_6_4   = 3;
	parameter WIDTH_SOURCE = 5;

	reg [WIDTH_SOURCE-1:0] IF_ID_rs1;
	reg [WIDTH_SOURCE-1:0] IF_ID_rs2;
	reg [OPCODE_6_4-1:0]   opcode;
	reg [WIDTH_SOURCE-1:0] ID_EX_Reg_rd;
	reg 				   ID_EX_MEM_Rd;

	wire PC_Stall;
	wire IF_ID_Stall;
	wire Mux_Sel_Flush;


	Hazard_Unit DUT (
		.IF_ID_rs1(IF_ID_rs1),
		.IF_ID_rs2(IF_ID_rs2),
		.opcode(opcode),
		.ID_EX_Reg_rd(ID_EX_Reg_rd),
		.ID_EX_MEM_Rd(ID_EX_MEM_Rd)
	);

	integer i;

	initial begin
		
		IF_ID_rs1 	 = 5'b0;
		IF_ID_rs2 	 = 5'b0;
		opcode    	 = 3'b000;
		ID_EX_Reg_rd = 5;
		ID_EX_MEM_Rd = 1'b0;

		#5
		// Check Normal Operation
		ID_EX_MEM_Rd = 1'b1;
		opcode = 3'b110; // Check when incoming is branch
		IF_ID_rs1 = 5;

		#5
		IF_ID_rs1 = 3;
		IF_ID_rs2 = 5;

		#5
		IF_ID_rs1 = 5;

		#10
		opcode = 3'b001;
		IF_ID_rs1 = 10;
		ID_EX_Reg_rd = 10;

		#10
		opcode = 3'b011;
		IF_ID_rs1    = 31;
		IF_ID_rs2    = 31;
		ID_EX_Reg_rd = 31;

		#10
		// Check Random Cases
		for (i = 0;i < 50;i = i + 1) begin
			

			IF_ID_rs1 = $random;
			IF_ID_rs2 = $random;
			ID_EX_MEM_Rd = $random;
			ID_EX_Reg_rd = $random;
			opcode = $random;

			#5;

		end
		$stop;

	end
endmodule