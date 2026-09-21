class scoreboard extends uvm_scoreboard;

    `uvm_component_utils(scoreboard)

    uart_xtn  uart;
    apb_xtn   apb;
    env_config env_cfg;

    reg_block   reg_model;
    uvm_status_e status;
    bit [7:0]   CTRL_REG;

    bit [7:0] q1[$], q2[$], mcr;

    uvm_tlm_analysis_fifo #(uart_xtn) uart_fifo;
    uvm_tlm_analysis_fifo #(apb_xtn)  apb_fifo;

    covergroup apb_cover_group;
        option.per_instance = 1;

        Reset: coverpoint apb.Presetn {
            bins rst = {0, 1};
        }

        Addr: coverpoint apb.Paddr {
            bins addr[] = {
                8'h0,
                8'h4,
                8'h8,
                8'hc,
                8'h10,
                8'h14,
                8'h1c,
                8'h20
            };
        }

        Selx: coverpoint apb.Psel {
            bins sel = {0, 1};
        }

        Enable: coverpoint apb.Penable {
            bins enb = {0, 1};
        }

        Write: coverpoint apb.Pwrite {
            bins wrt = {0, 1};
        }

        Ready: coverpoint apb.Pready {
            bins rdy = {0, 1};
        }

        Error: coverpoint apb.PSLVERR {
            bins err = {0, 1};
        }

        Wdata: coverpoint apb.PWdata {
            bins low  = {[8'h00:8'h0f]};
            bins high = {[8'h10:8'hff]};
        }

        Rdata: coverpoint apb.PRdata {
            bins low  = {[8'h00:8'h0f]};
            bins high = {[8'h10:8'hff]};
        }

        Selx_Enable_Ready: cross Selx, Enable, Ready;

    endgroup


    covergroup uart_cover_group;
        option.per_instance = 1;

        txd_data: coverpoint uart.txd {
            bins low  = {[8'h00:8'h0f]};
            bins high = {[8'h10:8'hff]};
        }

        rxd_data: coverpoint uart.rxd {
            bins low  = {[8'h00:8'h0f]};
            bins high = {[8'h10:8'hff]};
        }

    endgroup


    function new(string name = "scoreboard", uvm_component parent);
        super.new(name, parent);

        apb_cover_group  = new();
        uart_cover_group = new();
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        uart_fifo = new("uart_fifo", this);
        apb_fifo  = new("apb_fifo", this);

        if (!uvm_config_db#(env_config)::get(this, "", "env_config", env_cfg))
            `uvm_fatal("SCOREBOARD ENV CONFIG", "FAILED")

        reg_model = env_cfg.reg_model;
    endfunction


    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        fork
            forever begin
                apb_fifo.get(apb);
                apb_cover_group.sample();
                apb_check();
                ral();
            end

            forever begin
                uart_fifo.get(uart);
                uart_cover_group.sample();
                uart_check();
            end
        join

    endtask


    task uart_check();

        if (uart.rxd)
            q2.push_back(uart.rxd);

        if (uart.txd && !mcr[4])
            if (uart.txd == q1.pop_front())
                `uvm_info(
                    "SCOREBOARD",
                    "TRANSMITTED DATA SUCCESSFULLY",
                    UVM_LOW
                )
            else
                `uvm_error(
                    "SCOREBOARD",
                    "TRANSMITTED MISMATCH DATA"
                )

    endtask


    task apb_check();

        if (apb.Presetn) begin

            if (apb.Pwrite) begin
                case (apb.Paddr)
                    8'h0:  q1.push_back(apb.PWdata);
                    8'h10: mcr = apb.PWdata;
                endcase
            end

            else if ((apb.Paddr == 8'h0) && !apb.Pwrite) begin

                if (q1.size() && mcr[4])
                    if (apb.PRdata == q1.pop_front())
                        `uvm_info(
                            "SCOREBOARD",
                            "DATA LOOPBACK SUCCESSFUL",
                            UVM_LOW
                        )
                    else
                        `uvm_error(
                            "SCOREBOARD",
                            "LOOPBACK DATA MISMATCH"
                        )

                else if (q2.size())
                    if (apb.PRdata == q2.pop_front())
                        `uvm_info(
                            "SCOREBOARD",
                            "RECEIVED DATA SUCCESSFULLY",
                            UVM_LOW
                        )
                    else
                        `uvm_error(
                            "SCOREBOARD",
                            "RECEIVED MISMATCH DATA"
                        )

                else
                    `uvm_error(
                        "SCOREBOARD",
                        "NO DATA SENT FOR RECEIVER"
                    )
            end
        end

    endtask


    task ral();

        // For IER
        reg_model.ier.read(
            status,
            CTRL_REG,
            UVM_BACKDOOR,
            .map(reg_model.map)
        );

        if (apb.Paddr == 8'h4 && apb.Pwrite == 1)
            if (apb.PWdata == CTRL_REG) begin
                $display(
                    "PASS Addr = %p, Data = %h",
                    apb.Paddr,
                    apb.PWdata
                );
                `uvm_info(
                    "REGISTER COMPARISON SUCCEED",
                    "IER",
                    UVM_LOW
                )
            end
            else begin
                `uvm_error(
                    "REGISTER COMPARISON FAILED",
                    "IER"
                );
                $display(
                    "FAIL Addr = %p, Data = %h",
                    apb.Paddr,
                    apb.PWdata
                );
            end


        // For FCR
        reg_model.fcr.read(
            status,
            CTRL_REG,
            UVM_BACKDOOR,
            .map(reg_model.map)
        );

        if (apb.Paddr == 8'h8 && apb.Pwrite == 1)
            if (apb.PWdata == CTRL_REG) begin
                $display(
                    "PASS Addr = %p, Data = %h",
                    apb.Paddr,
                    apb.PWdata
                );
                `uvm_info(
                    "REGISTER COMPARISON SUCCEED",
                    "FCR",
                    UVM_LOW
                )
            end
            else begin
                `uvm_error(
                    "REGISTER COMPARISON FAILED",
                    "FCR"
                );
                $display(
                    "FAIL Addr = %p, Data = %h",
                    apb.Paddr,
                    apb.PWdata
                );
            end


        // For LCR
        reg_model.lcr.read(
            status,
            CTRL_REG,
            UVM_BACKDOOR,
            .map(reg_model.map)
        );

        if (apb.Paddr == 8'hc && apb.Pwrite == 1)
            if (apb.PWdata == CTRL_REG) begin
                $display(
                    "PASS Addr = %p, Data = %h",
                    apb.Paddr,
                    apb.PWdata
                );
                `uvm_info(
                    "REGISTER COMPARISON SUCCEED",
                    "LCR",
                    UVM_LOW
                )
            end
            else begin
                `uvm_error(
                    "REGISTER COMPARISON FAILED",
                    "LCR"
                );
                $display(
                    "FAIL Addr = %p, Data = %h",
                    apb.Paddr,
                    apb.PWdata
                );
            end


        // For MCR
        reg_model.mcr.read(
            status,
            CTRL_REG,
            UVM_BACKDOOR,
            .map(reg_model.map)
        );

        if (apb.Paddr == 8'h10 && apb.Pwrite == 1)
            if (apb.PWdata == CTRL_REG) begin
                $display(
                    "PASS Addr = %p, Data = %h",
                    apb.Paddr,
                    apb.PWdata
                );
                `uvm_info(
                    "REGISTER COMPARISON SUCCEED",
                    "MCR",
                    UVM_LOW
                )
            end
            else begin
                `uvm_error(
                    "REGISTER COMPARISON FAILED",
                    "MCR"
                );
                $display(
                    "FAIL Addr = %p, Data = %h",
                    apb.Paddr,
                    apb.PWdata
                );
            end


        // For DIV1
        reg_model.div1.read(
            status,
            CTRL_REG,
            UVM_BACKDOOR,
            .map(reg_model.map)
        );

        if (apb.Paddr == 8'h1c && apb.Pwrite == 1)
            if (apb.PWdata == CTRL_REG) begin
                $display(
                    "PASS Addr = %p, Data = %h",
                    apb.Paddr,
                    apb.PWdata
                );
                `uvm_info(
                    "REGISTER COMPARISON SUCCEED",
                    "DIV1",
                    UVM_LOW
                )
            end
            else begin
                `uvm_error(
                    "REGISTER COMPARISON FAILED",
                    "DIV1"
                );
                $display(
                    "FAIL Addr = %p, Data = %h",
                    apb.Paddr,
                    apb.PWdata
                );
            end


        // For DIV2
        reg_model.div2.read(
            status,
            CTRL_REG,
            UVM_BACKDOOR,
            .map(reg_model.map)
        );

        if (apb.Paddr == 8'h20 && apb.Pwrite == 1)
            if (apb.PWdata == CTRL_REG) begin
                $display(
                    "PASS Addr = %p, Data = %h",
                    apb.Paddr,
                    apb.PWdata
                );
                `uvm_info(
                    "REGISTER COMPARISON SUCCEED",
                    "DIV2",
                    UVM_LOW
                )
            end
            else begin
                `uvm_error(
                    "REGISTER COMPARISON FAILED",
                    "DIV2"
                );
                $display(
                    "FAIL Addr = %p, Data = %h",
                    apb.Paddr,
                    apb.PWdata
                );
            end

    endtask

endclass
