/*======================================================================
=============================SPI DRIVER CLASS===========================
=======================================================================*/
class spi_monitor extends uvm_monitor;
	`uvm_component_utils(spi_monitor)
	
	uvm_analysis_port #(spi_xtn) monitor_port;
	
	spi_agent_config 			 cfg;
	virtual spi_if 				 vif;
	bit              [7:0] 		 CR1;
	bit 					     cpol;
	bit 						 cpha;
	bit 					     lsb;

	function new(string name = "spi_monitor",uvm_component parent);
		super.new(name,parent);
		monitor_port = new("monitor_port",this);
	endfunction : new

	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
endclass : spi_monitor

function void spi_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Getting SPI agent config via config db
	if(!uvm_config_db #(spi_agent_config)::get(this,"","spi_agent_config",cfg))
		`uvm_fatal("SPI DRV","get failed for spi_agent_config")
	//Getting CR1 data from test via config db
	if(!uvm_config_db #(bit[7:0])::get(this,"","CR1",CR1))
		`uvm_fatal("SPI DRV","get failed for CR1")
endfunction : build_phase

function void spi_monitor::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	vif  = cfg.vif;
	cpol = CR1[3];
	cpha = CR1[2];
	lsb  = CR1[0];
endfunction : connect_phase

task spi_monitor::run_phase(uvm_phase phase);
	super.run_phase(phase);
	
	forever
		begin
		collect_data();
		end
endtask

//SPI MONITORING LOGIC
task spi_monitor::collect_data();
	spi_xtn xtn;
	xtn = spi_xtn::type_id::create("xtn");
	wait(vif.ss == 0);
	if (cpol ^ cpha) //MODE1 & MODE2
        for (int i = 0; i < 8; i++) 
			begin
            	@(vif.spi_mon_cb_neg);
				xtn.miso[i] = vif.spi_mon_cb_neg.miso;
            	xtn.mosi[i] = vif.spi_mon_cb_neg.mosi;
    		end

    else //MODE0 & MODE3
        for (int i = 0; i < 8; i++) 
			begin
                @(vif.spi_mon_cb_pos);
				xtn.miso[i] = vif.spi_mon_cb_pos.miso;
            	xtn.mosi[i] = vif.spi_mon_cb_pos.mosi;
        	end
	if(lsb == 0) //inverting bits for MSB
		begin
			xtn.mosi = {<<{xtn.mosi}};
			xtn.miso = {<<{xtn.miso}};
		end
	xtn.print;
	
	wait(vif.ss == 1);
	xtn.ss = 1;
	monitor_port.write(xtn); //Send to Scoreboard
endtask : collect_data
