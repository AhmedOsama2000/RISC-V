module Division_Unit #(
	parameter XLEN 		  = 32,
	parameter COUNT_WIDTH = $clog2(XLEN)
)
(
	//inputs
	input  wire               CLK,
	input  wire               rst_n,
    	input  wire [XLEN - 1:0]  dividend,
    	input  wire [XLEN - 1:0]  divisor,
    	input  wire               data_valid,

	//outputs    
	output reg  [XLEN - 1:0]  quotient,
	output reg  [XLEN - 1:0]  remainder,
	output wire               divided_by_zero,
	output reg                data_ready
);

localparam IDLE    = 2'b00;
localparam DIVIDE  = 2'b01;
localparam CORRECT = 2'b11;

reg [1:0] NS;
reg [1:0] CS;

reg [COUNT_WIDTH-1:0] counter;

reg [XLEN-1:0] 		  dividend_Q;
reg [XLEN-1:0] 		  dividend_temp;

reg [XLEN:0] 		  accumulator_reg;
reg [XLEN:0] 		  accumulator;

reg [XLEN-1:0] 		  divisor_reg;

reg                  	  Q_LSB;
reg                       flag_zero ;

assign divided_by_zero = (flag_zero & (!divisor)) ? 1'b1 : 1'b0 ;


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
			if (data_valid & (divisor != 'b0)) begin
				NS = DIVIDE;
			end
			else begin
				NS = IDLE;
			end
		end
		DIVIDE: begin
			if (&counter) begin
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
					if(!divisor) begin
						flag_zero <= 1'b1 ;
						data_ready <= 1'b1 ;	
					end else begin
						{accumulator_reg,dividend_Q} <=    {33'b0,dividend};
						divisor_reg 		     <=             divisor;
						flag_zero                    <=               1'b0 ;		
					end
			end
		end
		DIVIDE: begin
			{accumulator_reg,dividend_Q} <= {accumulator,dividend_temp[XLEN-1:1],Q_LSB};
			 counter <= counter + 1;
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

	if (!counter && CS == CORRECT) begin
		{accumulator,dividend_temp[XLEN-1:1],Q_LSB} = {accumulator_reg,dividend_Q[XLEN-1:1],dividend_Q[0]};
		if (accumulator_reg[XLEN]) begin
			accumulator = accumulator + divisor_reg;
		end
		else begin
			accumulator = accumulator_reg;
		end

	end
	else begin
		
		{accumulator,dividend_temp} = {accumulator_reg,dividend_Q};

		{accumulator,dividend_temp} = {accumulator[XLEN-1:0],dividend_temp[XLEN-1],dividend_temp[XLEN-2:0],1'b0};

		if (accumulator[XLEN]) begin
			accumulator = accumulator + divisor_reg;
		end
		else begin
			accumulator = accumulator - divisor_reg;
		end

		if (accumulator[XLEN]) begin
			Q_LSB = 1'b0;
		end
		else begin
			Q_LSB = 1'b1;
		end

	end

end

endmodule
