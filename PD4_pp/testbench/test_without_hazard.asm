	
	addi $1, $0, 1
	
	addi $2, $0, 5
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	add $1, $1, $2 
	
	addi $3, $0, 3
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	sub $2, $2, $3
	
	addi $3, $0, 3
	
	addi $4, $0, 2
	
	addi $5, $0, 2
	
	mult $4, $5
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	mflo $4
	
	addi $6, $0, 10
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	div $6, $5
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	mflo $5 
	
	slt $6, $2, $1
	
	slti $7, $3, 4
	
	and $8, $1, $2
	
	or $9, $1, $2
	
	nor $10, $0, $0
	
	xor $11, $1, $2
	
	andi $12, $6, 3
	
	ori $13, $1, 1
	
	xori $14, $4, 7
	
	div $5, $4
	
	mfhi $15
	
	mflo $16
	
	lui $17, 4097
	
	addi $22, $0, 53
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	add $0, $0, $0
	
	add $0, $0, $0

	sll $18, $22, 2
	
	srl $19, $22, 2
	
	sra $20, $22, 2
	
	#;testing arithmetic, logical, transfer and shift
	#;without hazard
	#;by adding 5 empty clock cycle
	#;20 functions are tested
	#;registers from $1 to $20, 
	#;corresponding to the output of each functions
	#;if correctness
	#;output of registers should be
	#;6,2,3,4,5
	#;1,1,2,6,0x11111111
	#;4,1,7,3,1
	#;1,0x10010000,212,13,13
	
	
	
	