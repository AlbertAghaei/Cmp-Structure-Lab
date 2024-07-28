#include <xc.h>
#include "configbits.c"
    .global main
.data
seg7:
.word 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71,0x3F, 0x06, 0x5B,
array:
    .word 0x66,0x3f,0x06,0x06, 0x3f,0x06,0x06,0x07,0x4F,0x66,0x3f,0x06
limit:
    .word 10000
.text
    
.ent main
 main:
    
la $8, ANSELB
sw $0, 0($8)

la $8, TRISB
ori $9, $0, 0x0000
sw $9, 0($8)
la $11, LATB
    
la $15, array 
addi $8, $0, 0x0064
addi $17, $0, 0x0000   
    
ori $18,$0,0x0000 //counter
ori $19,$0,0x0009
ori $22,$0,0x0024
ori $23,$0,0x0000    
lw  $24,limit    
loop:  // Displaying the id
    
lw $20, 0x0($15)
addi $21, $20, 0x0800
sw $21, 0($11)////digit1 shown
bne $17,$8,counter1    
digit2:  
lw $20, 0x4($15)
addi $21, $20, 0x0400
sw $21, 0($11)//digit2 shown
bne $17,$8,counter2
digit3:    
lw $20, 0x8($15)
addi $21, $20, 0x0200
sw $21, 0($11)//digit3 shown
bne $17,$8,counter3
digit4:    
lw $20, 0x0c($15)
addi $21, $20, 0x0100
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
addi $25,$25,0x0001
bne $25,$24,loop
j rest
rest:
and $25,$25,$0
sw $0, 0($11)
addi $23,$23,0x0001
bne $23,$24,rest
j next
next:
and $23,$23,$0
addi $15,$15,0x0004
addi $18,$18,0x0001
beq $18,$19,reset1
j loop
reset1:
and $18,$18,$0
subu $15,$15,$22
j loop

    .end main