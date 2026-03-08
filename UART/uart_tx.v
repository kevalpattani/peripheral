`timescale 1ns / 1ps

module uart_tx(input wire clk,
              input wire rst,
              input wire [7:0] tx_input,
              input wire send,
              output reg tx_output);
              
              reg [3:0] state;
              reg [3:0] next_state;
              reg [7:0] data_buf;
              reg [9:0] baud_counter;
              parameter baud_rate = 868; // (100Mhz / 115200) -> where 115200 is the baud rate
              wire baud_clock;
              
              always@(posedge clk or posedge rst) // state transition logic 
              begin
                if(rst)
                    state <= 4'b0000;
                else
                    state <= next_state;
              end
              
              always@(posedge clk or posedge rst) // baud_clock logic
              begin
                if(rst)
                begin
                    baud_counter <= 0;
                end
                
                else if (baud_counter == baud_rate - 1)
                begin
                    baud_counter <= 0;
                end
                
                else 
                begin
                    baud_counter <= baud_counter + 1;
                end                             
              end

  
              assign baud_clock = (baud_counter == baud_rate - 1);

  
              always@(posedge clk or posedge rst) // the main fsm logic with 11 stages 4'd0 to 4'd10
              begin
                if (rst)
                begin
                    next_state <= 4'd0;
                    tx_output <= 1'b1;
                    data_buf <= 8'b0;
                end
                else
                begin 
                    if (baud_clock)
                    begin
                    case(state)
                        4'd0: begin
                                if(send)
                                begin
                                    next_state <= 4'd1;
                                    tx_output <= 1'b1;
                                    data_buf <= tx_input;
                                end
                                else
                                begin
                                    next_state <= 4'd0;
                                    tx_output <= 1'b1;
                                end
                                end             
                        
                        4'd1: begin 
                                next_state <= 4'd2;
                                tx_output <= 1'b0;
                               end
                        
                        4'd2: begin 
                                next_state <= 4'd3;
                                tx_output <= data_buf[0];
                               end
                               
                        4'd3: begin 
                                next_state <= 4'd4;
                                tx_output <= data_buf[1];
                               end
                               
                        4'd4: begin 
                                next_state <= 4'd5;
                                tx_output <= data_buf[2];
                               end
                               
                        4'd5: begin 
                                next_state <= 4'd6;
                                tx_output <= data_buf[3];
                               end
                               
                        4'd6: begin 
                                next_state <= 4'd7;
                                tx_output <= data_buf[4];
                               end
                               
                        4'd7: begin 
                                next_state <= 4'd8;
                                tx_output <= data_buf[5];
                               end
                               
                        4'd8: begin 
                                next_state <= 4'd9;
                                tx_output <= data_buf[6];
                               end
                               
                        4'd9: begin 
                                next_state <= 4'd10;
                                tx_output <= data_buf[7];
                               end
                        
                        4'd10: begin 
                                next_state <= 4'd0;
                                tx_output <= 1'b1;
                               end
                        default: begin
                                next_state <= 4'd0;
                                tx_output <= 1'b1;
                               end
                  endcase
                  end
                end
              end          
endmodule
