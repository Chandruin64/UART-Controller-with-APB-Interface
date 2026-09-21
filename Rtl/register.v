module register (
    input        Pclk,
    input        Presetn,
    input        Psel,
    input        Pwrite,
    input        Penable,
    input        tx_fifo_empty,
    input        tx_fifo_full,
    input        tx_busy,
    input        rx_overrun,
    input        parity_error,
    input        framing_error,
    input        break_error,
    input        time_out,
    input        rx_fifo_empty,
    input        rx_fifo_full,
    input  [4:0] rx_fifo_count,
    input  [7:0] PWdata,
    input  [7:0] rx_data_out,
    input  [7:0] Paddr,
    output reg [7:0] PRdata,
    output reg [7:0] LCR,
    output reg       tx_fifo_we,
    output reg       irq,
    output             rx_fifo_re,
    output             Pready,
    output             PSLVERR,
    output             tx_enable,
    output             rx_enable,
    output             baud_pulse,
    output             loop_back
);

    parameter IDLE   = 2'd0,
              SETUP  = 2'd1,
              ACCESS = 2'd2;

    reg        ls_int;
    reg        rx_int;
    reg        tx_int;
    reg        last_tx_fifo_empty;
    reg        rx_fifo_over_threshold;
    reg        start_dlc;
    reg        enable;

    reg [7:0]  FCR;
    reg [7:0]  IER;
    reg [7:0]  IIR;
    reg [7:0]  LSR;
    reg [7:0]  THR;
    reg [7:0]  MCR;
    reg [7:0]  MSR;

    reg [15:0] Divisor;
    reg [15:0] dlc;

    reg [1:0]  state;

    always @(posedge Pclk) begin
        if (!Presetn)
            IER <= 8'h0;
        else if (Pwrite && (Paddr == 8'h4) && Pready)
            IER <= PWdata;
        else
            IER <= IER;
    end

    always @(posedge Pclk) begin
        if (!Presetn)
            IIR <= 8'hc1;
        else if (ls_int && IER[2])
            IIR <= 8'hc6;
        else if (rx_int && IER[0])
            IIR <= 8'hc4;
        else if (time_out)
            IIR <= 8'hcc;
        else if (tx_int && IER[1])
            IIR <= 8'hc2;
        else
            IIR <= 8'hc1;
    end

    always @(posedge Pclk) begin
        if (!Presetn)
            FCR <= 8'hc0;
        else if (Pwrite && (Paddr == 8'h8) && Pready)
            FCR <= PWdata;
        else
            FCR <= FCR;
    end

    always @(posedge Pclk) begin
        if (!Presetn)
            LCR <= 8'b11;
        else if (Pwrite && (Paddr == 8'hc) && Pready)
            LCR <= PWdata;
        else
            LCR <= LCR;
    end

    always @(posedge Pclk) begin
        if (!Presetn)
            LSR <= 8'h60;
        else if (!Pwrite && (Paddr == 8'h14) && Pready)
            LSR <= 8'h60;
        else begin
            LSR[0] <= LSR[0] ? LSR[0] : !rx_fifo_empty;
            LSR[1] <= LSR[1] ? LSR[1] : rx_overrun;
            LSR[2] <= LSR[2] ? LSR[2] : parity_error;
            LSR[3] <= LSR[3] ? LSR[3] : framing_error;
            LSR[4] <= LSR[4] ? LSR[4] : break_error;
            LSR[5] <= LSR[5] ? LSR[5] : tx_fifo_empty;
            LSR[6] <= LSR[6] ? LSR[6] : !tx_busy & tx_fifo_empty;
            LSR[7] <= LSR[7] ? LSR[7] :
                      rx_overrun | parity_error | framing_error | break_error;
        end
    end

    always @(posedge Pclk) begin
        if (!Presetn) begin
            MCR <= 8'h0;
            MSR <= 8'h0;
        end
        else if (Pwrite && (Paddr == 8'h10) && Pready)
            MCR <= PWdata;
        else
            MCR <= MCR;
    end

    always @(posedge Pclk) begin
        if (!Presetn)
            last_tx_fifo_empty <= 1'b0;
        else
            last_tx_fifo_empty <= tx_fifo_empty;
    end

    always @(posedge Pclk) begin
        if (!Presetn)
            tx_fifo_we <= 1'b0;
        else if (Pwrite && (Paddr == 8'h0) && (state == SETUP))
            tx_fifo_we <= 1'b1;
        else
            tx_fifo_we <= 1'b0;
    end

    always @(posedge Pclk) begin
        if (!Presetn)
            rx_int <= 1'b0;
        else
            rx_int <= rx_fifo_over_threshold;
    end

    always @(posedge Pclk) begin
        case (FCR[7:5])
            3'b000: rx_fifo_over_threshold <= (rx_fifo_count >= 1);
            3'b010: rx_fifo_over_threshold <= (rx_fifo_count >= 4);
            3'b100: rx_fifo_over_threshold <= (rx_fifo_count >= 8);
            3'b110: rx_fifo_over_threshold <= (rx_fifo_count >= 14);
            default: rx_fifo_over_threshold <= 1'b0;
        endcase
    end

    always @(posedge Pclk) begin
        if (!Presetn)
            tx_int <= 1'b0;
        else if (!Pwrite &&
                 Paddr == 8'h8 &&
                 PRdata == 8'hc2 &&
                 Pready)
            tx_int <= 1'b0;
        else
            tx_int <= tx_int | (tx_fifo_empty & !last_tx_fifo_empty);
    end

    always @(posedge Pclk) begin
        if (!Presetn)
            ls_int <= 1'h0;
        else if (!Pwrite && (Paddr == 8'h14))
            ls_int <= 1'b0;
        else
            ls_int <= |LSR[4:1];
    end

    always @(posedge Pclk) begin
        if (!Presetn)
            irq <= 1'b0;
        else if (!Pwrite && Paddr == 8'h8 && Pready)
            irq <= 1'b0;
        else
            irq <= time_out |
                   (IER[0] && rx_int) |
                   (IER[1] && tx_int) |
                   (IER[2] && ls_int);
    end

    always @(posedge Pclk) begin
        if (!Presetn)
            enable <= 1'b0;
        else if (|Divisor & ~(|dlc))
            enable <= 1'b1;
        else
            enable <= 1'b0;
    end

    always @(posedge Pclk) begin
        if (!Presetn)
            dlc <= 16'b0;
        else if (start_dlc | ~(|dlc))
            dlc <= Divisor - 16'd1;
        else
            dlc <= dlc - 16'd1;
    end

    always @(posedge Pclk) begin
        if (!Presetn)
            Divisor <= 16'b0;
        else if (Pwrite && (Paddr == 8'h1c) && Pready)
            Divisor[7:0] <= PWdata;
        else if (Pwrite && (Paddr == 8'h20) && Pready)
            Divisor[15:8] <= PWdata;
        else
            Divisor <= Divisor;
    end

    always @(posedge Pclk) begin
        if (!Presetn)
            start_dlc <= 1'b0;
        else if (Pwrite &&
                 ((Paddr == 8'h1c) || (Paddr == 8'h20)) &&
                 Pready) begin
            start_dlc <= 1'b1;
        end
        else
            start_dlc <= 1'b0;
    end

    always @(posedge Pclk) begin
        if (!Presetn)
            state <= IDLE;
        else begin
            case (state)

                IDLE: begin
                    if (Psel && !Penable)
                        state <= SETUP;
                    else
                        state <= IDLE;
                end

                SETUP: begin
                    if (Psel && Penable)
                        state <= ACCESS;
                    else if (!Psel)
                        state <= IDLE;
                    else
                        state <= SETUP;
                end

                ACCESS: begin
                    if (Psel && Penable)
                        state <= ACCESS;
                    else if (Psel && !Penable)
                        state <= SETUP;
                    else
                        state <= IDLE;
                end

                default:
                    state <= IDLE;

            endcase
        end
    end

    always @(posedge Pclk) begin
        if (!Presetn)
            PRdata <= 8'b0;
        else if (!Pwrite && Psel && Penable) begin
            if (Paddr == 8'h4)
                PRdata <= IER;
            else if (Paddr == 8'h8)
                PRdata <= IIR;
            else if (Paddr == 8'hc)
                PRdata <= LCR;
            else if (Paddr == 8'h14)
                PRdata <= LSR;
            else if (Paddr == 8'h10)
                PRdata <= MCR;
            else if (Paddr == 8'h18)
                PRdata <= MSR;
            else if (Paddr == 8'h1c)
                PRdata <= Divisor[7:0];
            else if (Paddr == 8'h20)
                PRdata <= Divisor[15:8];
            else if (Paddr == 8'h0)
                PRdata <= rx_data_out;
            else
                PRdata <= PRdata;
        end
        else
            PRdata <= PRdata;
    end

    assign rx_fifo_re = (!Pwrite &&
                         (Paddr == 8'h0) &&
                         Psel &&
                         !Penable);

    assign loop_back = MCR[4];
    assign Pready    = (state == ACCESS);

    assign PSLVERR = Psel &&
                     !((Paddr == 8'h0) ||
                       (Paddr == 8'h04) ||
                       (Paddr == 8'h08) ||
                       (Paddr == 8'h0c) ||
                       (Paddr == 8'h14 && !Pwrite) ||
                       (Paddr == 8'h10) ||
                       (Paddr == 8'h18 && !Pwrite) ||
                       (Paddr == 8'h1c) ||
                       (Paddr == 8'h20));

    assign tx_enable  = enable;
    assign rx_enable  = enable;
    assign baud_pulse = enable;

endmodule
