(* DONT_TOUCH = "TRUE" *)module mux8x1 #(
	parameter XLEN = 32
) 
(
	input  wire [XLEN-1:0] i0,
	input  wire [XLEN-1:0] i1,
	input  wire [XLEN-1:0] i2,
	input  wire [XLEN-1:0] i3,
	input  wire [XLEN-1:0] i4,
	input  wire            sel0,
	input  wire            sel1,
	input  wire            sel2,
	output reg  [XLEN-1:0] out
);

wire [2:0] sel_mux;

assign sel_mux = {sel2,sel1,sel0};

always @(*) begin
	if (sel_mux == 3'b000) begin
		out = i0;
	end
	else if (sel_mux == 3'b001) begin
		out = i1;
	end
	else if (sel_mux == 3'b010) begin
		out = i2;
	end
	else if (sel_mux == 3'b011) begin
		out = i3;
	end
	else if (sel_mux == 3'b100) begin
		out = i4;
	end
	else begin
		out = i0;
	end
end

endmodule