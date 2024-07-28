/*********************************************************************
* Description:
* This project demonstrates how to program the PIC32 microcontroller so as to show the state of a switch (attached to the RB0 pin) on an LED (attached to the RB8 pin), in real time.
********************************************************************/
#include <xc.h>
#include "configbits.c"
.global main
.data
    firstVar:
    .word 0x00000166,0x0000013f,0x00000106,0x00000106,0x0000013f,0x00000106,0x0000016d,0x0000016f,0x0000015b
    limit:
    .word 400000
.text     
.ent main
   
main:    
la $8, ANSELB
sw $0, 0($8)
la $8, TRISB
ori $9, $0, 0x0000
sw $9, 0($8)
la $10, PORTB
la $11, LATB
    
and $4,$0,$0 //counter1
lw $5,limit //1000000 
and $3,$0,$0 //counter2 : count to 8
ori $14,$0,0x000a    
la $12,firstVar //12 : s[0]    
    
loop:
bne $4,$5,notreset
and $6,$0,$0    
beq $4,$5,reset

j loop
reset:
and $4,$0,$0 //counter to next digit    
beq $6 ,$5,notreset //delay to show   
addi $6,$6,0x0001 //counter1
ori $2,$0,0x0004 
ori $15,$0,0x0001    
subu $16,$3,$15 //counter2-1   
mult $16,$2  //*4 for address
mflo $15    
addu $13,$12,$15    
lw $8,0($13)
sw $8, 0($10)    
j reset
notreset:
addi $4,$4,0x0001
beq $4,$5,counter2    
j loop   
counter2:
addi $3,$3,0x0001 //next digit
bne $3,$14,loop  
lw $3,0x0000    
j loop  

   
.end main