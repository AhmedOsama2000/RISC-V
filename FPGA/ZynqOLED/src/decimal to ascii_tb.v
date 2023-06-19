module decimal_to_ascii_tb();

   reg [31:0] decimal_tb;
   reg          load_data_tb;
   reg                clock_tb;
   reg              reset_tb;

   wire [511:0] ascii_tb;
   wire     complete_tb;

   decimal_to_ascii DUT (
  .decimal(decimal_tb),
  .load_data(load_data_tb),
  .clock(clock_tb),
  .reset(reset_tb),
  .complete(complete_tb),
  .ascii(ascii_tb)
);

always #5 clock_tb = ~clock_tb;



initial 
  begin
    clock_tb =1'b0 ;
    reset_tb =1'b1 ;
    load_data_tb = 1'b0 ;
   
#100
        reset_tb =1'b0 ;
        load_data_tb = 1'b1 ;
    decimal_tb = 32'd12812;
  #100
  load_data_tb = 1'b0 ;  
#1100
    load_data_tb = 1'b1 ;
    decimal_tb = 32'hffff_ffff;
  #100
  load_data_tb = 1'b0 ; 
#1300

    load_data_tb = 1'b1 ;
    decimal_tb = 32'd128;
  #100
  load_data_tb = 1'b0 ; 
#1300

#1300

    load_data_tb = 1'b1 ;
    decimal_tb = 32'd12;
  #100
  load_data_tb = 1'b0 ; 
#1300

    $finish;

    end

endmodule    
