(* DONT_TOUCH = "TRUE" *) module PC (
    // input
    input wire        CLK,
    input wire        rst_n,
    input wire [31:0] PC_Addr,
    input wire        En_PC,
    input wire        stall_pc,
    input wire        PC_Change,
    // output
    output reg [31:0] PC_Out,
    output reg        PC_done     
);

always @(posedge CLK,negedge rst_n) begin
    if (!rst_n) begin
        PC_Out  <= 32'b0;
        PC_done <= 1'b0;
    end
    else if (PC_Out == 32'h1f) begin
        PC_done <= 1'b1;
    end
    else if (En_PC && PC_Change) begin
        PC_Out <= PC_Addr/4;
    end      
    else if (En_PC && !stall_pc && !PC_done) begin
        PC_Out <= PC_Out + 1'b1;
    end
end


endmodule