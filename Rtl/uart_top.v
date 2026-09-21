module uart_top (
    input        Pclk,
    input        Presetn,
    input        Pwrite,
    input        Penable,
    input        Psel,
    input        rxd,
    input  [7:0] Paddr,
    input  [7:0] PWdata,
    output [7:0] PRdata,
    output       Pready,
    output       PSLVERR,
    output       irq,
    output       txd,
    output       baud_pulse
);

    wire        rx_fifo_re;
    wire        tx_busy;
    wire        rx_idle;
    wire        tx_fifo_empty;
    wire        tx_fifo_full;
    wire        rx_overrun;
    wire        parity_error;
    wire        framing_error;
    wire        break_error;
    wire        time_out;
    wire        rx_fifo_empty;
    wire        rx_fifo_full;
    wire        tx_fifo_we;
    wire        tx_enable;
    wire        rx_enable;
    wire        rx_fifo_push;
    wire        loop_back;

    wire [4:0]  rx_fifo_count;
    wire [4:0]  tx_fifo_count;

    wire [7:0]  rx_data_out;
    wire [7:0]  LCR;

    wire        rxd_in;

    assign rxd_in = loop_back ? txd : rxd;

    register r1 (
        .Pclk                (Pclk),
        .Presetn             (Presetn),
        .Psel                (Psel),
        .Pwrite              (Pwrite),
        .Penable             (Penable),
        .tx_fifo_empty       (tx_fifo_empty),
        .tx_fifo_full        (tx_fifo_full),
        .tx_busy             (tx_busy),
        .rx_overrun          (rx_overrun),
        .parity_error        (parity_error),
        .framing_error       (framing_error),
        .break_error         (break_error),
        .time_out            (time_out),
        .rx_fifo_empty       (rx_fifo_empty),
        .rx_fifo_full        (rx_fifo_full),
        .rx_fifo_count       (rx_fifo_count),
        .PWdata              (PWdata),
        .rx_data_out         (rx_data_out),
        .Paddr               (Paddr),
        .PRdata              (PRdata),
        .LCR                 (LCR),
        .Pready              (Pready),
        .PSLVERR             (PSLVERR),
        .tx_fifo_we          (tx_fifo_we),
        .tx_enable           (tx_enable),
        .rx_enable           (rx_enable),
        .baud_pulse          (baud_pulse),
        .loop_back           (loop_back),
        .rx_fifo_re          (rx_fifo_re),
        .irq                 (irq)
    );

    transmitter t1 (
        .Pclk                (Pclk),
        .Presetn             (Presetn),
        .Pwrite              (Pwrite),
        .Pready              (Pready),
        .Paddr               (Paddr),
        .tx_fifo_push        (tx_fifo_we),
        .enable              (tx_enable),
        .LCR                 (LCR),
        .PWDATA              (PWdata),
        .busy                (tx_busy),
        .tx_fifo_full        (tx_fifo_full),
        .tx_fifo_empty       (tx_fifo_empty),
        .TXD                 (txd),
        .tx_fifo_count       (tx_fifo_count)
    );

    receiver re1 (
        .Pclk                (Pclk),
        .Presetn             (Presetn),
        .Pwrite              (Pwrite),
        .Pready              (Pready),
        .Paddr               (Paddr),
        .PWdata1             (PWdata[1]),
        .rxd                 (rxd_in),
        .pop_rx_fifo         (rx_fifo_re),
        .enable              (rx_enable),
        .LCR                 (LCR),
        .rx_idle             (rx_idle),
        .push_rx_fifo        (rx_fifo_push),
        .rx_fifo_full        (rx_fifo_full),
        .rx_overrun          (rx_overrun),
        .framing_error       (framing_error),
        .break_error         (break_error),
        .time_out            (time_out),
        .parity_error        (parity_error),
        .rx_fifo_count       (rx_fifo_count),
        .rx_fifo_out         (rx_data_out),
        .rx_fifo_empty       (rx_fifo_empty)
    );

endmodule
