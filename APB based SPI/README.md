APB-Interfaced SPI Core — RTL Design \& UVM Verification 

•	Designed a single-master, single-slave SPI controller RTL with an APB register interface (control, baud-rate, status, and data registers) supporting all 4 CPOL/CPHA modes, LSB/MSB-first shifting, and a configurable baud-rate generator with Run/Wait/Stop power modes.

•	Built a dual-agent UVM environment (independent APB-master and SPI-slave agents, each with its own driver/monitor/sequencer) with a scoreboard cross-checking MOSI/MISO data; verified APB SETUP/ACCESS behavior (PSEL, PENABLE, PREADY, PSLVERR) via SVA across 11 directed tests (CPOL/CPHA/bit-order, reset, low-power, corner cases).



