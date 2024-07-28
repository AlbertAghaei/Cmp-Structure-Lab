#include <xc.h>

//You cannot use sp as a general purpose register.

#define TIMER_PERIOD (20000) // maximum value is 65535, actual rate is 5,000,000/TIMER_PERIOD

#define CT_INT_ON (1)
#define CT_INT_PRIOR_3 (3)

.global main

.data

seg:
.word 0x0000, 0x0000, 0x0000, 0x0000
//    seg1, seg2, seg3, seg4
InterruptCounter:
.word 0x0000
array:
.word 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F

.text
   
.ent main
main:

jal InterruptSetup

la $8, ANSELB
sw $0, 0($8)

la $8,ANSELA
sw $0,0($8)

la $8, TRISB
addi $9,$0,0xf000
sw $9, 0($8)
   
la $8,TRISA
sw $0 ,0($8)

la $8, LATB
sw $0, 0($8)  
 
ori $25,$0,0x0001//$4
ori $26,$0,0x0002//A1
ori $27,$0,0x0004//A2
ori $24,$0,0x0003  

ori $13,$0,0x1000//B12
ori $14,$0,0x2000//B13
ori $15,$0,0x4000//B14
ori $12,$0,0x8000//B15
ori $6,$0,0x4//4 numbers
ori $5,$0,0x0//counter
la $16,PORTB
la $17,LATA
la $8 , array

loop:
//$4
//jal delay 
A0:    
nop
sw $25,0($17)
addi $2 , $0 , 0
nop
nop
nop
jal delay    
lw $9,0($16) // port B
and $10,$9,$15
beq $10,$15,S11
and $10,$9,$14
beq $10,$14,S6
and $10,$9,$13
beq $10,$13,S1
jal delay
A1:
// A1
nop
sw $26,0($17)
addi $2 , $0 , 0
//jal delay
nop
nop
nop
lw $9,0($16)//Port B
and $10,$9,$12
beq $10,$12,S17
and $10,$9,$15
beq $10,$15,S12
and $10,$9,$14
beq $10,$14,S7
and $10,$9,$13
beq $10,$13,S2


   
// A2
nop
sw $27,0($17)
addi $2 , $0 , 0
//jal delay
nop
nop
nop
lw $9,0($16)//Port B
and $10,$9,$15
beq $10,$15,S13
and $10,$9,$14
beq $10,$14,S8
and $10,$9,$13
beq $10,$13,S3

segment:
jal delay    
addi $2 , $0 , 0

la $8, seg
ori $20, $20, 0x0100  
andi $20, $20, 0x01ff  
sw $20, 0($8)         //seg1
 
ori $21, $21, 0x0200  
andi $21, $21, 0x02ff
sw $21, 4($8)         //seg2

ori $22, $22, 0x0400
andi $22, $22, 0x04ff
sw $22, 8($8)         //seg3

ori $23, $23, 0x0800    
andi $23, $23, 0x08ff   
sw $23, 12($8)        //seg4
 
beq $5,$6,warning

j loop
warning:
la $8, seg
lw $20 , 0($8)
lw $21 , 4($8)
lw $22 , 8($8)
lw $23 , 12($8)

addi $20, $20, 0x80  
sw $20, 0($8)         //seg1

addi $21,  $21, 0x80  
sw $21, 4($8)         //seg2

ori $22,  $22, 0x80
sw $22, 8($8)         //seg3

ori $23,  $23, 0x80      
sw $23, 12($8)        //seg4

done:
j done

S1://1
addi $5,$5,0x1
beq $5,$25,seg11
beq $5,$26,seg21
beq $5,$24,seg31
beq $5,$27,seg41
seg11:
la $4 , array
lw $20 , 4($4)
j segment
seg21:
la $4 , array
lw $21 , 4($4)
j segment
seg31:
la $4 , array
lw $22 , 4($4)
j segment
seg41:
la $4 , array
lw $23 , 4($4)
j segment
   
   
S2://2
addi $5,$5,0x1
beq $5,$25,seg12
beq $5,$26,seg22
beq $5,$24,seg32
beq $5,$27,seg42
seg12:
la $4 , array
lw $20 , 8($4)
j segment
seg22:
la $4 , array
lw $21 , 8($4)
j segment
seg32:
la $4 , array
lw $22 , 8($4)
j segment
seg42:
la $4 , array
lw $23 , 8($4)
j segment
   
   
   
   
S3://3
addi $5,$5,0x1
beq $5,$25,seg13
beq $5,$26,seg23
beq $5,$24,seg33
beq $5,$27,seg43
seg13:
la $4 , array
lw $20 , 12($4)
j segment
seg23:
la $4 , array
lw $21 , 12($4)
j segment
seg33:
la $4 , array
lw $22 , 12($4)
j segment
seg43:
la $4 , array
lw $23 , 12($4)
j segment
   
   
   
   
S6://4
addi $5,$5,0x1
beq $5,$25,seg16
beq $5,$26,seg26
beq $5,$24,seg36
beq $5,$27,seg46
seg16:
la $4 , array
lw $20 , 16($4)
j segment
seg26:
la $4 , array
lw $21 , 16($4)
j segment
seg36:
la $4 , array
lw $22 , 16($4)
j segment
seg46:
la $4 , array
lw $23 , 16($4)
j segment
   
   
   
