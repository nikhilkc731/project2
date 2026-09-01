#Makefile for UVM Testbench - Lab 06

# SIMULATOR = Questa for Mentor's Questasim
# SIMULATOR = VCS for Synopsys's VCS

SIMULATOR = VCS

FSDB_PATH=/home/cad/eda/SYNOPSYS/VERDI_2022/verdi/T-2022.06-SP1/share/PLI/VCS/LINUX64

RTL= ../rtl/*
work= work #library name
SVTB1= ../tb/top.sv
INC = +incdir+../tb +incdir+../test +incdir+../APB_master_agent +incdir+../SPI_slave_agent 
SVTB2 = ../test/test_pkg.sv
VSIMOPT= -vopt -voptargs="+acc -assertdebug"
VSIMCOV= -coverage -sva 

VSIMBATCH = -c -do "log -r /*; assertion pass -recursive /top/*; assertion fail -recursive /top/*; coverage save -onexit cov; run -all; exit"
VSIMBATCH1= -c -do "log -r /*; assertion pass -recursive /top/*; assertion fail -recursive /top/*; coverage save -onexit cov1; run -all; exit"
VSIMBATCH2= -c -do "log -r /*; assertion pass -recursive /top/*; assertion fail -recursive /top/*; coverage save -onexit cov2; run -all; exit"
VSIMBATCH3= -c -do "log -r /*; assertion pass -recursive /top/*; assertion fail -recursive /top/*; coverage save -onexit cov3; run -all; exit"
VSIMBATCH4= -c -do "log -r /*; assertion pass -recursive /top/*; assertion fail -recursive /top/*; coverage save -onexit cov4; run -all; exit"
VSIMBATCH5= -c -do "log -r /*; assertion pass -recursive /top/*; assertion fail -recursive /top/*; coverage save -onexit cov5; run -all; exit"
VSIMBATCH6= -c -do "log -r /*; assertion pass -recursive /top/*; assertion fail -recursive /top/*; coverage save -onexit cov6; run -all; exit"
VSIMBATCH7= -c -do "log -r /*; assertion pass -recursive /top/*; assertion fail -recursive /top/*; coverage save -onexit cov7; run -all; exit"
VSIMBATCH8= -c -do "log -r /*; assertion pass -recursive /top/*; assertion fail -recursive /top/*; coverage save -onexit cov8; run -all; exit"
VSIMBATCH9= -c -do "log -r /*; assertion pass -recursive /top/*; assertion fail -recursive /top/*; coverage save -onexit cov9; run -all; exit"
VSIMBATCH10= -c -do "log -r /*; assertion pass -recursive /top/*; assertion fail -recursive /top/*; coverage save -onexit cov10; run -all; exit"

help:
	@echo =============================================================================================================
	@echo "! USAGE   	--  make target                             										!"
	@echo "! clean   	=>  clean the earlier log and intermediate files.       								!"
	@echo "! sv_cmp    	=>  Create library and compile the code.                   								!"
	@echo "! run_test	=>  clean, compile & run the simulation for ram_signle_adddr_test in batch mode.		!" 
	@echo "! run_test1	=>  clean, compile & run the simulation for ram_ten_addr_test in batch mode.			!" 
	@echo "! run_test2	=>  clean, compile & run the simulation for ram_odd_addr_test in batch mode.			!"
	@echo "! run_test3	=>  clean, compile & run the simulation for ram_even_addr_test in batch mode.		!" 
	@echo "! view_wave1 =>  To view the waveform of ram_signle_addr_test                                                    !"
	@echo "! view_wave2 =>  To view the waveform of ram_ten_addr_test                                                       !" 
	@echo "! view_wave3 =>  To view the waveform of ram_odd_addr_test                                                       !" 
	@echo "! view_wave4 =>  To view the waveform of ram_even_addr_test                                                      !" 
	@echo ====================================================================================================================

clean : clean_$(SIMULATOR)
sv_cmp : sv_cmp_$(SIMULATOR)
run_reset : run_reset_$(SIMULATOR)
run_test1 : run_test1_$(SIMULATOR)
run_test2 : run_test2_$(SIMULATOR)
run_test3 : run_test3_$(SIMULATOR)
view_wave1 : view_wave1_$(SIMULATOR)
view_wave2 : view_wave2_$(SIMULATOR)
view_wave3 : view_wave3_$(SIMULATOR)
view_wave4 : view_wave4_$(SIMULATOR)

# ----------------------------- Start of Definitions for Mentor's Questa Specific Targets -------------------------------#

sv_cmp_Questa:
	vlib $(work)
	vmap work $(work)
	vlog -work $(work) -cover sbcef $(RTL) $(INC) $(SVTB2) $(SVTB1) 	

run_ct_Questa: clean sv_cmp_Questa
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH10)  -wlf wave_ct.wlf -l ct_test.log  -sv_seed random work.top +UVM_TESTNAME=corner_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html cov10

run_lp_Questa: clean sv_cmp_Questa
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH9)  -wlf wave_lp.wlf -l lptest.log  -sv_seed random work.top +UVM_TESTNAME=low_power_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html cov9

run_reset_Questa: clean sv_cmp_Questa
	vsim  -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH)  -wlf wave.wlf -l test.log  -sv_seed 4249856925 work.top +UVM_TESTNAME=reset_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html cov0

run_test1_Questa: clean sv_cmp_Questa
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH1)  -wlf wave1.wlf -l test1.log  -sv_seed 1701173238  work.top +UVM_TESTNAME=cpha1_cpol1_lsb_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html cov1

run_test2_Questa: clean sv_cmp_Questa
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH2)  -wlf wave2.wlf -l test2.log  -sv_seed 709218636  work.top +UVM_TESTNAME=cpha0_cpol0_lsb_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html cov2

run_test3_Questa: clean sv_cmp_Questa
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH3)  -wlf wave3.wlf -l test3.log  -sv_seed 1392890260  work.top +UVM_TESTNAME=cpha0_cpol1_lsb_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html cov3

run_test4_Questa: clean sv_cmp_Questa
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH4)  -wlf wave4.wlf -l test4.log  -sv_seed 1403375676  work.top +UVM_TESTNAME=cpha1_cpol0_lsb_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html cov4

run_test5_Questa: clean sv_cmp_Questa
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH5)  -wlf wave5.wlf -l test5.log  -sv_seed 1659229092  work.top +UVM_TESTNAME=cpha1_cpol1_msb_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html cov5

run_test6_Questa: clean sv_cmp_Questa
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH6)  -wlf wave6.wlf -l test6.log  -sv_seed 455463596  work.top +UVM_TESTNAME=cpha0_cpol0_msb_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html cov6

run_test7_Questa: clean sv_cmp_Questa
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH7)  -wlf wave7.wlf -l test7.log  -sv_seed 1267064340  work.top +UVM_TESTNAME=cpha0_cpol1_msb_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html cov7

run_test8_Questa: clean sv_cmp_Questa
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH8)  -wlf wave8.wlf -l test8.log  -sv_seed 392552156  work.top +UVM_TESTNAME=cpha1_cpol0_msb_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html cov8

clean_Questa:
	rm -rf transcript* *log* fcover* covhtml* cov* *.wlf modelsim.ini work
	clear

regress_Questa: run_reset_Questa run_test1_Questa run_test2_Questa run_test3_Questa run_test4_Questa run_test5_Questa run_test6_Questa run_test7_Questa run_test8_Questa report_Questa cov_Questa

report_Questa:
	vcover merge cov.ucdb cov_generated.ucdb  cov0 cov1 cov2 cov3 cov4 cov5 cov6 cov7 cov8
	vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html cov.ucdb

cov_Questa:
	firefox covhtmlreport/index.html&

view_wave1_Questa: 
	vsim -view wave.wlf

view_wave2_Questa: 
	vsim -view wave1.wlf

view_wave3_Questa: 
	vsim -view wave2.wlf

view_wave4_Questa: 
	vsim -view wave3.wlf






# ----------------------------- End of Definitions for Mentor's Questa Specific Targets -------------------------------#

# ----------------------------- Start of Definitions for Synopsys's VCS Specific Targets -------------------------------#

sv_cmp_VCS:
	vcs -l vcs.log -timescale=1ns/1ps -sverilog -ntb_opts uvm -debug_access+all -full64 -kdb -lca -P $(FSDB_PATH)/novas.tab $(FSDB_PATH)/pli.a $(RTL) $(INC) $(SVTB2) $(SVTB1) 
	      
run_test_VCS:	clean  sv_cmp_VCS
	./simv -a vcs.log +fsdbfile+wave.fsdb +ntb_random_seed_automatic +UVM_TESTNAME=ram_single_addr_test
	
run_test1_VCS: clean  sv_cmp_VCS	
	./simv -a vcs.log +fsdbfile+wave1.fsdb +ntb_random_seed_automatic +UVM_TESTNAME=ram_ten_addr_test 	
	
run_test2_VCS: clean  sv_cmp_VCS	
	./simv -a vcs.log +fsdbfile+wave2.fsdb +ntb_random_seed_automatic +UVM_TESTNAME=ram_odd_addr_test
	
run_test3_VCS: clean  sv_cmp_VCS	
	./simv -a vcs.log +fsdbfile+wave3.fsdb +ntb_random_seed_automatic +UVM_TESTNAME=ram_even_addr_test 	
	
clean_VCS:
	rm -rf simv* csrc* *.tmp *.vpd *.vdb *.key *.log *hdrs.h *.fsdb verdi*
	clear

view_wave1_VCS: 
	verdi -ssf wave.fsdb
        
view_wave2_VCS: 
	verdi -ssf wave1.fsdb

view_wave3_VCS: 
	verdi -ssf wave2.fsdb

view_wave4_VCS: 
	verdi -ssf wave3.fsdb   

# ----------------------------- END of Definitions for Synopsys's VCS Specific Targets -------------------------------#
