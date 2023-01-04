module Forward_Unit_tb;

	parameter WIDTH_SOURCE = 5;

	reg				   	   EX_MEM_Reg_Wr;
	reg				   	   MEM_WB_Reg_Wr;
	reg [WIDTH_SOURCE-1:0] ID_EX_src_1;
	reg [WIDTH_SOURCE-1:0] ID_EX_src_2;
	reg [WIDTH_SOURCE-1:0] EX_MEM_Rd;
	reg [WIDTH_SOURCE-1:0] MEM_WB_Rd;

	wire	 			   Forward_A;
	wire 			       Forward_B;

	integer i;

	Forward_Unit DUT (
		.EX_MEM_Reg_Wr(EX_MEM_Reg_Wr),
		.MEM_WB_Reg_Wr(MEM_WB_Reg_Wr),
		.ID_EX_src_1(ID_EX_src_1),
		.ID_EX_src_2(ID_EX_src_2),
		.EX_MEM_Rd(EX_MEM_Rd),
		.MEM_WB_Rd(MEM_WB_Rd),
		.Forward_A(Forward_A),
		.Forward_B(Forward_B)
	);

	initial begin
		
		// Normal Operation
		EX_MEM_Reg_Wr = 0;
		MEM_WB_Reg_Wr = 0;
		ID_EX_src_1 = 0;
		ID_EX_src_2 = 0;
		EX_MEM_Rd = 0;
		MEM_WB_Rd = 0;

		#10
		// Test Forward From ALU
		EX_MEM_Reg_Wr = 1;
		EX_MEM_Rd = 5; // Destination is Register 5
		ID_EX_src_1 = 5;

		#5
		EX_MEM_Rd = 6; // Destination is Register 6
		ID_EX_src_2 = 6;

		#5
		// Double Forward From ALU
		ID_EX_src_1 = 3;
		ID_EX_src_2 = 3;
		EX_MEM_Rd   = 3;

		#10
		// Test Forward From Memory
		EX_MEM_Reg_Wr = 0;
		MEM_WB_Reg_Wr = 1;
		ID_EX_src_1 = 31;
		MEM_WB_Rd   = 31;

		#5
		ID_EX_src_2 = 15;
		MEM_WB_Rd   = 15;

		#5
		// Double Forward From Memory
		ID_EX_src_1 = 10;
		ID_EX_src_2 = 10;
		MEM_WB_Rd   = 10;

		#10
		// Test the forwarding when the destination is X0
		EX_MEM_Rd = 0;
		MEM_WB_Rd = 0;

		ID_EX_src_1 = $random;
		ID_EX_src_2 = $random;
		EX_MEM_Reg_Wr = 1;

		#10
		// Test Random cases
		for (i = 0;i < 10;i = i + 1) begin
			
			ID_EX_src_1 = $random;
			ID_EX_src_2 = $random;
			EX_MEM_Reg_Wr = $random;
			MEM_WB_Reg_Wr = $random;
			EX_MEM_Rd = $random;
			MEM_WB_Rd = $random;
			#5;
		end

		$stop;
	end

endmodule

