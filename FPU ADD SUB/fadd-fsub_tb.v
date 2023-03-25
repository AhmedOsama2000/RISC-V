module fadd_fsub_tb ();
    

parameter XLEN = 32;


reg    [XLEN-1 : 0]              frs1_tb ;
reg    [XLEN-1 : 0]              frs2_tb ;
reg                              En_tb ;
reg                              rst_n_tb ;
reg                              Funct_tb ;
wire   [XLEN-1 : 0]              frd_tb ;


fadd_fsub add_sub (

.frs1 (frs1_tb) ,
.frs2 (frs2_tb) ,
.En (En_tb) ,
.rst_n (rst_n_tb) ,
.Funct (Funct_tb) ,
.frd (frd_tb) 

);



initial
 begin
    $display("===============================================================================");
    $display("================================= run =================================");

    initialization ();
    #10
    En_tb = 1'b1 ;
    Funct_tb = 1'b0;
    #10
    frs1_tb = 32'b01000000001000000000000000000000 ;
    frs2_tb = 32'b00000000000000000000000000000000 ;
    #10
    frs1_tb = 32'b11000000001000000000000000000000 ;
    frs2_tb = 32'b00111111101000000000000000000000 ;
    #10
    #10
    Funct_tb = 1;
    frs1_tb = 32'b01000000001000000000000000000000 ;
    frs2_tb = 32'b00000000000000000000000000000000 ;
    #10
    frs1_tb = 32'b11000000001000000000000000000000 ;
    frs2_tb = 32'b00111111101000000000000000000000 ;
    #10
    frs1_tb = 32'b11000000001000000000000000000000 ;
    frs2_tb = 32'b10111111101000000000000000000000 ;

    #10
    $finish;
 end



// task check_add (

// input   [XLEN-1:0]                      expected_DATA,
// input       integer                     case_num
// );
//  begin
//     if (expected_DATA == frd_tb) begin
//         $display("Alert!");
//         $display ("OUTPUT IS TRUE , AT_time%0t, Case %0d", $time ,case_num);
//         $display("===============================================================================");
//     end

//     else begin
//         $display("Alert!");
//         $display ("OUTPUT IS FALSE , AT_time%0t, Case %0d , expected => %0b != %0b <= OUTPUT", $time ,case_num, expected_DATA , frd_tb);
//         $display("===============================================================================");
//     end     
//  end
// endtask


task initialization ();
 begin
    frs1_tb = 'b0 ;
    frs2_tb = 'b0 ;
    En_tb = 1'b0 ;
    rst_n_tb = 1'b0 ;
    Funct_tb = 1'b0 ;
 end
endtask

endmodule