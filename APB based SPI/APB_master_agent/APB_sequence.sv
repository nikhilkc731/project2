/*======================================================================
===========================APB SEQUENCE CLASS===========================
=======================================================================*/
class apb_sequence_base extends uvm_sequence #(apb_xtn);
    `uvm_object_utils(apb_sequence_base)

    function new(string name = "apb_sequence_base");
        super.new(name);
    endfunction : new

endclass : apb_sequence_base

//APB RESET SEQ
class apb_reset_sequence extends apb_sequence_base;
    `uvm_object_utils(apb_reset_sequence)

    function new(string name = "apb_reset_sequence");
        super.new(name);
    endfunction : new

    extern task body;

endclass : apb_reset_sequence

task apb_reset_sequence::body();

    repeat(1)
        begin
            req = apb_xtn::type_id::create("req");
            start_item(req);
            if(!req.randomize() with {PRESET_n == 1'b0;})
                `uvm_fatal("APB_SEQ","randomization failed")
            finish_item(req);
        end
endtask : body

//APB WRITE SEQ
class apb_write_sequence extends apb_sequence_base;
    `uvm_object_utils(apb_write_sequence)
	
    
    bit [7:0] CR1;
    bit [7:0] CR2;

    function new(string name = "apb_write_sequence");
        super.new(name);
    endfunction : new

    extern task body;

endclass : apb_write_sequence

task apb_write_sequence::body();
	//Getting CR1 & CR2 values from test via config db
    if(!uvm_config_db #(bit[7:0])::get(null,get_full_name,"CR1",CR1))
        `uvm_fatal("APB_SEQ","get failed for CR1 !!")
    if(!uvm_config_db #(bit[7:0])::get(null,get_full_name,"CR2",CR2))
        `uvm_fatal("APB_SEQ","get failed for CR2 !!")
    
    repeat(1)
        begin
            req = apb_xtn::type_id::create("req");
            start_item(req);
            if(!req.randomize() with {PRESET_n == 1'b1; PWRITE == 1'b1; PWDATA == CR1; PADDR == 3'b000;})
                `uvm_fatal("APB_SEQ","randomization failed")
            finish_item(req);
        end

    repeat(1)
        begin
            req = apb_xtn::type_id::create("req");
            start_item(req);
            if(!req.randomize() with {PRESET_n == 1'b1; PWRITE == 1'b1; PWDATA == CR2; PADDR == 3'b001;})
                `uvm_fatal("APB_SEQ","randomization failed")
            finish_item(req);
        end
    repeat(1)
        begin
            req = apb_xtn::type_id::create("req");
            start_item(req);
            if(!req.randomize() with {PRESET_n == 1'b1; PWRITE == 1'b1;/* SPPR == 3'd0; SPR == 3'd0;*/ PWDATA == {1'b0,SPPR,1'b0,SPR}; PADDR == 3'b010;})
                `uvm_fatal("APB_SEQ","randomization failed")
            finish_item(req);
        end
    repeat(1)
        begin
            req = apb_xtn::type_id::create("req");
            start_item(req);
            if(!req.randomize() with {PRESET_n == 1'b1; PWRITE == 1'b1; PADDR == 3'b101;})
                `uvm_fatal("APB_SEQ","randomization failed")
            finish_item(req);
        end
endtask : body

//APB READ SEQ
class apb_read_sequence extends apb_sequence_base;
    `uvm_object_utils(apb_read_sequence)
    bit [2:0] ADDR;
    function new(string name = "apb_read_sequence");
        super.new(name);
    endfunction : new
    extern task body;

endclass : apb_read_sequence

task apb_read_sequence::body();
	//Getting ADDR bit value from test via config db
    if(!uvm_config_db #(bit[2:0])::get(null,get_full_name,"ADDR",ADDR))
        ADDR = 3'b101;
    repeat(1)
        begin
            req = apb_xtn::type_id::create("req");
            start_item(req);
            if(!req.randomize() with {PRESET_n == 1'b1; PWRITE == 1'b0; PADDR == ADDR;})
                `uvm_fatal("APB_SEQ","randomization failed")
            finish_item(req);
        end
endtask : body
