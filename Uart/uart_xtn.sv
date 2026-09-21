class uart_xtn extends uvm_sequence_item;

    `uvm_object_utils(uart_xtn)

    rand bit [7:0] rxd;
    rand bit       bad_parity;
    rand bit       bad_stop_bit;

    bit [7:0] txd;
    bit       parity;
    bit       irq;
    bit       stop_bit;

    function new(string name = "uart_xtn");
        super.new(name);
    endfunction

    function void do_print(uvm_printer printer);
        super.do_print(printer);

        printer.print_field("irq",          irq,          1, UVM_BIN);
        printer.print_field("parity",       parity,       1, UVM_BIN);
        printer.print_field("stop_bit",     stop_bit,     1, UVM_BIN);
        printer.print_field("bad_parity",   bad_parity,   1, UVM_BIN);
        printer.print_field("bad_stop_bit", bad_stop_bit, 1, UVM_BIN);
        printer.print_field("rxd",          rxd,          8, UVM_BIN);
        printer.print_field("txd",          txd,          8, UVM_BIN);
    endfunction

endclass
