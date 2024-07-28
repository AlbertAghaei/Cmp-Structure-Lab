#include <xc.h>
#include "configbits.c"
    .global main
.data
seg7:
.word 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71
.text
    
.ent main
 main:
    
la $8, ANSELB
sw $0, 0($8)

la $8, TRISB
ori $9, $0, 0x0000
sw $9, 0($8)
la $11, LATB
    
la $15, seg7 
addi $8, $0, 0x0064
addi $17, $0, 0x0000   
Displayer:  // Displaying the number: 1234
lw $20, 0x04($15)
addi $21, $20, 0x0800
sw $21, 0($11)
bne $17,$8,counter1    
digit2:  
lw $20, 0x8($15)
addi $21, $20, 0x0400
sw $21, 0($11)
bne $17,$8,counter2
digit3:    
lw $20, 0x0c($15)
addi $21, $20, 0x0200
sw $21, 0($11)
bne $17,$8,counter3
digit4:    
lw $20, 0x10($15)
addi $21, $20, 0x0100
sw $21, 0($11)
bne $17,$8,counter4
    
j Displayer
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
j Displayer     
    .end main
    
    
   

    
