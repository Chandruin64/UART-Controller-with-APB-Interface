class uart_monitor extends uvm_monitor;

    `uvm_component_utils(uart_monitor)

    bit [7:0] lcr;
    bit [3:0] data_bits;
    bit       parity;

    uvm_analysis_port #(uart_xtn) monitor_port;
    virtual uart_if.UART_MON_MP vif;
    uart_agent_config cfg;

    function new(
        string name = "uart_monitor",
        uvm_component parent
    );
        super.new(name, parent);
        monitor_port = new("monitor_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(uart_agent_config)::get(
                this,
                "",
                "uart_agent_config",
                cfg
            ))
            `uvm_fatal("UART Agent Config", "Failed")
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vif = cfg.vif;
    endfunction

    task run_phase(uvm_phase phase);

        fork

            forever begin
                collect_trans();
            end

            forever begin
                collect_rcvr();
            end

        join

    endtask

    task collect_trans();

        uart_xtn xtn;

        xtn = uart_xtn::type_id::create("xtn");

        if (!uvm_config_db#(bit [7:0])::get(
                this,
                "",
                "lcr",
                lcr
            ))
            `uvm_fatal("UART LCR Config", "Failed")

        case (lcr[1:0])
            2'b00: data_bits = 4'd5;
            2'b01: data_bits = 4'd6;
            2'b10: data_bits = 4'd7;
            2'b11: data_bits = 4'd8;
            default: data_bits = 4'd8;
        endcase

        // Start bit
        wait (!vif.uart_mon_cb.txd);

        repeat (8) begin
            @(posedge vif.uart_mon_cb.baud_pulse);
        end

        repeat (16) begin
            @(posedge vif.uart_mon_cb.baud_pulse);
        end

        // Data bits
        for (int i = 0; i < data_bits; i++) begin
            xtn.txd[i] = vif.uart_mon_cb.txd;

            repeat (16) begin
                @(posedge vif.uart_mon_cb.baud_pulse);
            end
        end

        // Parity bit
        if (lcr[3]) begin
            xtn.parity = vif.uart_mon_cb.txd;

            repeat (16) begin
                @(posedge vif.uart_mon_cb.baud_pulse);
            end
        end

        // Stop bits
        if (lcr[2:0] == 3'b100) begin
            // 1.5 bit time
            xtn.stop_bit = vif.uart_mon_cb.txd;

            repeat (16) begin
                @(posedge vif.uart_mon_cb.baud_pulse);
            end
        end
        else if (lcr[2]) begin
            // 2 bit time
            xtn.stop_bit = vif.uart_mon_cb.txd;

            repeat (24) begin
                @(posedge vif.uart_mon_cb.baud_pulse);
            end
        end
        else begin
            // 1 bit time
            xtn.stop_bit = vif.uart_mon_cb.txd;

            repeat (8) begin
                @(posedge vif.uart_mon_cb.baud_pulse);
            end
        end

        xtn.irq = vif.uart_mon_cb.irq;

        monitor_port.write(xtn);

        `uvm_info(
            get_full_name(),
            $sformatf(
                "The Data sent from UART MONITOR: \n%s",
                xtn.sprint()
            ),
            UVM_LOW
        )

        cfg.uart_mon_rcvd_data_count++;

    endtask

    task collect_rcvr();

        uart_xtn xtn;

        xtn = uart_xtn::type_id::create("xtn");

        if (!uvm_config_db#(bit [7:0])::get(
                this,
                "",
                "lcr",
                lcr
            ))
            `uvm_fatal("UART LCR Config", "Failed")

        case (lcr[1:0])
            2'b00: data_bits = 4'd5;
            2'b01: data_bits = 4'd6;
            2'b10: data_bits = 4'd7;
            2'b11: data_bits = 4'd8;
            default: data_bits = 4'd8;
        endcase

        // Start bit
        wait (!vif.uart_mon_cb.rxd);

        repeat (8) begin
            @(posedge vif.uart_mon_cb.baud_pulse);
        end

        repeat (16) begin
            @(posedge vif.uart_mon_cb.baud_pulse);
        end

        // Data bits
        for (int i = 0; i < data_bits; i++) begin
            xtn.rxd[i] = vif.uart_mon_cb.rxd;

            repeat (16) begin
                @(posedge vif.uart_mon_cb.baud_pulse);
            end
        end

        // Parity bit
        if (lcr[3]) begin
            xtn.parity = vif.uart_mon_cb.rxd;

            repeat (16) begin
                // $display("Parity bit:%0d", vif.uart_mon_cb.rxd);
                @(posedge vif.uart_mon_cb.baud_pulse);
            end
        end

        // Stop bits
        if (lcr[2:0] == 3'b100) begin
            // 1.5 bit time
            xtn.stop_bit = vif.uart_mon_cb.rxd;

            repeat (16) begin
                @(posedge vif.uart_mon_cb.baud_pulse);
            end
        end
        else if (lcr[2]) begin
            // 2 bit time
            xtn.stop_bit = vif.uart_mon_cb.rxd;

            repeat (24) begin
                @(posedge vif.uart_mon_cb.baud_pulse);
            end
        end
        else begin
            // 1 bit time
            xtn.stop_bit = vif.uart_mon_cb.rxd;

            repeat (8) begin
                @(posedge vif.uart_mon_cb.baud_pulse);
            end
        end

        xtn.irq = vif.uart_mon_cb.irq;

        monitor_port.write(xtn);

        `uvm_info(
            get_full_name(),
            $sformatf(
                "The Data sent from UART MONITOR: \n%s",
                xtn.sprint()
            ),
            UVM_LOW
        )

        cfg.uart_mon_rcvd_data_count++;

    endtask

    function void report_phase(uvm_phase phase);
        `uvm_info(
            "UART MONITOR",
            $sformatf(
                "The no of transactions received: %0d",
                cfg.uart_mon_rcvd_data_count
            ),
            UVM_LOW
        )
    endfunction

endclass
