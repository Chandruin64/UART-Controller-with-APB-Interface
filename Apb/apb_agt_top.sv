class apb_agt_top extends uvm_env;

    `uvm_component_utils(apb_agt_top)

    apb_agent agent;

    function new(
        string name = "apb_agt_top",
        uvm_component parent
    );
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = apb_agent::type_id::create("agent", this);
    endfunction

endclass
