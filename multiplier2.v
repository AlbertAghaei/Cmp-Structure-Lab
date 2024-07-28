`timescale 1ns/1ns
module multiplier2(
//---------------------Port directions and deceleration
   input clk,  
   input start,
   input [7:0] A, 
   input [7:0] B, 
   output reg [15:0] Product,
   output ready
    );
//--------------------------------- register deceleration
reg [7:0] Multiplicand ;
reg [3:0]  counter;
//-----------------------------------------------------

//----------------------------------- wire deceleration
wire product_write_enable;
reg [8:0] adder_output;
//-------------------------------------------------------

//------------------------------------ combinational logic
assign product_write_enable = Product[0];
assign ready = counter[3];
always @ (*)
begin 
    if(product_write_enable)
    begin
     adder_output = Multiplicand + Product[15:8];
    end
    else
    begin
     adder_output = 8'b0 + Product[15:8];
    end

end
//-------------------------------------------------------

//------------------------------------- sequential Logic
always @ (posedge clk)

   if(start) begin
      counter <= 4'h0 ;
      Product <= B;
      Multiplicand <= A ;
   end

   else if(! ready) begin
         counter <= counter + 1;
         Product <= Product >>1 ;
 
      if(product_write_enable)
      begin
         Product[15:7] <= adder_output;
      end
   end   

endmodule
