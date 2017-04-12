# simple loop: test branches without data hazards

        addi $1, $0, 1  # initial value
        addi $2, $0, 1  # loop counter
        addi $3, $0, 5  # number of times the loop should be executed

        add $0, $0, $0
        add $0, $0, $0
        add $0, $0, $0
        add $0, $0, $0
        add $0, $0, $0

loop:   addi $1, $1, 10
        addi $2, $2, 1

        add $0, $0, $0
        add $0, $0, $0
        add $0, $0, $0
        add $0, $0, $0
        add $0, $0, $0

        bne $2, $3, loop


        add $0, $0, $0
        add $0, $0, $0
        add $0, $0, $0
        add $0, $0, $0
        add $0, $0, $0

EoP:    beq $0, $0, EoP
