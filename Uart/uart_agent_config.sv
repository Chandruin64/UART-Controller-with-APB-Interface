class uart_agent_config extends uvm_object;

    `uvm_object_utils(uart_agent_config)

    int uart_drv_sent_data_count = 0;
    int uart_mon_rcvd_data_count = 0;

    virtual uart_if vif;

    uvm_active_passive_enum is_active = UVM_ACTIVE;

    function new(string name = "uart_agent_config");
        super.new(name);
    endfunction

endclass
