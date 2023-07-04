(* DONT_TOUCH = "TRUE" *) module IMem (
	(* DONT_TOUCH = "TRUE" *) input  wire [31:0] PC,
	(* DONT_TOUCH = "TRUE" *) output wire [31:0] instr
);

(* DONT_TOUCH = "TRUE" *) wire [31:0] IMEM [0:31];

assign instr = IMEM[PC];


assign IMEM[0]  = 32'h03228293;
assign IMEM[1]  = 32'h03c30313;
assign IMEM[2]  = 32'h00628663;
assign IMEM[3]  = 32'h005303b3;
assign IMEM[4]  = 32'h02628433;
assign IMEM[5]  = 32'h40728a33;
assign IMEM[6]  = 32'h02738ab3;
assign IMEM[7]  = 32'h00748b33;

assign IMEM[8]  = 32'h00350293;
assign IMEM[9]  = 32'hd002f2d3;
assign IMEM[10] = 32'hd0037353;
assign IMEM[11] = 32'h1062f3d3;
assign IMEM[12] = 32'h00052407;
assign IMEM[13] = 32'ha06285d3;
assign IMEM[14] = 32'h0052f2d3;
assign IMEM[15] = 32'hfeb04ce3;

assign IMEM[16] = 32'h10637353;
assign IMEM[17] = 32'h10647553;
assign IMEM[18] = 32'h00000013;
assign IMEM[19] = 32'h00000013;
assign IMEM[20] = 32'h00000013;
assign IMEM[21] = 32'h00000013;
assign IMEM[22] = 32'h00000013;
assign IMEM[23] = 32'h00000013;

assign IMEM[24] = 32'h00000013;
assign IMEM[25] = 32'h00000013;
assign IMEM[26] = 32'h00000013;
assign IMEM[27] = 32'h00000013;
assign IMEM[28] = 32'h00000013;
assign IMEM[29] = 32'h00000013;
assign IMEM[30] = 32'h00000013;
assign IMEM[31] = 32'h00000013;


endmodule