class environment extends uvm_env;

    `uvm_component_utils(environment)

    apb_agt_top      apb_top;
    uart_agt_top     uart_top;
    scoreboard       sb;
    env_config       env_cfg;
    virtual_sequencer vseqr;

    function new(string name = "environment", uvm_component parent);
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        apb_top  = apb_agt_top::type_id::create("apb_top", this);
        uart_top = uart_agt_top::type_id::create("uart_top", this);
        sb       = scoreboard::type_id::create("sb", this);
        vseqr    = virtual_sequencer::type_id::create("vseqr", this);

        if (!uvm_config_db#(env_config)::get(this, "", "env_config", env_cfg))
            `uvm_fatal("Environment Config", "Failed")

        uvm_config_db#(apb_agent_config)::set(
            this,
            "*",
            "apb_agent_config",
            env_cfg.apb_cfg
        );

        uvm_config_db#(uart_agent_config)::set(
            this,
            "*",
            "uart_agent_config",
            env_cfg.uart_cfg
        );
    endfunction


    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        apb_top.agent.mon.monitor_port.connect(
            sb.apb_fifo.analysis_export
        );

        uart_top.agent.mon.monitor_port.connect(
            sb.uart_fifo.analysis_export
        );

        vseqr.apb_seqr  = apb_top.agent.seqr;
        vseqr.uart_seqr = uart_top.agent.seqr;
    endfunction

endclass
