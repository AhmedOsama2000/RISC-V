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


always @(posedge CLK or negedge RST) begin
    if (~RST) begin
        PC <= 'b0 ;
        Valid <= 1'b0 ;       
    end
    else if (PC_stall) begin
        PC <= PC ; 
        Valid <= 1'b0 ;
    end
    else if (PC_next_sel) begin
        PC <= PC_jump_branch ;
        Valid <= 1'b1 ; 
    end
    else begin
        PC <= PC + 4 ;
        Valid <= 1'b1 ; 
    end
end


endmodule