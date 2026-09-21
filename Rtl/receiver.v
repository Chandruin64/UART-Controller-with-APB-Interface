module receiver (
    input        Pclk,
    input        Presetn,
    input        rxd,
    input        pop_rx_fifo,
    input        enable,
    input        Pwrite,
    input        Pready,
    input        PWdata1,
    input  [7:0] LCR,
    input  [7:0] Paddr,
    output       rx_idle,
    output       push_rx_fifo,
    output       rx_fifo_full,
    output       rx_overrun,
    output       break_error,
    output       time_out,
    output reg   parity_error,
    output reg   framing_error,
    output [4:0] rx_fifo_count,
    output [7:0] rx_fifo_out,
    output       rx_fifo_empty
);

    parameter IDLE   = 4'd0,
              START  = 4'd1,
              BIT0   = 4'd2,
              BIT1   = 4'd3,
              BIT2   = 4'd4,
              BIT3   = 4'd5,
              BIT4   = 4'd6,
              BIT5   = 4'd7,
              BIT6   = 4'd8,
              BIT7   = 4'd9,
              PARITY = 4'd10,
              STOP1  = 4'd11,
              STOP2  = 4'd12;

    reg        flag;
    reg [3:0]  rx_state;
    reg [3:0]  bit_counter;
    reg [7:0]  rx_buffer;
    reg [7:0]  brc_value;
    reg [7:0]  counter_b;
    reg [9:0]  toc_value;
    reg [9:0]  counter_t;

    wire rx_fifo_resetn;

    assign rx_fifo_resetn = (Presetn &&
                             !(Pwrite && (Paddr == 8'h8) &&
                               Pready && PWdata1));

    fifo rx_fifo (
        .clk        (Pclk),
        .rstn       (rx_fifo_resetn),
        .push       (push_rx_fifo),
        .pop        (pop_rx_fifo),
        .data_in    (rx_buffer),
        .fifo_empty (rx_fifo_empty),
        .fifo_full  (rx_fifo_full),
        .data_out   (rx_fifo_out),
        .count      (rx_fifo_count)
    );

    always @(posedge Pclk) begin
        if (!Presetn) begin
            rx_state      <= IDLE;
            bit_counter   <= 4'd0;
            rx_buffer     <= 8'd0;
            framing_error <= 1'b0;
            parity_error  <= 1'b0;
            flag          <= 1'b0;
        end
        else begin
            rx_buffer    <= rx_buffer;
            parity_error <= parity_error;

            case (rx_state)

                IDLE: begin
                    if (!break_error && !rxd) begin
                        rx_buffer   <= 8'd0;
                        rx_state    <= START;
                        bit_counter <= 4'b0;
                    end
                    else begin
                        rx_state <= IDLE;
                    end
                end

                START: begin
                    if (bit_counter == 4'h7 &&
                        enable &&
                        !rxd) begin

                        rx_state    <= BIT0;
                        bit_counter <= 4'b0;
                    end
                    else begin
                        rx_state <= START;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                BIT0: begin
                    if (bit_counter == 4'hf && enable) begin
                        rx_buffer[0] <= rxd;
                        rx_state     <= BIT1;
                        bit_counter  <= 4'b0;
                    end
                    else begin
                        rx_state <= BIT0;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                BIT1: begin
                    if (bit_counter == 4'hf && enable) begin
                        rx_buffer[1] <= rxd;
                        rx_state     <= BIT2;
                        bit_counter  <= 4'b0;
                    end
                    else begin
                        rx_state <= BIT1;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                BIT2: begin
                    if (bit_counter == 4'hf && enable) begin
                        rx_buffer[2] <= rxd;
                        rx_state     <= BIT3;
                        bit_counter  <= 4'b0;
                    end
                    else begin
                        rx_state <= BIT2;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                BIT3: begin
                    if (bit_counter == 4'hf && enable) begin
                        rx_buffer[3] <= rxd;
                        rx_state     <= BIT4;
                        bit_counter  <= 4'b0;
                    end
                    else begin
                        rx_state <= BIT3;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                BIT4: begin
                    if (bit_counter == 4'hf &&
                        enable &&
                        (LCR[1:0] > 0)) begin

                        rx_buffer[4] <= rxd;
                        rx_state     <= BIT5;
                        bit_counter  <= 4'b0;
                    end
                    else if (bit_counter == 4'hf &&
                             enable &&
                             (LCR[1:0] == 2'b00) &&
                             (LCR[3] == 0)) begin

                        rx_buffer[4] <= rxd;
                        rx_state     <= STOP1;
                        bit_counter  <= 4'b0;
                    end
                    else if (bit_counter == 4'hf &&
                             enable &&
                             (LCR[1:0] == 2'b00) &&
                             (LCR[3] == 1)) begin

                        rx_buffer[4] <= rxd;
                        rx_state     <= PARITY;
                        bit_counter  <= 4'b0;
                    end
                    else begin
                        rx_state <= BIT4;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                BIT5: begin
                    if (bit_counter == 4'hf &&
                        enable &&
                        (LCR[1:0] > 1)) begin

                        rx_buffer[5] <= rxd;
                        rx_state     <= BIT6;
                        bit_counter  <= 4'b0;
                    end
                    else if (bit_counter == 4'hf &&
                             enable &&
                             (LCR[1:0] == 2'b01) &&
                             (LCR[3] == 0)) begin

                        rx_buffer[5] <= rxd;
                        rx_state     <= STOP1;
                        bit_counter  <= 4'b0;
                    end
                    else if (bit_counter == 4'hf &&
                             enable &&
                             (LCR[1:0] == 2'b01) &&
                             (LCR[3] == 1)) begin

                        rx_buffer[5] <= rxd;
                        rx_state     <= PARITY;
                        bit_counter  <= 4'b0;
                    end
                    else begin
                        rx_state <= BIT5;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                BIT6: begin
                    if (bit_counter == 4'hf &&
                        enable &&
                        (LCR[1:0] > 2)) begin

                        rx_buffer[6] <= rxd;
                        rx_state     <= BIT7;
                        bit_counter  <= 4'b0;
                    end
                    else if (bit_counter == 4'hf &&
                             enable &&
                             (LCR[1:0] == 2'b10) &&
                             (LCR[3] == 0)) begin

                        rx_buffer[6] <= rxd;
                        rx_state     <= STOP1;
                        bit_counter  <= 4'b0;
                    end
                    else if (bit_counter == 4'hf &&
                             enable &&
                             (LCR[1:0] == 2'b10) &&
                             (LCR[3] == 1)) begin

                        rx_buffer[6] <= rxd;
                        rx_state     <= PARITY;
                        bit_counter  <= 4'b0;
                    end
                    else begin
                        rx_state <= BIT6;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                BIT7: begin
                    if (bit_counter == 4'hf &&
                        enable &&
                        (LCR[1:0] == 2'b11) &&
                        (LCR[3] == 0)) begin

                        rx_buffer[7] <= rxd;
                        rx_state     <= STOP1;
                        bit_counter  <= 4'b0;
                    end
                    else if (bit_counter == 4'hf &&
                             enable &&
                             (LCR[1:0] == 2'b11) &&
                             (LCR[3] == 1)) begin

                        rx_buffer[7] <= rxd;
                        rx_state     <= PARITY;
                        bit_counter  <= 4'b0;
                    end
                    else begin
                        rx_state <= BIT7;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                PARITY: begin
                    if (bit_counter == 4'hf && enable) begin
                        rx_state    <= STOP1;
                        bit_counter <= 4'b0;
                    end
                    else if (bit_counter == 4'h0) begin
                        rx_state <= PARITY;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter + 4'b1;

                        case (LCR[5:3])

                            3'b001: begin
                                if (^{rxd, rx_buffer})
                                    parity_error <= 1'b1;
                                else
                                    parity_error <= 1'b0;
                            end

                            3'b011: begin
                                if (~^{rxd, rx_buffer})
                                    parity_error <= 1'b1;
                                else
                                    parity_error <= 1'b0;
                            end

                            3'b101: begin
                                if (rxd)
                                    parity_error <= 1'b1;
                                else
                                    parity_error <= 1'b0;
                            end

                            3'b111: begin
                                if (!rxd)
                                    parity_error <= 1'b1;
                                else
                                    parity_error <= 1'b0;
                            end

                            default: begin
                                parity_error <= 1'b0;
                            end

                        endcase
                    end
                    else begin
                        rx_state <= PARITY;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                STOP1: begin
                    if (bit_counter == 4'hf &&
                        enable &&
                        LCR[2] == 1'b1) begin

                        rx_state    <= STOP2;
                        bit_counter <= 4'b0;

                        if (rxd)
                            framing_error <= 1'b0;
                        else
                            framing_error <= 1'b1;
                    end
                    else if (bit_counter == 4'hf &&
                             enable &&
                             LCR[2] == 1'b0) begin

                        rx_state    <= STOP1;
                        bit_counter <= 4'b0;
                        flag         <= 1'b1;

                        if (rxd)
                            framing_error <= 1'b0;
                        else
                            framing_error <= 1'b1;
                    end
                    else if (bit_counter == 4'h7 &&
                             enable &&
                             LCR[2] == 1'b0 &&
                             flag) begin

                        rx_state <= STOP1;

                        if (!break_error) begin
                            rx_state    <= IDLE;
                            bit_counter <= 4'b0;
                        end
                    end
                    else begin
                        rx_state <= STOP1;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                STOP2: begin
                    if (bit_counter == 4'hf && enable) begin
                        rx_state    <= STOP2;
                        bit_counter <= 4'b0;
                        flag        <= 1'b1;

                        if (rxd)
                            framing_error <= 1'b0;
                        else
                            framing_error <= 1'b1;
                    end
                    else if (bit_counter == 4'd11 &&
                             enable &&
                             LCR[1:0] == 2'b00) begin

                        rx_state    <= STOP2;
                        bit_counter <= 4'b0;
                        flag        <= 1'b1;

                        if (rxd)
                            framing_error <= 1'b0;
                        else
                            framing_error <= 1'b1;
                    end
                    else if (bit_counter == 4'h7 &&
                             enable &&
                             flag) begin

                        rx_state <= STOP2;

                        if (!break_error) begin
                            rx_state    <= IDLE;
                            bit_counter <= 4'b0;
                        end
                    end
                    else if (bit_counter == 4'h3 &&
                             enable &&
                             flag &&
                             LCR[1:0] == 2'b00) begin

                        rx_state <= STOP2;

                        if (!break_error) begin
                            rx_state    <= IDLE;
                            bit_counter <= 4'b0;
                        end
                    end
                    else begin
                        rx_state <= STOP2;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                default: begin
                    rx_state <= rx_state;
                end

            endcase
        end
    end

    always @(posedge Pclk) begin
        if (!Presetn)
            counter_b <= 8'd159;
        else if (rxd)
            counter_b <= brc_value;
        else if (counter_b != 8'd0 && enable)
            counter_b <= counter_b - 1'b1;
        else
            counter_b <= counter_b;
    end

    always @(posedge Pclk) begin
        if (!Presetn)
            counter_t <= 10'd639;
        else if (push_rx_fifo || pop_rx_fifo || !rx_fifo_count)
            counter_t <= toc_value;
        else if (counter_t != 10'd0 && enable)
            counter_t <= counter_t - 1'b1;
        else
            counter_t <= counter_t;
    end

    always @(LCR) begin
        case (LCR[3:0])
            4'd0:  toc_value = 10'd447;
            4'd1:  toc_value = 10'd511;
            4'd2:  toc_value = 10'd575;
            4'd3:  toc_value = 10'd639;
            4'd4:  toc_value = 10'd479;
            4'd5:  toc_value = 10'd575;
            4'd6:  toc_value = 10'd638;
            4'd7:  toc_value = 10'd703;
            4'd8:  toc_value = 10'd511;
            4'd9:  toc_value = 10'd575;
            4'd10: toc_value = 10'd639;
            4'd11: toc_value = 10'd703;
            4'd12: toc_value = 10'd543;
            4'd13: toc_value = 10'd639;
            4'd14: toc_value = 10'd703;
            4'd15: toc_value = 10'd767;

            default:
                toc_value = toc_value;
        endcase

        brc_value = toc_value[9:2];
    end

    assign push_rx_fifo = ((rx_state == STOP1) &&
                           (bit_counter == 4'hf) &&
                           enable);

    assign rx_idle    = rx_state == IDLE;
    assign rx_overrun = (rx_fifo_full && push_rx_fifo && !pop_rx_fifo);
    assign break_error = (counter_b == 0) ? 1'b1 : 1'b0;
    assign time_out    = (counter_t == 0) ? 1'b1 : 1'b0;

endmodule
