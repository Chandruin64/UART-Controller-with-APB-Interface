interface apb_if (
    input bit clock
);

    bit        Pclk;
    logic      Presetn;
    logic      Pwrite;
    logic      Penable;
    logic      Psel;
    logic [7:0] Paddr;
    logic [7:0] PWdata;
    logic [7:0] PRdata;
    logic      Pready;
    logic      PSLVERR;

    assign Pclk = clock;

    clocking apb_drv_cb @(posedge clock);
        default input #1 output #1;

        output Presetn;
        output Pwrite;
        output Psel;
        output Penable;
        output Paddr;
        output PWdata;

        input PRdata;
        input Pready;
        input PSLVERR;
    endclocking

    clocking apb_mon_cb @(posedge clock);
        default input #1 output #1;

        input Presetn;
        input Pwrite;
        input Psel;
        input Penable;
        input Paddr;
        input PWdata;
        input PRdata;
        input Pready;
        input PSLVERR;
    endclocking

    modport APB_DUV_MP (
        input  Pclk,
        input  Presetn,
        input  Pwrite,
        input  Penable,
        input  Psel,
        input  Paddr,
        input  PWdata,
        output PRdata,
        output Pready,
        output PSLVERR
    );

    modport APB_DRV_MP (
        clocking apb_drv_cb
    );

    modport APB_MON_MP (
        clocking apb_mon_cb
    );

    // Assertions
    property pready_set;
        @(posedge clock) (Psel && Penable) |=> Pready;
    endproperty

    property pready_notset;
        @(posedge clock) (!Psel && !Penable) |=> !Pready;
    endproperty

    property pready_notset2;
        @(posedge clock) (Psel && !Penable) |=> !Pready;
    endproperty

    property read_only_lsr;
        @(posedge clock) Pwrite |-> Paddr != 8'h14;
    endproperty

    PREADY_SET:
        assert property (pready_set);

    PREADY_NOTSET:
        assert property (pready_notset);

    PREADY_NOTSET2:
        assert property (pready_notset2);

    READ_ONLY_LSR:
        assert property (read_only_lsr);

endinterface
