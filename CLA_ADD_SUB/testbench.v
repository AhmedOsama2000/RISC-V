module CLA_Adder_tb;

	parameter WIDTH = 32;

	reg [WIDTH-1:0] rs_1;
	reg [WIDTH-1:0] rs_2;
	reg              En;
	reg              SUB;
	wire [WIDTH-1:0] result;
	wire             overflow;

	reg [WIDTH:0] check_res;
	integer i;

	CLA_ADD_SUB DUT (
		.rs_1(rs_1),
		.rs_2(rs_2),
		.En(En),
		.SUB(SUB),
		.result(result),
		.overflow(overflow)
	);

	initial begin
		
		En = 1'b1;

		for (i = 0;i < 50;i = i + 1) begin
			rs_1 = $random;
			rs_2 = $random;
			SUB  = $random;
			#5
			check_sum(rs_1,rs_2);	
		end
		#5

		$stop;

	end

	task check_sum (input [WIDTH-1:0] src_1,input [WIDTH-1:0] src_2);
		begin
			
			if (SUB) begin
				check_res = rs_1 - rs_2;
			end
			else begin
				check_res = rs_1 + rs_2;
			end

			if (check_res == {overflow,result}) begin
				$display("%0t Correct check_res = %0d = {overflow,result}",$time,check_res,{overflow,result});
			end
			else begin
				$display("%0t Incorrect check_res = %0d != {overflow,result} == %0d",$time,check_res,{overflow,result});
			end

		end
	endtask

endmodule