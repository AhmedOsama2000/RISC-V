module RegFile_F #(
	parameter FLEN = 32
)
(
	// Control Signals
	input  wire 	       rst_n,
	input  wire 	       CLK,
	input  wire            Reg_Wr,
	input  wire       	   Reg_Rd,
	// Input
	input  wire [4:0] 	   Rs1_rd,
	input  wire [4:0] 	   Rs2_rd,
	input  wire [4:0]      Rd_Wr,
	input  wire [FLEN-1:0] Rd_In,
	// Output
	output reg  [FLEN-1:0] Rs1_Out,
	output reg  [FLEN-1:0] Rs2_Out
);

integer i = 0;

// Registers
reg [FLEN-1:0] F [0:31];

// Write Registers
always @(posedge CLK,negedge rst_n) begin
	
	if (!rst_n) begin
		for (i = 0;i < FLEN;i = i + 1) begin
			F[i] <= 'b0;
		end
		Rs1_Out <= 'b0;
		Rs2_Out <= 'b0;
	end
	else if (Reg_Wr) begin
		F[Rd_Wr] <= Rd_In;
	end

end

// Read Registers
always @(posedge CLK) begin
	
	if (Reg_Rd) begin
		Rs1_Out <= F[Rs1_rd];
		Rs2_Out <= F[Rs2_rd];
	end

end

endmodule