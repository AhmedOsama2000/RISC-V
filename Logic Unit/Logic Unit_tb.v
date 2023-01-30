module Logical_Unit_tb;

	parameter XLEN   = 32;

	reg [XLEN-1:0]   Rs1;
	reg [XLEN-1:0]   Rs2;
	reg [1:0]        funct3_1_0; 
	reg              En;

	wire [XLEN-1:0]  Result;

	reg  [XLEN-1:0] expected_result;

	localparam AND = 2'b11;
	localparam OR  = 2'b10;
	localparam XOR = 2'b00;

	Logical_Unit DUT (
		.Rs1(Rs1),
		.Rs2(Rs2),
		.funct3_1_0(funct3_1_0),
		.En(En),
		.Result(Result)
	);

	integer i;

	initial begin

		Rs1     = 0;
		Rs2     = 0;
		funct3_1_0 = 2'b00;
		En       = 0;
		#5
		for (i = 0;i < 20;i = i + 1) begin
			En = 1;
			Rs1 	   = $random;
			Rs2 	   = $random;
			funct3_1_0 = $random;
			check_result(Rs1,Rs2);
			#5;
		end

		$stop;

	end

	task check_result(input [XLEN-1:0] Rs1 ,input [XLEN-1:0] Rs2);
		begin
			#2
			case (funct3_1_0)
				AND: expected_result = Rs1 & Rs2;
				OR: expected_result = Rs1 | Rs2;
				XOR: expected_result = Rs1 ^ Rs2;
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
