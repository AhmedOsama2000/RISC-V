(* keep_hierarchy = "yes" *) module F_CMP #(
	parameter FLEN = 32
)
(
	input  wire            En,
	input  wire [FLEN-1:0] Rs1,
	input  wire [FLEN-1:0] Rs2,
	input  wire [1:0]	   Funct3_1_0,
	output reg  [FLEN-1:0] Result
);

localparam FEQ = 2'b10;
localparam FLT = 2'b01;
localparam FLE = 2'b00;

wire        sign_rs1;
wire        sign_rs2;
wire [7:0]  exp_rs1;
wire [7:0]  exp_rs2;
wire [22:0] mantisa_rs1;
wire [22:0] mantisa_rs2;

wire        eq_flag;
reg         less_flag;

assign {sign_rs1,exp_rs1,mantisa_rs1} = Rs1;
assign {sign_rs2,exp_rs2,mantisa_rs2} = Rs2;

assign eq_flag = ((Rs1 == Rs2) && En)? 1'b1:1'b0;

always @(*) begin
	
	Result = 'b0;
	if (En) begin
		case (Funct3_1_0)
			FEQ: begin
			 	Result[0] = (eq_flag)? 1'b1:1'b0;
		 	end 
			FLT: begin
				Result[0] = (less_flag)? 1'b1:1'b0;
			end
			FLE: begin
				Result[0] = (eq_flag || less_flag)? 1'b1:1'b0;
			end
			default: Result = 'b0;
		endcase
	end
	else begin
		Result = 'b0;
	end
end

always @(*) begin
	if (En) begin
		if ((sign_rs1 && !sign_rs2)) begin
				less_flag = 1'b1;
			end
			else if (({exp_rs1,mantisa_rs1} < {exp_rs2,mantisa_rs2}) && !sign_rs1 && !sign_rs2) begin
				less_flag = 1'b1;
			end
			else if (!({exp_rs1,mantisa_rs1} < {exp_rs2,mantisa_rs2}) && sign_rs1 && sign_rs2) begin
				less_flag = 1'b1;
			end
			else begin
				less_flag = 1'b0;
			end
	end
	else begin
		less_flag = 1'b0;
	end
end

endmodule