# this program is a companion to opt_branch_test.asm
# it contains an unrolled loop version of that file

# this program should be tested with and without rescheduling to
# determine how many stalls are saved

        addi $1, $0, 0  # test reg
        addi $2, $0, 50 # factor reg
        addi $10, $0, 0 # counter
        addi $11, $0, 2 # iterations
        addi $12, $0, 2 # multiplier
        mult $11, $12
        mflo $11        # loop iterates 2*2 = 4 times

loop:   add $1, $1, $2  # loop 1
        addi $11, $11, -1
        andi $5, $1, 100
        ori  $6, $1, 100
        xori $7, $2, 50

        add $1, $1, $2  # loop 2
        addi $11, $11, -1
        andi $5, $1, 100
        ori  $6, $1, 100
        xori $7, $2, 50

        add $1, $1, $2  # loop 3 
        addi $11, $11, -1
        andi $5, $1, 100
        ori  $6, $1, 100
        xori $7, $2, 50

        add $1, $1, $2  # loop 4
        addi $11, $11, -1
        andi $5, $1, 100
        ori  $6, $1, 100
        xori $7, $2, 50

        bne $11, $1, loop

        sw $1, 0($9)
        addi $1, $1, 1000

EoP:    beq $0, $0, EoP
