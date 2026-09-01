//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:10:57 02/02/2026 
// Design Name: 	 Baud_rate_generator
// Module Name:    Baud_rate_generator 
// Project Name: 	 APB_interfaced_SPI_core
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: Sub_Module RTL
//
//////////////////////////////////////////////////////////////////////////////////
module Baud_rate_generator(
    input PCLK, //system_clock
    input PRESET_n, //Active low asynchronous reset signal
    input [1:0] spi_mode_i, //spi_mode select 00 ->RUN, 01 ->WAIT, 10 ->STOP 
    input spiswai_i, //spi_wait bit 0 -> Run mode, 1 -> conservative mode
    input [2:0] sppr_i, //SPI baudrate register 3bits
    input [2:0] spr_i, //SPI baudrate register 3bits
    input cpol_i, //cpol=0 -> posedge, cpol=1 -> negedge
    input cpha_i, //cpha=0 -> odd edges, cpha=1 -> even edges
    input ss_i, //active low slave select signal
    output reg sclk_o, //serial clk to generate (PCLK / baudrate_divisor)
    output reg miso_receive_sclk_o, //slave->master flag when cpol=0 & cpha=0 (posedge)
    output reg miso_receive_sclk0_o, //slave->master flag when cpol=0 & cpha=1 / cpol=1 & cpha=0 (negedge)
    output reg mosi_send_sclk_o, //master->slave flag when cpol=0 & cpha=0 (posedge)
    output reg mosi_send_sclk0_o, //slave->master flag when cpol=0 & cpha=1 / cpol=1 & cpha=0 (negedge)
    output [11:0] BaudRateDivisor_o //12 bits since largest value possible is 2048
    );

//SPI mode parameters
parameter RUN = 2'b00;
parameter WAIT = 2'b01;
parameter STOP = 2'b10;

reg [11:0]count; //counter for sclk generation wrt baudrate
wire Presclk; //internal wire

assign Presclk = (cpol_i)? 1'b1 : 1'b0; //calculating sclk reset value based on cpol

assign BaudRateDivisor_o = (sppr_i + 12'd1) * (2 ** (spr_i + 12'd1)); //baudrate value based on spr and sppr values

//sclk output logic
always @(posedge PCLK or negedge PRESET_n) 
begin
	if (!PRESET_n)
		sclk_o <= Presclk;
	else if (!ss_i && (spi_mode_i == RUN || (spi_mode_i == WAIT && !spiswai_i)))
	begin
		if (count == ((BaudRateDivisor_o / 2) /*Calculating for both positive and negative cycle*/ - 1'b1))
			sclk_o <= ~sclk_o; //toggling sclk
		else
			sclk_o <= sclk_o;
	end
	else
		sclk_o <= Presclk;
end

//counter logic
always @(posedge PCLK or negedge PRESET_n) 
begin
	if (!PRESET_n)
		count <= 12'b0;
	else if (!ss_i && (spi_mode_i == RUN || (spi_mode_i == WAIT && !spiswai_i)))
	begin
		if (count == ((BaudRateDivisor_o / 2) - 1'b1))
			count <= 12'b0; //reset the count after counting the last value
		else
			count <= count + 1'b1; //increament counter
	end
	else
		count <= 12'b0;
end

//miso receive flag logic
always @(posedge PCLK or negedge PRESET_n) 
begin
		if (!PRESET_n)
		begin
			miso_receive_sclk_o <= 0;
			miso_receive_sclk0_o <= 0;
		end
		else if (cpol_i ^ cpha_i) //sampling/transmitting edge logic 1 -> negative edge, 0 -> positive edge
		begin
			miso_receive_sclk_o <= 1'b0;
			if ((sclk_o == 1'b1) && (count == ((BaudRateDivisor_o / 2) - 1'b1)) && (!ss_i)) //sampling done after negative edge of sclk till next positive edge of PCLK
			begin
				miso_receive_sclk0_o <= 1'b1;
			end
			else
			begin
				miso_receive_sclk0_o <= 1'b0;
			end
		end
		else
		begin
			miso_receive_sclk0_o <= 1'b0;
			if ((sclk_o == 1'b0) && (count == ((BaudRateDivisor_o / 2) - 1'b1)) && (!ss_i)) //sampling done after positive edge of sclk till next positive edge of PCLK
			begin
				miso_receive_sclk_o <= 1'b1;
			end
			else
			begin
				miso_receive_sclk_o <= 1'b0;
			end
		end
end

//mosi send flag logic
always @(posedge PCLK or negedge PRESET_n) 
begin
					if (!PRESET_n)
					begin
						mosi_send_sclk_o <= 0;
						mosi_send_sclk0_o <= 0;
					end
					else if (cpol_i ^ cpha_i)
					begin
						mosi_send_sclk0_o <= 1'b0;
						if((!ss_i) && (BaudRateDivisor_o == 12'd2)) //TO handle BaudRateDivisor_o = 2 case
							begin
								if(sclk_o == 1'b1)
									mosi_send_sclk_o <= 1'b1;
								else
									mosi_send_sclk_o <= 1'b0;
							end
						else
							begin
								if ((sclk_o == 1'b0) && (count == ((BaudRateDivisor_o / 2) - 1'b1)) && (!ss_i)) //transfer done before negative edge of sclk till next positive edge of PCLK
								begin
									mosi_send_sclk_o <= 1'b1;
								end
								else
								begin
									mosi_send_sclk_o <= 1'b0;
								end
							end
					end
					else
					begin
						mosi_send_sclk_o <= 1'b0;
						if((!ss_i) && (BaudRateDivisor_o == 12'd2))
							begin
								if(sclk_o == 1'b0)
									mosi_send_sclk0_o <= 1'b1;
								else
									mosi_send_sclk0_o <= 1'b0;
							end
						else
							begin
								if ((sclk_o == 1'b1) && (count == ((BaudRateDivisor_o / 2) - 1'b1)) && (!ss_i)) //transfer done before positive edge of sclk till next positive edge of PCLK
								begin
									mosi_send_sclk0_o <= 1'b1;
								end
								else
								begin
									mosi_send_sclk0_o <= 1'b0;
								end
							end
					end
end

endmodule
