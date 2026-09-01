/*======================================================================
================================TEST PACKAGE============================
=======================================================================*/
package test_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"

	`include "APB_xtn.sv"
	`include "SPI_xtn.sv"
	`include "APB_agent_config.sv"
	`include "SPI_agent_config.sv"
	`include "env_config.sv"
	`include "APB_sequence.sv"
	`include "APB_driver.sv"
	`include "APB_sequencer.sv"
	`include "APB_monitor.sv"
	`include "APB_agent.sv"
	`include "APB_agent_top.sv"
	`include "SPI_sequence.sv"
	`include "SPI_driver.sv"
	`include "SPI_sequencer.sv"
	`include "SPI_monitor.sv"
	`include "SPI_agent.sv"
	`include "SPI_agent_top.sv"
	`include "core_sb.sv"
	`include "env.sv"
	`include "test.sv"

endpackage : test_pkg
