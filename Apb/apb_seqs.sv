class apb_base_seqs extends uvm_sequence #(apb_xtn);

    `uvm_object_utils(apb_base_seqs)

    bit [7:0] lcr;

    function new(string name = "apb_base_seqs");
        super.new(name);
    endfunction

    task body();
        if (!uvm_config_db#(bit [7:0])::get(
                null,
                get_full_name(),
                "lcr",
                lcr
            ))
            `uvm_fatal("LCR CONFIG", "FAILED")
    endtask

endclass


class apb_half_duplex_trans_seq extends apb_base_seqs;

    `uvm_object_utils(apb_half_duplex_trans_seq)

    function new(string name = "apb_half_duplex_trans_seq");
        super.new(name);
    endfunction

    task body();
        super.body();

        repeat (1) begin

            // Interrupt Enable Register
            req = apb_xtn::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                Presetn == 1;
                Pwrite  == 1'b1;
                Paddr   == 8'h04;
                PWdata  == 8'b0000_0101;
            });
            finish_item(req);

            // FIFO Control Register
            req = apb_xtn::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                Presetn == 1;
                Pwrite  == 1'b1;
                Paddr   == 8'h08;
                PWdata  == 8'b0000_0000;
            });
            finish_item(req);

            // Line Control Register
            req = apb_xtn::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                Presetn == 1;
                Pwrite  == 1'b1;
                Paddr   == 8'h0c;
                PWdata  == lcr;
            });
            finish_item(req);

            // Modem Control Register
            req = apb_xtn::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                Presetn == 1;
                Pwrite  == 1'b1;
                Paddr   == 8'h10;
                PWdata  == 8'b0000_0000;
            });
            finish_item(req);

            // Divisor1 Register
            req = apb_xtn::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                Presetn == 1;
                Pwrite  == 1'b1;
                Paddr   == 8'h1c;
                PWdata  == 8'b0000_0100;
            });
            finish_item(req);

            // Divisor2 Register
            req = apb_xtn::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                Presetn == 1;
                Pwrite  == 1'b1;
                Paddr   == 8'h20;
                PWdata  == 8'b0000_0000;
            });
            finish_item(req);

            // Transmitter Holding Register
            req = apb_xtn::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                Presetn == 1;
                Pwrite  == 1'b1;
                Paddr   == 8'h00;
            });
            finish_item(req);

        end
    endtask

endclass


class apb_half_duplex_rcv_seq extends apb_base_seqs;

    `uvm_object_utils(apb_half_duplex_rcv_seq)

    function new(string name = "apb_half_duplex_rcv_seq");
        super.new(name);
    endfunction

    task body();
        super.body();

        repeat (1) begin

            // Interrupt Enable Register
            req = apb_xtn::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                Presetn == 1;
                Pwrite  == 1'b1;
                Paddr   == 8'h04;
                PWdata  == 8'b0000_0101;
            });
            finish_item(req);

            // FIFO Control Register
            req = apb_xtn::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                Presetn == 1;
                Pwrite  == 1'b1;
                Paddr   == 8'h08;
                PWdata  == 8'b0000_0000;
            });
            finish_item(req);

            // Line Control Register
            req = apb_xtn::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                Presetn == 1;
                Pwrite  == 1'b1;
                Paddr   == 8'h0c;
                PWdata  == lcr;
            });
            finish_item(req);

            // Modem Control Register
            req = apb_xtn::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                Presetn == 1;
                Pwrite  == 1'b1;
                Paddr   == 8'h10;
                PWdata  == 8'b0000_0000;
            });
            finish_item(req);

            // Divisor1 Register
            req = apb_xtn::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                Presetn == 1;
                Pwrite  == 1'b1;
                Paddr   == 8'h1c;
                PWdata  == 8'b0000_0100;
            });
            finish_item(req);

            // Divisor2 Register
            req = apb_xtn::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                Presetn == 1;
                Pwrite  == 1'b1;
                Paddr   == 8'h20;
            });
            finish_item(req);

        end
    endtask

endclass


class apb_loopback_seq extends apb_base_seqs;

    `uvm_object_utils(apb_loopback_seq)

    function new(string name = "apb_loopback_seq");
        super.new(name);
    endfunction

    task body();
        super.body();

        repeat (1) begin

            // Interrupt Enable Register
            req = apb_xtn::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                Presetn == 1;
                Pwrite  == 1'b1;
                Paddr   == 8'h04;
                PWdata  == 8'b0000_0101;
            });
            finish_item(req);

            // FIFO Control Register
            req = apb_xtn::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                Presetn == 1;
                Pwrite  == 1'b1;
                Paddr   == 8'h08;
                PWdata  == 8'b0000_0000;
            });
            finish_item(req);

            // Line Control Register
            req = apb_xtn::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                Presetn == 1;
                Pwrite  == 1'b1;
                Paddr   == 8'h0c;
                PWdata  == lcr;
            });
            finish_item(req);

            // Modem Control Register
            req = apb_xtn::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                Presetn == 1;
                Pwrite  == 1'b1;
                Paddr   == 8'h10;
                PWdata  == 8'b0001_0000;
            });
            finish_item(req);

            // Divisor1 Register
            req = apb_xtn::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                Presetn == 1;
                Pwrite  == 1'b1;
                Paddr   == 8'h1c;
                PWdata  == 8'b0000_0100;
            });
            finish_item(req);

            // Divisor2 Register
            req = apb_xtn::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                Presetn == 1;
                Pwrite  == 1'b1;
                Paddr   == 8'h20;
                PWdata  == 8'b0000_0000;
            });
            finish_item(req);

            // Transmitter Holding Register
            req = apb_xtn::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                Presetn == 1;
                Pwrite  == 1'b1;
                Paddr   == 8'h00;
            });
            finish_item(req);

        end
    endtask

endclass


class apb_rd_seq extends apb_base_seqs;

    `uvm_object_utils(apb_rd_seq)

    function new(string name = "apb_rd_seq");
        super.new(name);
    endfunction

    task body();

        // Receiver Buffer Register
        req = apb_xtn::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {
            Presetn == 1;
            Pwrite  == 1'b0;
            Paddr   == 8'h00;
        });
        finish_item(req);

    endtask

endclass


class apb_status_seq extends apb_base_seqs;

    `uvm_object_utils(apb_status_seq)

    function new(string name = "apb_status_seq");
        super.new(name);
    endfunction

    task body();

        // Line Status Register
        req = apb_xtn::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {
            Presetn == 1;
            Pwrite  == 1'b0;
            Paddr   == 8'h14;
        });
        finish_item(req);

    endtask

endclass
