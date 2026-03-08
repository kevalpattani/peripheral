`timescale 1ns / 1ps

module uart_rx(
    input  wire       clk,
    input  wire       rst,
    input  wire       rx_input,
    output reg [7:0]  rx_output
);

    reg  [9:0] baud_counter;
    parameter  baud_rate = 868; // (100Mhz / 115200) -> where 115200 is the baud rate
    wire       baud_clock;
    reg  [3:0] state;
    reg  [3:0] next_state;
    reg  [7:0] data_buf;
    reg        RCL;  // Receive Clear 
    reg  [1:0] state_DTFE; // seperate state for DTFE (Detect Falling Edge)
    reg  [1:0] next_state_DTFE; // seperate next_state for RCL
    reg       STBC; // Start The Baud Clock 
    wire       half_baud;
    reg        RCL_stopper; // its technically RCL <= 0 but in RX FSM


  always @(posedge clk or posedge rst) // Baud clock counter 
    begin
        if (rst)
        begin
            baud_counter <= 0;
        end
        else if (!STBC)
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
    assign half_baud  = (baud_counter == (baud_rate >> 1));


  always @(posedge clk or posedge rst) // state transition logic 
    begin
        if (rst)
        begin
            state       <= 4'b0000;
            state_DTFE  <= 2'b00;
        end
        else
        begin
            state       <= next_state;
            state_DTFE  <= next_state_DTFE;
        end
    end


  always @(posedge clk or posedge rst) // DTFE (Detect Falling Edge) FSM which start the clock fsm and main receiving fsm  
    begin
        if (rst)
        begin
            next_state_DTFE <= 2'b00;
            STBC            <= 1'b0;
        end
        else
        begin
            if (RCL)
            begin
                case (state_DTFE)

                    2'b00:
                    begin
                        if (rx_input)
                        begin
                            next_state_DTFE <= 2'b00;
                            STBC            <= 1'b0;
                        end
                        else
                        begin
                            next_state_DTFE <= 2'b01;
                            STBC            <= 1'b1;
                        end
                    end

                    2'b01:
                    begin
                        if (half_baud)
                        begin
                            if (rx_input)
                            begin
                                next_state_DTFE <= 2'b00;
                                STBC            <= 1'b0;
                            end
                            else
                            begin
                                next_state_DTFE <= 2'b10;
                                STBC            <= 1'b0;
                            end
                        end
                        else
                        begin
                            next_state_DTFE <= 2'b01;
                        end
                    end

                    2'b10:
                    begin
                        next_state_DTFE <= 2'b00;
                        STBC            <= 1'b1;
                        RCL_stopper     <= 1'b1;
                    end

                endcase
            end
        end
    end


  always @(posedge clk or posedge rst) // main RX FSM 
    begin
        if (rst)
        begin
            next_state <= 4'd0;
            data_buf   <= 8'd0;
            RCL        <= 1'b1;
            rx_output  <= 8'b0;
        end
        else
        begin
            if (RCL_stopper)
            begin
                RCL <= 0;
            end

            if (baud_clock)
            begin
                case (state)

                    4'd0:
                    begin
                        next_state   <= 4'd1;
                        RCL          <= 1'b0;
                        data_buf[0]  <= rx_input;
                    end

                    4'd1:
                    begin
                        next_state   <= 4'd2;
                        data_buf[1]  <= rx_input;
                    end

                    4'd2:
                    begin
                        next_state   <= 4'd3;
                        data_buf[2]  <= rx_input;
                    end

                    4'd3:
                    begin
                        next_state   <= 4'd4;
                        data_buf[3]  <= rx_input;
                    end

                    4'd4:
                    begin
                        next_state   <= 4'd5;
                        data_buf[4]  <= rx_input;
                    end

                    4'd5:
                    begin
                        next_state   <= 4'd6;
                        data_buf[5]  <= rx_input;
                    end

                    4'd6:
                    begin
                        next_state   <= 4'd7;
                        data_buf[6]  <= rx_input;
                    end

                    4'd7:
                    begin
                        next_state   <= 4'd8;
                        data_buf[7]  <= rx_input;
                    end

                    4'd8:
                    begin
                        next_state <= 4'd0;
                        RCL        <= 1'b1;
                        rx_output  <= data_buf;
                    end

                    default:
                    begin
                        next_state <= 4'd0;
                        data_buf   <= 8'b0;
                    end

                endcase
            end
        end
    end

endmodule
