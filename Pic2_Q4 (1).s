#include <xc.h>
#include "configbits.c"
.global main
.data
    firstSeg:
    .word 0x0000013f,0x00000106,0x0000015b,0x0000014f,0x00000166,0x0000016d,0x0000017d,0x00000107,0x0000017f,0x0000016f
    secondSeg:
    .word 0x0000013f,0x00000106,0x0000015b,0x0000014f,0x00000166,0x0000016d
    thirdSeg:
    .word 0x000001bf,0x00000186,0x000001db,0x000001cf,0x000001e6,0x000001ed,0x000001fd,0x00000187,0x000001ff,0x000001ef
    ForthSeg:
    .word 0x0000013f,0x00000106,0x0000015b,0x0000014f,0x00000166,0x0000016d
    limit1:
    .word 100
    limit2:
    .word 20
.text     
.ent main
   
main:    
la $8, ANSELB
sw $0, 0($8)
la $8, TRISB
ori $9, $0, 0x0000
sw $9, 0($8)
la $11, LATB
    
and $5,$0,$0 //counter delay
lw  $6,limit1 
lw  $22,limit2    
and $1,$0,$0 //counter1 : count to 9
ori $18,$0,0x000a  
and $2,$0,$0 //counter2 : count to 5
ori $30,$0,0x0006   
and $3,$0,$0 //counter3 : count to 9
ori $29,$0,0x000a  
and $4,$0,$0 //counter4 : count to 5
ori $28,$0,0x0006 
la $24,firstSeg //12 : s[0] 
la $25,secondSeg//19 : s[1]
la $26,thirdSeg//20 : s[2]
la $27,ForthSeg//19 : s[1]

 

addi $8, $0, 0x0064 //different digits
addi $17, $0, 0x0000 //differents counter  

//ori $18,$0,0x0000 //counter state
//ori $19,$0,0x0009
//ori $22,$0,0x0024//shutdown 
ori $23,$0,0x0000 //shutdown counter 
   
loop: //cornometer     
lw $20, 0x0($24)
addi $21, $20, 0x1000
sw $21, 0($11)//digit2 shown
bne $17,$8,counter1 
digit2:  
lw $20, 0x0($25)
addi $21, $20, 0x0100
sw $21, 0($11)////digit1 shown
bne $17,$8,counter2
digit3:    
lw $20, 0x0($26)
addi $21, $20, 0x0300
sw $21, 0($11)//digit3 shown
bne $17,$8,counter3
digit4:    
lw $20, 0x0($27)
addi $21, $20, 0x0700
sw $21, 0($11)//digit4 shown
bne $17,$8,counter4    
j loop   
counter1:
addi $17, $17, 0x0001    
bne $17, $8, counter1
addi $17, $0,0x0000
j digit2 
counter2:
addi $17, $17, 0x0001    
bne $17, $8, counter2
addi $17, $0 ,0x0000
j digit3
counter3:
addi $17, $17, 0x0001    
bne $17, $8, counter3
addi $17, $0, 0x0000
j digit4
counter4:
addi $17, $17, 0x0001    
bne $17, $8, counter4
addi $17, $0 ,0x0000
addi $5,$5,0x0001
bne $5,$6,loop
j rest
rest:
and $5,$5,$0
sw $0, 0($11)
addi $23,$23,0x0001
bne $23,$22,rest
j nextsecond
nextsecond:
and $23,$23,$0
addi $1,$1,0x1
beq $1,$18,decimal
addi $24,$24,0x0004
j loop
decimal:
and $1,$1,$0
la $24,firstSeg
addi $2,$2,0x1
beq $2,$30,minute
addi $25,$25,0x0004
j loop
minute:
and $2,$2,$0
la $25,secondSeg
addi $3,$3,0x1
beq $3,$29,minutedecimal
addi $26,$26,0x0004    
j loop
minutedecimal:
and $3,$3,$0
la $26,thirdSeg
addi $4,$4,0x1
beq $4,$28,resetcorn
addi $27,$27,0x0004    
j loop
resetcorn:
and $4,$4,$0
la $24,firstSeg //12 : s[0] 
la $25,secondSeg//19 : s[1]
la $26,thirdSeg//20 : s[2]
la $27,ForthSeg//19 : s[1]
j loop
    
    .end main