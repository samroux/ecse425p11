# program used to test static rescheduling. 
# modified version of opt_branch_test.asm

# branching is a special case -- the program flow should be conserved 
# by conserving the branch's location and the address it points to

# this program should be tested with and without rescheduling to
# determine how many stalls are saved

# *** hazard detection has a critical bug when it comes to hazards and
# *** forwarding when >2 insts are involved. see the report for details.
# *** unfortunately, removing those insts prevents us from using the scheduler
# *** to its full extent.
# *** there also seems to be problems with branch stall and hazard detection
# *** coexistence.

        addi $1, $0, 0  # test reg
        addi $2, $0, 50 # factor reg
        addi $10, $0, 0 # counter
        addi $11, $0, 4 # iterations

loop:   add $1, $1, $2  # add 50 to $1
        addi $11, $11, -1
        
        # padding -- is indep of the main loop logic
        # should still remain inside it
        andi $5, $1, 100
        ori  $6, $1, 100
        xori $7, $2, 50
        bne $11, $1, loop

        sw $1, 0($9)
        addi $1, $1, 1000

EoP:    beq $0, $0, EoP
