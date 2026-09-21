class reg_block extends uvm_reg_block;

    `uvm_object_utils(reg_block)

    ier_reg     ier;
    fcr_reg     fcr;
    lcr_reg     lcr;
    mcr_reg     mcr;
    div1_reg    div1;
    div2_reg    div2;
    uvm_reg_map map;

    function new(string name = "reg_block");
        super.new(name, build_coverage(UVM_CVR_ADDR_MAP));
    endfunction

    function void build();

        ier = ier_reg::type_id::create("ier");
        ier.configure(this, null, "");
        ier.build();
        ier.add_hdl_path_slice("IER", 0, 8);

        fcr = fcr_reg::type_id::create("fcr");
        fcr.configure(this, null, "");
        fcr.build();
        fcr.add_hdl_path_slice("FCR", 0, 8);

        lcr = lcr_reg::type_id::create("lcr");
        lcr.configure(this, null, "");
        lcr.build();
        lcr.add_hdl_path_slice("LCR", 0, 8);

        mcr = mcr_reg::type_id::create("mcr");
        mcr.configure(this, null, "");
        mcr.build();
        mcr.add_hdl_path_slice("MCR", 0, 8);

        div1 = div1_reg::type_id::create("div1");
        div1.configure(this, null, "");
        div1.build();
        div1.add_hdl_path_slice("Divisor[7:0]", 0, 8);

        div2 = div2_reg::type_id::create("div2");
        div2.configure(this, null, "");
        div2.build();
        div2.add_hdl_path_slice("Divisor[15:8]", 0, 8);

        map = create_map("map", 'h0, 4, UVM_LITTLE_ENDIAN);

        map.add_reg(ier,  32'h0000_0000, "RW");
        map.add_reg(fcr,  32'h0000_0004, "WO");
        map.add_reg(lcr,  32'h0000_0008, "RW");
        map.add_reg(mcr,  32'h0000_000c, "RW");
        map.add_reg(div1, 32'h0000_0010, "RW");
        map.add_reg(div2, 32'h0000_0014, "RW");

        add_hdl_path("top.duv.u1.r1", "RTL");

        lock_model();

    endfunction

endclass
