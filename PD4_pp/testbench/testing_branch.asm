    addi $1, $0, 0

    addi $2, $0, 5

    addi $3, $0, 0 

    addi $4, $0, 0

    addi $5, $0, 0

    bne $1, $2, loop1 

    j error

  

loop1:  addi $1, $1, 1 

        bne $1, $2, loop1 

        addi $3, $3, 1 

        addi $1, $0, 0

        beq $1, $2, error 

        addi $2, $0, 10

        bne $1, $2, loop2 

        j error

        

loop2:  addi $1, $1, 1 

        beq $1, $2, final 

        bne $1, $2, loop2 

        j error

        

final:  addi $1, $0, 20

        beq $1, $2, error 

        addi $1, $0, 21

        beq $1, $2, error 

        addi $1, $0, 22

        beq $1, $2, error 

        addi $1, $0, 23

        beq $1, $2, error 

        addi $1, $0, 24

        beq $1, $2, error 

        addi $1, $0, 25

        beq $1, $2, error 

        bne $1, $2, end 

        j error

        

error: addi $4, $0, 1  

    

end: addi $5, $0, 128
   