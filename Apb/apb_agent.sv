class apb_agent extends uvm_agent;

    `uvm_component_utils(apb_agent)

    apb_monitor mon;
    apb_sequencer seqr;
    apb_driver drv;
    apb_agent_config cfg;

    function new(
        string name = "apb_agent",
        uvm_component parent
    );
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(apb_agent_config)::get(
                this,
                "",
                "apb_agent_config",
                cfg
            ))
            `uvm_fatal("APB Agent Config", "Failed")

        mon = apb_monitor::type_id::create("mon", this);

        if (cfg.is_active == UVM_ACTIVE) begin
            drv  = apb_driver::type_id::create("drv", this);
            seqr = apb_sequencer::type_id::create("seqr", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (cfg.is_active == UVM_ACTIVE)
            drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction

endclass
