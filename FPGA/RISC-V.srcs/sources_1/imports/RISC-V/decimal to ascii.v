module decimal_to_ascii(
    
    input  wire  [31:0] decimal,
    input  wire       load_data,
    input  wire           clock,      //100MHz onboard clock
    input  wire           reset,
    output reg          complete,
    output reg    [511:0]  ascii
);

reg [7:0]          temp;
reg [31:0]  decimal_temp;
reg [1:0]        counter;
wire                done;
reg               flag;

reg clock_10;
reg [2:0] counter_clock ;


assign done = (decimal_temp == 32'd0) ? 1'b1 : 1'b0 ;
assign start =((decimal_temp != 32'd0)|| load_data ) ? 1'b1 : 1'b0 ;


always @(posedge clock)
begin
    if(counter_clock != 4)
        counter_clock <= counter_clock + 1;
    else
        counter_clock <= 0;
end

initial
    clock_10 <= 0;

always @(posedge clock)
begin
    if(counter_clock == 4)
        clock_10 <= ~clock_10;
end



always @(posedge clock_10) begin
    
        if (reset)
          begin
              //start <= 1'b0;
              ascii        <= {64{8'h02}};   // initial all 64 digits is spaces
              temp         <=      8'd02 ;
              decimal_temp <=      32'd0 ;
              complete     <=        1'b0;
              flag         <=        1'b0; 
 


          end
          else if (load_data) 
          begin
             decimal_temp <=    decimal ;
             ascii        <= {64{8'h02}};   // initial all 64 digits is spaces
             temp         <=      8'd02 ;
             complete     <=        1'b0; 
             flag         <=        1'b0; 

            
            
           end 
         else if ((~done) & start) 
          begin
             flag         <=                         1'b0; 
             temp         <= (decimal_temp % 10) + 8'd48 ;
             complete     <=                         1'b0; 
             decimal_temp <=           decimal_temp / 10 ;
             ascii        <=         {temp,ascii[511:8]} ;
           end 
        else if (counter == 2'b1) 
          begin
             ascii    <= {temp,ascii[511:8]} ;
             complete <=                1'b1 ;
             flag     <=                1'b1 ; 
           end 
end

always @(posedge clock_10) begin 
  if(reset || load_data) begin
     counter <= 2'b0;
  end else if (done && ~flag ) begin
     counter <= counter + 1;
  end else begin
    counter <= 2'b0;
  end
      
end


endmodule