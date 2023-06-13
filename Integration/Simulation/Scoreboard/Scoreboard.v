module Hazard (
	// INPUT
	input  wire                    CLK,
	input  wire 				   rst_n,
	// Floating instruction detection
	input  wire                    fpu_ins,
	// Instruction Board Detection
	// Div   Detection
	input  wire                    IDiv,
	// Load  Detection
	input  wire                    MEM_Rd_En,
	// Store Detection
	input  wire                    MEM_Wr_En,
	// PC Change Detection        
	input  wire                    pc_change,
	input  wire                    Div_Done, // From Integer ALU
	// From Caches
	input  wire                    d_ready,
	input  wire                    d_stall,
	input  wire                    i_stall,
	// Register Sources
	input  wire [4:0] IF_ID_rs1,
	input  wire [4:0] IF_ID_rs2,
	input  wire [4:0] IF_ID_rd,
	// Registered Destination Sources
	input  wire [4:0] ID_EX_Reg_rd,
	// OUTPUT
	output wire		  PC_Stall,
	output wire		  NOP_Ins // no-operation insertion
);

// STATE MACHINE ENCODING
// Instructions Pipelined boards
// Divide Registeration
localparam BOARD1    = 1'b0;
localparam IDIVIDE   = 1'b1; 

// Load Registeration
localparam BOARD2    = 1'b0;
localparam LOAD      = 1'b1; 

// Store Registeration
localparam BOARD3    = 1'b0;
localparam STORE     = 1'b1;

// PC change Registeration
localparam BOARD4    = 1'b0;
localparam PC_CHANGE = 1'b1; 

// Expected Hazards
reg   expc_haz;

// Detect if the source is x0
reg   rs1_zero;
reg   rs2_zero;

// Stall The Core signal
reg [1:0] stall_core;

reg NS_1;
reg NS_2;
reg NS_3;
reg NS_4;
reg CS_1;
reg CS_2;
reg CS_3;
reg CS_4;

// assign rs1_zero   = (~IF_ID_rs1)? 1'b1:1'b0;
// assign rs2_zero   = (~IF_ID_rs2)? 1'b1:1'b0;
// assign expc_haz   = ( (IF_ID_rs1 == ID_EX_Reg_rd) || (IF_ID_rs2 == ID_EX_Reg_rd) && !rs1_zero && !rs2_zero )? 1'b1:1'b0;
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
		CS_1 <= BOARD1;
		CS_2 <= BOARD2;
		CS_3 <= BOARD3;
		CS_4 <= BOARD4;
	end
	else begin
		CS_1 <= NS_1;
		CS_2 <= NS_2;
		CS_3 <= NS_3;
		CS_4 <= NS_4;
	end
end

// FSM Logic
// Board_1 =====> DIVIDE 
always @(*) begin
	case (CS_1) 
		BOARD1: begin
			if (IDiv) begin
				NS_1  = IDIVIDE;
			end
			else begin
				NS_1  = BOARD1;
			end
		end
		IDIVIDE: begin
			if (!Div_Done) begin
				NS_1  = IDIVIDE;
			end
			else begin
				NS_1  = BOARD1;
			end
		end
		default: NS_1 =  BOARD1;
	endcase
end
// Board_2 =====> LOAD
always @(*) begin
	case (CS_2) 
		BOARD2: begin
			if (MEM_Rd_En) begin
				NS_2 = LOAD;
			end
			else begin
				NS_2 = BOARD2;
			end
		end
		LOAD: begin
			if (!d_ready) begin
				NS_2  = LOAD;
			end
			else begin
				NS_2  = BOARD2;
			end
		end
		default: NS_2 = BOARD2;
	endcase
end
// Board_3 =====> STORE
always @(*) begin
	case (CS_3) 
		BOARD3: begin
			if (MEM_Wr_En) begin
				NS_3  = STORE;
			end
			else begin
				NS_3  = BOARD3;
			end
		end
		STORE: begin
			if (!d_stall) begin
				NS_3  = STORE;
			end
			else begin
				NS_3  = BOARD3;
			end
		end
		default: NS_3 =  BOARD3;
	endcase
end
// Board_4 =====> PC Change
always @(*) begin
	case (CS_4) 
		BOARD4: begin
			if (pc_change) begin
				NS_4  = PC_CHANGE;
			end
			else begin
				NS_4  = BOARD4;
			end
		end
		PC_CHANGE: begin
			if (!i_stall) begin
				NS_4  = PC_CHANGE;
			end
			else begin
				NS_4  = BOARD4;
			end
		end
		default: NS_4 =  BOARD4;
	endcase
end

// Handle Exceptions
always @(*) begin
	if (CS_1 == IDIVIDE && expc_haz && !fpu_ins) begin
		stall_core = 2'b11;
	end
	else if (CS_2 == LOAD && expc_haz) begin
		stall_core = 2'b11;
	end
	else if (CS_3 == STORE) begin
		stall_core = 2'b11;
	end
	else if (CS_4 == PC_CHANGE) begin
		stall_core = 2'b11;
	end
	else begin
		stall_core = 2'b00;
	end
end

endmodule