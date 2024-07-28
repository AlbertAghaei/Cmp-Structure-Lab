module fp_adderz(
    input wire [31:0] a,
    input wire [31:0] b,
    output wire [31:0] s
);
//wire assignments 
wire hidden_bit_a;
wire hidden_bit_b;
wire [7:0] exponent_a;
wire [7:0] exponent_b;
wire [25:0] normalized_fraction_a_0;
wire [25:0] normalized_fraction_a_1;
wire [25:0] ultimate_fraction_a;
wire [25:0] normalized_fraction_b_0;
wire [25:0] normalized_fraction_b_1;
wire [25:0] ultimate_fraction_b;
wire [8:0] small_alu_output;
wire borrow;
wire [7:0] exponent_diffrence;
wire [7:0] ultimate_exponent_diffrence;
wire [25:0] right_side_fraction;
wire [25:0] primary_left_side_fraction;
wire [25:0] ultimate_left_side_fraction;
wire sticky;
wire [26:0] right_side_fraction_with_sticky;
wire [26:0] left_side_fraction_with_sticky;
wire [27:0] th_complement_right_side;
wire [27:0] th_complement_left_side;
wire right_side_sign;
wire left_side_sign;
wire [28:0] ready_for_adder_right_side;
wire [28:0] ready_for_adder_left_side;
wire [28:0] big_alu_output;
wire [27:0] sm_big_alu_output;
wire [28:0] shifted_to_right_sm_big_alu_output;
wire [7:0] bigger_exponent;
wire [7:0] bigger_plus1_exponent;
wire result_sign;
wire [4:0] leading_one_index;
wire [4:0] reverse_leading_one_index ;
wire [28:0] primary_normalized_fraction;
wire [7:0] adjusted_exponent;
wire [24:0] rounded_fraction ;
wire [23:0] final_fraction_with_hidden_one;
wire [7:0] final_exponent ;
wire [7:0] the_final_exponent ; 





