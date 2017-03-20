proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/processor_tb/clock
    add wave -position end sim:/processor_tb/s_reset
}

vlib work

;# Compile components if any
vcom instruction_fetch.vhd
vcom instruction_memory.vhd
vcom if_id_reg.vhd
vcom register_file.vhd
vcom register_controller.vhd
vcom id_ex_reg.vhd
vcom alu.vhd
vcom alu_control.vhd
vcom execution.vhd
vcom ex_mem_reg.vhd
vcom data_memory.vhd
vcom mem_wb_reg.vhd
vcom write_back.vhd
vcom processor.vhd
vcom processor_tb.vht


;# Start simulation
vsim processor_tb

;# Generate a clock with 1ns period
force -deposit clock 0 0 ns, 1 1 ns -repeat 1 ns

;# Add the waves
AddWaves

;# Run for 2000 ns
run 10000ns
