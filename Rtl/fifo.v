module fifo (
    input        clk,
    input        rstn,
    input        push,
    input        pop,
    input  [7:0] data_in,
    output       fifo_empty,
    output       fifo_full,
    output reg [7:0] data_out,
    output reg [4:0] count
);

    integer i;
    reg [7:0] data_fifo [0:15];
    reg [3:0] ip_count;
    reg [3:0] op_count;

    // Write pointer and FIFO memory
    always @(posedge clk) begin
        if (!rstn) begin
            ip_count <= 0;

            for (i = 0; i < 16; i = i + 1)
                data_fifo[i] <= 0;
        end
        else begin
            ip_count <= ip_count;

            case ({push, pop})
                2'b00,
                2'b01: begin
                    ip_count <= ip_count;
                end

                2'b10: begin
                    if (count <= 5'd15) begin
                        ip_count <= ip_count + 1'b1;
                        data_fifo[ip_count] <= data_in;
                    end
                    else begin
                        ip_count <= ip_count;
                    end
                end

                2'b11: begin
                    ip_count <= ip_count + 1'b1;
                    data_fifo[ip_count] <= data_in;
                end

                default: begin
                    ip_count <= ip_count;
                end
            endcase
        end
    end

    // Read pointer and FIFO output
    always @(posedge clk) begin
        if (!rstn) begin
            op_count <= 0;
            data_out <= 0;
        end
        else begin
            data_out <= data_out;
            op_count <= op_count;

            case ({push, pop})
                2'b00,
                2'b10: begin
                    op_count <= op_count;
                end

                2'b01: begin
                    if (count > 4'd0) begin
                        op_count <= op_count + 1'b1;
                        data_out <= data_fifo[op_count];
                    end
                    else begin
                        op_count <= op_count;
                    end
                end

                2'b11: begin
                    op_count <= op_count + 1'b1;
                    data_out <= data_fifo[op_count];
                end

                default: begin
                    op_count <= op_count;
                end
            endcase
        end
    end

    // FIFO occupancy counter
    always @(posedge clk) begin
        if (!rstn) begin
            count <= 0;
        end
        else begin
            count <= count;

            case ({push, pop})
                2'b00,
                2'b11: begin
                    count <= count;
                end

                2'b01: begin
                    if (count > 5'd0)
                        count <= count - 1'b1;
                    else
                        count <= count;
                end

                2'b10: begin
                    if (count <= 5'd15)
                        count <= count + 1'b1;
                    else
                        count <= count;
                end

                default: begin
                    count <= count;
                end
            endcase
        end
    end

    assign fifo_empty = ~(|count);
    assign fifo_full  = (count == 5'd16);

endmodule
