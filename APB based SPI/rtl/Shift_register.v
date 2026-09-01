module Shift_register(
    input PCLK,
    input PRESET_n,
    input ss_i,
    input send_data_i,
    input lsbfe_i,
    input cpha_i,
    input cpol_i,
    input [11:0] BaudRateDivisor_i,
    input miso_receive_sclk_i,   // High for Mode 0 & Mode 3 sampling
    input miso_receive_sclk0_i,  // High for Mode 1 & Mode 2 sampling
    input mosi_send_sclk_i,      // High for Mode 1 & Mode 2 driving
    input mosi_send_sclk0_i,     // High for Mode 0 & Mode 3 driving
    input [7:0] data_mosi_i,
    input miso_i,
    input receive_data_i,
    output reg mosi_o,
    output reg [7:0] data_miso_o
    );
     
reg [7:0] shift_reg_tx;
reg [7:0] shift_reg_rx;
reg [3:0] bit_cnt; // To keep track of exactly 8 bits

// Qualify the internal flags based on CPOL/CPHA pairs
wire rx_flag = (cpol_i ^ cpha_i) ? miso_receive_sclk0_i : miso_receive_sclk_i;
wire tx_flag = (cpol_i ^ cpha_i) ? mosi_send_sclk_i     : mosi_send_sclk0_i;

// Assign parallel output to read register
//assign data_miso_o = (receive_data_i) ? shift_reg_rx : 8'h00;
always @(*) begin
	if (!PRESET_n)
		data_miso_o <= 8'b0;
	else if(receive_data_i)
		data_miso_o <= shift_reg_rx;
	else
		data_miso_o <= data_miso_o;
end
//==========================================================
// 1. MOSI Transmit (TX) Logic
//==========================================================
always @(posedge PCLK or negedge PRESET_n) begin
    if (!PRESET_n) begin
        shift_reg_tx <= 8'b0;
        mosi_o       <= 1'bx;
    end 
    else if (send_data_i) begin
        shift_reg_tx <= data_mosi_i;
        // Pre-drive the very first bit for Mode 0 and Mode 3 immediately on load
        if ((!cpol_i && !cpha_i) ||(cpol_i && !cpha_i) || (BaudRateDivisor_i == 12'd2)) begin
            mosi_o <= lsbfe_i ? data_mosi_i[0] : data_mosi_i[7];
        end
    end 
    else if (!ss_i) begin
		if((!cpol_i && !cpha_i) ||(cpol_i && !cpha_i) || (BaudRateDivisor_i == 12'd2))
			begin
				if (tx_flag && (bit_cnt < 4'd8)) begin
					if (lsbfe_i) begin
						// Shift Right for LSB First
						mosi_o       <= shift_reg_tx[1];
						shift_reg_tx <= {1'b0, shift_reg_tx[7:1]};
					end else begin
						// Shift Left for MSB First
						mosi_o       <= shift_reg_tx[6];
						shift_reg_tx <= {shift_reg_tx[6:0], 1'b0};
					end
				end
			end
		else
			begin
				if (tx_flag && (bit_cnt < 4'd8)) begin
					if (lsbfe_i) begin
						// Shift Right for LSB First
						mosi_o       <= shift_reg_tx[0];
						shift_reg_tx <= {1'b0, shift_reg_tx[7:1]};
					end else begin
						// Shift Left for MSB First
						mosi_o       <= shift_reg_tx[7];
						shift_reg_tx <= {shift_reg_tx[6:0], 1'b0};
					end
				end
			end
    end 
    else begin
        mosi_o <= 1'bx;
    end
end

//==========================================================
// 2. MISO Receive (RX) Logic
//==========================================================
always @(posedge PCLK or negedge PRESET_n) begin
    if (!PRESET_n) begin
        shift_reg_rx <= 8'b0;
    end 
    else if (!ss_i) begin
        if (rx_flag && (bit_cnt < 4'd8)) begin
            if (lsbfe_i) begin
                // Capture at MSB position, shift right for LSB first
                shift_reg_rx <= {miso_i, shift_reg_rx[7:1]};
            end else begin
                // Capture at LSB position, shift left for MSB first
                shift_reg_rx <= {shift_reg_rx[6:0], miso_i};
            end
        end
    end
end

//==========================================================
// 3. Bit Counter Logic (Prevents over-shifting)
//==========================================================
always @(posedge PCLK or negedge PRESET_n) begin
    if (!PRESET_n) begin
        bit_cnt <= 4'd0;
    end 
    else if (send_data_i) begin
        bit_cnt <= 4'd0;
    end 
    else if (!ss_i) begin
        if (rx_flag) begin
            bit_cnt <= bit_cnt + 1'b1;
        end
    end 
    else begin
        bit_cnt <= 4'd0;
    end
end

endmodule
