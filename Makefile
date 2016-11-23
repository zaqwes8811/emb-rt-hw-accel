all:
	vlog *.v

init:
	vlib work
	#vmap work local_lib

sim:
	vsim -t ns work.test

	# vlog *.v; vsim -t ns work.test; do waves.do

waves:
	echo ""
	# do waves.do