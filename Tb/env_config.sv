class env_config extends uvm_object;

    `uvm_object_utils(env_config)

    apb_agent_config  apb_cfg;
    uart_agent_config uart_cfg;
    reg_block         reg_model;

    function new(string name = "env_config");
        super.new(name);
    endfunction

endclass
