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
	@$(CC) -o ./run/simple_dds.tb $(TB_FOLDER)/simple_dds_tb.v $(RTL_FOLDER)/simple_dds.v;
	@cd ./run && $(CCR) simple_dds.tb | tee ../log/simple_dds_log_$$(date +%Y%m%d%H%M%S).tb;

wave_simple_dds: simple_dds
	@gtkwave out/wave_simple_dds.vcd

clean:
	@rm -rf log/*.tb log/*.vcd
	@rm -rf run/*.tb run/*.vcd
	@rm -rf out/*.tb out/*.vcd

