(* DONT_TOUCH = "TRUE" *) module top(
    input wire           clock, //100MHz onboard clock
    input wire           reset,
    // DTA interface 
    input wire [31:0]   decimal,
    input wire       load_data,
    //oled interface
    output wire   oled_spi_clk,    // 10MHZ
    output wire  oled_spi_data,
    output wire       oled_vdd,
    output wire      oled_vbat,
    output wire   oled_reset_n,
    output wire      oled_dc_n
);
 localparam StringLen = 64;
 
 reg [1:0] state;
 reg [7:0] sendData;
 reg sendDataValid;
 integer byteCounter;
 wire sendDone;


 // conection with DTA 
 wire   [511:0]    ascii;
 wire           complete;

 
 localparam IDLE = 'd0,
            SEND = 'd1,
            DONE = 'd2;
 
 always @(posedge clock)
 begin
    if(reset)
    begin
        state <= IDLE;
        byteCounter <= StringLen;
        sendDataValid <= 1'b0;
    end
    else
    begin
        case(state)
            IDLE:begin
                if((~sendDone) && complete)
                begin
                    sendData <= ascii[(byteCounter*8-1)-:8];
                    sendDataValid <= 1'b1;
                    state <= SEND;
                end
            end
            SEND:begin
                if(sendDone)
                begin
                    sendDataValid <= 1'b0;
                    byteCounter <= byteCounter-1;
                    if(byteCounter != 1)
                        state <= IDLE;
                    else
                        state <= DONE;
                end
            end
            DONE:begin
                state <= DONE;
            end
        endcase
    end
 end
 
    
    
(* DONT_TOUCH = "TRUE" *) oledControl OC(
    .clock(clock), //100MHz onboard clock
    .reset(reset),
    //oled interface
    .oled_spi_clk(oled_spi_clk),
    .oled_spi_data(oled_spi_data),
    .oled_vdd(oled_vdd),
    .oled_vbat(oled_vbat),
    .oled_reset_n(oled_reset_n),
    .oled_dc_n(oled_dc_n),
    //
    .sendData(sendData),
    .sendDataValid(sendDataValid),
    .sendDone(sendDone)
        );    
    

(* DONT_TOUCH = "TRUE" *) decimal_to_ascii DTA(
    
    .decimal(decimal),
    .load_data(load_data),
    .clock(clock),      //100MHz onboard clock
    .reset(reset),
    .complete(complete),
    .ascii(ascii)
);


endmodule