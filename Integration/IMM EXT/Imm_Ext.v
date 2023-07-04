module IMM_EXT 
(
	input  wire [31:0] IMM_IN,
	input  wire [4:0]  opcode,     
	output reg  [31:0] IMM_OUT
);

localparam ARITM_IMM = 5'b00100;

localparam LOAD_I    = 5'b00000; // load integer  value
localparam LOAD_F    = 5'b00001; // load floating value

localparam JAL       = 5'b11011;
localparam BRANCH 	 = 5'b11000;

localparam STORE_I 	 = 5'b01000; // Store integer  value
localparam STORE_F 	 = 5'b01001; // Store floating value

localparam LUI     	 = 5'b01101; 
localparam AUIPC   	 = 5'b00101;

localparam JALR    	 = 5'b11001;

always @(*) begin
	case (opcode)
		JAL: begin
			IMM_OUT = {{11{IMM_IN[31]}},IMM_IN[31],IMM_IN[19:12],IMM_IN[20],IMM_IN[30:21],1'b0};
		end
		LUI , AUIPC: begin
			IMM_OUT = {IMM_IN[31:12], {12{1'b0}}};
		end
		ARITM_IMM , JALR, LOAD_I , LOAD_F: begin
			IMM_OUT = {{20{IMM_IN[31]}},IMM_IN[31:20]};
		end
		BRANCH: begin
			IMM_OUT = {{19{IMM_IN[31]}},IMM_IN[31],IMM_IN[7],IMM_IN[30:25],IMM_IN[11:8],1'b0};
		end
		STORE_I , STORE_F: begin
			IMM_OUT = {{20{IMM_IN[31]}},IMM_IN[31:25],IMM_IN[11:7]};
		end
		default: IMM_OUT = 32'b0;
	endcase
end

endmodule
