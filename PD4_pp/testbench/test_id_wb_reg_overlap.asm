# test concurrent write and read in ID

	addi $1, $0, 50
	
	add $0, $0, $0
	add $0, $0, $0
	add $0, $0, $0
	
	add $3, $0, $1
	
#loop: beq $0, $0, loop
