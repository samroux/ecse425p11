# the same program used to test the functionality of optimization,
# (test_optimization.asm)
# but with an infinite loop at the end, now that branches are 
# compatible with scheduling.

lw $1, 0($0)
lw $2, 4($0)
add $3, $1, $2
sw $3, 12($0)
lw $4, 8($0)
add $3, $1, $4
sw $3, 16($0)

EoP: beq $0, $0, EoP
