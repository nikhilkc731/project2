/*======================================================================
=============================ENVIRONMENT CLASS==========================
=======================================================================*/
class core_env extends uvm_env;
	`uvm_component_utils(core_env)

	apb_agent_top   apb_top;
	spi_agent_top   spi_top;
	core_sb         sbh[];
	env_config      cfg;

	function new(string name = "core_env",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass : core_env

function void core_env::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Getting env config from test via config db
	if(!uvm_config_db #(env_config)::get(this,"","env_config",cfg))
		`uvm_fatal("ENV","get failed for env_config")

	if(cfg.has_apb_agent)
		apb_top = apb_agent_top::type_id::create("apb_top",this);
	if(cfg.has_spi_agent)
		spi_top = spi_agent_top::type_id::create("spi_top",this);
	if(cfg.has_scoreboard)
		begin
			    sbh = new[cfg.num_of_apb_agents];
			for(int i = 0; i < cfg.num_of_apb_agents; i++)
				sbh[i] = core_sb::type_id::create($sformatf("sbh[%0d]",i),this);
		end
endfunction : build_phase

function void core_env::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	//Monitor to Scoreboard connection
	if(cfg.has_apb_agent)
		for(int i = 0; i < cfg.num_of_apb_agents; i++)
			apb_top.apb_agth[i].monh.monitor_port.connect(sbh[i].apb_fifo.analysis_export);
	if(cfg.has_spi_agent)
		for(int i = 0; i < cfg.num_of_spi_agents; i++)
			spi_top.spi_agth[i].monh.monitor_port.connect(sbh[i].spi_fifo.analysis_export);
endfunction : connect_phase
