(* DONT_TOUCH = "TRUE" *) module Hazard (
	// INPUT
	input  wire       CLK,
	input  wire 	  rst_n,
	// Floating instruction detection
	input  wire       fpu_ins,
	input  wire [6:0] Opcode,
	// Instruction Board Detection
	// Div   Detection
	input  wire       IDiv,
	// PC Change Detection        
	input  wire       pc_change,
	input  wire       Div_Done, // From Integer ALU
	// Register Sources
	input  wire [4:0] IF_ID_rs1,
	input  wire [4:0] IF_ID_rs2,
	input  wire [4:0] IF_ID_rd,
	// Registered Destination Sources
	input  wire [4:0] ID_EX_Reg_rd,
	// OUTPUT
	output wire		  PC_Stall,
	output wire		  NOP_Ins, // no-operation insertion
	output reg        flush
);

// Expected Hazards
reg   expc_haz;

localparam IDLE = 1'b0;
localparam IDIV = 1'b1;

// Detect if the source is x0
reg   rs1_zero;
reg   rs2_zero;

// Stall The Core signal
reg [1:0] stall_core;

reg NS;
reg CS;

assign {PC_Stall,NOP_Ins} = stall_core; 

always @(*) begin
	if (!IF_ID_rs1) begin
		rs1_zero = 1'b1 ;
	end
	else begin
		rs1_zero = 1'b0 ;
	end
end

always @(*) begin
	if (!IF_ID_rs2) begin
		rs2_zero = 1'b1 ;
	end
	else begin
		rs2_zero = 1'b0 ;
	end
end

always @(*) begin
	if ((IF_ID_rs1 == ID_EX_Reg_rd) || (IF_ID_rs2 == ID_EX_Reg_rd)) begin
		if (!rs1_zero && !rs2_zero) begin
			expc_haz = 1'b1 ;
		end
		else begin
			expc_haz = 1'b0 ;
		end
	end
	else begin
		expc_haz = 1'b0 ;
	end
end

// Next State Logic 
always @(posedge CLK,negedge rst_n) begin	
	if (!rst_n) begin
		CS <= IDLE;
	end
	else begin
		CS <= NS;
	end
end

// FSM Logic
always @(*) begin
	case (CS) 
		IDLE: begin
			if (IDiv) begin
				NS  = IDIV;
			end
			else begin
				NS  = IDLE;
			end
		end
		IDIV: begin
			if (!Div_Done) begin
				NS  = IDIV;
			end
			else begin
				NS  = IDLE;
			end
		end
		default: NS =  IDLE;
	endcase
end

// Handle Exceptions
always @(*) begin
	flush 	   = 1'b0;
	stall_core = 2'b00;
	if (CS == IDIV && !fpu_ins) begin
		stall_core = 2'b11;
	end
	else if (pc_change) begin
		flush      = 1'b1;
		stall_core = 2'b01;
	end
	else if ( (Opcode == 7'b0000011 || Opcode == 7'b0000111) && expc_haz) begin
		stall_core = 2'b11;
	end
	else begin
		stall_core = 2'b00;
		flush      = 1'b0;
	end
end

endmodule