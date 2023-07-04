module delayGen(
    input wire clock,
    input wire delayEn,
    output reg delayDone
    );
    
reg [17:0] counter;    

always @(posedge clock)
begin
    if(delayEn & counter!=200000)
        counter <= counter+1;
    else
        counter <= 0;
end

always @(posedge clock)
begin
    if(delayEn & counter==200000)
        delayDone <= 1'b1;
    else
        delayDone <= 1'b0;
end
    
endmodule