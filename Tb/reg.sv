class ier_reg extends uvm_reg;

    `uvm_object_utils(ier_reg)

    function new(string name = "ier_reg");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction

    rand uvm_reg_field RDAI;   // Receiver Data Available Interrupt
    rand uvm_reg_field THREI;  // Transmitter Holding Register Empty Interrupt
    rand uvm_reg_field RLSI;   // Receiver Line Status Interrupt

    function void build();
        RDAI  = uvm_reg_field::type_id::create("RDAI");
        THREI = uvm_reg_field::type_id::create("THREI");
        RLSI  = uvm_reg_field::type_id::create("RLSI");

        RDAI.configure(this, 1, 0, "RW", 0, 0, 0, 1, 1);
        THREI.configure(this, 1, 1, "RW", 0, 0, 0, 1, 1);
        RLSI.configure(this, 1, 2, "RW", 0, 0, 0, 1, 1);
    endfunction

endclass


class fcr_reg extends uvm_reg;

    `uvm_object_utils(fcr_reg)

    function new(string name = "fcr_reg");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction

    rand uvm_reg_field RRF;  // Reset Receiver FIFO
    rand uvm_reg_field RTF;  // Reset Transmitter FIFO
    rand uvm_reg_field FTL;  // FIFO Trigger Level

    function void build();
        RRF = uvm_reg_field::type_id::create("RRF");
        RTF = uvm_reg_field::type_id::create("RTF");
        FTL = uvm_reg_field::type_id::create("FTL");

        RRF.configure(this, 1, 1, "WO", 0, 0, 0, 1, 1);
        RTF.configure(this, 1, 2, "WO", 0, 0, 0, 1, 1);
        FTL.configure(this, 2, 6, "WO", 0, 3, 0, 1, 1);
    endfunction

endclass


class lcr_reg extends uvm_reg;

    `uvm_object_utils(lcr_reg)

    function new(string name = "lcr_reg");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction

    rand uvm_reg_field DB;   // Data Bits
    rand uvm_reg_field SB;   // Stop Bit
    rand uvm_reg_field PE;   // Parity Enable
    rand uvm_reg_field EP;   // Even Parity
    rand uvm_reg_field SP;   // Sticky Parity
    rand uvm_reg_field BCB;  // Break Control Bit

    function void build();
        DB  = uvm_reg_field::type_id::create("DB");
        SB  = uvm_reg_field::type_id::create("SB");
        PE  = uvm_reg_field::type_id::create("PE");
        EP  = uvm_reg_field::type_id::create("EP");
        SP  = uvm_reg_field::type_id::create("SP");
        BCB = uvm_reg_field::type_id::create("BCB");

        DB.configure(this, 2, 0, "RW", 0, 3, 0, 1, 1);
        SB.configure(this, 1, 2, "RW", 0, 0, 0, 1, 1);
        PE.configure(this, 1, 3, "RW", 0, 0, 0, 1, 1);
        EP.configure(this, 1, 4, "RW", 0, 0, 0, 1, 1);
        SP.configure(this, 1, 5, "RW", 0, 0, 0, 1, 1);
        BCB.configure(this, 1, 6, "RW", 0, 0, 0, 1, 1);
    endfunction

endclass


class mcr_reg extends uvm_reg;

    `uvm_object_utils(mcr_reg)

    function new(string name = "mcr_reg");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction

    rand uvm_reg_field LB;  // LoopBack

    function void build();
        LB = uvm_reg_field::type_id::create("LB");
        LB.configure(this, 1, 4, "RW", 0, 0, 0, 1, 1);
    endfunction

endclass


class div1_reg extends uvm_reg;

    `uvm_object_utils(div1_reg)

    function new(string name = "div1_reg");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction

    rand uvm_reg_field LSB;

    function void build();
        LSB = uvm_reg_field::type_id::create("LSB");
        LSB.configure(this, 8, 0, "RW", 0, 0, 0, 1, 1);
    endfunction

endclass


class div2_reg extends uvm_reg;

    `uvm_object_utils(div2_reg)

    function new(string name = "div2_reg");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction

    rand uvm_reg_field MSB;

    function void build();
        MSB = uvm_reg_field::type_id::create("MSB");
        MSB.configure(this, 8, 0, "RW", 0, 0, 0, 1, 1);
    endfunction

endclass
