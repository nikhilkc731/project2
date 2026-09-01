/*======================================================================
============================APB MONITOR CLASS===========================
=======================================================================*/
class apb_monitor extends uvm_monitor;
	`uvm_component_utils(apb_monitor)
	
	virtual apb_if.APB_MON_MP    vif;
	apb_agent_config             cfg;
	uvm_analysis_port #(apb_xtn) monitor_port;
	
	function new(string name = "apb_monitor",uvm_component parent);
		super.new(name,parent);
		monitor_port = new("monitor_port",this);
	endfunction : new

	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
endclass : apb_monitor

function void apb_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Getting APB agent config via config db
	if(!uvm_config_db #(apb_agent_config)::get(this,"","apb_agent_config",cfg))
		`uvm_fatal("APB MON","get failed for apb_agent_config")
endfunction : build_phase

function void apb_monitor::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	vif = cfg.vif;
endfunction : connect_phase

task apb_monitor::run_phase(uvm_phase phase);
	super.run_phase(phase);
	fork
        forever 
			begin //Thread 1
            	@(negedge vif.PRESET_n); // Monitor PRESET sampling since it's Asynchronous
            	begin
                	apb_xtn reset_xtn; 
					reset_xtn = apb_xtn::type_id::create("reset_xtn");
                	reset_xtn.PRESET_n = 1'b0;
                	reset_xtn.PSEL     = 1'b0;
                	reset_xtn.PENABLE  = 1'b0;
                	reset_xtn.PWRITE   = 1'b0;
                	monitor_port.write(reset_xtn);
            	end
            	wait(vif.PRESET_n == 1'b1); 
        	end
		forever
			begin
				collect_data();
			end
	join
endtask : run_phase

//Monitoring logic
task apb_monitor::collect_data();
	apb_xtn xtn;
	xtn = apb_xtn::type_id::create("xtn");
	@(vif.apb_mon_cb);
	if(vif.apb_mon_cb.PRESET_n == 0)
		begin
			xtn.PRESET_n = vif.apb_mon_cb.PRESET_n;
			xtn.PSEL     = vif.apb_mon_cb.PSEL;
			xtn.PENABLE  = vif.apb_mon_cb.PENABLE;
			xtn.PWRITE   = vif.apb_mon_cb.PWRITE;
			xtn.PADDR    = vif.apb_mon_cb.PADDR;
			xtn.PWDATA   = vif.apb_mon_cb.PWDATA;
		end
	else
		begin
			wait(vif.apb_mon_cb.PENABLE && vif.apb_mon_cb.PREADY);
			xtn.PRESET_n = vif.apb_mon_cb.PRESET_n;
			xtn.PSEL     = vif.apb_mon_cb.PSEL;
			xtn.PENABLE  = vif.apb_mon_cb.PENABLE;
			xtn.PWRITE   = vif.apb_mon_cb.PWRITE;
			xtn.PADDR    = vif.apb_mon_cb.PADDR;
			xtn.PWDATA   = vif.apb_mon_cb.PWDATA;
		end
		if(!xtn.PWRITE)
			begin
				xtn.PRDATA = vif.apb_mon_cb.PRDATA;
			end
	`uvm_info("APB MON",$sformatf("%s",xtn.sprint()),UVM_LOW)
	monitor_port.write(xtn); //Send to Scoreboard
	
endtask : collect_data
