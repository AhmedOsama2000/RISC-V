module CLA_Adder_tb;

	parameter WIDTH = 32;

	reg [WIDTH-1:0] Rs1;
	reg [WIDTH-1:0] Rs2;
	reg              En;
	reg              funct7_5;
	wire [WIDTH-1:0] result;
	wire             overflow;

	reg [WIDTH-1:0] check_res;
	integer i;

	CLA_ADD_SUB DUT (
		.Rs1(Rs1),
		.Rs2(Rs2),
		.En(En),
		.funct7_5(funct7_5),
		.result(result),
		.overflow(overflow)
	);

	initial begin
		
		En = 1'b1;

		for (i = 0;i < 50;i = i + 1) begin
			Rs1 = $random;
			Rs2 = $random;
			funct7_5  = $random;
			#5
			check_sum(Rs1,Rs2);	
		end
		#5

		En = 1'b0;
		#5

		$stop;

	end

	task check_sum (input signed [WIDTH-1:0]  src_1,input signed [WIDTH-1:0] src_2);
		begin
			
			if (funct7_5) begin
				check_res = src_1 - src_2;
			end
			else begin
				check_res = src_1 + src_2;
			end

			if (check_res == result) begin
				$display("%0t Correct check_res",$time);
			end
			else begin
				$display("%0t Incorrect check_res = %0d != {overflow,result} == %0d",$time,check_res,{overflow,result});
			end

		end
	endtask

endmodule
