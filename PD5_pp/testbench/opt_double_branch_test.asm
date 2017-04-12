# test two successive branches

        addi $1, $0, 50
        addi $5, $0, 2
        addi $6, $0, 3

loop1:  add $2, $1, $1
        add $2, $2, $1
        add $2, $2, $2
        sw $2, 0($15)
        addi $5, $5, -1
        bne $5, $0, loop1

loop2:  add $3, $1, $1
        add $3, $3, $1
        add $3, $3, $3
        sw $3, 0($16)
        addi $6, $6, -1
        bne $6, $0, loop2

        addi $10, $0, 1000

EoP:    beq $0, $0, EoP
