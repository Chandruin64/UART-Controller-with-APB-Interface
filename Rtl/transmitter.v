module transmitter (
    input        Pclk,
    input        Presetn,
    input        tx_fifo_push,
    input        enable,
    input        Pwrite,
    input        Pready,
    input  [7:0] LCR,
    input  [7:0] PWDATA,
    input  [7:0] Paddr,
    output       busy,
    output       tx_fifo_full,
    output       tx_fifo_empty,
    output       TXD,
    output [4:0] tx_fifo_count
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

    reg [3:0] tx_state;
    reg [3:0] bit_counter;
    reg [7:0] tx_buffer;

    wire [7:0] tx_fifo_out;
    wire       pop_tx_fifo;
    wire       tx_fifo_resetn;

    reg TXD_temp;

    assign tx_fifo_resetn = (Presetn &&
                             !(Pwrite && (Paddr == 8'h8) &&
                               Pready && PWDATA[2]));

    fifo tx_fifo (
        .clk        (Pclk),
        .rstn       (tx_fifo_resetn),
        .push       (tx_fifo_push),
        .pop        (pop_tx_fifo),
        .data_in    (PWDATA),
        .fifo_empty (tx_fifo_empty),
        .fifo_full  (tx_fifo_full),
        .data_out   (tx_fifo_out),
        .count      (tx_fifo_count)
    );

    assign pop_tx_fifo = !tx_fifo_empty &&
                         enable &&
                         (tx_state == IDLE);

    always @(posedge Pclk) begin
        if (!Presetn) begin
            tx_state    <= 4'd0;
            bit_counter <= 4'd0;
            tx_buffer   <= 8'd0;
            TXD_temp    <= 1'b1;
        end
        else begin
            tx_buffer <= tx_buffer;
            TXD_temp  <= TXD_temp;

            case (tx_state)

                IDLE: begin
                    TXD_temp <= 1'b1;

                    if (!tx_fifo_empty && enable) begin
                        tx_state    <= START;
                        bit_counter <= 4'b0;
                    end
                    else begin
                        tx_state <= IDLE;
                    end
                end

                START: begin
                    TXD_temp <= 1'b0;

                    if (bit_counter == 4'hf && enable) begin
                        tx_buffer   <= tx_fifo_out;
                        tx_state    <= BIT0;
                        bit_counter <= 4'b0;
                    end
                    else begin
                        tx_state <= START;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                BIT0: begin
                    TXD_temp <= tx_buffer[0];

                    if (bit_counter == 4'hf && enable) begin
                        tx_state    <= BIT1;
                        bit_counter <= 4'b0;
                    end
                    else begin
                        tx_state <= BIT0;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                BIT1: begin
                    TXD_temp <= tx_buffer[1];

                    if (bit_counter == 4'hf && enable) begin
                        tx_state    <= BIT2;
                        bit_counter <= 4'b0;
                    end
                    else begin
                        tx_state <= BIT1;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                BIT2: begin
                    TXD_temp <= tx_buffer[2];

                    if (bit_counter == 4'hf && enable) begin
                        tx_state    <= BIT3;
                        bit_counter <= 4'b0;
                    end
                    else begin
                        tx_state <= BIT2;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                BIT3: begin
                    TXD_temp <= tx_buffer[3];

                    if (bit_counter == 4'hf && enable) begin
                        tx_state    <= BIT4;
                        bit_counter <= 4'b0;
                    end
                    else begin
                        tx_state <= BIT3;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                BIT4: begin
                    TXD_temp <= tx_buffer[4];

                    if (bit_counter == 4'hf &&
                        enable &&
                        (LCR[1:0] > 0)) begin

                        tx_state    <= BIT5;
                        bit_counter <= 4'b0;
                    end
                    else if (bit_counter == 4'hf &&
                             enable &&
                             (LCR[1:0] == 2'b00) &&
                             (LCR[3] == 0)) begin

                        tx_state    <= STOP1;
                        bit_counter <= 4'b0;
                    end
                    else if (bit_counter == 4'hf &&
                             enable &&
                             (LCR[1:0] == 2'b00) &&
                             (LCR[3] == 1)) begin

                        tx_state    <= PARITY;
                        bit_counter <= 4'b0;
                    end
                    else begin
                        tx_state <= BIT4;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                BIT5: begin
                    TXD_temp <= tx_buffer[5];

                    if (bit_counter == 4'hf &&
                        enable &&
                        (LCR[1:0] > 1)) begin

                        tx_state    <= BIT6;
                        bit_counter <= 4'b0;
                    end
                    else if (bit_counter == 4'hf &&
                             enable &&
                             (LCR[1:0] == 2'b01) &&
                             (LCR[3] == 0)) begin

                        tx_state    <= STOP1;
                        bit_counter <= 4'b0;
                    end
                    else if (bit_counter == 4'hf &&
                             enable &&
                             (LCR[1:0] == 2'b01) &&
                             (LCR[3] == 1)) begin

                        tx_state    <= PARITY;
                        bit_counter <= 4'b0;
                    end
                    else begin
                        tx_state <= BIT5;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                BIT6: begin
                    TXD_temp <= tx_buffer[6];

                    if (bit_counter == 4'hf &&
                        enable &&
                        (LCR[1:0] > 2)) begin

                        tx_state    <= BIT7;
                        bit_counter <= 4'b0;
                    end
                    else if (bit_counter == 4'hf &&
                             enable &&
                             (LCR[1:0] == 2'b10) &&
                             (LCR[3] == 0)) begin

                        tx_state    <= STOP1;
                        bit_counter <= 4'b0;
                    end
                    else if (bit_counter == 4'hf &&
                             enable &&
                             (LCR[1:0] == 2'b10) &&
                             (LCR[3] == 1)) begin

                        tx_state    <= PARITY;
                        bit_counter <= 4'b0;
                    end
                    else begin
                        tx_state <= BIT6;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                BIT7: begin
                    TXD_temp <= tx_buffer[7];

                    if (bit_counter == 4'hf &&
                        enable &&
                        (LCR[1:0] == 2'b11) &&
                        (LCR[3] == 0)) begin

                        tx_state    <= STOP1;
                        bit_counter <= 4'b0;
                    end
                    else if (bit_counter == 4'hf &&
                             enable &&
                             (LCR[1:0] == 2'b11) &&
                             (LCR[3] == 1)) begin

                        tx_state    <= PARITY;
                        bit_counter <= 4'b0;
                    end
                    else begin
                        tx_state <= BIT7;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                PARITY: begin
                    TXD_temp <= TXD_temp;

                    if (bit_counter == 4'hf && enable) begin
                        tx_state    <= STOP1;
                        bit_counter <= 4'b0;
                    end
                    else if (bit_counter == 4'h0) begin
                        if (enable)
                            bit_counter <= bit_counter + 1'b1;
                        else
                            bit_counter <= bit_counter;

                        tx_state <= PARITY;

                        case (LCR[5:4])
                            2'b00: begin
                                TXD_temp <= ~^tx_buffer;
                            end

                            2'b01: begin
                                TXD_temp <= ^tx_buffer;
                            end

                            2'b10: begin
                                TXD_temp <= 1'b1;
                            end

                            2'b11: begin
                                TXD_temp <= 1'b0;
                            end

                            default: begin
                                TXD_temp <= TXD_temp;
                            end
                        endcase
                    end
                    else begin
                        tx_state <= PARITY;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                STOP1: begin
                    TXD_temp <= 1'b1;

                    if (bit_counter == 4'hf &&
                        enable &&
                        LCR[2] == 1'b1) begin

                        tx_state    <= STOP2;
                        bit_counter <= 4'b0;
                    end
                    else if (bit_counter == 4'hf &&
                             enable &&
                             LCR[2] == 1'b0) begin

                        tx_state    <= IDLE;
                        bit_counter <= 4'b0;
                    end
                    else begin
                        tx_state <= STOP1;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                STOP2: begin
                    TXD_temp <= 1'b1;

                    if (bit_counter == 4'hf && enable) begin
                        tx_state    <= IDLE;
                        bit_counter <= 4'b0;
                    end
                    else if (bit_counter == 4'h7 &&
                             enable &&
                             LCR[1:0] == 2'b00) begin

                        tx_state    <= IDLE;
                        bit_counter <= 4'b0;
                    end
                    else begin
                        tx_state <= STOP2;

                        if (enable)
                            bit_counter <= bit_counter + 4'b1;
                        else
                            bit_counter <= bit_counter;
                    end
                end

                default: begin
                    tx_state <= tx_state;
                end

            endcase
        end
    end

    assign busy = tx_state != IDLE;
    assign TXD  = LCR[6] ? 1'b0 : TXD_temp;

endmodule
