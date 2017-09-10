`include "vscale_md_constants.vh"

module vscale_mul_div
  (
   input                     clk,
   input                     reset,
   input                     req_valid,
   output                    req_ready,
   input                     req_in_1_signed,
   input                     req_in_2_signed,
   input [`MDF_OP_WIDTH-1:0] req_op,
   input [2:0]               req_rm,//TEMP//TEMP//
   input                     req_out_sel,
   input [31:0]              req_in_1,
   input [31:0]              req_in_2,
   input [31:0]              req_in_3,
   output reg                resp_valid,
   output [31:0]             resp_result,
   output reg [31:0]         resp_fbypass,
   output [31:0]             resp_fresult,
   output wire [4:0]         resp_fflag
   );

   reg                       x_signed;
   reg                       y_signed;
   reg [31:0]                x;
   reg [31:0]                y;
   reg                       out_sel;
   reg [`MDF_OP_WIDTH-1:0]   op;
   reg [`MDF_OP_WIDTH-1:0]   fop;
   reg [31:0]                xh, xl;

   reg [31:0]                frslt;
   reg [4:0]                 fflag;

   always @(posedge clk) begin
      if(req_valid & req_ready) begin
         x_signed <= req_in_1_signed;
         y_signed <= req_in_2_signed;
         x <= req_in_1;
         if((req_op==`MDF_OP_FML)|(req_op==`MDF_OP_FMA)|(req_op==`MDF_OP_FNA)|(req_op==`MDF_OP_FMS)|(req_op==`MDF_OP_FNS))
           y<={(req_in_2[30:23]!=8'h00),req_in_2[22:0],8'h00};
         else
           y <= req_in_2;
         out_sel <= req_out_sel;
         op <= req_op;
      end
   end

   reg [4:0]     i;
   reg [32:0]    buf0,buf1,buf2;
   assign resp_result = (out_sel==`MD_OUT_HI) ? buf2[31:0] : buf1[31:0];
   assign req_ready = (i == 5'b00000);
   always @ (posedge clk)
     resp_fbypass <= (out_sel==`MD_OUT_HI) ? buf2[31:0] : buf1[31:0];

   assign resp_fresult = (fop==`MDF_OP_NOP) ? resp_fbypass : frslt;
   assign resp_fflag   = (fop==`MDF_OP_NOP) ? 0            : fflag;

///////////////// MUL Only vvvvvvvvvvvvvvvvvvvvvvvvvvvv
   wire [2:0]    br0 = {xh[1:0],1'b0};
   wire [2:0]    br1 = xh[3:1];
   wire [2:0]    br2 = xh[5:3];
   wire [2:0]    br3 = xh[15:13];
   wire [2:0]    br4 = xh[17:15];
   wire [2:0]    br5 = xh[19:17];

   wire [35:0]   by0, by1, by2;
   wire [35:0]   by3, by4, by5;

   wire          ng0 = (br0[2:1]==2'b10)|(br0[2:0]==3'b110);
   wire          ng1 = (br1[2:1]==2'b10)|(br1[2:0]==3'b110);
//   wire          ng2 = (br2[2:1]==2'b10)|(br2[2:0]==3'b110);
   reg           ng2;
   wire          ng3 = (br3[2:1]==2'b10)|(br3[2:0]==3'b110);
   wire          ng4 = (br4[2:1]==2'b10)|(br4[2:0]==3'b110);
//   wire          ng5 = (br5[2:1]==2'b10)|(br5[2:0]==3'b110);
   reg           ng5;

   booth booth0(.i(1'b0), .y_signed(y_signed), .br(br0), .y(y), .by(by0));
   booth booth1(.i(1'b1), .y_signed(y_signed), .br(br1), .y(y), .by(by1));
   booth booth2(.i(1'b1), .y_signed(y_signed), .br(br2), .y(y), .by(by2));
   booth booth3(.i(1'b1), .y_signed(y_signed), .br(br3), .y(y), .by(by3));
   booth booth4(.i(1'b1), .y_signed(y_signed), .br(br4), .y(y), .by(by4));
   booth booth5(.i(1'b1), .y_signed(y_signed), .br(br5), .y(y), .by(by5));

   wire [50:18]  ms =  buf0[32:0];
   wire [64:0]   m  = {buf2[32:0],buf1[31:0]};
   reg [32:0]    in00,in01,in02,in10,in11,in12,in20,in21,in22;
   reg [1:0]     in0v,in1v,in2v;

///////////////// MUL Only ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
///////////////// DIV Only vvvvvvvvvvvvvvvvvvvvvvvvvvvv
   reg [31:0]    q;
   reg           sign;
   reg           plus;

   wire [31:0]   sxh;
   assign sxh = (sign!=buf0[32]) ? xh :
                (sign!=buf1[32]) ? buf0[31:0] :
                (sign!=buf2[32]) ? buf1[31:0] :
                buf2[31:0];

   wire [1:0]    dq;
   assign dq  = (sign!=buf0[32]) ? 0 :
                (sign!=buf1[32]) ? 1 :
                (sign!=buf2[32]) ? 2 :
                3;
///////////////// DIV Only ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
///////////////// FPU Only vvvvvvvvvvvvvvvvvvvvvvvvvvvv
   reg           fpu_ex;
   reg           sgn1, sgn0;
   reg [7:0]     expr, expd;

   wire [7:0]    expx = (req_in_1[30:23]==8'h00) ? 8'h01 : req_in_1[30:23];
   wire [7:0]    expy = (req_in_2[30:23]==8'h00) ? 8'h01 : req_in_2[30:23];
   wire [7:0]    expz = (req_in_3[30:23]==8'h00) ? 8'h01 : req_in_3[30:23];
   wire [8:0]    expm = expx + expy - 127;
   wire [9:0]    exps = ( ((req_op==`MDF_OP_FAD)|(req_op==`MDF_OP_FSB)) ? {1'b0,expx}-{1'b0,expy} :
                          (req_op==`MDF_OP_FML) ? {1'b0,expm} :
                          ((req_op==`MDF_OP_FMA)|(req_op==`MDF_OP_FNA)|
                           (req_op==`MDF_OP_FMS)|(req_op==`MDF_OP_FNS)) ? {1'b0,expm} - {1'b0,expz} :
                          {9{1'bx}});

   reg [25:0]    fracr;
   reg [26:0]    guard;

   wire [2:0]    grs = {guard[26],guard[25],|guard[24:0]};
   wire [4:0]    nrmsft;                                        // expr >= nrmsft : subnormal output
   wire [25+3:0] nrmi,nrm0,nrm1,nrm2,nrm3,nrm4;

   assign nrmsft[4] = (~(|nrmi[25+3:9+3]) |(&nrmi[25+3:9+3]) )& (expr[7:4]!=4'h0);
   assign nrmsft[3] = (~(|nrm0[25+3:17+3])|(&nrm0[25+3:17+3]))&((expr[7:3]&{3'h7, ~nrmsft[4],  1'b1})!=5'h00);
   assign nrmsft[2] = (~(|nrm1[25+3:21+3])|(&nrm1[25+3:21+3]))&((expr[7:2]&{4'hf, ~nrmsft[4:3],1'b1})!=6'h00);
   assign nrmsft[1] = (~(|nrm2[25+3:23+3])|(&nrm2[25+3:23+3]))&((expr[7:1]&{5'h1f,~nrmsft[4:2],1'b1})!=7'h00);
   assign nrmsft[0] = (~(|nrm3[25+3:24+3])|(&nrm3[25+3:24+3]))&((expr[7:0]&{6'h3f,~nrmsft[4:1],1'b1})!=8'h00);

   assign nrmi = {fracr,grs};
   assign nrm0 = (~nrmsft[4]) ? nrmi : {nrmi[9+3 :0], 16'h0000};
   assign nrm1 = (~nrmsft[3]) ? nrm0 : {nrm0[17+3:0], 8'h00};
   assign nrm2 = (~nrmsft[2]) ? nrm1 : {nrm1[21+3:0], 4'h0};
   assign nrm3 = (~nrmsft[1]) ? nrm2 : {nrm2[23+3:0], 2'b00};
   assign nrm4 = (~nrmsft[0]) ? nrm3 : {nrm3[24+3:0], 1'b0};
   wire [1:0] ssn = {nrm4[2],(|nrm4[1:0])};
   wire [2:0] grsn = {nrm4[4:3],|ssn};
   assign rnd = (~nrmi[28]) ? (grsn[1:0]==2'b11)|(grsn[2:1]==2'b11)
                            : ((grsn[1:0]==2'b00)|                          // inc
                               ((grsn[1]^grsn[0])     &(grsn[0]))|          // rs=11
                               ((grsn[2]^(|grsn[1:0]))&(grsn[1]^grsn[0]))); // gr=11
   wire [7:0]  expn = expr-nrmsft+(nrmi[28]^nrm4[27]); // subnormal(+0) or normal(+1)

   always @(*)begin
      fflag=0;
      if(fpu_ex)begin
         frslt[31:0] = {buf0[31],{8{buf0[30]}},buf0[22:0]};
         fflag[4:2] = buf0[29:27];
      end else if({fracr,guard}==0)begin
         frslt[31:0] = {sgn0&sgn1,31'h0};//TEMP//TEMP//not pipe
      end else if(~nrmi[28])begin
         fflag[0]=|grsn[1:0];
         if((expr[7:1]==7'h7f)&(nrmi[27]))begin
            frslt[30:0] = 31'h7f800000;
            fflag[2]=1'b1;
            fflag[0]=1'b1;
         end else begin
            frslt[30:0] = {expn,nrm4[26:4]}+rnd;
            fflag[0]=|grsn[1:0];
            fflag[1]=((frslt[30:23]==8'h00)|((expn[7:0]==8'h00)&~ssn[1]))&(fflag[0]);
            fflag[2]=(frslt[30:23]==8'hff);
         end
         frslt[31] = sgn1;
      end else begin
         frslt[30:0] = {expn,~nrm4[26:4]}+rnd;
         frslt[31] = ~sgn1;
         fflag[0]=|grsn[1:0];
         fflag[1]=((frslt[30:23]==8'h00)|((expn[7:0]==8'h00)&((~ssn[1]&~ssn[0])|(ssn[1]&ssn[0])) ))&(fflag[0]);
      end
   end
//   assign frslt[30:0] = {expn,nrm4[26:4]}+rnd;
//   assign frslt[31] = sgn1;

///////////////// FPU Only ^^^^^^^^^^^^^^^^^^^^^^^^^^^^

   always @ (*) begin
      if(   (op==`MDF_OP_MUL)|(op==`MDF_OP_FML)|
         ( ((op==`MDF_OP_FMA)|(op==`MDF_OP_FNA)|(op==`MDF_OP_FMS)|(op==`MDF_OP_FNS)) &(i>1) )  )begin
         in0v = 2'b00;
         in1v = 2'b00;
         in2v = 2'b00;
         in10[32] = 1'b0; in11[32] = 1'b0; in12[32] = 1'b0;
         case(i)
           5: begin
              in00[32:0] = {3'b000,by0[35:14],8'h00};
              in01[32:0] = {1'b0,by1[35:12],8'h00};
              in02[32:0] = {1'b0,by2[33:10],8'h00};
              {in20[32:0],in10[31:0]} = {7'h00,by3[35:0],               by0[13:0]               ,8'h00};
              {in21[32:0],in11[31:0]} = {5'h00,by4[35:0],1'b0,ng3,      by1[11:0],1'b0,ng0      ,8'h00};
              {in22[32:0],in12[31:0]} = {3'h0 ,by5[35:0],1'b0,ng4,2'b00,by2[ 9:0],1'b0,ng1,2'b00,8'h00};
           end
           4,3: begin
              in00[32:0] = {3'b000,ms[50],~ms[50],ms[49:30],ms[29:22]};
              in01[32:0] = {1'b0,by1[35:12],8'h00};
              in02[32:0] = {1'b0,by2[33:10],8'h00};
              {in20[32:0],in10[31:0]} = {3'h0 , m[64], ~m[64], m[63:12]                       ,m[11:4]};
              {in21[32:0],in11[31:0]} = {5'h00,by4[35:0],1'b0,ng5,      by1[11:0],1'b0,ng2      ,8'h00};
              {in22[32:0],in12[31:0]} = {3'h0 ,by5[33:0],1'b0,ng4,2'b00,by2[ 9:0],1'b0,ng1,2'b00,8'h00};
           end
           2: begin
              in00[32:0] = {3'b000,ms[50],~ms[50],ms[49:30],ms[29:22]};//Dummy
              in01[32:0] = {1'b0,by1[35:12],8'h00};//Dummy
              in02[32:0] = {1'b0,by2[33:10],8'h00};//Dummy
              {in20[32:0],in10[31:0]} = {1'b0, m[63:0]};
              {in21[32:0],in11[31:0]} = {1'b0,by4[35:0],1'b0,ng5,26'h0};
              {in22[32:0],in12[31:0]} = {ms[50],~ms[50],ms[49:18],1'b0,ng2,12'h000};
           end
           default: begin // 1
              in00[32:0] = {3'b000,ms[50],~ms[50],ms[49:30],ms[29:22]};//Dummy
              in01[32:0] = {1'b0,by1[35:12],8'h00};//Dummy
              in02[32:0] = {1'b0,by2[33:10],8'h00};//Dummy
              {in20[32:0],in10[31:0]} = {1'b0, m[63:0]};
              {in21[32:0],in11[31:0]} = {1'b0,by3[33:0],1'b0,ng5,28'h0};
              {in22[32:0],in12[31:0]} = {1'b0,by4[31:0],1'b0,ng3,30'h0};
           end
         endcase
      end else if(op==`MDF_OP_DIV)begin
         if(y==0) begin
            in00 = {x_signed&sxh[30],sxh[30:0],xl[31]};
            in01 = {y_signed&y[31],y[31:0]}^{33{~plus}};
            in02 = {33{sign}};
            if(x_signed) begin
               in10 = {xh[0],xl[31:1]};
            end else begin
               in10 = xl[31:0];
            end
            in11 = ({33{1'b0}});
            in12 = ({33{1'b0}});
            in20 = ({33{1'b0}});
            in21 = ({33{1'b1}});
            in22 = ({33{1'b0}});
            if(plus) begin
               in0v = 2'b00;
               in1v = 2'b00;
               in2v = 2'b00;
            end else begin
               in0v = 2'b00;
               in1v = 2'b00;
               in2v = 2'b00;
            end
         end else if((i>2)|(i>1)&(~x_signed))begin
            in00 = {x_signed&sxh[29],sxh[29:0],xl[31:30]};
            in01 = {y_signed&y[31],y[31:0]}^{33{~plus}};
            in02 = 33'h000000000;
            in10 = {x_signed&sxh[29],sxh[29:0],xl[31:30]};
            in11 = {y[31:0],1'b0}^{33{~plus}};
            in12 = 33'h000000000;
            in20 = {x_signed&sxh[29],sxh[29:0],xl[31:30]};
            in21 = {y_signed&y[31],y[31:0]}^{33{~plus}};
            in22 = {y[31:0],1'b0}^{33{~plus}};
            if(plus) begin
               in0v = 2'b00;
               in1v = 2'b00;
               in2v = 2'b00;
            end else begin
               in0v = 2'b01;
               in1v = 2'b01;
               in2v = 2'b11;
            end
         end else if(i>1)begin
            in00 = {x_signed&sxh[30],sxh[30:0],xl[31]};
            in01 = {y_signed&y[31],y[31:0]}^{33{~plus}};
            in02 = {33{sign}};
            in10 = {x_signed&sxh[30],sxh[30:0],xl[31]};
            in11 = {y[31:0],1'b0}^{33{~plus}};
            in12 = {33{sign}};
            in20 = {x_signed&sxh[30],sxh[30:0],xl[31]};
            in21 = {y_signed&y[31],y[31:0]}^{33{~plus}};
            in22 = {y[31:0],1'b0}^{33{~plus}};
            if(plus) begin
               in0v = 2'b00;
               in1v = 2'b00;
               in2v = 2'b00;
            end else begin
               in0v = 2'b01;
               in1v = 2'b01;
               in2v = 2'b11;
            end
//         end else if(i==1)begin
         end else begin
            in00 = {x_signed&sxh[30],sxh[30:0],xl[31]};
            in01 = {y_signed&y[31],y[31:0]}^{33{~plus}};
            in02 = {33{sign}};
            in10 = sxh;
            in11 = {{32{1'b0}},(buf0[32]&sign)};
            in12 = ({33{1'b0}});
            in20 = ({33{1'b0}});
            in21 = q^{33{plus}};
            in22 = dq^{33{plus}};
            if(plus) begin
               in0v = 2'b00;
               in1v = 2'b00;
               in2v = 2'b11;
            end else begin
               in0v = 2'b00;
               in1v = 2'b00;
               in2v = 2'b00;
            end
         end
      end else if((op==`MDF_OP_FAD)|(op==`MDF_OP_FSB))begin
         in0v = 2'b00;
         in1v = 2'b00;
         in2v = 2'b00;
         in00 = {33{1'b0}};
         in01 = {33{1'b0}};
         in02 = {33{1'b0}};
         in10[32] = 1'b0;
         in11[32] = 1'b0;
         in12[32] = 1'b0;
         if(expd>=27)begin
            if(sgn0^sgn1)begin  // {fracr,guard} <= {frac1,27'h0}-({frac0,27'h0}>>27);
               {in20[32:0],in10[31:0]} =  {1'b0,xh[31:0],xl[31:0]};
               {in21[32:0],in11[31:0]} =~({1'b0,buf2[31:0],buf1[31:0]}>>27);
               {in22[32:0],in12[31:0]} =  {{33{1'b0}},{31{1'b0}},1'b1};
            end else begin      // {fracr,guard} <= {frac1,27'h0}+({frac0,27'h0}>>27);
               {in20[32:0],in10[31:0]} =  {1'b0,xh[31:0],xl[31:0]};
               {in21[32:0],in11[31:0]} = ({1'b0,buf2[31:0],buf1[31:0]}>>27);
               {in22[32:0],in12[31:0]} =  {{33{1'b0}},{31{1'b0}},1'b0};
            end
         end else begin
            if(sgn0^sgn1)begin  // {fracr,guard} <= {frac1,27'h0}-({frac0,27'h0}>>expd);
               {in20[32:0],in10[31:0]} =  {1'b0,xh[31:0],xl[31:0]};
               {in21[32:0],in11[31:0]} =~({1'b0,buf2[31:0],buf1[31:0]}>>expd);
               {in22[32:0],in12[31:0]} =  {{33{1'b0}},{31{1'b0}},1'b1};
            end else begin      // {fracr,guard} <= {frac1,27'h0}+({frac0,27'h0}>>expd);
               {in20[32:0],in10[31:0]} =  {1'b0,xh[31:0],xl[31:0]};
               {in21[32:0],in11[31:0]} = ({1'b0,buf2[31:0],buf1[31:0]}>>expd);
               {in22[32:0],in12[31:0]} =  {{33{1'b0}},{31{1'b0}},1'b0};
            end
         end
//      end else if((op==`MDF_OP_FMA)|(op==`MDF_OP_FNA)|(op==`MDF_OP_FMS)|(op==`MDF_OP_FNS))begin
      end else begin
         in0v = 2'b00;
         in1v = 2'b00;
         in2v = 2'b00;
         in10[32] = 1'b0;
         in11[32] = 1'b0;
         in12[32] = 1'b0;
         in00[32] = 1'b0;
         in01[32] = 1'b0;
         in02[32] = 1'b0;
         if(expd>=55)begin
            if(sgn0^sgn1)begin  // {m,guard} <= {m[55:0],25'h0}-({fracz,56'h0}>>55);
               {in20[32:0],in10[31:0],in00[31:0]} =~({1'b0,xl[31:0],63'h0}>>55);
               {in21[32:0],in11[31:0],in01[31:0]} = ({1'b0,buf2[31:0],buf1[31:0],32'h0});
//               {in22[32:0],in12[31:0],in02[31:0]} =  {{33{1'b0}},{32{1'b0}},{31{1'b0}},1'b1};
               {in22[32:0],in12[31:0],in02[31:0]} =  {{33{1'b0}},{31{1'b0}},1'b1,{32{1'b0}}}; //TEMP//TEMP// loss of accuracy
            end else begin      // {m,guard} <= {m[55:0],25'h0}+({fracz,56'h0}>>55);
               {in20[32:0],in10[31:0],in00[31:0]} = ({1'b0,xl[31:0],63'h0}>>55);
               {in21[32:0],in11[31:0],in01[31:0]} = ({1'b0,buf2[31:0],buf1[31:0],32'h0});
               {in22[32:0],in12[31:0],in02[31:0]} =  {{33{1'b0}},{32{1'b0}},{31{1'b0}},1'b0};
            end
         end else begin
            if(sgn0^sgn1)begin  // {m[55:0],25'h0}-({fracz,56'h0}>>expd);
               {in20[32:0],in10[31:0],in00[31:0]} =~({1'b0,xl[31:0],63'h0}>>expd);
               {in21[32:0],in11[31:0],in01[31:0]} = ({1'b0,buf2[31:0],buf1[31:0],32'h0});
//               {in22[32:0],in12[31:0],in02[31:0]} =  {{33{1'b0}},{32{1'b0}},{31{1'b0}},1'b1};
               {in22[32:0],in12[31:0],in02[31:0]} =  {{33{1'b0}},{31{1'b0}},1'b1,{32{1'b0}}}; //TEMP//TEMP// loss of accuracy
            end else begin      // {m[55:0],25'h0}+({fracz,56'h0}>>expd);
               {in20[32:0],in10[31:0],in00[31:0]} = ({1'b0,xl[31:0],63'h0}>>expd);
               {in21[32:0],in11[31:0],in01[31:0]} = ({1'b0,buf2[31:0],buf1[31:0],32'h0});
               {in22[32:0],in12[31:0],in02[31:0]} =  {{33{1'b0}},{32{1'b0}},{31{1'b0}},1'b0};
            end
         end
      end
   end

   wire [32:0] sum0,sum1,sum2;
   wire [33:0] cry0,cry1,cry2;

   wire        sum64 = ((op==`MDF_OP_MUL)|(op==`MDF_OP_FAD)|(op==`MDF_OP_FSB)|(op==`MDF_OP_FML)|
                        (op==`MDF_OP_FMA)|(op==`MDF_OP_FNA)|(op==`MDF_OP_FMS)|(op==`MDF_OP_FNS));

   csa csa0(.in0(in00[32:0]), .in1(in01[32:0]), .in2(in02[32:0]), .sum(sum0[32:0]), .cry(cry0[33:1]));
   csa csa1(.in0(in10[32:0]), .in1(in11[32:0]), .in2(in12[32:0]), .sum(sum1[32:0]), .cry(cry1[33:1]));
   csa csa2(.in0(in20[32:0]), .in1(in21[32:0]), .in2(in22[32:0]), .sum(sum2[32:0]), .cry(cry2[33:1]));

   assign cry0[0] = in0v[0];
   assign cry1[0] = in1v[0];
   assign cry2[0] = (sum64) ? cry1[32] : in2v[0];

   wire [32:0] out0 = sum0[32:0] + {       cry0[32],cry0[31:0]} +  in0v[1];
   wire [32:0] out1 = sum1[32:0] + {~sum64&cry1[32],cry1[31:0]} +  in1v[1];
   wire [32:0] out2 = sum2[32:0] + {       cry2[32],cry2[31:0]} + (in2v[1]|(sum64&out1[32]));

   always @ (posedge clk) begin
      resp_valid <= 1'b0;
      fop <= `MDF_OP_NOP;
      if(~req_ready) begin
         buf2 <= out2;
         buf1 <= out1;
         if(~fpu_ex)begin
            buf0 <= out0;
         end
      end
      if(reset) begin
         i<=0;
         fpu_ex <= 1'b0;
      end else if(req_valid & req_ready) begin // req cycle
         fpu_ex <= 1'b0;
         if(req_op==`MDF_OP_MUL) begin // req cycle MUL
            i<=5;
            xh<=req_in_1;
         end else if(req_op==`MDF_OP_DIV) begin  // req cycle DIV
            i  <= 17;
            q  <= ({32{1'b0}});
            sign <=  req_in_1[31]&req_in_1_signed;
            plus <= (req_in_1[31]&req_in_1_signed)^(req_in_2[31]&req_in_1_signed);
            if(req_in_1_signed) begin
               xh <= ({32{req_in_1[31]}});
               xl <= {req_in_1[30:0],1'b0};
            end else begin
               xh <= ({32{1'b0}});
               xl <= req_in_1[31:0];
            end
            buf2[32] <= ~(req_in_1_signed&req_in_1[31]);
            buf1[32] <= ~(req_in_1_signed&req_in_1[31]);
            buf0[32] <= ~(req_in_1_signed&req_in_1[31]);
         end else if(req_op==`MDF_OP_NOP) begin // req cycle FPU
            resp_valid <= 1'b1;
            buf2[31:0] <= req_in_1[31:0];
         end else if(req_op==`MDF_OP_SGN) begin // req cycle FPU
            resp_valid <= 1'b1;
            case(req_rm)
              3'b000 : buf2[31:0] <= { req_in_2[31],req_in_1[30:0]};
              3'b001 : buf2[31:0] <= {~req_in_2[31],req_in_1[30:0]};
              3'b010 : buf2[31:0] <= {req_in_1[31]^req_in_2[31],req_in_1[30:0]};
            endcase
         end else if((req_op==`MDF_OP_FAD)|(req_op==`MDF_OP_FSB)) begin // req cycle FPU ADD SUB
            resp_valid <= 1'b1;
            buf0 <= out0;
            if((req_in_1[30:23]==8'hff)&(req_in_1[22:0]!=0))begin
               fpu_ex <= 1'b1;
               buf0 <= req_in_1|32'h00400000;
               buf0[29:23] <= 0;
               buf0[29] <= ~req_in_1[22]|((req_in_2[30:23]==8'hff)&~req_in_2[22]&(req_in_2[21:0]!=0));
            end else if((req_in_2[30:23]==8'hff)&(req_in_2[22:0]!=0))begin
               fpu_ex <= 1'b1;
               buf0 <= (req_in_2^32'h80000000)|32'h00400000;
               buf0[29:23] <= 0;
               buf0[29] <= ~req_in_2[22]|((req_in_1[30:23]==8'hff)&~req_in_1[22]&(req_in_1[21:0]!=0));
            end else if((req_in_1[30:23]==8'hff)&(req_in_2[30:23]==8'hff))begin
               fpu_ex <= 1'b1;
               if(req_in_1[31]^req_in_2[31]^(req_op==`MDF_OP_FSB))begin
//                  buf0[31:0] <= 32'hffc00000;//TEMP//TEMP//
                  buf0[31:0] <= 32'h7fc00000;//TEMP//TEMP//
                  buf0[29:23] <= 0;
                  buf0[29] <= 1'b1;
               end else begin
                  buf0[31:0] <= req_in_1;
                  buf0[29:23] <= 0;
               end
            end else if(req_in_1[30:23]==8'hff)begin
               fpu_ex <= 1'b1;
               buf0[31:0] <= req_in_1;
               buf0[29:23] <= 0;
            end else if(req_in_2[30:23]==8'hff)begin
               fpu_ex <= 1'b1;
               buf0[31:0] <= req_in_2^32'h80000000;
               buf0[29:23] <= 0;
            end

            if(exps>=0)begin
               sgn1 <= req_in_1[31];
               sgn0 <= req_in_2[31]^(req_op==`MDF_OP_FSB);
               expr <= expx;
               expd <= exps;
               buf1[32]<=1'b0;
               {xh,xl[31:0]}      <= {(req_in_1[30:23]!=8'h00),req_in_1[22:0],27'h0};
               {buf2, buf1[31:0]} <= {(req_in_2[30:23]!=8'h00),req_in_2[22:0],27'h0};
            end else begin
               sgn0 <= req_in_1[31];
               sgn1 <= req_in_2[31]^(req_op==`MDF_OP_FSB);
               expr <= expy;
               expd <= -exps;
               buf1[32]<=1'b0;
               {buf2, buf1[31:0]} <= {(req_in_1[30:23]!=8'h00),req_in_1[22:0],27'h0};
               {xh,xl[31:0]}      <= {(req_in_2[30:23]!=8'h00),req_in_2[22:0],27'h0};
            end
         end else if(req_op==`MDF_OP_FML) begin // req cycle FPU MUL
            fpu_ex <= 1'b0;
            //TEMP//TEMP//special case
            i<=5;
            sgn1 <= req_in_1[31]^req_in_2[31];
            expr <= exps;
            xh<={8'h00,(req_in_1[30:23]!=8'h00),req_in_1[22:0]};
         end else if((req_op==`MDF_OP_FMA)|(req_op==`MDF_OP_FNA)|(req_op==`MDF_OP_FMS)|(req_op==`MDF_OP_FNS)) begin // req cycle FPU MADD
            fpu_ex <= 1'b0;
            //TEMP//TEMP//special case
            i<=5;
            xh<={8'h00,(req_in_1[30:23]!=8'h00),req_in_1[22:0]};
            xl<={8'h00,(req_in_3[30:23]!=8'h00),req_in_3[22:0]};
            if(exps>=0)begin
               sgn1 <= req_in_1[31]^req_in_2[31]^(req_op==`MDF_OP_FNA)^(req_op==`MDF_OP_FNS);
               sgn0 <= req_in_3[31]^(req_op==`MDF_OP_FNA)^(req_op==`MDF_OP_FMS);
               expr <= expm;
               expd <= exps;
            end else begin
            end
         end
      end else begin
         if(((op==`MDF_OP_MUL)&(i>0))|((op==`MDF_OP_FML)&(i>0))|
            (((op==`MDF_OP_FMA)|(op==`MDF_OP_FNA)|(op==`MDF_OP_FMS)|(op==`MDF_OP_FNS))&(i>1))) begin // cont cycle MUL
            ng2 <= (br2[2:1]==2'b10)|(br2[2:0]==3'b110);
            if(i!=2)
              ng5 <= (br5[2:1]==2'b10)|(br5[2:0]==3'b110);
            else
              ng5 <= (br4[2:1]==2'b10)|(br4[2:0]==3'b110);
            if((op==`MDF_OP_FML)&(i==2))begin
               {fracr[25:0],guard[26:0]} <= {out2[24:0],out1[31:5],|out1[4:0]}; //TEMP//TEMP//TEMP//
               resp_valid <= 1'b1;
               i<=0;
            end else if(i==1)begin
               resp_valid <= 1'b1;
               i<=i-1;
            end else begin
               i<=i-1;
            end
            if(x_signed)
              xh<={{4{xh[31]}},xh[31:4]};
            else
              xh<={4'h0       ,xh[31:4]};
         end else if((op==`MDF_OP_DIV)&(i>0)) begin // cont cycle DIV
            if(y==0) begin // DIV
               resp_valid <= 1'b1;
               i <= 0;
            end else if((i>2)|(i>1)&(~x_signed))begin
               q[31:2] <= q[29:0]|dq;
               xh <= {sxh[29:0],xl[31:30]};
               xl <= {xl[29:0],2'b00};
               i  <= i-1;
            end else if(i>1)begin
               q[31:1] <= q[30:0]|dq;
               xh <= {sxh[30:0],xl[31]};
               xl <= {xl[30:0],1'b0};
               i  <= i-1;
            end else if(i==1)begin
               resp_valid <= 1'b1;
               i  <= i-1;
            end
         end else if((op==`MDF_OP_FAD)|(op==`MDF_OP_FSB)) begin // cont cycle FAD FSB
            {fracr[25:0],guard[26:0]} <= {out2[20:0],out1[31:0]};
            if(resp_valid) fop <= op;
         end else if(((op==`MDF_OP_FMA)|(op==`MDF_OP_FNA)|(op==`MDF_OP_FMS)|(op==`MDF_OP_FNS))&(i==1)) begin // cont cycle FMADD
            {fracr[25:0],guard[26:0]} <= {out2[24:0],out1[31:5],|out1[4:0]}; //TEMP//TEMP//TEMP//
            resp_valid <= 1'b1;
            i<=0;
         end else if(((op==`MDF_OP_FML)|(op==`MDF_OP_FMA)|(op==`MDF_OP_FNA)|(op==`MDF_OP_FMS)|(op==`MDF_OP_FNS))&(resp_valid))begin
            fop <= op;
         end
      end // cont cycle
   end

endmodule

module booth
  (
   input             i,
   input             y_signed,
   input [2:0]       br,
   input [31:0]      y,
   output reg [35:0] by
   );

   wire              S = ((br==3'b000)|(br==3'b111)) ? 1'b0 : (y[31]&y_signed)^br[2] ;

   always @(*) begin
      case(br)
        3'b000: by[32:0] =  {33{1'b0}};
        3'b001: by[32:0] =  {y[31]&y_signed,y[31:0]};
        3'b010: by[32:0] =  {y[31]&y_signed,y[31:0]};
        3'b011: by[32:0] =  {y[31:0],1'b0};
        3'b100: by[32:0] = ~{y[31:0],1'b0};
        3'b101: by[32:0] = ~{y[31]&y_signed,y[31:0]};
        3'b110: by[32:0] = ~{y[31]&y_signed,y[31:0]};
        3'b111: by[32:0] =  {33{1'b0}};
      endcase
      if(i) by[35:33] = {2'b01,~S};
      else  by[35:33] = {~S,S,S};
   end
endmodule

module csa
  #(
    parameter w = 33
    )
   (
    input [w-1:0]  in0,
    input [w-1:0]  in1,
    input [w-1:0]  in2,
    output [w-1:0] sum,
    output [w:1]   cry
    );

   assign sum = in0^in1^in2;
   assign cry = (in0&in1)|(in1&in2)|(in2&in0);

endmodule
