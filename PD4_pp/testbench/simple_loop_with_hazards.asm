# simple loop with hazards : test branches with data hazards

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

        addi $2, $2, 50 # should be ignored until the loop is done

EoP:    beq $0, $0, EoP
