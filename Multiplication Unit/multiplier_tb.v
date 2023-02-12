`timescale 1ns / 1ns
module multiplier_tb (); 

    parameter data_width_tb = 32 ; 
    parameter group_count_tb = 17 ;
    reg    [data_width_tb-1 : 0]    Multiplicand_tb ;
    reg    [data_width_tb-1 : 0]    Multiplier_tb ;
    wire    [2*data_width_tb-1 :0]    Product_tb ;


    // Clock Generator // 

  




 //initial block
initial 

    begin
            $display($time, " << Starting the Simulation >>");

            Multiplicand_tb = 'd5 ;
            Multiplier_tb   = 'd20;
            #10
            Multiplicand_tb = -'d5 ;
            Multiplier_tb   = -'d20;

            #5 
            $stop;

    end 

    initial
$monitor("time=%.3f ps, Multiplicand_tb=%b, Multiplier_tb=%b, Product_tb=%b\n",$realtime,Multiplicand_tb,Multiplier_tb,Product_tb);




    multiplier  dut  (


    .Multiplicand(Multiplicand_tb),
    .Multiplier(Multiplier_tb),
    .Product(Product_tb) 

        ); 

endmodule