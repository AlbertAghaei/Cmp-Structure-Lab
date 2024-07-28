lui $1,0x00001001
lw $2,0x00000000($1)
lw $3,0x00000004($1)
lw $4,0x00000008($1)
lw $5,0x0000000C($1) 
multu $4,$2
mflo $6 #$6 is the first
mfhi $7
multu $4,$3
mflo $8
mfhi $9
multu $5,$2
mflo $10
mfhi $11
multu $5,$3
mflo $12
mfhi $13

addu $14,$7,$8 
sltu $15,$14,$7
addu $16,$14,$10 #$16 is the second
sltu $17,$16,$10
addu $18,$17,$15 #$18 is second for third carry

addu $19,$11,$9 
sltu $20,$19,$9
addu $21,$19,$12 
sltu $22,$21,$12
addu $23,$22,$20 
addu $24,$21,$18 #$24 is the third
sltu $25,$24,$21
addu $26,$23,$25 #$26 is thired for forth carry

addu $27,$13,$26 #$27 is the forth

sw $6, 0x00000010($1)
sw $16, 0x00000014($1)
sw $24, 0x00000018($1)
sw $27, 0x0000001C($1)



