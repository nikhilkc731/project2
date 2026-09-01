//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:06:16 02/06/2026 
// Design Name: 
// Module Name:    SPI_slave_control_select 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module SPI_slave_control_select(
    input PCLK, //system_clock
    input PRESET_n, //Active low asynchronous reset signal
    input mstr_i, //signal to set SPI in master or slvae mode. 1->master_mode, 0->slave mode
    input spiswai_i, //spi_wait bit 0 -> Run mode, 1 -> conservative mode
    input [1:0] spi_mode_i, //spi_mode select 00 ->RUN, 01 ->WAIT, 10 ->STOP
    input send_data_i, //flag to send data from the data register
    input [11:0] BaudRateDivisor_i, //12 bits since largest value possible is 2048
    output reg receive_data_o, //receive data output flag
    output reg ss_o, //active low slave select signal
    output tip_o //compliment of slave select signal (transfer in progress)
    );
	 
parameter data_bits = 8; //number of data bits

//SPI modes
parameter RUN = 2'b00;
parameter WAIT = 2'b01;
parameter STOP = 2'b10;

reg [15:0]count; //internal counter to keep count of PCLK signals to reach target
wire [15:0]target;
reg rcv; //register to process & store the value for receive data signal

assign tip_o = ~ss_o;
assign target = data_bits * BaudRateDivisor_i; //number of PCLK signals in terms of sclk.

//receive data flag logic set to rcv
always @(posedge PCLK or negedge PRESET_n) 
begin
	if(!PRESET_n)
		receive_data_o <= 1'b0;
	else
		receive_data_o <= rcv;
end

//slave select logic
always @(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		ss_o <= 1'b1;
	else if(mstr_i && (spi_mode_i == RUN || (spi_mode_i == WAIT && !spiswai_i)))
	begin
		if(send_data_i)
			ss_o <= 1'b0;
		else
		begin
			if(count < target)
				ss_o <= 1'b0; //keep ss -> 0 till 31st clock-cycles when baudrate is 4 else set it to 1.
			else
				ss_o <= 1'b1;
		end
	end
	else
	ss_o <= 1'b1;
end

//counter logic
always @(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		count <= 16'hffff;
	else if(mstr_i && (spi_mode_i == RUN || (spi_mode_i == WAIT && !spiswai_i)))
	begin
		if(send_data_i) 
			count <= 16'b0;
		else
		begin
			if(count < target) //count till 31st clock cycles when baudrate is 4
				count <= count + 1'b1;
			else
				count <= 16'hffff;
		end
	end
	else
		count <= 16'hffff;
end


//rcv data logic
always @(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		rcv <= 1'b0;
	else if(mstr_i && (spi_mode_i == RUN || (spi_mode_i == WAIT && !spiswai_i)))
	begin
		if(send_data_i)
			rcv <= 1'b0;  
		else
		begin
			if(count == target-1'b1)
			rcv <= 1'b1; //set receive data to high after 31st clock cycles and when send_data is 0.
			else
			rcv <= 1'b0;
		end
	end
	else
		rcv <= 1'b0;
end

endmodule
