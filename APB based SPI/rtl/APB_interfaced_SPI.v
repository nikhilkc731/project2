//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:28:30 02/13/2026 
// Design Name: 
// Module Name:    APB_interfaced_SPI 
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
module APB_interfaced_SPI(
    input PCLK,
    input PRESET_n,
    input [2:0] PADDR,
    input PWRITE,
    input PSEL,
    input PENABLE,
    input [7:0] PWDATA,
    input miso,
    output ss,
    output sclk,
    output spi_interrupt_request,
    output mosi,
    output [7:0] PRDATA,
    output PREADY,
    output PSLVERR
    );
	 
wire receive_data_w,tip_w,mstr_w,cpol_w,cpha_w,lsbfe_w,spiswai_w,send_data_w,miso_receive_sclk_w,miso_receive_sclk0_w,mosi_send_sclk_w,mosi_send_sclk0_w;
wire [2:0] sppr_w,spr_w;
wire [7:0] mosi_data_w,miso_data_w;
wire [11:0] BaudRateDivisor_w;
wire [1:0] spi_mode_w;

APB_slave_interface sb4 (PCLK,PRESET_n,PADDR,PWRITE,PSEL,PENABLE,PWDATA,ss,miso_data_w,receive_data_w,tip_w,PRDATA,mstr_w,cpol_w,cpha_w,lsbfe_w,spiswai_w,sppr_w,spr_w,spi_interrupt_request,PREADY,PSLVERR,send_data_w,mosi_data_w,spi_mode_w);
Baud_rate_generator sb1 (PCLK,PRESET_n,spi_mode_w,spiswai_w,sppr_w,spr_w,cpol_w,cpha_w,ss,sclk,miso_receive_sclk_w,miso_receive_sclk0_w,mosi_send_sclk_w,mosi_send_sclk0_w,BaudRateDivisor_w);
SPI_slave_control_select sb2 (PCLK,PRESET_n,mstr_w,spiswai_w,spi_mode_w,send_data_w,BaudRateDivisor_w,receive_data_w,ss,tip_w);
Shift_register sb3 (PCLK,PRESET_n,ss,send_data_w,lsbfe_w,cpha_w,cpol_w,BaudRateDivisor_w,miso_receive_sclk_w,miso_receive_sclk0_w,mosi_send_sclk_w,mosi_send_sclk0_w,mosi_data_w,miso,receive_data_w,mosi,miso_data_w);
endmodule
