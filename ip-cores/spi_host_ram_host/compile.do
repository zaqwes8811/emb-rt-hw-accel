#http://users.ece.cmu.edu/~jhoe/doku/doku.php?id=a_short_intro_to_modelsim_verilog_simulator


vlog *.v

vsim -L work -t ns work.in_fsm_testbench
add wave -radix unsigned * 
run 80