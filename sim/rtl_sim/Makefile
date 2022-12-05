# Makefile for the simple_dds core. Handles testbench and linting.
# Author: Patrick Hoey


SHELL=bash
CC=iverilog
CCR=vvp

RTL_FOLDER=$(shell cd ../../rtl/verilog; pwd)
TB_FOLDER=$(shell cd ./src; pwd)


all: simple_dds

lint_all: lint_simple_dds

lint_simple_dds:
	@verilator --lint-only --Wall $(RTL_FOLDER)/simple_dds && echo "LINT: OK"

simple_dds:
	@$(CC) -o ./run/simple_dds.tb $(TB_FOLDER)/simple_dds_tb.v $(RTL_FOLDER)/simple_dds.v $(RTL_FOLDER)/dds_core.v $(RTL_FOLDER)/sine_lut.v $(RTL_FOLDER)/tri_lut.v $(RTL_FOLDER)/saw_lut.v $(RTL_FOLDER)/lfsr.v;
		@cd ./run && $(CCR) simple_dds.tb | tee ../log/simple_dds_log_$$(date +%Y%m%d%H%M%S).tb;

wave_simple_dds: simple_dds
	@gtkwave out/wave_simple_dds.vcd

lint_lfsr:
	@verilator --lint-only --Wall $(RTL_FOLDER)/lfsr && echo "LINT: OK"

lfsr:
	@$(CC) -o ./run/lfsr.tb $(TB_FOLDER)/lfsr_tb.v $(RTL_FOLDER)/lfsr.v
	@cd ./run && $(CCR) lfsr.tb | tee ../log/lfsr_log_$$(date +%Y%m%d%H%M%S).tb;

wave_lfsr: lfsr
	@gtkwave out/wave_lfsr.vcd



clean:
	@rm -rf log/*.tb log/*.vcd
	@rm -rf run/*.tb run/*.vcd
	@rm -rf out/*.tb out/*.vcd