S7: //5
addi $5,$5,0x1
beq $5,$25,seg17
beq $5,$26,seg27
beq $5,$24,seg37
beq $5,$27,seg47
seg17:
la $4 , array
lw $20 , 20($4)
j segment
seg27:
la $4 , array
lw $21 , 20($4)
j segment
seg37:
la $4 , array
lw $22 , 20($4)
j segment
seg47:
la $4 , array
lw $23 , 20($4)
j segment
   
   
S8: //6
addi $5,$5,0x1
beq $5,$25,seg18
beq $5,$26,seg28
beq $5,$24,seg38
beq $5,$27,seg48
seg18:
la $4 , array
lw $20 , 24($4)
j segment
seg28:
la $4 , array
lw $21 , 24($4)
j segment
seg38:
la $4 , array
lw $22 , 24($4)
j segment
seg48:
la $4 , array
lw $23 , 24($4)
j segment

   
S11: //7
addi $5,$5,0x1
beq $5,$25,seg111
beq $5,$26,seg211
beq $5,$24,seg311
beq $5,$27,seg411
seg111:
la $4 , array
lw $20 , 28($4)
j segment
seg211:
la $4 , array
lw $21 , 28($4)
j segment
seg311:
la $4 , array
lw $22 , 28($4)
j segment
seg411:
la $4 , array
lw $23 , 28($4)
j segment
   
   
S12://8
addi $5,$5,0x1
beq $5,$25,seg112
beq $5,$26,seg212
beq $5,$24,seg312
beq $5,$27,seg412
seg112:
la $4 , array
lw $20 , 32($4)
j segment
seg212:
la $4 , array
lw $21 , 32($4)
j segment
seg312:
la $4 , array
lw $22 , 32($4)
j segment
seg412:
la $4 , array
lw $23 , 32($4)
j segment
   
   
S13://9
addi $5,$5,0x1
beq $5,$25,seg113
beq $5,$26,seg213
beq $5,$24,seg313
beq $5,$27,seg413
seg113:
la $4 , array
lw $20 , 36($4)
j segment
seg213:
la $4 , array
lw $21 , 36($4)
j segment
seg313:
la $4 , array
lw $22 , 36($4)
j segment
seg413:
la $4 , array
lw $23 , 36($4)
j segment
   
   
S17: //0
addi $5,$5,0x1
beq $5,$25,seg117
beq $5,$26,seg217
beq $5,$24,seg317
beq $5,$27,seg417
seg117:
la $4 , array
lw $20 , 0($4)
j segment
seg217:
la $4 , array
lw $21 , 0($4)
j segment
seg317:
la $4 , array
lw $22 , 0($4)
j segment
seg417:
la $4 , array
lw $23 , 0($4)
j segment

.end main
delay :
addi v0 , $0 , 0
loop2:
lui v1,0x2
ori v1,v1,0x3000
//ori s2 , s2 , 0xffff
addi v0 , v0 , 1
// if counter
bne v0, v1, loop2

j ra

/*********************************************************************
 * This is the actual interrupt handler that gets installed
 * in the interrupt vector table. It jumps to the core-timer
 * interrupt handler function.
 *
 * Note: The ".section .vector_0" is not allocatable. Hence to force
 * this section to be allocatable, use the "ax" directive.
 ********************************************************************/
.section .vector_0,code
   j      CoreTimerIntHandler

/*********************************************************************
 * CoreTimerIntHandler()
 * Interrupt handler function for core-timer. The function
 * clears the interrupt flag, shows one digit on the seven segment board and updates the
 * core-timer registers.
 *
 * pre-condition: A jump to ISR is registered in vector table
 * Input: none
 * Output: none
 * Side effect: shows one digit on the seven segment board
 ********************************************************************/
