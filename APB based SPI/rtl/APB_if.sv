interface apb_if (input bit clock);
	logic PCLK;
	logic PRESET_n;
	logic [2:0] PADDR;
	logic PWRITE;
	logic PSEL;
	logic PENABLE;
	logic [7:0] PWDATA;
	logic [7:0] PRDATA;
	logic PREADY;
	logic PSLVERR;
	logic spi_interrupt_request;
	assign PCLK = clock;
	
	clocking apb_drv_cb @(posedge clock);
		default input #1 output #1;
		output PRESET_n;
		output PADDR;
		output PWRITE;
		output PSEL;
		output PENABLE;
		output PWDATA;
		input PRDATA;
		input PREADY;
		input PSLVERR;
	endclocking : apb_drv_cb

	clocking apb_mon_cb @(posedge clock);
		default input #1 output #1;
		input PRESET_n;
		input PADDR;
		input PWRITE;
		input PSEL;
		input PENABLE;
		input PWDATA;
		input PRDATA;
		input PREADY;
		input PSLVERR;
	endclocking : apb_mon_cb

	modport APB_DRV_MP (clocking apb_drv_cb);
	modport APB_MON_MP (clocking apb_mon_cb, input PRESET_n);

	property signal_stable;
		@(posedge clock) $rose(PSEL) |-> ($stable(PWRITE) && $stable(PADDR) && $stable(PWDATA)) until PREADY[->1];
	endproperty : signal_stable

	property PENABLE_stable;
		@(posedge clock) $rose(PENABLE) |-> $stable(PSEL) && $stable(PENABLE) until PREADY[->1];
	endproperty : PENABLE_stable

	property PREADY_check;
		@(posedge clock) (PSEL) && (PENABLE) |=> PREADY;
	endproperty : PREADY_check

	property address_reserved;
		@(posedge clock) $rose(PREADY) |=> ((PADDR != 3'b100) || (PADDR != 3'b110) || (PADDR != 3'b111));
	endproperty : address_reserved

	property PENABLE_deassert;
		@(posedge clock) $fell(PSEL) |=> (!PENABLE);
	endproperty : PENABLE_deassert

	property valid_write_data_transfer;
		@(posedge clock) $rose(PREADY) && PWRITE && PADDR == 3'b101 |=> (PWDATA != 8'h00);
	endproperty : valid_write_data_transfer

	property valid_read_data_transfer;
		@(posedge clock) $rose(PREADY) && !PWRITE && PADDR == 3'b101 |=> (PRDATA != 8'h00);
	endproperty : valid_read_data_transfer

	property PREADY_low_at_start;
		@(posedge clock) PSEL && !PENABLE |-> (!PREADY);
	endproperty : PREADY_low_at_start

	property PREADY_deassert;
		@(posedge clock) (!PSEL && !PENABLE && PREADY) |=> (!PREADY);
	endproperty : PREADY_deassert

	SIGNAL_STABLE:	assert property(signal_stable)
						$info("SIGNAL STABILITY is verified");
					else
						$error("SIGNAL STABILTY is not verified");
					
	PENABLE_STABLE: assert property(PENABLE_stable)
						$info("PENABLE STABILTY is verified");
					else
						$error("PENABLE STABILTY is not verified");

	PSEL_TO_PREADY: assert property(PREADY_check)
						$info("PREADY is verified");
					else
						$error("PREADY is not verified");

	ADDRESS_RESERVED: assert property(address_reserved)
						$info("ADDRESS RESERVATION is verified");
					else
						$error("ADDRESS RESERVATION is not verified");

	PENABLE_DEASSERT: assert property(PENABLE_deassert)
						$info("PENABLE DEASSERTION is verified");
					else
						$error("PENABLE DEASSERTION is not verified");

	WRITE_TRANSFER:	assert property(valid_write_data_transfer)
						$info("WRITE TRANSFER is verified");
					else
						$error("WRITE TRANSFER is not verified");

	READ_TRANSFER:	assert property(valid_read_data_transfer)
						$info("READ TRANSFER is verified");
					else
						$error("READ TRANSFER is not verified");

	PREADY_LOW_AT_START: assert property(PREADY_low_at_start)
						$info("PREADY LOW START is verified");
					else
						$error("PREADY LOW START is not verified");

	PREADY_DEASSERT: assert property(PREADY_deassert)
						$info("PREADY DEASSERTION is verified");
					else
						$error("PREADY DEASSERTION is not verified");

	SIGNAL_STABLE_COVER:	cover property(signal_stable);
	PENABLE_STABLE_COVER: cover property(PENABLE_stable);
	PSEL_TO_PREADY_COVER: cover property(PREADY_check);
	ADDRESS_RESERVED_COVER: cover property(address_reserved);
	PENABLE_DEASSERT_COVER: cover property(PENABLE_deassert);
	WRITE_TRANSFER_COVER:	cover property(valid_write_data_transfer);
	READ_TRANSFER_COVER:	cover property(valid_read_data_transfer);
	PREADY_LOW_AT_START_COVER: cover property(PREADY_low_at_start);
	PREADY_DEASSERT_COVER: cover property(PREADY_deassert);

endinterface : apb_if