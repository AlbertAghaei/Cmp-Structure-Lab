`timescale 1ns/1ns
module multiplier3(
//---------------------Port directions and deceleration
   input clk,  
   input start,
   input  [7:0] A, 
   input  [7:0] B, 
   output reg  [15:0] Product,
   output  wire ready
    );
//--------------------------------- register deceleration
reg  [7:0] Multiplicand ;
reg  [3:0]  counter;
//-----------------------------------------------------

//----------------------------------- wire deceleration
wire product_write_enable;
wire [8:0] multiplexer_output;
wire  [8:0] adder_output;
//-------------------------------------------------------

//------------------------------------ combinational logic
assign product_write_enable = Product[0];
assign ready = counter[3];
assign multiplexer_output = product_write_enable ? ({Multiplicand[7],Multiplicand}) : (9'b0);
assign adder_output = multiplexer_output + {Product[15],Product[15:8]} ;
//------------------------------------- sequential Logic
always @ (posedge clk)

   if(start) begin
      counter <= 4'h0 ;
      Product <= B;
      Multiplicand <= A ;
   end

   else if(! ready) begin
      
         counter <= counter + 1;
         Product <= {Product[15],Product[15:1]};

          if(counter==4'b0110)
         begin
            Multiplicand <= ((~Multiplicand)+1'b1);
         end
         Product[15:7] <= adder_output;

         
   end   

endmodule
