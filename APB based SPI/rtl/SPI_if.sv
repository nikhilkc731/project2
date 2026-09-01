interface spi_if (input bit PCLK,input bit PRESET_n);
	logic ss;
	logic sclk;
	logic mosi;
	logic miso;

	// Positive edge driving block
    clocking spi_drv_cb_pos @(posedge sclk);
        default input #1 output #1;
        input ss, mosi;
        output miso;
    endclocking

    // Negative edge driving block
    clocking spi_drv_cb_neg @(negedge sclk);
        default input #1 output #1;
        input ss, mosi;
        output miso;
    endclocking

	 clocking spi_mon_cb_pos @(posedge sclk);
        default input #1 output #1;
        input ss, mosi;
        input miso;
    endclocking

    // Negative edge monitoring block
    clocking spi_mon_cb_neg @(negedge sclk);
        default input #1 output #1;
        input ss, mosi;
        input miso;
    endclocking

	modport SPI_DRV_MP (clocking spi_drv_cb_pos, clocking spi_drv_cb_neg);
	modport SPI_MON_MP (clocking spi_mon_cb_pos, clocking spi_mon_cb_neg);

// Internal tracking variables
    bit detected_cpol;

    //======================================================================
    // 1. ROBUST ACTIVE-LOW MODE DETECTION
    //======================================================================
    always @(posedge PCLK) begin
        if (!PRESET_n) begin
            detected_cpol   <= 1'b0;
        end else begin
            // Detect the end of a transfer (Active-Low rising edge)
            if (ss == 1'b1) begin
                detected_cpol   <= sclk;
            end

        end
    end

    //======================================================================
    // 2. SYNCHRONOUS ASSERTIONS (USING STANDARD $error)
    //======================================================================

    // ASSERTION 2: Idle Polarity Level Check
    // When SS is inactive (1), SCLK must stay locked at the detected CPOL level
    property p_cpol_level_check;
        @(posedge PCLK) disable iff (!PRESET_n)
        (ss == 1'b1) && $stable(ss) && $stable(sclk) |-> (sclk == detected_cpol);
    endproperty
    assert_cpol_level: assert property (p_cpol_level_check)
        $info("ASSERTION 1 PASSED");
        else $error("[SPI_SVA_ERR] Protocol Violation: SCLK is (%0b) drifted away from its expected CPOL idle level (%0b) while SS was high!", sclk,detected_cpol);
    
    CHECK1 : cover property (p_cpol_level_check);

    // 2. Assert that the entire active-low window of SS contains exactly 16 edges
    property p_exact_8_bits_frame;
        @(posedge PCLK) disable iff (!PRESET_n)
        $fell(ss) |-> ($changed(sclk))[=16] ##1 $rose(ss);
    endproperty

    assert_frame_length: assert property (p_exact_8_bits_frame)
        $info("ASSERTION 2 PASSED");
        else $error("[SPI_SVA_ERR] Frame Protocol Violation! SS did not contain exactly 8 bits of SCLK activity before closing.");

    CHECK2 : cover property (p_exact_8_bits_frame);
endinterface : spi_if
