`timescale 1ns / 1ps

module uart_tx_tb;

    reg clk;
    reg rst;
    reg [7:0] tx_input;
    reg send;
    wire tx_output;

    uart_tx DUT (
        .clk(clk),
        .rst(rst),
        .tx_input(tx_input),
        .send(send),
        .tx_output(tx_output)
    );

    always #5 clk = ~clk;

    initial
    begin
        clk = 0;
        rst = 1;
        send = 1;
        tx_input = 8'b0;

        #50;
        rst = 0;

        #100;
        tx_input = 8'b10101010;
        send = 1;

        #10;
        send = 1;

        #200000;

        tx_input = 8'b11001100;
        send = 1;

        #10;
        send = 1;

        #200000;

        $finish;
    end

endmodule
