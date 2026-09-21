module top;

    import uvm_pkg::*;
    import pkg::*;

    bit clock;

    always begin
        #5 clock = ~clock;
    end

    apb_if  apb_intf(clock);
    uart_if uart_intf(clock);

    uart duv(apb_intf, uart_intf);

    initial begin
        uvm_config_db#(virtual apb_if)::set(
            null,
            "*",
            "apb_if",
            apb_intf
        );

        uvm_config_db#(virtual uart_if)::set(
            null,
            "*",
            "uart_if",
            uart_intf
        );

        run_test();
    end

endmodule
