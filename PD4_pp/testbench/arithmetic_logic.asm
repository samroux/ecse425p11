	addi $1, $0, 0

	addi $2, $0, 3

	addi $3, $0, 5

	addi $4, $0, 3

	addi $5, $0, 2
	
	addi $6, $0, 4
	
	addi $7, $0, 8
	
	addi $8, $0, 4

	bne $1, $2, arithmetic
	
	j error
	
arithmetic:	add $1, $1, $2 

			sub $3, $3, $4
			
			mult $5, $6
			
			mflo $5
			
			div $7, $8
			
			mflo $7
			
			slt $1, $3, $5
			
			slti $2, $1, 2
			
			addi $4, $0, 1
			
			beq $2, $4, logical
			
			j error
			
logical:	or $8, $6, $1

			or $7, $2, $3
			
			and $5, $8, $7
			
			nor $4, $8, $7
			
			xor $6, $8, $7
			
			andi $1, $7, 2
			
			ori $2, $8, 1
			
			xori $3, $8, 1
			
			bne $8, $2, error
			
			addi $1, $1, 1
			
			bne $7, $1, error
			
			slt $4, $5, $4
			
			addi $3, $3, 2
			
			bne $6, $3, error
			
			j end
			
error: 		addi $1, $0, 1

end: 		addi $5, $0, 128