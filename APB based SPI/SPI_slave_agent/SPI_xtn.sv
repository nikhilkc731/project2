/*======================================================================
========================SPI TRANSACTION CLASS===========================
=======================================================================*/
class spi_xtn extends uvm_sequence_item;
    `uvm_object_utils(spi_xtn)

    	 bit 	   ss;
		 bit 	   sclk;
		 bit [7:0] mosi;
	rand bit [7:0] miso;

    function new(string name = "spi_xtn");
        super.new (name);
    endfunction : new

    extern function void do_copy(uvm_object rhs);
    extern function bit do_compare(uvm_object rhs,uvm_comparer comparer);
    extern function void do_print(uvm_printer printer);

endclass : spi_xtn

function void spi_xtn::do_copy(uvm_object rhs);
    spi_xtn rhs_;
    if(!$cast(rhs_,rhs))
        `uvm_fatal("spi_XTN","cast failed for do_copy")
    
    super.do_copy(rhs);
    this.ss   = rhs_.ss;
    this.sclk = rhs_.sclk;
    this.mosi = rhs_.mosi;
    this.miso = rhs_.miso;
endfunction : do_copy

function bit spi_xtn::do_compare(uvm_object rhs,uvm_comparer comparer);
    spi_xtn rhs_;
    if(!$cast(rhs_,rhs))
        `uvm_fatal("spi_XTN","cast failed for do_compare")
    
    return super.do_compare(rhs,comparer) &&
    this.ss   == rhs_.ss &&
    this.sclk == rhs_.sclk &&
    this.mosi == rhs_.mosi &&
    this.miso == rhs_.miso;
endfunction : do_compare

function void spi_xtn::do_print(uvm_printer printer);
    super.do_print(printer);

//                       STRING_NAME      VALUE     SIZE     BASE
    printer.print_field( "sclk",       this.sclk,    1,    UVM_DEC);
    printer.print_field( "ss",         this.ss,      1,    UVM_DEC);
    printer.print_field( "mosi",       this.mosi,    8,    UVM_HEX);
    printer.print_field( "miso",       this.miso,    8,    UVM_HEX);
endfunction : do_print
