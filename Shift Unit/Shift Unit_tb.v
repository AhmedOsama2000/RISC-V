module Shift_Unit_tb;

	parameter XLEN   = 32;

	reg signed [XLEN-1:0] Rs1;
	reg [5:0]   	      Rs2;
	reg  		      funct3_2; 
	reg                   funct7_5;
	reg                   En;

	wire [XLEN-1:0]       Result;


	wire [1:0] funct_test;
	reg [XLEN-1:0] expected_result;

	Shift_Unit DUT (
		.Rs1(Rs1),
		.Rs2(Rs2),
		.funct3_2(funct3_2),
		.funct7_5(funct7_5),
		.En(En),
		.Result(Result)
	);

	localparam SLL = 2'b00;
	localparam SRL = 2'b01;
	localparam SRA = 2'b11;
	integer i;

	assign funct_test = {funct7_5,funct3_2};

	initial begin

		Rs1     = 0;
		Rs2     = 0;
		funct3_2 = 0;
		funct7_5 = 0;
		En       = 0;

		// SLL
		#5
		En   = 1;
		Rs1 = 50;
		Rs2 = 4;
		check_result(Rs1,Rs2);

		// SRL
		#5
		funct3_2 = 1;
		Rs1 	 = 32'hABCDFFFF;
		Rs2 	 = 5;
		check_result(Rs1,Rs2);

		// SRA
		#5
		funct7_5 = 1;
		Rs1 	 = 32'hABCDFFFF;
		Rs2 	 = 3;
		check_result(Rs1,Rs2);
		#5

		for (i = 0;i < 20;i = i + 1) begin
			
			Rs1 	 = $random;
			Rs2 	 = $random;
			funct3_2 = $random;
			funct7_5 = $random;
			#5
			check_result(Rs1,Rs2);
		end

		$stop;

	end

	task check_result(input signed [XLEN-1:0] Rs1 ,input [4:0] Rs2);
		begin
			#2
			case (funct_test)
				SLL: expected_result = Rs1 << Rs2;
				SRL: expected_result = Rs1 >> Rs2;
				SRA: expected_result = Rs1 >>> Rs2;
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
