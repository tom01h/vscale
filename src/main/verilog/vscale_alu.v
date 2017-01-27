`include "vscale_alu_ops.vh"
`include "rv32_opcodes.vh"
`include "vscale_ctrl_constants.vh"

module vscale_alu
  (
   input [`ALU_OP_WIDTH-1:0]    op,
   input [`SRC_A_SEL_WIDTH-1:0] src_a_sel,
   input [`XPR_LEN-1:0]         PC_DX,
   input [`XPR_LEN-1:0]         rs1_data,
   input [`SRC_B_SEL_WIDTH-1:0] src_b_sel,
   input [`XPR_LEN-1:0]         imm,
   input [`XPR_LEN-1:0]         rs2_data,
   output reg [`XPR_LEN-1:0]    out
   );

   reg [`XPR_LEN-1:0]           in1;
   reg [`XPR_LEN-1:0]           in2;
   always @(*) begin
      case (src_a_sel)
        `SRC_A_RS1 : in1 = rs1_data;
        `SRC_A_PC : in1 = PC_DX;
        default : in1 = 0;
      endcase // case (src_a_sel)
   end

   always @(*) begin
      case (src_b_sel)
        `SRC_B_RS2 : in2 = rs2_data;
        `SRC_B_IMM : in2 = imm;
        `SRC_B_FOUR : in2 = 4;
        default : in2 = 0;
      endcase // case (src_b_sel)
   end

   wire [`SHAMT_WIDTH-1:0]   shamt;

   assign shamt = in2[`SHAMT_WIDTH-1:0];

   always @(*) begin
      case (op)
        `ALU_OP_ADD : out = in1 + in2;
        `ALU_OP_SLL : out = in1 << shamt;
        `ALU_OP_XOR : out = in1 ^ in2;
        `ALU_OP_OR : out = in1 | in2;
        `ALU_OP_AND : out = in1 & in2;
        `ALU_OP_SRL : out = in1 >> shamt;
        `ALU_OP_SEQ : out = {31'b0, in1 == in2};
        `ALU_OP_SNE : out = {31'b0, in1 != in2};
        `ALU_OP_SUB : out = in1 - in2;
        `ALU_OP_SRA : out = $signed(in1) >>> shamt;
        `ALU_OP_SLT : out = {31'b0, $signed(in1) < $signed(in2)};
        `ALU_OP_SGE : out = {31'b0, $signed(in1) >= $signed(in2)};
        `ALU_OP_SLTU : out = {31'b0, in1 < in2};
        `ALU_OP_SGEU : out = {31'b0, in1 >= in2};
        default : out = 0;
      endcase // case op
   end


endmodule // vscale_alu
