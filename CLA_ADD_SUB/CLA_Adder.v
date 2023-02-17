module CLA_ADD_SUB
#(
  	parameter WIDTH = 4
)
(
	input  wire [WIDTH-1:0] rs_1,
	input  wire [WIDTH-1:0] rs_2,
	input  wire             En,
	input  wire             funct7_5,
	output wire [WIDTH-1:0] result,
	output wire             overflow
);
     
wire [WIDTH:0]   Carry;
wire [WIDTH-1:0] G;
wire [WIDTH-1:0] Pg;
wire [WIDTH-1:0] Sum;
wire [WIDTH-1:0] passed_rs2; 

assign passed_rs2 = (funct7_5 && En)? ~rs_2:rs_2;

// Create the Full Adders
genvar full_adder_gen;
generate
	for (full_adder_gen = 0; full_adder_gen < WIDTH;full_adder_gen = full_adder_gen + 1) begin

		// Output Carry is not needed but generated via the CLA_Generator
		FA full_adder_insts ( 
			.A0(rs_1[full_adder_gen]),
			.B0(passed_rs2[full_adder_gen]),
			.C0(Carry[full_adder_gen]),
			.En(En),
			.S0(Sum[full_adder_gen])
		);
	end
endgenerate
 	
// CLA_Generator	
// Generate carries
genvar             gen_c;
generate
	for (gen_c = 0; gen_c < WIDTH; gen_c = gen_c + 1) begin

	    assign G[gen_c]  			= rs_1[gen_c] & passed_rs2[gen_c] & En;
	    assign Pg[gen_c]  		= (rs_1[gen_c] | passed_rs2[gen_c]) & En;
	    assign Carry[gen_c+1] = (G[gen_c] | (Pg[gen_c] & Carry[gen_c])) & En;

	 end
endgenerate
   
  // Carry Depend on ADD/SUB Operation
  assign Carry[0] = funct7_5;
 
  assign {overflow,result} = {Carry[WIDTH] ^ Carry[WIDTH-1],Sum};
 
endmodule
