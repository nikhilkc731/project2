/*======================================================================
================================TEST CLASS==============================
=======================================================================*/

//Base Test Class
class base_test extends uvm_test;
	`uvm_component_utils(base_test)
	
	env_config          cfg;
	apb_agent_config    apb_cfg[];
	spi_agent_config    spi_cfg[];

	bit 				has_apb_agent = 1;
	bit 				has_spi_agent = 1;	
	
	int unsigned        num_of_apb_agents = 1;
	int unsigned 	    num_of_spi_agents = 1;

	bit 				has_scoreboard = 1;
	bit 				has_virtual_sequencer = 1;

	core_env envh;
	
	function new(string name = "base_test",uvm_component parent);
		super.new(name,parent);
		cfg = env_config::type_id::create("cfg");
	endfunction : new

	extern function void build_phase(uvm_phase phase);
	extern function void config_env();
	extern function void end_of_elaboration_phase (uvm_phase phase);
	
endclass : base_test

function void base_test::build_phase(uvm_phase phase);
	//APB AGENT CONFIGURATION
	if(has_apb_agent)
		begin
			apb_cfg     = new[num_of_apb_agents];
			cfg.apb_cfg = new[num_of_apb_agents];
			foreach (apb_cfg[i]) 
				begin
					apb_cfg[i] = apb_agent_config::type_id::create($sformatf("apb_cfg[%0d]",i));
					apb_cfg[i].is_active = UVM_ACTIVE;
					if(!uvm_config_db #(virtual apb_if)::get(this,"",$sformatf("vif[%0d]",i),apb_cfg[i].vif))
						`uvm_fatal("TEST","get failed for apb_vif")
					cfg.apb_cfg[i] = apb_cfg[i];
				end
		end

	//SPI AGENT CONFIGURATION
	if(has_spi_agent)
		begin
			spi_cfg     = new[num_of_spi_agents];
			cfg.spi_cfg = new[num_of_spi_agents];
			foreach (spi_cfg[i]) 
				begin
					spi_cfg[i] = spi_agent_config::type_id::create($sformatf("spi_cfg[%0d]",i));
					spi_cfg[i].is_active = UVM_ACTIVE;
					if(!uvm_config_db #(virtual spi_if)::get(this,"",$sformatf("vif[%0d]",i),spi_cfg[i].vif))
						`uvm_fatal("TEST","get failed for spi_vif")
					cfg.spi_cfg[i] = spi_cfg[i];
				end
		end
	config_env();
	envh = core_env::type_id::create("envh",this);
	
endfunction : build_phase

function void base_test::config_env();
	//ENV CONFIGURATION
	cfg.has_apb_agent         = has_apb_agent;
	cfg.has_spi_agent         = has_spi_agent;	
	
	cfg.num_of_apb_agents     = num_of_apb_agents;
	cfg.num_of_spi_agents     = num_of_spi_agents;

	cfg.has_scoreboard        = has_scoreboard;
	cfg.has_virtual_sequencer = has_virtual_sequencer;

	//Setting ENV CONFURATION in config db
	uvm_config_db #(env_config)::set(this,"*","env_config",cfg);

endfunction : config_env

function void base_test::end_of_elaboration_phase(uvm_phase phase);
	//Printing TOPOLOGY
	uvm_top.print_topology();
endfunction : end_of_elaboration_phase

//TEST CASE 1 : CPOL = 1 CPHA = 1 LSBFE = 1
class cpha1_cpol1_lsb_test extends base_test;
	`uvm_component_utils(cpha1_cpol1_lsb_test)
	
	bit [7:0] CR1 = 8'b11111111;
	bit [7:0] CR2 = 8'b00010000;

	apb_reset_sequence apb_reset_seq;
	apb_write_sequence apb_wr_seq;
	apb_read_sequence  apb_rd_seq;
	spi_write_sequence spi_wr_seq;
	
	function new(string name = "cpha1_cpol1_lsb_test",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass : cpha1_cpol1_lsb_test

function void cpha1_cpol1_lsb_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	uvm_config_db #(bit[7:0])::set(this,"*","CR1",CR1);
	uvm_config_db #(bit[7:0])::set(this,"*","CR2",CR2);
	
	apb_reset_seq = apb_reset_sequence::type_id::create("apb_reset_seq");
	apb_wr_seq    = apb_write_sequence::type_id::create("apb_wr_seq");
	apb_rd_seq 	  = apb_read_sequence::type_id::create("apb_rd_seq");
	spi_wr_seq    = spi_write_sequence::type_id::create("spi_wr_seq");

endfunction : build_phase

function void cpha1_cpol1_lsb_test::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
endfunction : end_of_elaboration_phase

task cpha1_cpol1_lsb_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
		//for(int j =0; j< 100; j++)
		for(int i = 0;i < cfg.num_of_apb_agents;i++)
			begin
				apb_reset_seq.start(envh.apb_top.apb_agth[i].seqrh); //RESET SEQ
				apb_wr_seq.start(envh.apb_top.apb_agth[i].seqrh);	 //APB WRITE SEQ
				//CHECK IF DR WRITE IS ZERO
				if((envh.apb_top.apb_agth[i].drvh.req.PADDR == 3'b101) && (envh.apb_top.apb_agth[i].drvh.req.PWDATA != 8'h00))
					begin
						spi_wr_seq.start(envh.spi_top.spi_agth[i].seqrh); //SPI WRITE SEQ
						apb_rd_seq.start(envh.apb_top.apb_agth[i].seqrh); //APB READ SEQ
					end
			end
			//phase.phase_done.set_drain_time(this,250);
	phase.drop_objection(this);
endtask : run_phase


//TEST CASE 2 : CPOL = 0 CPHA = 0 LSBFE = 1
class cpha0_cpol0_lsb_test extends base_test;
	`uvm_component_utils(cpha0_cpol0_lsb_test)
	
	bit [7:0] CR1 = 8'b11110011;
	bit [7:0] CR2 = 8'b00010000;

	apb_reset_sequence apb_reset_seq;
	apb_write_sequence apb_wr_seq;
	apb_read_sequence  apb_rd_seq;
	spi_write_sequence spi_wr_seq;
	
	function new(string name = "cpha0_cpol0_lsb_test",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass : cpha0_cpol0_lsb_test

function void cpha0_cpol0_lsb_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	uvm_config_db #(bit[7:0])::set(this,"*","CR1",CR1);
	uvm_config_db #(bit[7:0])::set(this,"*","CR2",CR2);
	
	apb_reset_seq = apb_reset_sequence::type_id::create("apb_reset_seq");
	apb_wr_seq 	  = apb_write_sequence::type_id::create("apb_wr_seq");
	apb_rd_seq    = apb_read_sequence::type_id::create("apb_rd_seq");
	spi_wr_seq    = spi_write_sequence::type_id::create("spi_wr_seq");
endfunction : build_phase

function void cpha0_cpol0_lsb_test::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
endfunction : end_of_elaboration_phase

task cpha0_cpol0_lsb_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
		for(int j = 0;j < 100; j++)
		for(int i = 0;i < cfg.num_of_apb_agents;i++)
			begin
				apb_reset_seq.start(envh.apb_top.apb_agth[i].seqrh); //RESET SEQ
				apb_wr_seq.start(envh.apb_top.apb_agth[i].seqrh);    //APB WRITE SEQ
				//CHECK IF DR WRITE IS ZERO
				if((envh.apb_top.apb_agth[i].drvh.req.PADDR == 3'b101) && (envh.apb_top.apb_agth[i].drvh.req.PWDATA != 8'h00))
					begin
						spi_wr_seq.start(envh.spi_top.spi_agth[i].seqrh); //SPI WRITE SEQ
						apb_rd_seq.start(envh.apb_top.apb_agth[i].seqrh); //APB READ SEQ
					end
			end
			//phase.phase_done.set_drain_time(this,250);
	phase.drop_objection(this);

endtask : run_phase

//TEST CASE 3 : CPOL = 0 CPHA = 1 LSBFE = 1
class cpha1_cpol0_lsb_test extends base_test;
	`uvm_component_utils(cpha1_cpol0_lsb_test)
	
	bit [7:0] CR1 = 8'b11110111;
	bit [7:0] CR2 = 8'b00010000;

	apb_reset_sequence apb_reset_seq;
	apb_write_sequence apb_wr_seq;
	apb_read_sequence  apb_rd_seq;
	spi_write_sequence spi_wr_seq;
	
	function new(string name = "cpha1_cpol0_lsb_test",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass : cpha1_cpol0_lsb_test

function void cpha1_cpol0_lsb_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	uvm_config_db #(bit[7:0])::set(this,"*","CR1",CR1);
	uvm_config_db #(bit[7:0])::set(this,"*","CR2",CR2);
	
	apb_reset_seq = apb_reset_sequence::type_id::create("apb_reset_seq");
	apb_wr_seq    = apb_write_sequence::type_id::create("apb_wr_seq");
	apb_rd_seq    = apb_read_sequence::type_id::create("apb_rd_seq");
	spi_wr_seq    = spi_write_sequence::type_id::create("spi_wr_seq");
endfunction : build_phase

function void cpha1_cpol0_lsb_test::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
endfunction : end_of_elaboration_phase

task cpha1_cpol0_lsb_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
		for(int j = 0;j < 100; j++)
		for(int i = 0;i < cfg.num_of_apb_agents;i++)
			begin
				apb_reset_seq.start(envh.apb_top.apb_agth[i].seqrh); //RESET SEQ
				apb_wr_seq.start(envh.apb_top.apb_agth[i].seqrh);    //APB WRITE SEQ
				//CHECK IF DR WRITE IS ZERO
				if((envh.apb_top.apb_agth[i].drvh.req.PADDR == 3'b101) && (envh.apb_top.apb_agth[i].drvh.req.PWDATA != 8'h00))
					begin
						spi_wr_seq.start(envh.spi_top.spi_agth[i].seqrh); //SPI WRITE SEQ
						apb_rd_seq.start(envh.apb_top.apb_agth[i].seqrh); //APB READ SEQ
					end
			end
			//phase.phase_done.set_drain_time(this,250);
	phase.drop_objection(this);

endtask : run_phase

//TEST CASE 4 : CPOL = 0 CPHA = 1 LSBFE = 1
class cpha0_cpol1_lsb_test extends base_test;
	`uvm_component_utils(cpha0_cpol1_lsb_test)
	
	bit [7:0] CR1 = 8'b11111011;
	bit [7:0] CR2 = 8'b00010000;

	apb_reset_sequence apb_reset_seq;
	apb_write_sequence apb_wr_seq;
	apb_read_sequence  apb_rd_seq;
	spi_write_sequence spi_wr_seq;
	
	function new(string name = "cpha0_cpol1_lsb_test",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass : cpha0_cpol1_lsb_test

function void cpha0_cpol1_lsb_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	uvm_config_db #(bit[7:0])::set(this,"*","CR1",CR1);
	uvm_config_db #(bit[7:0])::set(this,"*","CR2",CR2);
	
	apb_reset_seq = apb_reset_sequence::type_id::create("apb_reset_seq");
	apb_wr_seq    = apb_write_sequence::type_id::create("apb_wr_seq");
	apb_rd_seq    = apb_read_sequence::type_id::create("apb_rd_seq");
	spi_wr_seq    = spi_write_sequence::type_id::create("spi_wr_seq");
endfunction : build_phase

function void cpha0_cpol1_lsb_test::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
endfunction : end_of_elaboration_phase

task cpha0_cpol1_lsb_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
		for(int j = 0;j < 100; j++)
		for(int i = 0;i < cfg.num_of_apb_agents;i++)
			begin
				apb_reset_seq.start(envh.apb_top.apb_agth[i].seqrh); //RESET SEQ
				apb_wr_seq.start(envh.apb_top.apb_agth[i].seqrh);    //APB WRITE SEQ
				//CHECK IF DR WRITE IS ZERO
				if((envh.apb_top.apb_agth[i].drvh.req.PADDR == 3'b101) && (envh.apb_top.apb_agth[i].drvh.req.PWDATA != 8'h00))
					begin
						spi_wr_seq.start(envh.spi_top.spi_agth[i].seqrh); //SPI WRITE SEQ
						apb_rd_seq.start(envh.apb_top.apb_agth[i].seqrh); //APB READ SEQ
					end
			end
			//phase.phase_done.set_drain_time(this,250);
	phase.drop_objection(this);

endtask : run_phase

//TEST CASE 5 : CPOL = 1 CPHA = 1 LSBFE = 0
class cpha1_cpol1_msb_test extends base_test;
	`uvm_component_utils(cpha1_cpol1_msb_test)
	
	bit [7:0] CR1 = 8'b11111110;
	bit [7:0] CR2 = 8'b00010000;

	apb_reset_sequence apb_reset_seq;
	apb_write_sequence apb_wr_seq;
	apb_read_sequence  apb_rd_seq;
	spi_write_sequence spi_wr_seq;
	
	function new(string name = "cpha1_cpol1_msb_test",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass : cpha1_cpol1_msb_test

function void cpha1_cpol1_msb_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	uvm_config_db #(bit[7:0])::set(this,"*","CR1",CR1);
	uvm_config_db #(bit[7:0])::set(this,"*","CR2",CR2);
	
	apb_reset_seq = apb_reset_sequence::type_id::create("apb_reset_seq");
	apb_wr_seq    = apb_write_sequence::type_id::create("apb_wr_seq");
	apb_rd_seq    = apb_read_sequence::type_id::create("apb_rd_seq");
	spi_wr_seq    = spi_write_sequence::type_id::create("spi_wr_seq");
endfunction : build_phase

function void cpha1_cpol1_msb_test::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
endfunction : end_of_elaboration_phase

task cpha1_cpol1_msb_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
		for(int j = 0;j < 100; j++)
		for(int i = 0;i < cfg.num_of_apb_agents;i++)
			begin
				apb_reset_seq.start(envh.apb_top.apb_agth[i].seqrh); //RESET SEQ
				apb_wr_seq.start(envh.apb_top.apb_agth[i].seqrh);    //APB WRITE SEQ
				//CHECK IF DR WRITE IS ZERO
				if((envh.apb_top.apb_agth[i].drvh.req.PADDR == 3'b101) && (envh.apb_top.apb_agth[i].drvh.req.PWDATA != 8'h00))
					begin
						spi_wr_seq.start(envh.spi_top.spi_agth[i].seqrh); //SPI WRITE SEQ
						apb_rd_seq.start(envh.apb_top.apb_agth[i].seqrh); //APB READ SEQ
					end
			end
			//phase.phase_done.set_drain_time(this,250);
	phase.drop_objection(this);

endtask : run_phase

//TEST CASE 6 : CPOL = 0 CPHA = 0 LSBFE = 0
class cpha0_cpol0_msb_test extends base_test;
	`uvm_component_utils(cpha0_cpol0_msb_test)
	
	bit [7:0] CR1 = 8'b11110010;
	bit [7:0] CR2 = 8'b00010000;

	apb_reset_sequence apb_reset_seq;
	apb_write_sequence apb_wr_seq;
	apb_read_sequence  apb_rd_seq;
	spi_write_sequence spi_wr_seq;
	
	function new(string name = "cpha0_cpol0_msb_test",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass : cpha0_cpol0_msb_test

function void cpha0_cpol0_msb_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	uvm_config_db #(bit[7:0])::set(this,"*","CR1",CR1);
	uvm_config_db #(bit[7:0])::set(this,"*","CR2",CR2);
	
	apb_reset_seq = apb_reset_sequence::type_id::create("apb_reset_seq");
	apb_wr_seq    = apb_write_sequence::type_id::create("apb_wr_seq");
	apb_rd_seq    = apb_read_sequence::type_id::create("apb_rd_seq");
	spi_wr_seq    = spi_write_sequence::type_id::create("spi_wr_seq");
endfunction : build_phase

function void cpha0_cpol0_msb_test::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
endfunction : end_of_elaboration_phase

task cpha0_cpol0_msb_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
		for(int j = 0;j < 100; j++)
		for(int i = 0;i < cfg.num_of_apb_agents;i++)
			begin
				apb_reset_seq.start(envh.apb_top.apb_agth[i].seqrh); //RESET SEQ
				apb_wr_seq.start(envh.apb_top.apb_agth[i].seqrh);    //APB WRITE SEQ
				//CHECK IF DR WRITE IS ZERO
				if((envh.apb_top.apb_agth[i].drvh.req.PADDR == 3'b101) && (envh.apb_top.apb_agth[i].drvh.req.PWDATA != 8'h00))
					begin
						spi_wr_seq.start(envh.spi_top.spi_agth[i].seqrh); //SPI WRITE SEQ
						apb_rd_seq.start(envh.apb_top.apb_agth[i].seqrh); //APB READ SEQ
					end
			end
			//phase.phase_done.set_drain_time(this,250);
	phase.drop_objection(this);

endtask : run_phase

//TEST CASE 7 : CPOL = 0 CPHA = 1 LSBFE = 0
class cpha1_cpol0_msb_test extends base_test;
	`uvm_component_utils(cpha1_cpol0_msb_test)
	
	bit [7:0] CR1 = 8'b11110110;
	bit [7:0] CR2 = 8'b00010000;

	apb_reset_sequence apb_reset_seq;
	apb_write_sequence apb_wr_seq;
	apb_read_sequence  apb_rd_seq;
	spi_write_sequence spi_wr_seq;
	
	function new(string name = "cpha1_cpol0_msb_test",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass : cpha1_cpol0_msb_test

function void cpha1_cpol0_msb_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	uvm_config_db #(bit[7:0])::set(this,"*","CR1",CR1);
	uvm_config_db #(bit[7:0])::set(this,"*","CR2",CR2);
	
	apb_reset_seq = apb_reset_sequence::type_id::create("apb_reset_seq");
	apb_wr_seq    = apb_write_sequence::type_id::create("apb_wr_seq");
	apb_rd_seq    = apb_read_sequence::type_id::create("apb_rd_seq");
	spi_wr_seq    = spi_write_sequence::type_id::create("spi_wr_seq");
endfunction : build_phase

function void cpha1_cpol0_msb_test::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
endfunction : end_of_elaboration_phase

task cpha1_cpol0_msb_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
		for(int j = 0;j < 100; j++)
		for(int i = 0;i < cfg.num_of_apb_agents;i++)
			begin
				apb_reset_seq.start(envh.apb_top.apb_agth[i].seqrh); //RESET SEQ
				apb_wr_seq.start(envh.apb_top.apb_agth[i].seqrh);    //APB WRITE SEQ
				//CHECK IF DR WRITE IS ZERO
				if((envh.apb_top.apb_agth[i].drvh.req.PADDR == 3'b101) && (envh.apb_top.apb_agth[i].drvh.req.PWDATA != 8'h00))
					begin
						spi_wr_seq.start(envh.spi_top.spi_agth[i].seqrh); //SPI WRITE SEQ
						apb_rd_seq.start(envh.apb_top.apb_agth[i].seqrh); //APB READ SEQ
					end
			end
			//phase.phase_done.set_drain_time(this,250);
	phase.drop_objection(this);

endtask : run_phase

//TEST CASE 8 : CPOL = 1 CPHA = 0 LSBFE = 0
class cpha0_cpol1_msb_test extends base_test;
	`uvm_component_utils(cpha0_cpol1_msb_test)
	
	bit [7:0] CR1 = 8'b11111010;
	bit [7:0] CR2 = 8'b00010000;

	apb_reset_sequence apb_reset_seq;
	apb_write_sequence apb_wr_seq;
	apb_read_sequence  apb_rd_seq;
	spi_write_sequence spi_wr_seq;
	
	function new(string name = "cpha0_cpol1_msb_test",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass : cpha0_cpol1_msb_test

function void cpha0_cpol1_msb_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	uvm_config_db #(bit[7:0])::set(this,"*","CR1",CR1);
	uvm_config_db #(bit[7:0])::set(this,"*","CR2",CR2);
	
	apb_reset_seq = apb_reset_sequence::type_id::create("apb_reset_seq");
	apb_wr_seq    = apb_write_sequence::type_id::create("apb_wr_seq");
	apb_rd_seq    = apb_read_sequence::type_id::create("apb_rd_seq");
	spi_wr_seq    = spi_write_sequence::type_id::create("spi_wr_seq");
endfunction : build_phase

function void cpha0_cpol1_msb_test::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
endfunction : end_of_elaboration_phase

task cpha0_cpol1_msb_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
		for(int j = 0;j < 100; j++)
		for(int i = 0;i < cfg.num_of_apb_agents;i++)
			begin
				apb_reset_seq.start(envh.apb_top.apb_agth[i].seqrh); //RESET SEQ
				apb_wr_seq.start(envh.apb_top.apb_agth[i].seqrh);    //APB WRITE SEQ
				//CHECK IF DR WRITE IS ZERO
				if((envh.apb_top.apb_agth[i].drvh.req.PADDR == 3'b101) && (envh.apb_top.apb_agth[i].drvh.req.PWDATA != 8'h00))
					begin
						spi_wr_seq.start(envh.spi_top.spi_agth[i].seqrh); //SPI WRITE SEQ
						apb_rd_seq.start(envh.apb_top.apb_agth[i].seqrh); //APB READ SEQ
					end
			end
			//phase.phase_done.set_drain_time(this,250);
	phase.drop_objection(this);

endtask : run_phase

//TEST CASE 9 : RESET TEST
class reset_test extends base_test;
	`uvm_component_utils(reset_test)
	
	bit [7:0] CR1 = 8'b11111010;
	bit [7:0] CR2 = 8'b00010000;
	bit [3:0] ADDR;
	apb_reset_sequence apb_reset_seq;
	apb_write_sequence apb_wr_seq;
	apb_read_sequence  apb_rd_seq;
	spi_write_sequence spi_wr_seq;
	
	function new(string name = "reset_test",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass : reset_test

function void reset_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	uvm_config_db #(bit[7:0])::set(this,"*","CR1",CR1);
	uvm_config_db #(bit[7:0])::set(this,"*","CR2",CR2);
	uvm_config_db #(bit)::set(this,"*","reset_test",1);
	
	apb_reset_seq = apb_reset_sequence::type_id::create("apb_reset_seq");
	apb_wr_seq    = apb_write_sequence::type_id::create("apb_wr_seq");
	apb_rd_seq    = apb_read_sequence::type_id::create("apb_rd_seq");

endfunction : build_phase

function void reset_test::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
endfunction : end_of_elaboration_phase

task reset_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
		for(int i = 0;i < cfg.num_of_apb_agents;i++)
			begin
				apb_wr_seq.start(envh.apb_top.apb_agth[i].seqrh);   //APB WRITE SEQ
				apb_reset_seq.start(envh.apb_top.apb_agth[i].seqrh);//RESET SEQ
				for(int num = 0; num < 5;num++)
					begin
						if(num == 4)
							uvm_config_db #(bit[2:0])::set(this,"*","ADDR",5);
						else
							uvm_config_db #(bit[2:0])::set(this,"*","ADDR",num);
						apb_rd_seq.start(envh.apb_top.apb_agth[i].seqrh); //APB READ SEQ
					end
			end
			//phase.phase_done.set_drain_time(this,250);
	phase.drop_objection(this);

endtask : run_phase

//TEST CASE 10 : LOW POWER TEST
class low_power_test extends base_test;
	`uvm_component_utils(low_power_test)
	
	bit [7:0] CR1 = 8'b11110010;
	bit [7:0] CR2 = 8'b00010000;

	apb_reset_sequence apb_reset_seq;
	apb_write_sequence apb_wr_seq;
	apb_read_sequence  apb_rd_seq;
	spi_write_sequence spi_wr_seq;
	
	function new(string name = "low_power_test",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass : low_power_test

function void low_power_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	uvm_config_db #(bit[7:0])::set(this,"*","CR1",CR1);
	uvm_config_db #(bit[7:0])::set(this,"*","CR2",CR2);
	
	
	apb_reset_seq = apb_reset_sequence::type_id::create("apb_reset_seq");
	apb_wr_seq    = apb_write_sequence::type_id::create("apb_wr_seq");
	apb_rd_seq    = apb_read_sequence::type_id::create("apb_rd_seq");
	spi_wr_seq    = spi_write_sequence::type_id::create("spi_wr_seq");

endfunction : build_phase

function void low_power_test::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
endfunction : end_of_elaboration_phase

task low_power_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
		//Normal mode
		for(int i = 0;i < cfg.num_of_apb_agents;i++)
			begin
				apb_reset_seq.start(envh.apb_top.apb_agth[i].seqrh); //RESET SEQ
				apb_wr_seq.start(envh.apb_top.apb_agth[i].seqrh);    //APB WRITE SEQ
				//CHECK IF DR WRITE IS ZERO
				if((envh.apb_top.apb_agth[i].drvh.req.PADDR == 3'b101) && (envh.apb_top.apb_agth[i].drvh.req.PWDATA != 8'h00))
					begin
						spi_wr_seq.start(envh.spi_top.spi_agth[i].seqrh); //SPI WRITE SEQ
						apb_rd_seq.start(envh.apb_top.apb_agth[i].seqrh); //APB READ SEQ
					end
			end


		//WAIT mode
		CR1 = 8'b10110010;
		CR2 = 8'b00010000;

		uvm_config_db #(bit[7:0])::set(this,"*","CR1",CR1);
		uvm_config_db #(bit[7:0])::set(this,"*","CR2",CR2);

		for(int i = 0;i < cfg.num_of_apb_agents;i++)
			begin
				apb_reset_seq.start(envh.apb_top.apb_agth[i].seqrh); //RESET SEQ
				apb_wr_seq.start(envh.apb_top.apb_agth[i].seqrh);    //APB WRITE SEQ
				//CHECK IF DR WRITE IS ZERO
				if((envh.apb_top.apb_agth[i].drvh.req.PADDR == 3'b101) && (envh.apb_top.apb_agth[i].drvh.req.PWDATA != 8'h00))
					begin
						spi_wr_seq.start(envh.spi_top.spi_agth[i].seqrh); //SPI WRITE SEQ
						apb_rd_seq.start(envh.apb_top.apb_agth[i].seqrh); //APB READ SEQ
					end
			end

		//STOP mode
		CR1 = 8'b10110010;
		CR2 = 8'b00010010;
		
		uvm_config_db #(bit[7:0])::set(this,"*","CR1",CR1);
		uvm_config_db #(bit[7:0])::set(this,"*","CR2",CR2);

		uvm_config_db #(bit)::set(this,"*","low_power_test",1);

		for(int i = 0;i < cfg.num_of_apb_agents;i++)
			begin
				apb_reset_seq.start(envh.apb_top.apb_agth[i].seqrh); //RESET SEQ
				apb_wr_seq.start(envh.apb_top.apb_agth[i].seqrh);    //APB WRITE SEQ
			end
	phase.phase_done.set_drain_time(this, 200000); //WAIT for Scoreboard to complete
	phase.drop_objection(this);

endtask : run_phase

//TEST CASE 11 : CORNER TEST CASE
class corner_test extends base_test;
	`uvm_component_utils(corner_test)
	
	bit [7:0] CR1 = 8'b11111111;
	bit [7:0] CR2 = 8'b00010000;

	apb_reset_sequence apb_reset_seq;
	apb_write_sequence apb_wr_seq;
	apb_read_sequence  apb_rd_seq;
	spi_write_sequence spi_wr_seq;
	
	function new(string name = "corner_test",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass : corner_test

function void corner_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	uvm_config_db #(bit[7:0])::set(this,"*","CR1",CR1);
	uvm_config_db #(bit[7:0])::set(this,"*","CR2",CR2);
	
	apb_reset_seq = apb_reset_sequence::type_id::create("apb_reset_seq");
	apb_wr_seq    = apb_write_sequence::type_id::create("apb_wr_seq");
	apb_rd_seq 	  = apb_read_sequence::type_id::create("apb_rd_seq");
	spi_wr_seq    = spi_write_sequence::type_id::create("spi_wr_seq");

endfunction : build_phase

function void corner_test::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
endfunction : end_of_elaboration_phase

task corner_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
	//Change clock period to 5, PCLK freq = 200Mhz
		for(int i = 0;i < cfg.num_of_apb_agents;i++)
			begin
				apb_reset_seq.start(envh.apb_top.apb_agth[i].seqrh); //RESET SEQ
				apb_wr_seq.start(envh.apb_top.apb_agth[i].seqrh);	 //APB WRITE SEQ
				//CHECK IF DR WRITE IS ZERO
				if((envh.apb_top.apb_agth[i].drvh.req.PADDR == 3'b101) && (envh.apb_top.apb_agth[i].drvh.req.PWDATA != 8'h00))
					begin
						spi_wr_seq.start(envh.spi_top.spi_agth[i].seqrh); //SPI WRITE SEQ
						apb_rd_seq.start(envh.apb_top.apb_agth[i].seqrh); //APB READ SEQ
					end
			end
			//phase.phase_done.set_drain_time(this,250);
	phase.drop_objection(this);
endtask : run_phase
