module uart (
    apb_if.APB_DUV_MP  apb,
    uart_if.UART_DUV_MP uart
);

    uart_top u1 (
        .Pclk        (apb.Pclk),
        .Presetn     (apb.Presetn),
        .Pwrite      (apb.Pwrite),
        .Penable     (apb.Penable),
        .Psel        (apb.Psel),
        .Paddr       (apb.Paddr),
        .PWdata      (apb.PWdata),
        .PRdata      (apb.PRdata),
        .Pready      (apb.Pready),
        .PSLVERR     (apb.PSLVERR),
        .rxd         (uart.rxd),
        .irq         (uart.irq),
        .txd         (uart.txd),
        .baud_pulse  (uart.baud_pulse)
    );

endmodule
