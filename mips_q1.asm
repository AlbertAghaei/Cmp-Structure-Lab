lui $1,0x00001001
lw $8,0x00000000($1)
lw $9,0x00000004($1)
lw $10,0x00000008($1)
lw $11,0x0000000C($1)
addu $12, $8, $10
add $13, $9, $11
sltu $14, $12, $8
add $13, $13, $14 
sw $12, 0x00000010($1)
sw $13, 0x00000014($1)