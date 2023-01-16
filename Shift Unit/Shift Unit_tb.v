module Shift_Unit_tb;

	parameter XLEN   = 32;

	reg [XLEN-1:0]   Src1;
	reg [XLEN-1:0]   Src2;
	reg  			 funct3_2; 
	reg              funct7_5;
	reg              En;

	wire [XLEN-1:0]  Result;

	Shift_Unit DUT (
		.Src1(Src1),
		.Src2(Src2),
		.funct3_2(funct3_2),
		.funct7_5(funct7_5),
		.En(En),
		.Result(Result)
	);

	integer i;

	initial begin

		Src1     = 0;
		Src2     = 0;
		funct3_2 = 0;
		funct7_5 = 0;
		En       = 0;

		// SLL
		#5
		En   = 1;
		Src1 = 50;
		Src2 = 4;

		// SRL
		#5
		funct3_2 = 1;
		Src1 	 = 32'hABCDFFFF;
		Src2 	 = 5;

		// SRA
		#5
		funct7_5 = 1;
		Src1 	 = 32'hABCDFFFF;
		Src2 	 = 3;

		#5

		for (i = 0;i < 10;i = i + 1) begin
			
			Src1 	 = $random;
			Src2 	 = $random;
			funct3_2 = $random;
			funct7_5 = $random;
			#5;
		end

		$stop;

	end

endmodule