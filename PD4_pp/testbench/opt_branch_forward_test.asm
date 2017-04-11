# test whether branches are able to skip over a block of code,
# and how rescheduling handles that order

        addi $1, $0, 1000
        addi $2, $0, 100
        bne $1, $2, jump1

        addi $1, $0, -10
        addi $2, $0, -10

jump1:  addi $3, $1, $2
        beq $1, $2, jump2
        addi $4, $1, 1000


jump2:  addi $5, $4, 10
        addi $6, $2, 1000

EoP:    beq $0, $0, EoP


# registers should be
#   $1 = 1000
#   $2 = 100
#   $3 = 1100
#   $4 = 2000
#   $5 = 2010
#   $6 = 1100
