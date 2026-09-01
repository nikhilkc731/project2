/*======================================================================
============================APB DRIVER CLASS============================
=======================================================================*/
class apb_driver extends uvm_driver #(apb_xtn);
	`uvm_component_utils(apb_driver)
	
	apb_agent_config          cfg;
	virtual apb_if.APB_DRV_MP vif;

	function new(string name = "apb_driver",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task drive_to_dut(apb_xtn xtn);
endclass : apb_driver

function void apb_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Getting APB agent config via config db
	if(!uvm_config_db #(apb_agent_config)::get(this,"","apb_agent_config",cfg))
		`uvm_fatal("APB DRV","get failed for apb_agent_config")
endfunction : build_phase

function void apb_driver::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	vif = cfg.vif;
endfunction : connect_phase

task apb_driver::run_phase(uvm_phase phase);
	super.run_phase(phase);
	forever
		begin
			seq_item_port.get_next_item(req);
			drive_to_dut(req);
			seq_item_port.item_done();
		end
endtask : run_phase

task apb_driver::drive_to_dut(apb_xtn xtn);
	//Driving logic
	vif.apb_drv_cb.PSEL     <= '1;
	vif.apb_drv_cb.PENABLE  <= '0; //SETUP phase
	vif.apb_drv_cb.PADDR    <= xtn.PADDR;
	vif.apb_drv_cb.PWRITE   <= xtn.PWRITE;
	vif.apb_drv_cb.PRESET_n <= xtn.PRESET_n;
	if(xtn.PWRITE)
		vif.apb_drv_cb.PWDATA <= xtn.PWDATA;

	@(vif.apb_drv_cb);
	vif.apb_drv_cb.PENABLE <= '1; //ENABLE phase
	if(xtn.PRESET_n)
		wait(vif.apb_drv_cb.PREADY) //Transmition done ack
		if(xtn.PWRITE == 0)
			begin
				xtn.PRDATA = vif.apb_drv_cb.PRDATA;
			end
	vif.apb_drv_cb.PSEL    <= '0;
	vif.apb_drv_cb.PENABLE <= '0; //IDLE phase
	@(vif.apb_drv_cb);
endtask : drive_to_dut
