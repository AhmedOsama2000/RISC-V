module non_restoring_floating #(
	parameter XLEN_m 		  = 24,
	parameter COUNT_WIDTH = 5  // 5 bits 
)
(
	//inputs
	input  wire               CLK,
	input  wire               rst_n,
    input  wire [XLEN_m - 1:0]  dividend,
    input  wire [XLEN_m - 1:0]  divisor,
    input  wire               data_valid,

	//outputs    
	output reg  [XLEN_m - 1:0]  quotient,
	output reg  [XLEN_m - 1:0]  remainder,
	output reg                data_ready
);

localparam IDLE    = 2'b00;
localparam DIVIDE  = 2'b01;
localparam CORRECT = 2'b11;

reg [1:0] NS;
reg [1:0] CS;

reg [COUNT_WIDTH-1:0] counter;

reg [XLEN_m-1:0] 		  dividend_Q;
reg [XLEN_m-1:0] 		  dividend_temp;

reg [XLEN_m:0] 		  accumulator_reg;
reg [XLEN_m:0] 		  accumulator;

reg [XLEN_m-1:0] 		  divisor_reg;

reg                   Q_LSB;
reg                   flag_zero ;




// Next State Logic
always @(posedge CLK,negedge rst_n) begin
	
	if (!rst_n) begin
		CS <= IDLE;
	end
	else begin
		CS <= NS;
	end

end

// FSM LOGIC
always @(*) begin
	
	case (CS)
		IDLE: begin
			if (data_valid) begin
				NS = DIVIDE;
			end
			else begin
				NS = IDLE;
			end
		end
		DIVIDE: begin
			if (counter == 5'd23) begin
				NS = CORRECT;
			end
			else begin
				NS = DIVIDE;
			end
		end
		CORRECT: begin
			NS = IDLE;
		end
		default: NS = IDLE;
	endcase
end

// FSM OUTPUT
always @(posedge CLK) begin
	
	case(CS)
		IDLE: begin
			counter    <= 'b0;
			data_ready <= 1'b0;
			
			if (data_valid) begin
					
				 	{accumulator_reg,dividend_Q} <= {25'b0,dividend};
					divisor_reg 				 <= divisor;
					flag_zero                    <= 1'b0 ;		
					
			end
		end
		DIVIDE: begin
			{accumulator_reg,dividend_Q} <= {accumulator,dividend_temp[XLEN_m-1:1],Q_LSB};
			counter    					 <= counter + 1;
		end
		CORRECT: begin
			quotient   <= dividend_Q;
			remainder  <= accumulator;
			data_ready <= 1'b1;
		end
	endcase
end

// Accumulator ALU
always @(*) begin

	if ((counter == 5'd24) && CS == CORRECT) begin
		{accumulator,dividend_temp[XLEN_m-1:1],Q_LSB} = {accumulator_reg,dividend_Q[XLEN_m-1:1],dividend_Q[0]};
		if (accumulator_reg[XLEN_m]) begin
			accumulator = accumulator + divisor_reg;
		end
		else begin
			accumulator = accumulator_reg;
		end

	end
	else begin
		
		{accumulator,dividend_temp} = {accumulator_reg,dividend_Q};

		{accumulator,dividend_temp} = {accumulator[XLEN_m-1:0],dividend_temp[XLEN_m-1],dividend_temp[XLEN_m-2:0],1'b0};

		if (accumulator[XLEN_m]) begin
			accumulator = accumulator + divisor_reg;
		end
		else begin
			accumulator = accumulator - divisor_reg;
		end

		if (accumulator[XLEN_m]) begin
			Q_LSB = 1'b0;
		end
		else begin
			Q_LSB = 1'b1;
		end

	end

end

endmodule