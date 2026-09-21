class apb_driver extends uvm_driver #(apb_xtn);

    `uvm_component_utils(apb_driver)

    virtual apb_if.APB_DRV_MP vif;
    apb_agent_config cfg;

    function new(
        string name = "apb_driver",
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
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vif = cfg.vif;
    endfunction

    task run_phase(uvm_phase phase);

        vif.apb_drv_cb.Presetn <= 1'b0;

        repeat (5)
            @(vif.apb_drv_cb);

        vif.apb_drv_cb.Presetn <= 1'b1;

        repeat (3)
            @(vif.apb_drv_cb);

        forever begin
            seq_item_port.get_next_item(req);
            drive(req);
            seq_item_port.item_done();
        end

    endtask

    task drive(apb_xtn xtn);

        @(vif.apb_drv_cb);

        vif.apb_drv_cb.Presetn  <= xtn.Presetn;
        vif.apb_drv_cb.Pwrite   <= xtn.Pwrite;
        vif.apb_drv_cb.Psel     <= 1'b1;
        vif.apb_drv_cb.Penable  <= 1'b0;
        vif.apb_drv_cb.Paddr    <= xtn.Paddr;

        if (xtn.Pwrite)
            vif.apb_drv_cb.PWdata <= xtn.PWdata;

        @(vif.apb_drv_cb);

        vif.apb_drv_cb.Penable <= 1'b1;

        @(vif.apb_drv_cb);

        if (!xtn.Pwrite)
            xtn.PRdata <= vif.apb_drv_cb.PRdata;

        vif.apb_drv_cb.Psel    <= 1'b0;
        vif.apb_drv_cb.Penable <= 1'b0;

        `uvm_info(
            get_full_name(),
            $sformatf(
                "The Data sent from APB Driver: \n%s",
                xtn.sprint()
            ),
            UVM_LOW
        )

        cfg.apb_drv_sent_data_count++;

        @(vif.apb_drv_cb);

    endtask

    function void report_phase(uvm_phase phase);
        `uvm_info(
            "APB DRIVER",
            $sformatf(
                "The number of transactions sent: %0d",
                cfg.apb_drv_sent_data_count
            ),
            UVM_LOW
        )
    endfunction

endclass
