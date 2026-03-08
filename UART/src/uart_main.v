`timescale 1ns / 1ps

module uart_main(input wire clk,
                 input wire rst,
                 input wire [7:0] led_switch,
                 input wire send_switch,
                 input wire mode, // to switch the led from tx to rx where tx is high and rx is low state
                 output wire tx_output,
                 input wire rx_input,
                 output reg [7:0] led_output);
                 
                 reg [7:0] rx_output;
                 reg [7:0] tx_input;
                 
                 uart_tx tx (.clk(clk),.rst(rst),.tx_input(tx_input),.send(send_switch),.tx_output(tx_output));
                 
                 uart_rx rx (.clk(clk),.rst(rst),.rx_input(rx_input),.rx_output(rx_output));
                 
                 
                 always@(*)
                 begin
                     tx_input = led_switch;
                     led_output = rx_output;
                     
                     if (mode)
                        led_output = led_switch;
                     end      
endmodule
