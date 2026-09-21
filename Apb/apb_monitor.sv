class apb_monitor extends uvm_monitor;

    `uvm_component_utils(apb_monitor)

    uvm_analysis_port #(apb_xtn) monitor_port;
    virtual apb_if.APB_MON_MP vif;
    apb_agent_config cfg;

    function new(
        string name = "apb_monitor",
        uvm_component parent
    );
        super.new(name, parent);
        monitor_port = new("monitor_port", this);
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
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vif = cfg.vif;
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            collect();
        end
    endtask

    task collect();

        apb_xtn xtn;

        xtn = apb_xtn::type_id::create("xtn");

        wait (vif.apb_mon_cb.Pready);

        xtn.Presetn = vif.apb_mon_cb.Presetn;
        xtn.Pwrite  = vif.apb_mon_cb.Pwrite;
        xtn.Psel    = vif.apb_mon_cb.Psel;
        xtn.Penable = vif.apb_mon_cb.Penable;
        xtn.Paddr   = vif.apb_mon_cb.Paddr;

        if (vif.apb_mon_cb.Pwrite)
            xtn.PWdata = vif.apb_mon_cb.PWdata;
        else
            xtn.PRdata = vif.apb_mon_cb.PRdata;

        xtn.Pready  = vif.apb_mon_cb.Pready;
        xtn.PSLVERR = vif.apb_mon_cb.PSLVERR;

        `uvm_info(
            get_full_name(),
            $sformatf(
                "The Data collected from APB Monitor: \n%s",
                xtn.sprint()
            ),
            UVM_LOW
        );

        cfg.apb_mon_rcvd_data_count++;

        monitor_port.write(xtn);

        @(vif.apb_mon_cb);

    endtask

    function void report_phase(uvm_phase phase);
        `uvm_info(
            "APB MONITOR",
            $sformatf(
                "The no of transactions collected: %0d",
                cfg.apb_mon_rcvd_data_count
            ),
            UVM_LOW
        )
    endfunction

endclass
