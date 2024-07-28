`timescale 1ns/1ns
module booth
#(
    parameter nb
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
reg [1:0] product_write_enable;
reg help;
wire  [nb+1:0] adder_output0;
wire  [nb+1:0] adder_output1;
wire  [nb+1:0] adder_output2;
wire  [nb+1:0] adder_output1m;
wire  [nb+1:0] adder_output2m;
//-------------------------------------------------------

//------------------------------------ combinational logic
assign ready = counter[$clog2(nb)];
assign adder_output0 = {Product[nb+nb-1],Product[nb+nb-1],Product[nb+nb-1:nb]};//0
assign adder_output1 = {Multiplicand[nb-1],Multiplicand[nb-1],Multiplicand} + {Product[nb+nb-1],Product[nb+nb-1],Product[nb+nb-1:nb]} ;//+A
assign adder_output2 = {Multiplicand[nb-1],Multiplicand[nb-1:0],1'b0} +{Product[nb+nb-1] ,Product[nb+nb-1] ,Product[nb+nb-1:nb]};//+2A
assign adder_output1m = {Product[nb+nb-1],Product[nb+nb-1],Product[nb+nb-1:nb]} - {Multiplicand[nb-1],Multiplicand[nb-1],Multiplicand} ;//-A
assign adder_output2m ={Product[nb+nb-1] ,Product[nb+nb-1] ,Product[nb+nb-1:nb]} - {Multiplicand[nb-1],Multiplicand[nb-1:0],1'b0};//-2A
always @(*)
begin
    product_write_enable = Product[1:0];
end
//------------------------------------- sequential Logic
always @ (posedge clk)

   if(start) begin
      help <=1'b0;
      product_write_enable[0] <=B[0];
      product_write_enable[1] <=B[1];
      counter <= {(nb){0}} ;
      Product <= {{(nb){0}},B};                                                                                                                                                                                 
      Multiplicand <= A ;
   end

   else if(! ready) begin
         counter <= counter + 2;
         Product <= {Product[nb+nb-1],Product[nb+nb-1],Product[nb+nb-1:2]};
         if(product_write_enable==2'b00 && help==1'b0)
         begin
            help <= Product[1];
            Product[nb+nb-1:nb-2] <= adder_output0;
         end
         else if (product_write_enable===2'b00 && help==1'b1)
         begin
            help <= Product[1];
            Product[nb+nb-1:nb-2] <= adder_output1;
         end
          else if (product_write_enable===2'b01 && help==1'b0)
         begin
             help <= Product[1];
             Product[nb+nb-1:nb-2] <= adder_output1;
         end
          else if (product_write_enable===2'b01 && help==1'b1 )
         begin
            help <= Product[1];
             Product[nb+nb-1:nb-2] <= adder_output2;
             
         end
          else if (product_write_enable===2'b10  && help==1'b0)
         begin
            help <= Product[1];
             Product[nb+nb-1:nb-2] <= adder_output2m;
             
         end
          else if (product_write_enable===2'b10 && help==1'b1 )
         begin
            help <= Product[1];
             Product[nb+nb-1:nb-2] <= adder_output1m;
           
         end
          else if (product_write_enable===2'b11 && help==1'b0)
         begin
           help <= Product[1];
             Product[nb+nb-1:nb-2] <= adder_output1m;
         end
          else if (product_write_enable===2'b11  && help==1'b1 )
         begin
                help <= Product[1];
             Product[nb+nb-1:nb-2] <= adder_output0;
         end
         
   end   

endmodule
