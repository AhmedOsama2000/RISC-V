module Branch_Unit_tb;

	parameter XLEN   = 32;
	parameter FUNCT3 = 3;

	reg [FUNCT3-1:0] 	  funct3;
	reg signed [XLEN-1:0] Rs1;
	reg signed [XLEN-1:0] Rs2;

	reg        [XLEN-1:0] Expected_res;
	reg 			 	  En;

	wire Branch_taken;

	reg [XLEN-1:0] temp_res;

	reg expected_branch_taken;

	integer i;

	always @(*) begin
		
		Expected_res = Rs1 - Rs2;

	end

	Branch_Unit DUT (
		.Rs1(Rs1),
		.Rs2(Rs2),
		.ALU_Res(Expected_res),
		.funct3(funct3),
		.En(En),
		.Branch_taken(Branch_taken)
		);

	localparam BEQ  = 3'b000;
	localparam BNE  = 3'b001;
	localparam BLT  = 3'b100;
	localparam BGE  = 3'b101;
	localparam BLTU = 3'b110;
	localparam BGEU = 3'b111;

	initial begin
		
		En = 0;
		Rs1 = 0;
		Rs2 = 0;

		#5
		En = 1;
		funct3 = BEQ;
		Rs1 = 5;
		Rs2 = 5;
		check_result(Rs1,Rs2);

		#5
		funct3 = BNE;
		check_result(Rs1,Rs2);

		#5

		funct3 = BLT;
		Rs1 = -7;
		Rs2 = 4;
		check_result(Rs1,Rs2);

		#5
		funct3 = BGE;
		Rs1 = 50;
		Rs2 = 30;
		check_result(Rs1,Rs2);

		#5
		funct3 = BLTU;
		Rs1 = -7;
		Rs2 = 4;
		check_result(Rs1,Rs2);

		#5
		funct3 = BGEU;
		Rs1 = -50;
		Rs1 = -10;
		check_result(Rs1,Rs2);

		#5

		for (i = 0;i < 50;i = i + 1) begin

			funct3 = $random;
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
			case (funct3)
				BEQ:  expected_branch_taken = (Src1 == Src2)? 1'b1:1'b0;
				BNE:  expected_branch_taken = (Src1 != Src2)? 1'b1:1'b0;
				BLT: begin
					if (Src1[XLEN-1] != Src2[XLEN-1]) begin
						expected_branch_taken = Src1[XLEN-1];
					end
					else begin
						expected_branch_taken = Expected_res[XLEN-1];
					end 
				end
				BLTU: begin
					if (Src1 < Src2) begin
						expected_branch_taken = 1'b1;
					end
					else begin
						expected_branch_taken = 1'b0;
					end 
				end
				BGE: begin
					temp_res = Expected_res * -1;
					if (Src1[XLEN-1] != Src2[XLEN-1]) begin
						expected_branch_taken = Src2[XLEN-1];
					end
					else begin
						expected_branch_taken = temp_res[XLEN-1];
					end 
				end
				BGEU: begin
					if (Src1 >= Src2) begin
						expected_branch_taken = 1'b1;
					end
					else begin
						expected_branch_taken = 1'b0;
					end 
				end
				default: expected_branch_taken = 1'b0;
			endcase
			if (expected_branch_taken === Branch_taken) begin
				$display("At time %0t:Result = %0d = %0d",$time,Branch_taken,expected_branch_taken);
			end
			else begin
				$display("At time %0t:Result = %0d not = %0d",$time,Branch_taken,expected_branch_taken);
			end

		end
	endtask

endmodule