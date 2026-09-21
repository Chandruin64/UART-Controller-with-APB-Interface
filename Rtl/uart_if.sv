interface uart_if (
    input bit clock
);

    logic rxd;
    logic irq;
    logic txd;
    logic baud_pulse;

    clocking uart_drv_cb @(posedge clock);
        default input #1 output #1;

        output rxd;
        input  irq;
        input  txd;
        input  baud_pulse;
    endclocking

    clocking uart_mon_cb @(posedge clock);
        default input #1 output #1;

        input rxd;
        input irq;
        input txd;
        input baud_pulse;
    endclocking

    modport UART_DUV_MP (
        input  rxd,
        output irq,
        output txd,
        output baud_pulse
    );

    modport UART_DRV_MP (
        clocking uart_drv_cb
    );

    modport UART_MON_MP (
        clocking uart_mon_cb
    );

endinterface
