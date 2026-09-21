class uart_agt_top extends uvm_env;

    `uvm_component_utils(uart_agt_top)

    uart_agent agent;

    function new(
        string name = "uart_agt_top",
        uvm_component parent
    );
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = uart_agent::type_id::create("agent", this);
    endfunction

endclass
