module SET_UNIT_tb;

	parameter XLEN   = 32;

	reg signed [XLEN-1:0] Rs1;
	reg signed [XLEN-1:0] Rs2;
	reg                   funct3_0;
	reg        [XLEN-1:0] Expected_res;
	reg 			 	  En;
	wire       [XLEN-1:0] result;


	reg [XLEN-1:0] check_res;
	reg [XLEN-1:0] Expected_alu_res;

	integer i;

	always @(*) begin
		
		Expected_alu_res = Rs1 - Rs2;

	end

	SET_UNIT DUT (
		.Rs1(Rs1),
		.Rs2(Rs2),
		.ALU_Res(Expected_alu_res),
		.funct3_0(funct3_0),
		.En(En),
		.result(result)
	);

	initial begin
		
		En = 1'b1;
		Rs1 = 0;
		Rs2 = 0;

		#5
		// Check SLTU
		Rs1 = -5;
		Rs2 = -7;
		funct3_0 = 1'b1;
		check_result(Rs1,Rs2);

		#5
		// Check SLT
		Rs1 = -5;
		Rs2 = -3;
		funct3_0 = 1'b0;
		check_result(Rs1,Rs2);
		#5

		for (i = 0;i < 50;i = i + 1) begin

			funct3_0 = $random;
			Rs1 = $random;
			Rs2 = $random;
			check_result(Rs1,Rs2);
			#5;

		end

		$stop;
	end

	task check_result(input signed [XLEN-1:0] Src1 ,input [XLEN-1:0] Src2);
		begin
			#1
			if (funct3_0) begin
				if (Src1 < Src2) begin
					check_res = 32'h00000001;
				end
				else begin
					check_res = 'b0;
				end
			end
			else begin
				if (Src1[XLEN-1] != Src2[XLEN-1]) begin
					check_res = {28'h0000000,3'b000,Src1[XLEN-1]};
				end
				else begin
					check_res = {28'h0000000,3'b000,Expected_alu_res[XLEN-1]};
				end 
			end

			if (check_res == result) begin
				$display("At %0t Correct",$time);
			end
			else begin
				$display("At %0t Incorrect",$time);
			end

		end
	endtask

endmodule