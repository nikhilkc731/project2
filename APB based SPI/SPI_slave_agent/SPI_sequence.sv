/*======================================================================
===========================SPI SEQUENCE CLASS===========================
=======================================================================*/
class spi_sequence_base extends uvm_sequence #(spi_xtn);
    `uvm_object_utils(spi_sequence_base)

    function new(string name = "spi_sequence_base");
        super.new(name);
    endfunction : new

endclass : spi_sequence_base

//SPI WRITE SEQ
class spi_write_sequence extends spi_sequence_base;
    `uvm_object_utils(spi_write_sequence)

    function new(string name = "spi_write_sequence");
        super.new(name);
    endfunction : new

    task body();
        repeat(1)
            req = spi_xtn::type_id::create("req");
            start_item(req);
            if(!req.randomize())
                `uvm_fatal("SPI_SEQ","randomization failed")
            finish_item(req);
    endtask : body

endclass : spi_write_sequence
