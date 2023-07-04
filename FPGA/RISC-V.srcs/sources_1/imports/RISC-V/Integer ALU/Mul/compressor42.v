module compressor42(
    in1,in2,in3,in4,cin,out1,out2,cout
);
    parameter length = 32;
    input   [length*2-1 : 0]  in1,in2,in3,in4;
    input                     cin;
    output  [length*2 : 0]  out1,out2;
    output                    cout;
    wire    [length*2-1 : 0]  w1,w2,w3;

assign w1 = in1 ^ in2 ^ in3 ^ in4;
assign w2 = (in1 & in2) | (in3 & in4);
assign w3 = (in1 | in2) & (in3 | in4);

assign out2 = { w1[length*2-1] , w1} ^ {w3 , cin};
assign cout = w3[length*2-1];
assign out1 = ({ w1[length*2-1] , w1} & {w3 , cin}) | (( ~{w1[length*2-1] , w1}) & { w2[length*2-1] , w2});

endmodule  