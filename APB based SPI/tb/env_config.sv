/*======================================================================
=======================ENV CONFIGURATION CLASS==========================
=======================================================================*/
class env_config extends uvm_object;
	`uvm_object_utils(env_config)
	
	function new(string name = "env_config");
		super.new(name);
	endfunction : new

	bit              has_apb_agent         = 1;
	bit              has_spi_agent         = 1;	
	
	int unsigned     num_of_apb_agents     = 1;
	int unsigned     num_of_spi_agents     = 1;

	bit              has_scoreboard        = 1;
	bit              has_virtual_sequencer = 1;
	
	//APB & SPI AGENT CONFIGURATION DYNAMIC HANDLES
	apb_agent_config apb_cfg[];
	spi_agent_config spi_cfg[];

endclass : env_config
