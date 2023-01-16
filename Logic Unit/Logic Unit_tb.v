module Logical_Unit_tb;

	parameter XLEN   = 32;

	reg [XLEN-1:0]   Src1;
	reg [XLEN-1:0]   Src2;
	reg [1:0] 		 funct3_1_0; 
	reg              En;

	wire [XLEN-1:0]  Result;

	Logical_Unit DUT (
		.Src1(Src1),
		.Src2(Src2),
		.funct3_1_0(funct3_1_0),
		.En(En),
		.Result(Result)
	);

	integer i;

	initial begin

		Src1     = 0;
		Src2     = 0;
		funct3_1_0 = 2'b00;
		En       = 0;
		#5
		for (i = 0;i < 20;i = i + 1) begin
			En = 1;
			Src1 	   = $random;
			Src2 	   = $random;
			funct3_1_0 = $random;
			#5;
		end

		$stop;

	end

endmodule