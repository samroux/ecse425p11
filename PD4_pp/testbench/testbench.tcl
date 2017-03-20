proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/processor_tb/clock
    add wave -position end sim:/processor_tb/s_reset
}

vlib work

;# Compile components if any
vcom processor_tb.vht
vcom processor.vhd
vcom instruction_fetch.vhd
vcom instruction_memory.vhd
vcom if_id_reg.vhd
vcom register_controller.vhd
vcom register_file.vhd
vcom id_ex_reg.vhd
vcom execute.vhd
vcom alu.vhd
vcom alu_control.vhd
vcom control_unit.vhd
vcom ex_mem_reg.vhd
vcom data_memory.vhd
vcom mem_wb_reg.vhd
vcom write_back.vhd

;# Start simulation
vsim processor_tb

;# Generate a clock with 2ns period
force -deposit clk 0 0 ns, 1 1 ns -repeat 2 ns

;# Add the waves
AddWaves

;# Run for 2000 ns
run 2000ns
