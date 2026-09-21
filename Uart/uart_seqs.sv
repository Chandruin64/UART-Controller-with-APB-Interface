class uart_base_seqs extends uvm_sequence #(uart_xtn);

    `uvm_object_utils(uart_base_seqs)

    function new(string name = "uart_base_seqs");
        super.new(name);
    endfunction

endclass


class uart_half_duplex_rcv_seq extends uart_base_seqs;

    `uvm_object_utils(uart_half_duplex_rcv_seq)

    function new(string name = "uart_half_duplex_rcv_seq");
        super.new(name);
    endfunction

    task body();

        req = uart_xtn::type_id::create("req");

        start_item(req);

        assert(req.randomize() with {
            bad_parity   == 0;
            bad_stop_bit == 0;
        });

        finish_item(req);

    endtask

endclass
