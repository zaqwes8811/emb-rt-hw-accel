

all:
	vlog fsm/*.v

vsim: all
	#vsim -c -do "run 1000000" sum_tb
	vsim sum_tb

init:
	vlib work