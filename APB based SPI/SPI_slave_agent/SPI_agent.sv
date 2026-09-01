/*======================================================================
==========================SPI AGENT CLASS===============================
=======================================================================*/
class spi_agent extends uvm_agent;
	`uvm_component_utils(spi_agent)
	
	spi_driver drvh;
	spi_sequencer seqrh;
	spi_monitor monh;
	spi_agent_config cfg;

	function new(string name = "spi_agent", uvm_component parent);
		super.new(name,parent);
	endfunction : new

	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass : spi_agent

function void spi_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Getting SPI agent config via config db
	if(!uvm_config_db #(spi_agent_config)::get(this,"","spi_agent_config",cfg))
		`uvm_fatal("SPI AGENT","get failed for spi_agent_config")
	monh = spi_monitor::type_id::create("monh",this);
	if(cfg.is_active == UVM_ACTIVE)
		begin
			drvh  = spi_driver::type_id::create("drvh",this);
			seqrh = spi_sequencer::type_id::create("seqrh",this);
		end
endfunction : build_phase

function void spi_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	if(cfg.is_active == UVM_ACTIVE)
		drvh.seq_item_port.connect(seqrh.seq_item_export);
endfunction : connect_phase
