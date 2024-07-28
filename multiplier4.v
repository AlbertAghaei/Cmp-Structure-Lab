`timescale 1ns/1ns
module multiplier4
#(
    parameter nb=32
)(
//---------------------Port directions and deceleration
   input clk,  
   input start,
   input  [nb-1:0] A, 
   input  [nb-1:0] B, 
   output reg  [nb+nb-1:0] Product,
   output ready
    );
//--------------------------------- register deceleration
reg  [nb-1:0] Multiplicand ;
reg  [$clog2(nb):0]  counter;
//-----------------------------------------------------

//----------------------------------- wire deceleration
wire product_write_enable;
wire [nb:0] multiplexer_output;
wire  [nb:0] adder_output;
//-------------------------------------------------------

//------------------------------------ combinational logic
assign product_write_enable = Product[0];
assign ready = counter[$clog2(nb)];
assign multiplexer_output = product_write_enable ? ({Multiplicand[nb-1],Multiplicand}) : ({(nb+1){0}});
assign adder_output = multiplexer_output + {Product[nb+nb-1],Product[nb+nb-1:nb]} ;
//------------------------------------- sequential Logic
always @ (posedge clk)

   if(start) begin
      counter <= {(nb){0}} ;
      Product <= {{(nb){0}},B};
      Multiplicand <= A ;
   end

   else if(! ready) begin
      
         counter <= counter + 1;
         Product <= {Product[nb+nb-1],Product[nb+nb-1:1]};

          if(counter==nb-2)
         begin
            Multiplicand <= ((~Multiplicand)+1'b1);
         end
         Product[nb+nb-1:nb-1] <= adder_output;

         
   end   

endmodule
