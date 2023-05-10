module SET_UNIT #(
	parameter XLEN = 32
) 
(
	input  wire [XLEN-1:0] Rs1,
	input  wire [XLEN-1:0] Rs2,
	input  wire [XLEN-1:0] ALU_Res,
	input  wire  		   funct3_0,
	input  wire 		   En,
	output reg  [XLEN-1:0] result 
);

localparam SLT  = 1'b0;
localparam SLTU = 1'b1;

always @(*) begin
	
	if (En && funct3_0 == SLTU) begin

		if (Rs1 < Rs2) begin
			result = 32'h00000001;
		end
		else begin
			result = 32'h00000000;
		end

	end
	else if (En && funct3_0 == SLT) begin
		if (Rs1[XLEN-1] == Rs2[XLEN-1]) begin
			// Reuse the ALU_Result 
			result = {28'h0000000,3'b000,ALU_Res[XLEN-1]};
		end
		else begin
			result = {28'h0000000,3'b000,Rs1[XLEN-1]};
		end
	end
	else begin
		result = 32'h00000000;
	end

end

endmodule