# This program is used in conjunction with the register_controller test bench.
# It is used to supply compiled versions of test instructions.

    addi    $11, $0,  5
    addi    $12, $0,  6
    add     $2,  $11, $12
    lw      $3,  4($0)

loop:   addi $4, $3, $11
    beq     $4,  $4, loop
