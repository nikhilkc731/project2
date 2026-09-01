//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:39:20 02/11/2026 
// Design Name: 
// Module Name:    APB_slave_interface 
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
module APB_slave_interface(
    input PCLK,
    input PRESET_n,
    input [2:0] PADDR_i,
    input PWRITE_i,
    input PSEL_i,
    input PENABLE_i,
    input [7:0] PWDATA_i,
    input ss_i,
    input [7:0] miso_data_i,
    input receive_data_i,
    input tip_i,
    output reg [7:0] PRDATA_o,
    output mstr_o,
    output cpol_o,
    output cpha_o,
    output lsbfe_o,
    output spiswai_o,
    output [2:0] sppr_o,
    output [2:0] spr_o,
    output reg spi_interrupt_request_o,
    output PREADY_o,
    output PSLVERR_o,
    output reg send_data_o,
    output reg [7:0] mosi_data_o,
    output reg [1:0]spi_mode_o
    );

parameter CR1_ADDR = 3'b000;
parameter CR2_ADDR = 3'b001;
parameter BR_ADDR = 3'b010;
parameter SR_ADDR = 3'b011;
parameter DR_ADDR = 3'b101;

reg [1:0]apb_current_state, apb_next_state, spi_next_state;

parameter IDLE = 2'b00;
parameter SETUP = 2'b01;
parameter ENABLE = 2'b10;
parameter RUN = 2'b00;
parameter WAIT = 2'b01;
parameter STOP = 2'b10;

reg [7:0]SPI_CR1;
reg [7:0]SPI_CR2;
reg [7:0]SPI_BR;
wire [7:0]SPI_SR;
reg [7:0]SPI_DR;


wire SPIE,SPE,SPTIE,SSOE;
wire MODFEN;
wire SPIF,SPTEF;
wire MODF;

parameter CR2_MASK = 8'b00011011;
parameter BR_MASK = 8'b01110111;

wire rd_en,wr_en;

assign rd_en = (!PWRITE_i && (apb_current_state == ENABLE))? 1'b1 : 1'b0;
assign wr_en = (PWRITE_i && (apb_current_state == ENABLE))? 1'b1 : 1'b0;

assign PREADY_o = (apb_current_state == ENABLE)? 1'b1 : 1'b0;
assign PSLVERR_o = (apb_current_state == ENABLE)? ~tip_i : 1'b0;

always @(*)
begin
	if(rd_en)
	begin
		case(PADDR_i)
		CR1_ADDR : PRDATA_o = SPI_CR1;
		CR2_ADDR : PRDATA_o = SPI_CR2;
		BR_ADDR : PRDATA_o = SPI_BR;
		SR_ADDR : PRDATA_o = SPI_SR;
		DR_ADDR : PRDATA_o = SPI_DR;
		default : PRDATA_o = 8'b0;
		endcase
	end
	else
		PRDATA_o = 8'b0;
end

assign lsbfe_o = SPI_CR1[0];
assign SSOE = SPI_CR1[1];
assign cpha_o = SPI_CR1[2];
assign cpol_o = SPI_CR1[3];
assign mstr_o = SPI_CR1[4];
assign SPTIE = SPI_CR1[5];
assign SPE = SPI_CR1[6];
assign SPIE = SPI_CR1[7];

