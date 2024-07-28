`timescale 1ns/100ps

   `define ADD  4'b0000
   `define SUB  4'b0001
   `define SLT  4'b0010
   `define SLTU 4'b0011
   `define AND  4'b0100
   `define XOR  4'b0101
   `define OR   4'b0110
   `define NOR  4'b0111
   `define LUI  4'b1000
module multi_cycle_mips(

   input clk,
   input reset,


   // Memory Ports
   output  [31:0] mem_addr,
   input   [31:0] mem_read_data,
   output  [31:0] mem_write_data,
   output         mem_read,
   output         mem_write
);

   // Data Path Registers
   reg MRE, MWE;
   reg [31:0] A, B, PC, IR, MDR, MAR ;
   //multiplication and jumps regs and wires
   reg [31:0] multlo , multhi;
   wire [63:0] multproduct;
   reg multflag ;
   wire multready ;
   wire [4:0] WRz;
   wire [31:0] WDz;

   // Data Path Control Lines, donot forget, regs are not always regs !!
   reg setMRE, clrMRE, setMWE, clrMWE;
   reg Awrt, Bwrt, RFwrt, PCwrt, IRwrt, MDRwrt, MARwrt;

   // Memory Ports Binding
   assign mem_addr = MAR;
   assign mem_read = MRE;
   assign mem_write = MWE;
   assign mem_write_data = B;

   // Mux & ALU Control Lines
   reg [3:0] aluOp;
   reg [1:0] aluSelB;
   reg SgnExt, aluSelA, IorD;
   // changing registers bc of bold instructions
   reg[1:0] RegDst ; 
   reg[1:0] MemtoReg ; 
   reg HorI;


   // Wiring
   wire aluZero;
   wire [31:0] aluResult, rfRD1, rfRD2;

   reg[1:0] pc_controller ;
   // Clocked Registers
   always @( posedge clk ) begin
      if( reset )
         PC <= #0.1 32'h00000000;
      else if( PCwrt )
         begin
            case(pc_controller)
            2'b00: PC <= #0.1 A;
            2'b01: PC <= #0.1 {PC[31:28],IR[25:0],2'b00};
            2'b10: PC <= #0.1 aluResult ;
            endcase
         end

      if( Awrt ) A <= #0.1 rfRD1;
      if( Bwrt ) B <= #0.1 rfRD2;

      if( MARwrt ) MAR <= #0.1 IorD ? aluResult : PC;

      if( IRwrt ) IR <= #0.1 mem_read_data;
      if( MDRwrt ) MDR <= #0.1 mem_read_data;

      if( reset | clrMRE ) MRE <= #0.1 1'b0;
          else if( setMRE) MRE <= #0.1 1'b1;

      if( reset | clrMWE ) MWE <= #0.1 1'b0;
          else if( setMWE) MWE <= #0.1 1'b1;
   end
   //WD WR verification
