/*======================================================================
=============================APB AGENT CLASS============================
=======================================================================*/
class apb_agent extends uvm_agent;
	`uvm_component_utils(apb_agent)
	
	apb_driver       drvh;
	apb_sequencer    seqrh;
	apb_monitor      monh;
	apb_agent_config cfg;

	function new(string name = "apb_agent", uvm_component parent);
		super.new(name,parent);
	endfunction : new

	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass : apb_agent

function void apb_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Getting APB_agent_config via config db
	if(!uvm_config_db #(apb_agent_config)::get(this,"","apb_agent_config",cfg))
		`uvm_fatal("APB_AGENT","get failed for abp_agent_config")
	monh = apb_monitor::type_id::create("monh",this);
	if(cfg.is_active == UVM_ACTIVE)
		begin
			drvh  = apb_driver::type_id::create("drvh",this);
			seqrh = apb_sequencer::type_id::create("seqrh",this);
		end
endfunction : build_phase

function void apb_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	if(cfg.is_active == UVM_ACTIVE)
		drvh.seq_item_port.connect(seqrh.seq_item_export);
endfunction : connect_phase
