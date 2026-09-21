class uart_driver extends uvm_driver #(uart_xtn);

    `uvm_component_utils(uart_driver)

    bit [7:0] lcr;
    bit [3:0] data_bits;
    bit       parity;

    virtual uart_if.UART_DRV_MP vif;
    uart_agent_config cfg;

    function new(
        string name = "uart_driver",
        uvm_component parent
    );
        super.new(name, parent);
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

        forever begin
            vif.uart_drv_cb.rxd <= 1'b1;

            seq_item_port.get_next_item(req);
            drive(req);
            seq_item_port.item_done();
        end

    endtask

    task drive(uart_xtn xtn);

        if (!uvm_config_db#(bit [7:0])::get(
                this,
                "",
                "lcr",
                lcr
            ))
            `uvm_fatal("UART LCR Config", "Failed")

        case (lcr[1:0])

            2'b00: begin
                data_bits = 4'd5;

                case (lcr[5:3])
                    3'b001: parity = ~^xtn.rxd[4:0];
                    3'b011: parity = ^xtn.rxd[4:0];
                    3'b101: parity = 1'b1;
                    3'b111: parity = 1'b0;
                    default: parity = 1'b0;
                endcase
            end

            2'b01: begin
                data_bits = 4'd6;

                case (lcr[5:3])
                    3'b001: parity = ~^xtn.rxd[5:0];
                    3'b011: parity = ^xtn.rxd[5:0];
                    3'b101: parity = 1'b1;
                    3'b111: parity = 1'b0;
                    default: parity = 1'b0;
                endcase
            end

            2'b10: begin
                data_bits = 4'd7;

                case (lcr[5:3])
                    3'b001: parity = ~^xtn.rxd[6:0];
                    3'b011: parity = ^xtn.rxd[6:0];
                    3'b101: parity = 1'b1;
                    3'b111: parity = 1'b0;
                    default: parity = 1'b0;
                endcase
            end

            2'b11: begin
                data_bits = 4'd8;

                case (lcr[5:3])
                    3'b001: parity = ~^xtn.rxd[7:0];
                    3'b011: parity = ^xtn.rxd[7:0];
                    3'b101: parity = 1'b1;
                    3'b111: parity = 1'b0;
                    default: parity = 1'b0;
                endcase
            end

            default: begin
                data_bits = 4'd8;

                case (lcr[5:3])
                    3'b001: parity = ~^xtn.rxd[7:0];
                    3'b011: parity = ^xtn.rxd[7:0];
                    3'b101: parity = 1'b1;
                    3'b111: parity = 1'b0;
                    default: parity = 1'b0;
                endcase
            end

        endcase

        // Start bit
        vif.uart_drv_cb.rxd <= 1'b0;
        repeat (16)
            @(posedge vif.uart_drv_cb.baud_pulse);

        // Data bits
        for (int i = 0; i < data_bits; i++) begin
            vif.uart_drv_cb.rxd <= xtn.rxd[i];

            repeat (16)
                @(posedge vif.uart_drv_cb.baud_pulse);
        end

        // Parity bit
        if (lcr[3]) begin
            vif.uart_drv_cb.rxd <= xtn.bad_parity ^ parity;

            repeat (16)
                @(posedge vif.uart_drv_cb.baud_pulse);
        end

        // Stop bits
        if (lcr[2:0] == 3'b100) begin
            vif.uart_drv_cb.rxd <= xtn.bad_stop_bit ^ 1'b1;

            // 1.5 bit time
            repeat (24)
                @(posedge vif.uart_drv_cb.baud_pulse);
        end
        else if (lcr[2]) begin
            vif.uart_drv_cb.rxd <= xtn.bad_stop_bit ^ 1'b1;

            // 2 bit time
            repeat (32)
                @(posedge vif.uart_drv_cb.baud_pulse);
        end
        else begin
            vif.uart_drv_cb.rxd <= xtn.bad_stop_bit ^ 1'b1;

            // 1 bit time
            repeat (16)
                @(posedge vif.uart_drv_cb.baud_pulse);
        end

        `uvm_info(
            get_full_name(),
            $sformatf(
                "The Data sent from UART DRIVER: \n%s",
                xtn.sprint()
            ),
            UVM_LOW
        )

        cfg.uart_drv_sent_data_count++;

    endtask

    function void report_phase(uvm_phase phase);
        `uvm_info(
            "UART DRIVER",
            $sformatf(
                "The no of transactions sent: %0d",
                cfg.uart_drv_sent_data_count
            ),
            UVM_LOW
        )
    endfunction

endclass