always @(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		SPI_CR1 <= 8'h04;
	else if(wr_en)
	begin
		if(PADDR_i == CR1_ADDR)
			SPI_CR1 <= PWDATA_i;
		else
			SPI_CR1 <= SPI_CR1;
	end
	else
		SPI_CR1 <= SPI_CR1; //to hold the value
end

assign spiswai_o = SPI_CR2[1];
assign MODFEN = SPI_CR2[4];

always @(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		SPI_CR2 <= 8'h00;
	else if(wr_en)
	begin
		if(PADDR_i == CR2_ADDR)
			SPI_CR2 <= (PWDATA_i & CR2_MASK);
		else
			SPI_CR2 <= SPI_CR2;
	end
	else
		SPI_CR2 <= SPI_CR2;
end

assign sppr_o = SPI_BR[6:4];
assign spr_o = SPI_BR[2:0];

always @(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		SPI_BR <= 8'h00;
	else if(wr_en)
	begin
		if(PADDR_i == BR_ADDR)
			SPI_BR <= (PWDATA_i & BR_MASK);
		else
			SPI_BR <= SPI_BR;
	end
	else
		SPI_BR <= SPI_BR;
end

always @(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		SPI_DR <= 8'b0;
	else if(wr_en)
	begin
		if(PADDR_i == DR_ADDR)
			SPI_DR <= PWDATA_i;
		else
			SPI_DR <= SPI_DR;
	end
	else
	begin
		if((SPI_DR == PWDATA_i) && (SPI_DR != miso_data_i) && ((spi_mode_o == RUN)||((spi_mode_o == WAIT)&&(!spiswai_o))))
		begin
			SPI_DR <= 8'b0;
		end
		else
		begin
			if(receive_data_i && ((spi_mode_o == RUN)||((spi_mode_o == WAIT)&&(!spiswai_o))))
				SPI_DR <= miso_data_i;
			else
				SPI_DR <= SPI_DR;
		end
	end
end

assign SPTEF = (SPI_DR == 8'd0) ? 1'b1 : 1'b0;
assign SPIF = (SPI_DR != 8'd0) ? 1'b1 : 1'b0;

assign SPI_SR = (!PRESET_n) ? 8'h20 : {SPIF,1'b0,SPTEF,MODF,4'b0};

always @(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		send_data_o <= 1'b0;
	else if(wr_en)
		send_data_o <= 1'b0;
	else
	begin
		if((SPI_DR == PWDATA_i)&&(SPI_DR != miso_data_i)&&(SPI_DR != 8'b0)&&((spi_mode_o == RUN)||((spi_mode_o == WAIT)&&(!spiswai_o))))
			send_data_o <= 1'b1;
		else
			send_data_o <= 1'b0;
	end
end

always @(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		mosi_data_o <= 8'b0;
	else if((SPI_DR == PWDATA_i)&&(SPI_DR != miso_data_i)&&((spi_mode_o == RUN)||((spi_mode_o == WAIT)&&(!spiswai_o))))
		mosi_data_o <= SPI_DR;
	else
		mosi_data_o <= mosi_data_o;
end

assign MODF = (!ss_i && mstr_o && MODFEN && !SSOE);

always @(*)
begin
	if(!SPIE && !SPTIE)
		spi_interrupt_request_o = 1'b0;
	else
	begin
		if(!SPTIE && SPIE)
			spi_interrupt_request_o = (SPIF & MODF);
		else
		begin
			if(!SPIE && SPTIE)
				spi_interrupt_request_o = SPTEF;
			else
				spi_interrupt_request_o = (SPIF | MODF | SPTEF);
		end
	end
end

//SPI and ABP FSM sequential logic
always @(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
	begin
		apb_current_state <= IDLE;
		spi_mode_o <= RUN;
	end
	else
	begin
		apb_current_state <= apb_next_state;
		spi_mode_o <= spi_next_state;
	end
end

//APB FSM combinational logic
always @(*)
begin
		case(apb_current_state)
		IDLE : begin
		if(PSEL_i && !PENABLE_i)
			apb_next_state = SETUP;
		else if(PSEL_i && PENABLE_i)
			apb_next_state = ENABLE;
		else
			apb_next_state = IDLE;
			end
		SETUP: begin
		if(PSEL_i && PENABLE_i)
			apb_next_state = ENABLE;
		else if(PSEL_i && !PENABLE_i)
			apb_next_state = SETUP;
		else
			apb_next_state = IDLE;
		end
		ENABLE: begin
		if(PSEL_i && !PENABLE_i)
			apb_next_state = SETUP;
		else if(!PSEL_i)
			apb_next_state = IDLE;
		else
			apb_next_state = ENABLE;
		end
		default: apb_next_state = IDLE;
		endcase
end

//SPI FSM combinational logic
always @(*)
begin
	case(spi_mode_o)
	RUN : begin
	if(!SPE)
		spi_next_state = WAIT;
	else
		spi_next_state = RUN;
	end
	WAIT: begin
		if(SPE && !spiswai_o)
		spi_next_state = RUN;
		else if(SPE && spiswai_o)
		spi_next_state = RUN;
	else if(spiswai_o)
		spi_next_state = STOP;
	else
		spi_next_state = WAIT;
	end
	STOP: begin
	if(SPE)
		spi_next_state  = RUN;
	else if(!spiswai_o)
		spi_next_state = WAIT;
	else
		spi_next_state = STOP;
	end
	default: spi_next_state = RUN;
	endcase
end

endmodule
