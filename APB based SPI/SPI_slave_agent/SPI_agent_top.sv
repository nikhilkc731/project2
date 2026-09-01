/*======================================================================
==========================SPI AGENT TOP CLASS===========================
=======================================================================*/
class spi_agent_top extends uvm_env;
	`uvm_component_utils(spi_agent_top)
	
	spi_agent spi_agth[];	
	env_config cfg;
	function new(string name = "spi_agent_top",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	extern function void build_phase(uvm_phase phase);

endclass : spi_agent_top

function void spi_agent_top::build_phase(uvm_phase phase);
	//Getting ENV config from test via config db
	if(!uvm_config_db #(env_config)::get(this,"","env_config",cfg))
		`uvm_fatal("SPI_AGENT_TOP","get failed for env_config")
	if(cfg.has_spi_agent)
		begin
			spi_agth = new[cfg.num_of_spi_agents];
			foreach(spi_agth[i])
				begin
					//Setting SPI agent config for SPI agent and its sub components
					uvm_config_db #(spi_agent_config)::set(this,$sformatf("spi_agth[%0d]*",i),"spi_agent_config",cfg.spi_cfg[i]);
					spi_agth[i] = spi_agent::type_id::create($sformatf("spi_agth[%0d]",i),this);
				end
		end
endfunction : build_phase