assign WRz = RegDst[1] ? 5'b11111 : (RegDst[0] ? IR[15:11] : IR[20:16]  )  ;
assign WDz = MemtoReg[1] ? (MemtoReg[0] ? (HorI ? (multlo) : (multhi)) : (PC)) : (MemtoReg[0] ? (MDR) : (aluResult));
   // Register File
   reg_file rf(
      .clk( clk ),
      .write( RFwrt ),
      .RR1( IR[25:21] ),
      .RR2( IR[20:16] ),
      .RD1( rfRD1 ),
      .RD2( rfRD2 ),
      .WR( WRz ),
      .WD( WDz )
   );

   // Sign/Zero Extension
   wire [31:0] SZout = SgnExt ? {{16{IR[15]}}, IR[15:0]} : {16'h0000, IR[15:0]};

   // ALU-A Mux
   wire [31:0] aluA = aluSelA ? A : PC;

   // ALU-B Mux
   reg [31:0] aluB;
   always @(*)
   case (aluSelB)
      2'b00: aluB = B;
      2'b01: aluB = 32'h4;
      2'b10: aluB = SZout;
      2'b11: aluB = SZout << 2;
   endcase

   my_alu alu(
      .A( aluA ),
      .B( aluB ),
      .Op( aluOp ),

      .X( aluResult ),
      .Z( aluZero )
   );


   multiplier multu(
      .clk( clk ),
      .start(multflag),
      .A(rfRD1),
      .B(rfRD2),
      .Product(multproduct),
      .ready(multready)
   );
   // Controller Starts Here

   // Controller State Registers
   reg [4:0] state, nxt_state;

   // State Names & Numbers
   localparam
      RESET = 0, FETCH1 = 1, FETCH2 = 2, FETCH3 = 3, DECODE = 4,
      EX_MULTU_1 = 5 ,EX_MULTU_2 = 6,
      EX_ALU_R = 7, EX_ALU_I = 8,
      EX_MFLO_MFHI_R = 9,
      EX_LW_1 = 11, EX_LW_2 = 12, EX_LW_3 = 13, EX_LW_4 = 14, EX_LW_5 = 15,
      EX_JUMPR_1=16 ,EX_JUMPR_2=17, EX_JUMP_1=18 , EX_JUMP_2=19 ,
      EX_SW_1 = 21, EX_SW_2 = 22, EX_SW_3 = 23 , 
      EX_BRA_1 = 25, EX_BRA_2 = 26  ,EX_JAL_1 = 28 , EX_JAL_2 = 29;

   // State Clocked Register 
   always @(posedge clk)
      if(reset)
         state <= #0.1 RESET;
      else
         state <= #0.1 nxt_state;

   task PrepareFetch;
      begin
         IorD = 0;
         setMRE = 1;
         MARwrt = 1;
         nxt_state = FETCH1;
      end
   endtask

   // State Machine Body Starts Here
   always @( * ) begin

      nxt_state = 'bx;

      SgnExt = 'bx; IorD = 'bx;
      MemtoReg = 'bx; RegDst = 'bx;
      aluSelA = 'bx; aluSelB = 'bx; aluOp = 'bx;

      PCwrt = 0; pc_controller = 'bx;
      Awrt = 0; Bwrt = 0;
      RFwrt = 0; IRwrt = 0;
      MDRwrt = 0; MARwrt = 0;
      setMRE = 0; clrMRE = 0;
      setMWE = 0; clrMWE = 0;
      multflag=0;HorI='bx;

      case(state)

         RESET:
            PrepareFetch;

         FETCH1:
            nxt_state = FETCH2;

         FETCH2:
            nxt_state = FETCH3;

         FETCH3: begin
            IRwrt = 1;
            pc_controller = 2'b10;
            PCwrt = 1;
            clrMRE = 1;
            aluSelA = 0;
            aluSelB = 2'b01;
            aluOp = `ADD;
            nxt_state = DECODE;
         end

         DECODE: begin
            Awrt = 1;
            Bwrt = 1;
            case( IR[31:26] )
               6'b000_000:             // R-format
                  case( IR[5:3] )
                     3'b000: ;
                     3'b001: nxt_state = EX_JUMPR_1;// jr , jalr
                     3'b010: nxt_state = EX_MFLO_MFHI_R;//mflo and mfhi
                     3'b011: nxt_state = EX_MULTU_1;//multu
                     3'b100: nxt_state = EX_ALU_R;
                     3'b101: nxt_state = EX_ALU_R;
                     3'b110: ;
                     3'b111: ;
                  endcase
               //I-format
               6'b001_000,             // addi
               6'b001_001,             // addiu
               6'b001_010,             // slti
               6'b001_011,             // sltiu
               6'b001_100,             // andi
               6'b001_101,             // ori
               6'b001_110,             // xori
               6'b001_111:             // lui
                  nxt_state = EX_ALU_I;

               6'b100_011:
                  nxt_state = EX_LW_1;

               6'b101_011:
                  nxt_state = EX_SW_1;

               6'b000_100,
               6'b000_101:
                  nxt_state = EX_BRA_1;
               //J-format
               6'b000_010: nxt_state = EX_JUMP_1 ;// j
               6'b000_011: nxt_state = EX_JAL_1  ;// jal 

               // rest of instructiones should be decoded here

            endcase
         end
         //jr & jalr
         EX_JUMPR_1 : begin
            case (IR[2:0])
            3'b000:
            begin
            pc_controller = 2'b00; 
            PCwrt = 1;
            nxt_state = EX_JUMPR_2;
            end
            3'b001:
            begin
            pc_controller = 2'b00; 
            PCwrt = 1; 
            RFwrt = 1;
            RegDst = 2'b10 ;
            MemtoReg = 2'b10 ;
            nxt_state = EX_JUMPR_2;
            end
            endcase
         end
         EX_JUMPR_2 : PrepareFetch;
         //j 
         EX_JUMP_1 :
             begin
               pc_controller=2'b01;
               PCwrt = 1;
               nxt_state = EX_JUMP_2;
             end
         EX_JUMP_2 : PrepareFetch;
         //jal
         EX_JAL_1 :
         begin
            pc_controller=2'b01;
            PCwrt = 1'b1;
            RFwrt = 1'b1;
            RegDst = 2'b10;
            MemtoReg = 2'b10;
            nxt_state = EX_JAL_2 ;
         end
         EX_JAL_2 : PrepareFetch;
      
          EX_ALU_R: begin
            aluSelA=1'b1;
            aluSelB=2'b00;
            RegDst=2'b01;
            MemtoReg=2'b00;
            RFwrt=1'b1;
            case(IR[5:3])
            3'b100:begin
               case (IR[2:0])
                   3'b000:aluOp=`ADD;
                   3'b001:aluOp=`ADD;//addu
                   3'b010:aluOp=`SUB;
                   3'b011:aluOp=`SUB;//subu
                   3'b100:aluOp=`AND;
                   3'b101:aluOp=`OR;
                   3'b110:aluOp=`XOR;
                   3'b111:aluOp=`NOR;
                   endcase
               end 
            3'b101:begin
               case (IR[2:0])
                   3'b010:aluOp=`SLT;
                   3'b011:aluOp=`SLTU;
                   endcase
               end
            endcase
            PrepareFetch;
         end

          EX_ALU_I: begin
            case(IR[31:26])
            //addi
            6'b001000:begin
             aluSelA=1'b1;
             aluSelB=2'b10; 
             aluOp=`ADD;
             RegDst=2'b00;
             MemtoReg=2'b00;
             RFwrt=1'b1;
             SgnExt=1'b1; 
            end
            //addiu
            6'b001001:begin
             aluSelA=1'b1;
             aluSelB=2'b10; 
             aluOp=`ADD;
             RegDst=2'b00;
             MemtoReg=2'b00;
             RFwrt=1'b1;
             SgnExt=1'b0; 
            end
            //slti
            6'b001010:
            begin
             aluSelA=1'b1;
             aluSelB=2'b10; 
             aluOp=`SLT;
             RegDst=2'b00;
             MemtoReg=2'b00;
             RFwrt=1'b1;
             SgnExt=1'b1; 
            end
            //sltiu
            6'b001011:begin
             aluSelA=1'b1;
             aluSelB=2'b10; 
             aluOp=`SLTU;
             RegDst=2'b00;
             MemtoReg=2'b00;
             RFwrt=1'b1;
             SgnExt=1'b0; 
            end
            //andi
            6'b001100:begin
             aluSelA=1'b1;
             aluSelB=2'b10; 
             aluOp=`AND;
             RegDst=2'b00;
             MemtoReg=2'b00;
             RFwrt=1'b1;
             SgnExt=1'b0; 
            end
            //ori
            6'b001101:begin
             aluSelA=1'b1;
             aluSelB=2'b10; 
             aluOp=`OR;
             RegDst=2'b00;
             MemtoReg=2'b00;
             RFwrt=1'b1;
             SgnExt=1'b0; 
            end
            //xori
            6'b001110:begin
             aluSelA=1'b1;
             aluSelB=2'b10; 
             aluOp=`XOR;
             RegDst=2'b00;
             MemtoReg=2'b00;
             RFwrt=1'b1;
             SgnExt=1'b0; 
            end
            //lui 
            6'b001_111:begin
             aluSelA=1'b1;
             aluSelB=2'b10; 
             aluOp=`LUI;
             RegDst=2'b00;
             MemtoReg=2'b00;
             RFwrt=1'b1;
             SgnExt=1'b0; 
            end
            endcase
         PrepareFetch;
         end

         //lw
          EX_LW_1: begin
            aluSelA=1'b1;
            aluSelB=2'b10;
            aluOp=`ADD;
            SgnExt=1'b1;
            MARwrt=1'b1;
            IorD=1'b1;
            setMRE=1'b1;
            nxt_state=EX_LW_2;
         end
         EX_LW_2:nxt_state=EX_LW_3;
         EX_LW_3:nxt_state=EX_LW_4;
         EX_LW_4:begin
            clrMRE=1'b1;
            MDRwrt=1'b1;
            nxt_state=EX_LW_5;
         end
         EX_LW_5:begin
            RegDst=2'b00;
            MemtoReg=2'b01;
            RFwrt=1'b1;
            PrepareFetch;
         end
         //sw
         EX_SW_1: begin
            aluSelA=1'b1;
            aluSelB=2'b10;
            aluOp=`ADD;
            SgnExt=1'b1;
            MARwrt=1'b1;
            IorD=1'b1;
            setMWE=1'b1;
            nxt_state= EX_SW_2;
         end
         EX_SW_2 :begin
            clrMWE=1'b1;
            nxt_state= EX_SW_3;
         end
         EX_SW_3 :PrepareFetch;

         //beq & bne
         EX_BRA_1: begin
            case(IR[31:26])
            //beq
            6'b000100:
            begin
            aluSelA=1'b1;
            aluSelB=2'b00;
            aluOp=`SUB;
            if(aluZero==1'b1)
            nxt_state=EX_BRA_2;
            else
            PrepareFetch;
            end
            //bne
            6'b000101:
            begin
            aluSelA=1'b1;
            aluSelB=2'b00;
            aluOp=`SUB;
            if(aluZero==1'b0)
            nxt_state=EX_BRA_2;
            else
            PrepareFetch;
            end 
            endcase
            
         end
         EX_BRA_2:begin
            aluSelA=1'b0;
            aluSelB=2'b11;
            SgnExt=1'b1;
            aluOp=`ADD;
            PCwrt=1'b1;
            pc_controller = 2'b10;
            IorD=1'b1;
            MARwrt=1'b1;
            setMRE=1'b1;
            nxt_state= FETCH1;
         end 
         //multu
         EX_MULTU_1:begin
            multflag =1'b1;
            nxt_state = EX_MULTU_2;
         end
         EX_MULTU_2:begin
            if(multready)
            begin
               multlo = multproduct [31:0];
               multhi = multproduct [63:32];
               PrepareFetch;
            end
            else
            nxt_state = EX_MULTU_2;
         end
         EX_MFLO_MFHI_R:begin
          RegDst=2'b01;
          RFwrt = 1'b1;
          case(IR[2:0])
            3'b000:
            begin
            MemtoReg = 2'b11;
            HorI=1'b0;
            PrepareFetch;
            end
            3'b010:
            begin
            MemtoReg = 2'b11;
            HorI=1'b1;
            PrepareFetch;
            end
          endcase
          end


      endcase

   end

endmodule

//==============================================================================

module my_alu(
   input [3:0] Op,
   input [31:0] A,
   input [31:0] B,

   output [31:0] X,
   output        Z 
  

);


   wire sub = Op != `ADD;

   wire [31:0] bb = sub ? ~B : B;

   wire [32:0] sum = A + bb + sub;

   wire sltu = ! sum[32];

   wire v = sub ? 
        ( A[31] != B[31] && A[31] != sum[31] )
      : ( A[31] == B[31] && A[31] != sum[31] );

   wire slt = v ^ sum[31];

   reg [31:0] x;

   always @( * )
      case( Op )
         `ADD : x = sum;
         `SUB : x = sum;
         `SLT : x = slt;
         `SLTU: x = sltu;
         `AND : x =   A & B;
         `OR  : x =   A | B;
         `NOR : x = ~(A | B);
         `XOR : x =   A ^ B;
         `LUI : x =  {B[15:0], 16'h0};
         default : x = 32'hxxxxxxxx;
      endcase

   assign #2 X = x;
   assign #2 Z = x == 32'h00000000;




endmodule

//==============================================================================

module reg_file(
   input clk,
   input write,
   input [4:0] WR,
   input [31:0] WD,
   input [4:0] RR1,
   input [4:0] RR2,
   output [31:0] RD1,
   output [31:0] RD2
);

   reg [31:0] rf_data [0:31];

   assign #2 RD1 = rf_data[ RR1 ];
   assign #2 RD2 = rf_data[ RR2 ];   

   always @( posedge clk ) begin
      if ( write )
         rf_data[ WR ] <= WD;

      rf_data[0] <= 32'h00000000;
   end

endmodule

//==============================================================================

module multiplier(
//-----------------------Port directions and deceleration
   input clk,  
   input start,
   input [31:0] A, 
   input [31:0] B, 
   
   output reg [63:0] Product,
   output ready
    );



//------------------------------------------------------

//----------------------------------- register deceleration

reg [63:0] Multiplicand ;
reg [31:0]  Multiplier;
reg [6:0]  counter;
//-------------------------------------------------------

//------------------------------------- wire deceleration
wire product_write_enable;
wire [63:0] adder_output;
//---------------------------------------------------------

//-------------------------------------- combinational logic
assign adder_output = Multiplicand + Product;
assign product_write_enable = Multiplier[0];
assign ready = counter==32;
//---------------------------------------------------------

//--------------------------------------- sequential Logic
always @ (posedge clk)

   if(start) begin
      counter <= {(7){0}} ;
      Multiplier <= B;
      Product <= {(64){0}};
      Multiplicand <= {{(32){0}}, A} ;
   end

   else if(! ready) begin
         counter <= counter + 1;
         Multiplier <= Multiplier >> 1;
         Multiplicand <= Multiplicand << 1;

      if(product_write_enable)
      begin
         Product <= adder_output;
      end
   end   

endmodule


//==============================================================================
