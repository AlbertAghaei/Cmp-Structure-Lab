ori $2, $0, 0x0004
ori $3, $0, 0x0008
ori $4, $0, 0x0000
ori $7, $0, 0x000a
ori $8, $0, 0x0002
ori $11, $0, 0x0000

lui $10,0x00001001
lw $5,0x00000000($10)

loop:
divu $5,$7
mfhi $9
mflo $5
sllv $9,$9,$11
addu $15,$15,$9
addu $11,$11,$2
addi $4, $4,1
beq $4,$3,out
j loop

out:
sw $15, 0x00000010($10)