.text
.ent CoreTimerIntHandler
CoreTimerIntHandler:
   /* interrupt prologue */
   addiu sp, sp, -20
   sw $1, 0(sp)
   sw t0, 4(sp)
   sw t1, 8(sp)
   
   mfc0 t1, $14          /* read EPC register (program counter at last exeption) */
   sw t1, 12(sp)      /* save EPC on stack */
   
   mfc0 t1, $12         /* read STATUS register */
   sw t1, 16(sp)         /* save STATUS on stack */
   
   mfc0        t0, $13          /* read CAUSE register */
   srl         t0, t0,0xA      /* align RIPL (Requested Interrupt Priority Level) to bit 0 */
   ins         t1, t0, 10, 6      /* insert RIPL to IPL(Interrupt Priority Level) field (copy and replace from 6 LSBs of k0 to k1 starting at bit 10 of k1, k1<15:10> = k0<5:0>) */
   ins         t1, zero, 1, 4 /* k1<4:1> = zero<3:0> */
   mtc0        t1, $12         /* write STATUS register  (status<15:10> = cause<15:10>, status<4:1> = 0)  */
   
   
   /* set up t0 with time period and then call the update core-timer routine for next interrupt. */
   ori     t0, zero, TIMER_PERIOD
   mtc0   $0, $9   // count register ($9) in coprocessor0 = 0
   mtc0   t0, $11  // compare register ($11) in coprocessor0 = TIMER_PERIOD
   
   /* clear interrupt flag */
   addiu   t1, zero, 1
   la      t0, IFS0CLR
   sw      t1, 0(t0) // IFS0<0> = 0
   
   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
   la t0, LATBCLR
   addi t1, zero, 0x0fff
   sw t1, 0(t0)
   
   la t1, InterruptCounter
   lw t0, 0(t1)
   addiu t0, t0, 4
   sw t0, 0(t1)      // InterruptCounter = InterruptCounter + 4
   andi t0, t0, 0xf     // t0 = InterrupCounter%16
   la t1, seg
   add t0, t1, t0       // t0 = seg address + InterrupCounter%16
   
    lw t1, 0(t0)        // t1 = pattern
    andi t1, t1, 0x0fff
    la t0, LATBSET
    sw t1, 0(t0)        // LATB<11:0> = seg<11:0>
     
   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
   /* interrupt epilogue */
   di                      /* disable interrupts */
   
   lw t1, 12(sp)      /* restore EPC from stack */
   mtc0 t1, $14
   
   lw t1, 16(sp)         /* restore STATUS from stack */
   mtc0 t1, $12
   
   lw $1, 0(sp)
   lw t0, 4(sp)
   lw t1, 8(sp)
   addiu sp, sp, 20
   
   ei                        /* enable interrupts */
   /* return from interrupt */
   eret        
.end CoreTimerIntHandler
   
 /*********************************************************************
 * InterruptSetup()
 *
 * cause<23> = 1
 * ei
 * count = 0
 * compare = TIMER_PERIOD
 * IFS0CLR<0> = 0
 * IPC0<4:2> = CT_INT_PRIOR_3
 * IEC0<0> = CT_INT_ON
 ********************************************************************/
.ent InterruptSetup
InterruptSetup:
    /* function prologue - save registers used in this function
     * on stack and adjust stack-pointer
     */
   addiu   sp, sp, -8
   sw      s0, 0(sp)
   sw      s1, 4(sp)

   //INTEnableSystemMultiVectoredInt:
   mfc0    s0, $13
   lui     s1, 0x0080
   or      s0, s0, s1
   mtc0    s0, $13  // bit <23> (IV bit = Interrupt Vector) in the cause register ($13) in coprocessor0 is set
   ei      /* enable system-wide interrupts */
   
   //OpenCoreTimer:
   ori     s0, zero, TIMER_PERIOD  // s0 = TIMER_PERIOD
   mtc0   $0, $9   // count register ($9) in coprocessor0 = 0
   mtc0   s0, $11  // compare register ($11) in coprocessor0 = TIMER_PERIOD
   
   //mCTClearIntFlag:
   addiu   s1, zero, 1
   la      s0, IFS0CLR
   sw      s1, 0(s0) // bit <0> in the Interrupt Flag Status register is cleared
   
   //mCTSetIntPriority:
   addiu   s1, zero, (7 << 2)
   la      s0, IPC0CLR
   sw      s1, 0(s0)
   ori     s0, zero, CT_INT_PRIOR_3 // s0 = CT_INT_PRIOR_3
   sll     s1, s0, 2
   la      s0, IPC0SET
   sw      s1, 0(s0) // bits <4:2> in the Interrupt Priority Control register (of the core timer interrupt), which are the core timer interrupt priority bits = CT_INT_PRIOR_3
   
   //mCTIntEnable:
   ori     s1, zero, CT_INT_ON // s1 = CT_INT_ON
   la      s0, IEC0SET
   sw      s1, 0(s0) // bit <0> in the Interrupt Enable Control register (of the core timer interrupt), which is the core timer interrupt enable bit = CT_INT_ON
   
   /* function epilogue - restore registers used in this function
     * from stack and adjust stack-pointer
     */
   lw      s1, 4(sp)
   lw      s0, 0(sp)
   addiu   sp, sp, 8
   
   /* return to caller */
   jr      ra
.end InterruptSetup