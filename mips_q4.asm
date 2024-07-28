lui $13,0x00001001
lw $2,0x00000000($13)
lw $3,0x00000004($13)
lui $1,0x8000
ori $1,$1,0x0000
and $4, $2, $1   # Sign bit of num1
and $5, $3, $1   # Sign bit of num2
lui $1,0x7f80
ori $1,$1,0x0000
and $6, $2, $1  # Exponent of num1
and $7, $3, $1   # Exponent of num2
lui $1,0x007f
ori $1,$1,0xffff
and $8, $2, $1  # Mantissa of num1
and $9, $3, $1   # Mantissa of num2

    # Compare sign bits
bne $4,$5,sign 

    # Compare exponents
beq $6,$7,gotomantisa
sub $11, $6, $7
sltu $11, $zero, $11   # If exponent of num1 < exponent of num2, set $11 to 1
bne $11,$zero,exponent2
     sw $2, 0x00000000($13)
     sw $3, 0x00000004($13)
     j done
  


    # Compare mantissas
gotomantisa:
sub $12, $8, $9
sltu $12, $zero, $12   # If mantissa of num1 < mantissa of num2, set $12 to 1
bne $12,$zero,mantisa2
   sw $2, 0x00000000($13)
   sw $3, 0x00000004($13)
   j done


  sign: 
  beq $4,$zero,positive
   sw $3, 0x00000000($13)
   sw $2, 0x00000004($13)
   j done
  positive:
   sw $2, 0x00000000($13)
   sw $3, 0x00000004($13)
   j done
   
   exponent2:
   sw $3, 0x00000000($13)
   sw $2, 0x00000004($13)
   j done 
   
   mantisa2:
   sw $3, 0x00000000($13)
   sw $2, 0x00000004($13)
   j done
   
 done:
