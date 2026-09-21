class base_test extends uvm_test;

    `uvm_component_utils(base_test)

    environment env;

    env_config        env_cfg;
    apb_agent_config  apb_cfg;
    uart_agent_config uart_cfg;
    reg_block         reg_model;

    function new(string name = "base_test", uvm_component parent);
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env_cfg   = env_config::type_id::create("env_cfg");
        apb_cfg   = apb_agent_config::type_id::create("apb_cfg");
        uart_cfg  = uart_agent_config::type_id::create("uart_cfg");
        reg_model = reg_block::type_id::create("reg_model");

        reg_model.build();

        if (!uvm_config_db#(virtual apb_if)::get(
                this, "", "apb_if", apb_cfg.vif
            ))
            `uvm_fatal("APB Interface Config", "Failed");

        if (!uvm_config_db#(virtual uart_if)::get(
                this, "", "uart_if", uart_cfg.vif
            ))
            `uvm_fatal("UART Interface Config", "Failed");

        env_cfg.reg_model = reg_model;
        env_cfg.apb_cfg   = apb_cfg;
        env_cfg.uart_cfg  = uart_cfg;

        uvm_config_db#(env_config)::set(
            this, "*", "env_config", env_cfg
        );

        env = environment::type_id::create("env", this);
    endfunction


    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

endclass


class half_duplex_trans_test extends base_test;

    `uvm_component_utils(half_duplex_trans_test)

    half_duplex_trans_vseq seq;

    function new(
        string name = "half_duplex_trans_test",
        uvm_component parent
    );
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        uvm_config_db#(bit [7:0])::set(
            this,
            "*",
            "lcr",
            8'b0000_0111
        );
    endfunction


    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        seq = half_duplex_trans_vseq::type_id::create("seq");
        seq.start(env.vseqr);

        phase.drop_objection(this);
    endtask

endclass


class half_duplex_rcv_test extends base_test;

    `uvm_component_utils(half_duplex_rcv_test)

    half_duplex_rcv_vseq seq;

    function new(
        string name = "half_duplex_rcv_test",
        uvm_component parent
    );
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        uvm_config_db#(bit [7:0])::set(
            this,
            "*",
            "lcr",
            8'b0000_0111
        );
    endfunction


    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        seq = half_duplex_rcv_vseq::type_id::create("seq");
        seq.start(env.vseqr);

        phase.drop_objection(this);
    endtask

endclass


class full_duplex_test extends base_test;

    `uvm_component_utils(full_duplex_test)

    full_duplex_vseq seq;

    function new(
        string name = "full_duplex_test",
        uvm_component parent
    );
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        uvm_config_db#(bit [7:0])::set(
            this,
            "*",
            "lcr",
            8'b0000_0111
        );
    endfunction


    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        seq = full_duplex_vseq::type_id::create("seq");
        seq.start(env.vseqr);

        phase.drop_objection(this);
    endtask

endclass


class loopback_test extends base_test;

    `uvm_component_utils(loopback_test)

    loopback_vseq seq;

    function new(
        string name = "loopback_test",
        uvm_component parent
    );
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        uvm_config_db#(bit [7:0])::set(
            this,
            "*",
            "lcr",
            8'b0000_0111
        );
    endfunction


    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        seq = loopback_vseq::type_id::create("seq");
        seq.start(env.vseqr);

        phase.drop_objection(this);
    endtask

endclass
