class virtual_seqs extends uvm_sequence #(uvm_sequence_item);

    `uvm_object_utils(virtual_seqs)

    virtual_sequencer vseqr;
    apb_sequencer     apb_seqr;
    uart_sequencer    uart_seqr;

    function new(string name = "virtual_seqs");
        super.new(name);
    endfunction

    task body();
        if (!$cast(vseqr, m_sequencer))
            `uvm_fatal("VIRTUAL SEQS", "SEQUENCER CASTING FAILED")

        apb_seqr  = vseqr.apb_seqr;
        uart_seqr = vseqr.uart_seqr;
    endtask

endclass


class half_duplex_trans_vseq extends virtual_seqs;

    `uvm_object_utils(half_duplex_trans_vseq)

    apb_half_duplex_trans_seq apb;
    apb_status_seq            stat;

    function new(string name = "half_duplex_trans_vseq");
        super.new(name);
    endfunction

    task body();
        super.body();

        repeat (1) begin
            apb = apb_half_duplex_trans_seq::type_id::create("apb");
            apb.start(apb_seqr);

            #10000;

            stat = apb_status_seq::type_id::create("stat");
            stat.start(apb_seqr);
        end
    endtask

endclass


class half_duplex_rcv_vseq extends virtual_seqs;

    `uvm_object_utils(half_duplex_rcv_vseq)

    apb_half_duplex_rcv_seq apb;
    uart_half_duplex_rcv_seq uart;
    apb_rd_seq               rd;

    function new(string name = "half_duplex_rcv_vseq");
        super.new(name);
    endfunction

    task body();
        super.body();

        repeat (1) begin
            apb = apb_half_duplex_rcv_seq::type_id::create("apb");
            apb.start(apb_seqr);

            uart = uart_half_duplex_rcv_seq::type_id::create("uart");
            uart.start(uart_seqr);

            rd = apb_rd_seq::type_id::create("rd");
            rd.start(apb_seqr);
        end
    endtask

endclass


class full_duplex_vseq extends virtual_seqs;

    `uvm_object_utils(full_duplex_vseq)

    apb_half_duplex_trans_seq apb;
    uart_half_duplex_rcv_seq uart;
    apb_rd_seq               rd;

    function new(string name = "full_duplex_vseq");
        super.new(name);
    endfunction

    task body();
        super.body();

        repeat (1) begin
            apb = apb_half_duplex_trans_seq::type_id::create("apb");
            apb.start(apb_seqr);

            uart = uart_half_duplex_rcv_seq::type_id::create("uart");
            uart.start(uart_seqr);

            rd = apb_rd_seq::type_id::create("rd");
            rd.start(apb_seqr);
        end
    endtask

endclass


class loopback_vseq extends virtual_seqs;

    `uvm_object_utils(loopback_vseq)

    apb_loopback_seq apb;
    apb_rd_seq       rd;

    function new(string name = "loopback_vseq");
        super.new(name);
    endfunction

    task body();
        super.body();

        repeat (1) begin
            apb = apb_loopback_seq::type_id::create("apb");
            apb.start(apb_seqr);

            #10000;

            rd = apb_rd_seq::type_id::create("rd");
            rd.start(apb_seqr);
        end
    endtask

endclass
