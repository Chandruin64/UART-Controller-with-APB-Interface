class apb_agent_config extends uvm_object;

    `uvm_object_utils(apb_agent_config)

    int apb_drv_sent_data_count;
    int apb_mon_rcvd_data_count;

    virtual apb_if vif;

    uvm_active_passive_enum is_active = UVM_ACTIVE;

    function new(string name = "apb_agent_config");
        super.new(name);
    endfunction

endclass
