/*======================================================================
=========================APB AGENT TOP CLASS============================
=======================================================================*/
class apb_agent_top extends uvm_env;
	`uvm_component_utils(apb_agent_top)
	
	apb_agent  apb_agth[];	
	env_config cfg;

	function new(string name = "apb_agent_top",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	extern function void build_phase(uvm_phase phase);

endclass : apb_agent_top

function void apb_agent_top::build_phase(uvm_phase phase);
	//Getting ENV config via config db
	if(!uvm_config_db #(env_config)::get(this,"","env_config",cfg))
		`uvm_fatal("APB_AGENT_TOP","get failed for env_config")
	if(cfg.has_apb_agent)
		begin
			apb_agth = new[cfg.num_of_apb_agents];
			foreach(apb_agth[i])
				begin
					//Setting APB agent config via config db
					uvm_config_db #(apb_agent_config)::set(this,$sformatf("apb_agth[%0d]*",i),"apb_agent_config",cfg.apb_cfg[i]);
					apb_agth[i] = apb_agent::type_id::create($sformatf("apb_agth[%0d]",i),this);
				end
		end
endfunction : build_phase
			