// continiues assignments
assign hidden_bit_a = (a[30:23]==8'b0) ? 0 : 1 ;
assign hidden_bit_b = (b[30:23]==8'b0) ? 0 : 1 ;
assign exponent_a = hidden_bit_a ? a[30:23] : 8'b00000001 ;
assign exponent_b = hidden_bit_b ? b[30:23] : 8'b00000001 ;
assign normalized_fraction_a_0 = {1'b0,a[22:0],2'b00};
assign normalized_fraction_a_1 = {1'b1,a[22:0],2'b00};
assign normalized_fraction_b_0 = {1'b0,b[22:0],2'b00};
assign normalized_fraction_b_1 = {1'b1,b[22:0],2'b00};
assign ultimate_fraction_a = hidden_bit_a ? normalized_fraction_a_1 : normalized_fraction_a_0;
assign ultimate_fraction_b = hidden_bit_b ? normalized_fraction_b_1 : normalized_fraction_b_0;
assign small_alu_output = {1'b0,exponent_a} + (~{1'b0,exponent_b}+1'b1);
assign borrow = small_alu_output[8];
assign exponent_diffrence = small_alu_output[7:0];
assign right_side_fraction = borrow ? ultimate_fraction_b : ultimate_fraction_a;
assign primary_left_side_fraction = borrow ? ultimate_fraction_a : ultimate_fraction_b ;
assign ultimate_exponent_diffrence = borrow ? (~(exponent_diffrence)+1'b1) : exponent_diffrence ;
assign ultimate_left_side_fraction = primary_left_side_fraction >> ultimate_exponent_diffrence;
//assign sticky= | primary_left_side_fraction[ultimate_exponent_diffrence-2'b10:0];
assign sticky = | (primary_left_side_fraction + (~(ultimate_left_side_fraction<<ultimate_exponent_diffrence)+1'b1));
assign right_side_fraction_with_sticky = {right_side_fraction,1'b0};
assign left_side_fraction_with_sticky = {ultimate_left_side_fraction,sticky};
assign right_side_sign = (right_side_fraction==ultimate_fraction_a) ? a[31] : b[31];
assign left_side_sign = (right_side_sign==a[31]) ? b[31] : a[31];
assign th_complement_right_side = (right_side_sign==1'b0) ? {1'b0,right_side_fraction_with_sticky} : (~{1'b0,right_side_fraction_with_sticky}+1'b1) ;
assign th_complement_left_side = (left_side_sign==1'b0) ? {1'b0,left_side_fraction_with_sticky} : (~{1'b0,left_side_fraction_with_sticky}+1'b1) ;
assign ready_for_adder_right_side = {th_complement_right_side[27],th_complement_right_side};
assign ready_for_adder_left_side = {th_complement_left_side[27],th_complement_left_side};
assign big_alu_output = ready_for_adder_left_side + ready_for_adder_right_side ;
assign bigger_exponent = borrow ? exponent_b : exponent_a ;
assign result_sign = big_alu_output[28];
assign sm_big_alu_output = result_sign ? (~(big_alu_output[27:0])+1'b1) : big_alu_output[27:0] ;
assign shifted_to_right_sm_big_alu_output = ({sm_big_alu_output,sm_big_alu_output[0]}>>1) ;
assign bigger_plus1_exponent= bigger_exponent + 1'b1 ;
assign leading_one_index = shifted_to_right_sm_big_alu_output[28] ? 28 :
                           shifted_to_right_sm_big_alu_output[27] ? 27 :
                           shifted_to_right_sm_big_alu_output[26] ? 26 :
                           shifted_to_right_sm_big_alu_output[25] ? 25 :
                           shifted_to_right_sm_big_alu_output[24] ? 24 : 
                           shifted_to_right_sm_big_alu_output[23] ? 23 :
                           shifted_to_right_sm_big_alu_output[22] ? 22 :
                           shifted_to_right_sm_big_alu_output[21] ? 21 :
                           shifted_to_right_sm_big_alu_output[20] ? 20 :
                           shifted_to_right_sm_big_alu_output[19] ? 19 :
                           shifted_to_right_sm_big_alu_output[18] ? 18 :
                           shifted_to_right_sm_big_alu_output[17] ? 17 :
                           shifted_to_right_sm_big_alu_output[16] ? 16 :
                           shifted_to_right_sm_big_alu_output[15] ? 15 :
                           shifted_to_right_sm_big_alu_output[14] ? 14 :
                           shifted_to_right_sm_big_alu_output[13] ? 13 :
                           shifted_to_right_sm_big_alu_output[12] ? 12 :
                           shifted_to_right_sm_big_alu_output[11] ? 11 :
                           shifted_to_right_sm_big_alu_output[10] ? 10 :
                           shifted_to_right_sm_big_alu_output[9] ? 9 :
                           shifted_to_right_sm_big_alu_output[8] ? 8 :
                           shifted_to_right_sm_big_alu_output[7] ? 7 :
                           shifted_to_right_sm_big_alu_output[6] ? 6 :
                           shifted_to_right_sm_big_alu_output[5] ? 5 :
                           shifted_to_right_sm_big_alu_output[4] ? 4 :
                           shifted_to_right_sm_big_alu_output[3] ? 3 :
                           shifted_to_right_sm_big_alu_output[2] ? 2 :
                           shifted_to_right_sm_big_alu_output[1] ? 1 : 0 ;
assign reverse_leading_one_index = (5'b11011 + (~(leading_one_index)+1'b1));
assign primary_normalized_fraction = (bigger_exponent<reverse_leading_one_index) ? (shifted_to_right_sm_big_alu_output<<bigger_exponent) : (shifted_to_right_sm_big_alu_output<<reverse_leading_one_index) ;
assign adjusted_exponent = (bigger_exponent<reverse_leading_one_index) ? 8'b00000000 :(bigger_plus1_exponent + (~(reverse_leading_one_index)+1'b1));
assign rounded_fraction = ((primary_normalized_fraction[3]==1'b1) &&  ((| primary_normalized_fraction[2:0])==1'b1)) ? (primary_normalized_fraction[28:4]+1'b1) :
                          (primary_normalized_fraction[3]==1'b0) ? (primary_normalized_fraction[28:4]) : 
                          ((primary_normalized_fraction[3]==1'b1) && ((| primary_normalized_fraction[2:0])==1'b0) && (primary_normalized_fraction[4]==1'b0)) ?  (primary_normalized_fraction[28:4]) : 
                          ((primary_normalized_fraction[3]==1'b1) && ((| primary_normalized_fraction[2:0])==1'b0) && (primary_normalized_fraction[4]==1'b1)) ?  (primary_normalized_fraction[28:4]+1'b1) : 29'b0 ;
assign final_fraction_with_hidden_one = (rounded_fraction[24]==1'b1) ? (rounded_fraction[24:1]) : (rounded_fraction[23:0]) ;
assign final_exponent = (rounded_fraction[24]==1'b1) ? (adjusted_exponent+1'b1) : (adjusted_exponent) ;
assign the_final_exponent = (final_fraction_with_hidden_one[23]==1'b1) ? final_exponent : 8'b00000000 ;
assign s = {result_sign,the_final_exponent,final_fraction_with_hidden_one[22:0]};
endmodule