class uart_agent extends uvm_agent;

    `uvm_component_utils(uart_agent)

    uart_monitor   mon;
    uart_sequencer seqr;
    uart_driver    drv;
    uart_agent_config cfg;

    function new(
        string name = "uart_agent",
        uvm_component parent
    );
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(uart_agent_config)::get(
                this,
                "",
                "uart_agent_config",
                cfg
            ))
          `uvm_fatal("UART Agent Config", "Failed")

        mon = uart_monitor::type_id::create("mon", this);

        if (cfg.is_active == UVM_ACTIVE) begin
            drv  = uart_driver::type_id::create("drv", this);
            seqr = uart_sequencer::type_id::create("seqr", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (cfg.is_active == UVM_ACTIVE)
            drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction

endclass
