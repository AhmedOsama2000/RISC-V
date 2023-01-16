module Logical_Unit_tb;

	parameter XLEN   = 32;

	reg [XLEN-1:0]   Src1;
	reg [XLEN-1:0]   Src2;
	reg [1:0] 		 funct3_1_0; 
	reg              En;

	wire [XLEN-1:0]  Result;

	reg  [XLEN-1:0] expected_result;

	localparam AND = 2'b11;
	localparam OR  = 2'b10;
	localparam XOR = 2'b00;

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
			check_result(Src1,Src2);
			#5;
		end

		$stop;

	end

	task check_result(input [XLEN-1:0] Src1 ,input [XLEN-1:0] Src2);
		begin
			#2
			case (funct3_1_0)
				AND: expected_result = Src1 & Src2;
				OR: expected_result = Src1 | Src2;
				XOR: expected_result = Src1 ^ Src2;
				default: expected_result = 'b0;
			endcase
			if (expected_result === Result) begin
				$display("At time %0t:Result = %0d = %0d",$time,Result,expected_result);
			end
			else begin
				$display("At time %0t:Result = %0d not = %0d",$time,Result,expected_result);
			end

		end
	endtask

endmodule
