`timescale 1ns/1ps

module uart_rx_tb;

reg clk;
reg rst;
reg tx_input;

wire [7:0] rx_output;

parameter BIT_TIME = 8680; // ns (868 clocks * 10ns)


uart_rx DUT(
    .clk(clk),
    .rst(rst),
    .tx_input(tx_input),
    .rx_output(rx_output)
);


// Debug wires (hierarchical access)
wire [3:0] state        = DUT.state;
wire [1:0] state_DTFE   = DUT.state_DTFE;
wire STBC               = DUT.STBC;
wire [9:0] baud_counter = DUT.baud_counter;
wire baud_clock         = DUT.baud_clock;
wire half_baud          = DUT.half_baud;


always #5 clk = ~clk;

task send_byte;
input [7:0] data;
integer i;
begin
    $display("Sending byte: %h at time %t", data, $time);

    // start bit
    tx_input = 0;
    #(BIT_TIME);

    // data bits (LSB first)
    for(i=0;i<8;i=i+1)
    begin
        tx_input = data[i];
        #(BIT_TIME);
    end

    // stop bit
    tx_input = 1;
    #(BIT_TIME);

end
endtask


always @(posedge baud_clock)
begin
    $display("time=%t state=%d data=%b", $time, state, tx_input);
end


always @(rx_output)
begin
    $display("RX OUTPUT = %h at time %t", rx_output, $time);
end


// Simulation sequence
initial begin

    clk = 0;
    rst = 1;
    tx_input = 1;

    #100;
    rst = 0;

    #20000;

    // Send multiple frames
    send_byte(8'hA5);
    #50000;

    send_byte(8'h3C);
    #50000;

    send_byte(8'hF0);
    #50000;

    send_byte(8'h55);
    #100000;

    $display("Simulation finished");
    $finish;

end

endmodule
