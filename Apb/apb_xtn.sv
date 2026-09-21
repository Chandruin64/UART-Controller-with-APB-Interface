class apb_xtn extends uvm_sequence_item;

    `uvm_object_utils(apb_xtn)

    rand bit        Presetn;
    rand bit        Pwrite;
    bit             Psel;
    bit             Penable;
    rand bit [7:0]  Paddr;
    rand bit [7:0]  PWdata;
    bit      [7:0]  PRdata;
    bit             Pready;
    bit             PSLVERR;

    constraint c1 {
        if (Pwrite)
            Paddr inside {
                8'h0,
                8'h04,
                8'h08,
                8'h0c,
                8'h10,
                8'h1c,
                8'h20
            };
        else
            Paddr inside {
                8'h0,
                8'h04,
                8'h08,
                8'h0c,
                8'h14,
                8'h10,
                8'h18,
                8'h1c,
                8'h20
            };
    }

    constraint c2 {
        Presetn dist {0 := 1, 1 := 99};
    }

    function new(string name = "apb_xtn");
        super.new(name);
    endfunction

    function void do_print(uvm_printer printer);
        super.do_print(printer);

        printer.print_field("Presetn", Presetn, 1, UVM_BIN);
        printer.print_field("Pwrite",  Pwrite,  1, UVM_BIN);
        printer.print_field("Psel",    Psel,    1, UVM_BIN);
        printer.print_field("Penable", Penable, 1, UVM_BIN);
        printer.print_field("Paddr",   Paddr,   8, UVM_BIN);
        printer.print_field("PWdata",  PWdata,  8, UVM_BIN);
        printer.print_field("PRdata",  PRdata,  8, UVM_BIN);
        printer.print_field("Pready",  Pready,  1, UVM_BIN);
        printer.print_field("PSLVERR", PSLVERR, 1, UVM_BIN);
    endfunction

endclass
