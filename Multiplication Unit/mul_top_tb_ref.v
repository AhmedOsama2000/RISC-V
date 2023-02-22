`timescale 1ns/1ns
module mul_top_tb_ref;

parameter XLEN = 32;

reg   [XLEN-1:0]    Multiplier;
reg   [XLEN-1:0]    Multiplicand;
wire  [XLEN*2-1: 0] Product;


mul_top_ref u0(
    .Multiplier(Multiplier),
    .Multiplicand(Multiplicand),
    .Product(Product)
);

reg [XLEN*2-1:0] expected_mul;

integer i;

initial begin
    Multiplier = 32'h8000_0000;
    Multiplicand = 32'h8000_0001;
    check_mul(Multiplier,Multiplicand);
    #1

    Multiplier = 10;
    Multiplicand = 6;
    check_mul(Multiplier,Multiplicand);
    #1

    Multiplier = 5;
    Multiplicand = 5;
    check_mul(Multiplier,Multiplicand);
    #1

    Multiplier = 5;
    Multiplicand = 10;
    check_mul(Multiplier,Multiplicand);
    #1

    Multiplier = 5;
    Multiplicand = 70;
    check_mul(Multiplier,Multiplicand);
    #1

    Multiplier = 5;
    Multiplicand = 50;
    check_mul(Multiplier,Multiplicand);
    #1

    Multiplier = 5;
    Multiplicand = 40;
    check_mul(Multiplier,Multiplicand);
    #1

    Multiplier = 32'hfffe_ffff;
    Multiplicand = 32'hffef_ffff;
    check_mul(Multiplier,Multiplicand);
    #1

    Multiplier = 32'hffff_ffff;
    Multiplicand = 'b0;
    check_mul(Multiplier,Multiplicand);
    #1

    for (i = 0; i < 50;i = i + 1) begin
        
        Multiplier = $random;
        Multiplicand = $random;
        check_mul(Multiplier,Multiplicand);
        #1;
    end

    #1
    $stop;

end

task check_mul (input signed [XLEN-1:0] a1,input signed [XLEN-1:0] b1);
    begin
        #1
        expected_mul = a1 * b1;
        if (expected_mul == (Product)) begin
            $display("%0t Correct",$time);
        end
        else begin
            $display("%0t Incorrect expected_mul = %0d != %0d",$time,expected_mul,Product);
        end

    end
endtask

endmodule