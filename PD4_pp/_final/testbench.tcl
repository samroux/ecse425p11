proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/processor_tb/clock
    add wave -position end sim:/processor_tb/s_reset
    add wave -position end sim:/processor_tb/dut/EX/branch_taken_EX
    add wave -position end sim:/processor_tb/dut/I_F/branch_taken
    add wave -position end sim:/processor_tb/dut/I_F/branch_address
	add wave -position end sim:/processor_tb/dut/H_D_F/FWD_REQUIRED
	add wave -position end sim:/processor_tb/dut/I_D/hazard_detected
    add wave -position end sim:/processor_tb/dut/I_F/IR 
    add wave -position end sim:/processor_tb/dut/I_D/IR_IF
    add wave -position end sim:/processor_tb/dut/I_D/IR_ID
    add wave -position end sim:/processor_tb/dut/EX/inst 
    add wave -position end sim:/processor_tb/dut/EX/IR_EX
    add wave -position end sim:/processor_tb/dut/MEM/IR_in
    add wave -position end sim:/processor_tb/dut/MEM/IR_out
    add wave -position end sim:/processor_tb/dut/WB/IR_reg
    add wave -position end sim:/processor_tb/dut/I_F/PC 
    add wave -position end sim:/processor_tb/dut/I_D/PC_IF
    add wave -position end sim:/processor_tb/dut/I_D/PC_ID
    add wave -position end sim:/processor_tb/dut/EX/PC_ID_EX
    add wave -position end sim:/processor_tb/dut/EX/PC_EX 
    add wave -position end sim:/processor_tb/dut/MEM/PC_in
    add wave -position end sim:/processor_tb/dut/I_D/A 
    add wave -position end sim:/processor_tb/dut/I_D/B 
    add wave -position end sim:/processor_tb/dut/I_D/Imm 
    add wave -position end sim:/processor_tb/dut/EX/rs_from_ID
    add wave -position end sim:/processor_tb/dut/EX/rt_from_ID
    add wave -position end sim:/processor_tb/dut/EX/imm_sign_ext
    add wave -position end sim:/processor_tb/dut/EX/ALUOutput
    add wave -position end sim:/processor_tb/dut/MEM/ALUOutput
    add wave -position end sim:/processor_tb/dut/MEM/ALUOutput_out
    add wave -position end sim:/processor_tb/dut/WB/ALUOutput
    add wave -position end sim:/processor_tb/dut/WB/WB_output
    add wave -position end sim:/processor_tb/dut/WB/WB_dest_reg
    add wave -position end sim:/processor_tb/dut/I_D/WB_return
    add wave -position end sim:/processor_tb/dut/I_D/WB_addr
    add wave -position end sim:/processor_tb/dut/I_D/reg_write_input
    add wave -position end sim:/processor_tb/dut/I_D/reg_write_addr
    add wave -position end sim:/processor_tb/dut/MEM/MemRead
    add wave -position end sim:/processor_tb/dut/MEM/MemWrite
    add wave -position end sim:/processor_tb/dut/MEM/LMD
    add wave -position end sim:/processor_tb/dut/I_F/write_to_files
    add wave -position end sim:/processor_tb/dut/I_D/write_to_file 
    add wave -position end sim:/processor_tb/dut/MEM/write_to_file 
}

vlib work

;# Compile components if any
vcom instruction_fetch.vhd
vcom instruction_memory.vhd
vcom if_id_reg.vhd
vcom register_file.vhd
vcom register_controller.vhd
vcom hazard_detection_fwd.vhd
vcom id_ex_reg.vhd
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

;# Run for 100 ns
run 50ns
