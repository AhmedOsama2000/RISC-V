module Memory_Ctrl
(
	input  wire Funct3_0,
	input  wire MEM_Rd_En, // Load  Condition
	input  wire MEM_Wr_En, // Store Condition
	output reg  LB,
	output reg  LH,
	output reg  SB,
	output reg  SH
);

localparam BYTE  = 1'b0;
localparam HALF  = 1'b1;

always @(*) begin
	LB = 1'b0;
	LH = 1'b0;
	SB = 1'b0;
	SH = 1'b0;
	if (Funct3_0 == BYTE && MEM_Rd_En) begin
		LB = 1'b1;
	end
	else if (Funct3_0 == HALF && MEM_Rd_En) begin
		LH = 1'b1;
	end
	else if (Funct3_0 == BYTE && MEM_Wr_En) begin
		SB = 1'b1;
	end
	else if (Funct3_0 == HALF && MEM_Wr_En) begin
		SH = 1'b1;
	end
	else begin
		LB = 1'b0;
		LH = 1'b0;
		SB = 1'b0;
		SH = 1'b0;
	end
end

endmodule