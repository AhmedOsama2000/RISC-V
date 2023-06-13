module PC #(

parameter XLEN = 32

)

(
// input
input   wire                              CLK ,
input   wire                              RST ,
input   wire                              PC_next_sel ,
input   wire                              PC_stall ,
input   wire    [XLEN-1:0]                PC_jump_branch ,

// output
output  reg     [XLEN-1:0]                PC ,      
output  reg                               Valid 
);

reg         en_pc_st_0; // ENABLE PC STATE 0 IF FIRST RUN CORE
reg [2:0]   COUNTER;

always @(posedge CLK or negedge RST) begin
    if (~RST) begin
        PC          <= 'b0 ;
        en_pc_st_0  <= 1'b0 ;
        Valid       <= 1'b0 ;       
    end
    else if (PC_stall || COUNTER == 3'b111) begin
        Valid <= 1'b0 ;
        PC    <= PC ; 
    end
    else if (PC == 32'b0 && ~en_pc_st_0) begin
        en_pc_st_0 <= 1'b1 ; 
        Valid      <= 1'b1 ;
    end
    else if (PC_next_sel) begin
        PC    <= PC_jump_branch ;
        Valid <= 1'b1 ; 
    end
    else begin
        PC    <= PC + 4 ;
        Valid <= 1'b1 ; 
    end
end


always @(posedge CLK or negedge RST) begin
    if (~RST) begin
        COUNTER <= 'b0 ;
    end
    else if (COUNTER == 3'b111) begin
        COUNTER <= 'b0 ;
    end
    else if (Valid) begin
        COUNTER <= COUNTER + 1 ;
    end
end


endmodule