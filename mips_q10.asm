ori $2, $0, 0x0002
ori $3, $0, 0x0001
ori $4, $0, 0x0000
ori $7, $0, 0x0020
ori $8, $0, 0x0002
ori $11, $0, 0x0000

lui $10,0x00001001
lw $14,0x00000000($10)

loop:
divu $14,$8
mfhi $9
mflo $14
addu $24,$24,$9
addu $4,$4,$3
beq $4,$7,out
j loop

out:
sw $24, 0x00000010($10)