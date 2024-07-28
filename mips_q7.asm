ori $2, $0, 0x0001
ori $3, $0, 0x0008
ori $4, $0, 0x0000
ori $7, $0, 0x000a

lui $10,0x00001001
lw $5,0x00000000($10)

loop:
andi $6, $5, 0x000f 
multu  $6,$2
mflo $14
addu $15,$15,$14
srl $5, $5, 4 
mult $2,$7
mflo $2
addi $4, $4,1
beq $4,$3,out
j loop

out:
sw $15, 0x00000010($10)

