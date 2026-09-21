package pkg;

    import uvm_pkg::*;

    `include "uvm_macros.svh"

    `include "reg.sv"
    `include "reg_block.sv"
    `include "apb_agent_config.sv"
    `include "uart_agent_config.sv"
    `include "env_config.sv"

    `include "apb_xtn.sv"
    `include "apb_seqs.sv"
    `include "apb_sequencer.sv"
    `include "apb_monitor.sv"
    `include "apb_driver.sv"
    `include "apb_agent.sv"
    `include "apb_agt_top.sv"

    `include "uart_xtn.sv"
    `include "uart_seqs.sv"
    `include "uart_sequencer.sv"
    `include "uart_monitor.sv"
    `include "uart_driver.sv"
    `include "uart_agent.sv"
    `include "uart_agt_top.sv"

    `include "virtual_sequencer.sv"
    `include "virtual_seqs.sv"
    `include "scoreboard.sv"
    `include "env.sv"
    `include "test.sv"

endpackage
