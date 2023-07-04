module Data_Memory (clk, we, addr, di, dout);
    input clk;
//    input en;
    input         we;
    input  [31:0] addr;
    input  [31:0] di;
    output [31:0] dout;
    
    reg [31:0] ram [0:7];
    reg [31:0] dout;
    
    always @(posedge clk) begin
        if (we) //write enable
            ram[addr] <= di;
        else
            dout <= ram[addr];
        end
    
   initial begin
        ram[0] = 32'h40490fdb;
        ram[1] = 32'ha;
        ram[2] = 32'hc;
        ram[3] = 32'h3;
        ram[4] = 32'h44;
        ram[5] = 32'h2;
        ram[6] = 32'h5;
        ram[7] = 32'h5;
   end
    
endmodule
