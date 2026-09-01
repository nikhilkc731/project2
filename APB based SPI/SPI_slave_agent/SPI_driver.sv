/*======================================================================
=============================SPI DRIVER CLASS===========================
=======================================================================*/
class spi_driver extends uvm_driver #(spi_xtn);
	`uvm_component_utils(spi_driver)

	spi_agent_config       cfg;
	virtual spi_if         vif;
	bit              [7:0] CR1;
	bit 				   cpol;
	bit 				   cpha;
	bit 			       lsb;
	function new(string name = "spi_driver",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task drive_to_dut(spi_xtn xtn);
endclass : spi_driver

function void spi_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Getting spi agent config via config db
	if(!uvm_config_db #(spi_agent_config)::get(this,"","spi_agent_config",cfg))
		`uvm_fatal("SPI DRV","get failed for spi_agent_config")
	//Getting CR1 data from test via config db
	if(!uvm_config_db #(bit[7:0])::get(this,"","CR1",CR1))
		`uvm_fatal("SPI DRV","get failed for CR1")
endfunction : build_phase

function void spi_driver::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	vif  = cfg.vif;
	cpol = CR1[3];
	cpha = CR1[2];
	lsb  = CR1[0];
endfunction : connect_phase

task spi_driver::run_phase(uvm_phase phase);
	super.run_phase(phase);
	//vif.miso <= '0;
	forever
		begin
			seq_item_port.get_next_item(req);
			drive_to_dut(req);
			seq_item_port.item_done();
		end
endtask

//SPI DRIVING LOGIC
task spi_driver::drive_to_dut(spi_xtn xtn);
    xtn.print();

    if(lsb == 0) //inverting bits for MSB
		xtn.miso = {<<{xtn.miso}};

    wait(vif.ss == 0);

    if (!cpha) //Data availability is immediate MODE0 & MODE2
		begin
			vif.miso <= xtn.miso[0];
			for (int i = 1; i < 8; i++) 
				begin
					if(cpol ^ cpha)
						begin
							@(vif.spi_drv_cb_pos);
							vif.spi_drv_cb_pos.miso <= xtn.miso[i];
						end
					else
						begin
							@(vif.spi_drv_cb_neg);
							vif.spi_drv_cb_neg.miso <= xtn.miso[i];
						end
				end
		end

    else //Data availability is at next edge MODE1 & MODE3
        for (int i = 0; i < 8; i++) 
			begin
				if(cpol ^ cpha)
					begin
                		@(vif.spi_drv_cb_pos);
						vif.spi_drv_cb_pos.miso <= xtn.miso[i];
					end
				else
					begin
						@(vif.spi_drv_cb_neg);
            			vif.spi_drv_cb_neg.miso <= xtn.miso[i];
					end
        	end

    @(posedge vif.ss);
    vif.miso <= 1'bz;
endtask : drive_to_dut
