`include "vscale_ctrl_constants.vh"
`include "vscale_alu_ops.vh"
`include "rv32_opcodes.vh"
`include "vscale_csr_addr_map.vh"
`include "vscale_md_constants.vh"

module vscale_ctrl
  (
   input                              clk,
   input                              reset,
   input [`INST_WIDTH-1:0]            inst_DX,
   input                              imem_wait,
   input                              imem_badmem_e,
   input                              dmem_wait,
   input                              dmem_badmem_e,
   input                              cmp_true,
   input [`PRV_WIDTH-1:0]             ms_prv,
   input [`FS_WIDTH-1:0]              ms_fs,
   output reg [`PC_SRC_SEL_WIDTH-1:0] PC_src_sel,
   output reg                         branch_taken,
   output reg [`IMM_TYPE_WIDTH-1:0]   imm_type,
   output                             bypass_rs1,
   output                             bypass_rs2,
   output [1:0]                       bypass_frs1,
   output [1:0]                       bypass_frs2,
   output [1:0]                       bypass_frs3,
   output reg [`SRC_A_SEL_WIDTH-1:0]  src_a_sel,
   output reg [`SRC_B_SEL_WIDTH-1:0]  src_b_sel,
   output reg                         src_f_sel,
   output reg [`ALU_OP_WIDTH-1:0]     alu_op,
   output wire                        dmem_read,
   output wire                        dmem_write,
   output wire [2:0]                  dmem_size,
   output wire [`MEM_TYPE_WIDTH-1:0]  dmem_type,
   output                             md_req_valid,
   input                              md_req_ready,
   output reg                         md_req_in_1_signed,
   output reg                         md_req_in_2_signed,
   output reg [`MDF_OP_WIDTH-1:0]     md_req_op,
   output reg                         md_req_out_sel,
   input                              md_resp_valid,
   output wire                        mret,
   output                             csr_req,
   output reg [`CSR_CMD_WIDTH-1:0]    csr_cmd,
   output reg                         csr_imm_sel,
   input                              misaligned_addr_p,
   input                              misaligned_fetch,
   input                              illegal_csr_access,
   input                              interrupt_pending,
   input                              interrupt_taken,
   output wire                        wr_reg_WB,
   output reg                         wr_freg_FWB,
   output reg [`REG_ADDR_WIDTH-1:0]   reg_to_wr_WB,
   output reg [`REG_ADDR_WIDTH-1:0]   freg_to_wr_FWB,
   output reg [`WB_SRC_SEL_WIDTH-1:0] wb_src_sel_WB,
   output reg [`WB_SRC_SEL_WIDTH-1:0] wb_fsrc_sel_FWB,
   output wire                        stall_IF,
   output wire                        kill_IF,
   output wire                        stall_DX,
   output wire                        kill_DX,
   output wire                        stall_WB,
   output wire                        kill_WB,
   output wire                        exception_WB,
   output wire [`ECODE_WIDTH-1:0]     exception_code_WB,
   output wire                        retire_WB,
   output wire                        stall_FWB
   );

   // IF stage ctrl pipeline registers
   reg                                replay_IF;

   // IF stage ctrl signals
   wire                               ex_IF;

   // DX stage ctrl pipeline registers
   reg                                had_ex_DX;
   reg                                prev_killed_DX;

   // DX stage ctrl signals
   wire [6:0]                         opcode = inst_DX[6:0];
   wire [6:0]                         funct7 = inst_DX[31:25];
   wire [11:0]                        funct12 = inst_DX[31:20];
   wire [2:0]                         funct3 = inst_DX[14:12];
   wire [`REG_ADDR_WIDTH-1:0]         rs1_addr = inst_DX[19:15];
   wire [`REG_ADDR_WIDTH-1:0]         rs2_addr = inst_DX[24:20];
   wire [`REG_ADDR_WIDTH-1:0]         rs3_addr = inst_DX[31:27];
   wire [`REG_ADDR_WIDTH-1:0]         reg_to_wr_DX = inst_DX[11:7];
   reg                                illegal_instruction;
   reg                                ebreak;
   reg                                ecall;
   reg                                mret_unkilled;
   reg                                fence_i;
   wire [`ALU_OP_WIDTH-1:0]           add_or_sub;
   wire [`ALU_OP_WIDTH-1:0]           srl_or_sra;
   reg [`ALU_OP_WIDTH-1:0]            alu_op_arith;
   reg                                bra;
   reg                                dmem_read_unkilled;
   reg                                dmem_write_unkilled;
   reg                                jal;
   reg                                jalr;
   wire                               redirect;
   reg                                wr_reg_unkilled_DX;
   wire                               wr_reg_DX;
   reg                                wr_freg_unkilled_DX;
   wire                               wr_freg_DX;
   reg                                bypass_freg_unkilled_DX;
   wire                               bypass_freg_DX;
   reg [`WB_SRC_SEL_WIDTH-1:0]        wb_src_sel_DX;
   reg [`WB_SRC_SEL_WIDTH-1:0]        wb_fsrc_sel_DX;
   wire                               new_ex_DX;
   wire                               ex_DX;
   reg [`ECODE_WIDTH-1:0]             ex_code_DX;
   wire                               killed_DX;
   reg                                uses_md_unkilled;
   wire                               uses_md;
   reg                                wfi_unkilled_DX;
   wire                               wfi_DX;
   
   // WB stage ctrl pipeline registers
   reg                                wr_reg_unkilled_WB;
   reg                                wr_freg_unkilled_WB;
   wire                               wr_freg_WB;
   reg                                bypass_freg_unkilled_WB;
   wire                               bypass_freg_WB;
   reg [`WB_SRC_SEL_WIDTH-1:0]        wb_fsrc_sel_WB;
   reg                                had_ex_WB;
   reg [`ECODE_WIDTH-1:0]             prev_ex_code_WB;
   reg                                dmem_read_WB;
   reg                                dmem_write_WB;
   reg                                prev_killed_WB;
   reg                                uses_md_WB;
   reg                                wfi_unkilled_WB;
   
   // WB stage ctrl pipeline registers
   reg                                bypass_freg_FWB;

   // WB stage ctrl signals
   wire                               ex_WB;
   reg [`ECODE_WIDTH-1:0]             ex_code_WB;
   wire                               dmem_access_exception;
   wire                               exception = ex_WB;
   wire                               killed_WB;
   wire                               load_in_WB;
   wire                               active_wfi_WB;
   
   // Hazard signals
   wire                               load_use;
   wire                               fpu_use;
   reg                                uses_rs1;
   reg                                uses_rs2;
   wire                               raw_rs1;
   wire                               raw_rs2;
   wire                               raw_on_busy_md;
   reg                                uses_frs1;
   reg                                uses_frs2;
   reg                                uses_frs3;
   wire [1:0]                         raw_frs1;
   wire [1:0]                         raw_frs2;
   wire [1:0]                         raw_frs3;

   reg                                imem_wait_l;
   always @(posedge clk) begin
      imem_wait_l <= imem_wait;
   end

   // IF stage ctrl

   always @(posedge clk) begin
      if (reset) begin
         replay_IF <= 1'b1;
      end else begin
         replay_IF <= (fence_i && dmem_write_WB);
      end
   end

   // interrupts kill IF, DX instructions -- WB may commit
   assign kill_IF = stall_IF || ex_IF || ex_DX || ex_WB || redirect || replay_IF || interrupt_taken;
   assign stall_IF = stall_DX ||
                     ((imem_wait_l && !redirect) && !(ex_WB || interrupt_taken));
   assign ex_IF = imem_badmem_e && !imem_wait_l && !redirect && !replay_IF;

   // DX stage ctrl

   always @(posedge clk) begin
      if (reset) begin
         had_ex_DX <= 0;
         prev_killed_DX <= 0;
      end else if (!stall_DX) begin
         had_ex_DX <= ex_IF;
         prev_killed_DX <= kill_IF;
      end
   end

   // interrupts kill IF, DX instructions -- WB may commit
   // Exceptions never show up falsely due to hazards -- don't get exceptions on stall
   wire misaligned_read  = misaligned_addr_p & dmem_read_unkilled;
   wire misaligned_write = misaligned_addr_p & dmem_write_unkilled;
   assign kill_DX = stall_DX || ex_DX || ex_WB || interrupt_taken;
   assign stall_DX = stall_WB ||
                     (( // internal hazards
                        load_use ||
                        fpu_use ||
                        raw_on_busy_md ||
                        (fence_i && dmem_write_WB) ||
                        (uses_md_unkilled && !md_req_ready)
                        ) && !(ex_DX || ex_WB || interrupt_taken));
   assign new_ex_DX = ebreak || ecall || misaligned_read || misaligned_write || misaligned_fetch || illegal_instruction || illegal_csr_access;
   assign ex_DX = had_ex_DX || new_ex_DX; // TODO: add causes
   assign killed_DX = prev_killed_DX || kill_DX;

   always @(*) begin
      ex_code_DX = `ECODE_INST_ACCESS_FAULT;
      if (had_ex_DX) begin
         ex_code_DX = `ECODE_INST_ACCESS_FAULT;
      end else if (misaligned_read) begin
         ex_code_DX = `ECODE_STORE_AMO_ADDR_MISALIGNED;
      end else if (misaligned_write) begin
           ex_code_DX = `ECODE_LOAD_ADDR_MISALIGNED;
      end else if (misaligned_fetch) begin
         ex_code_DX = `ECODE_INST_ADDR_MISALIGNED;
      end else if (illegal_instruction) begin
         ex_code_DX = `ECODE_ILLEGAL_INST;
      end else if (illegal_csr_access) begin
         ex_code_DX = `ECODE_ILLEGAL_INST;
      end else if (ebreak) begin
         ex_code_DX = `ECODE_BREAKPOINT;
      end else if (ecall) begin
         ex_code_DX = `ECODE_ECALL_FROM_U + ms_prv;
      end
   end // always @ begin


   /*
    Note: the convention is to use an initial default
    assignment for all control signals (except for
    illegal instructions) and override the default
    values when appropriate, rather than using the
    default keyword. The exception is for illegal
    instructions; in the interest of brevity, this
    signal is set in the default case of any case
    statement after initially being zero.
    */

   assign dmem_size = {1'b0,funct3[1:0]};
   assign dmem_type = funct3;

   always @(*) begin
      illegal_instruction = 1'b0;
      csr_cmd = `CSR_IDLE;
      csr_imm_sel = funct3[2];
      ecall = 1'b0;
      ebreak = 1'b0;
      mret_unkilled = 1'b0;
      fence_i = 1'b0;
      branch_taken = 1'b0;
      bra = 1'b0;
      jal = 1'b0;
      jalr = 1'b0;
      uses_rs1 = 1'b1;
      uses_rs2 = 1'b0;
      uses_frs1 = 1'b0;
      uses_frs2 = 1'b0;
      uses_frs3 = 1'b0;
      imm_type = `IMM_I;
      src_a_sel = `SRC_A_RS1;
      src_b_sel = `SRC_B_IMM;
      src_f_sel = 1'b0;
      alu_op = `ALU_OP_ADD;
      dmem_read_unkilled = 1'b0;
      dmem_write_unkilled = 1'b0;
      wr_reg_unkilled_DX = 1'b0;
      wr_freg_unkilled_DX = 1'b0;
      bypass_freg_unkilled_DX = 1'b0;
      wb_src_sel_DX = `WB_SRC_ALU;
      wb_fsrc_sel_DX = `WB_SRC_MD;
      uses_md_unkilled = 1'b0;
      wfi_unkilled_DX = 1'b0;
      case (opcode)
        `RV32_LOAD : begin
           dmem_read_unkilled = 1'b1;
           wr_reg_unkilled_DX = 1'b1;
           wb_src_sel_DX = `WB_SRC_MEM;
        end
        `RV32_STORE : begin
           uses_rs2 = 1'b1;
           imm_type = `IMM_S;
           dmem_write_unkilled = 1'b1;
        end
        `RV32_LOAD_FP : begin
           illegal_instruction = (ms_fs == `FS_OFF);
           src_f_sel = 1'b1;
           dmem_read_unkilled = 1'b1;
           wr_freg_unkilled_DX = 1'b1;
           wb_src_sel_DX = `WB_SRC_MEM;
           wb_fsrc_sel_DX = `WB_SRC_MEM;
           uses_md_unkilled = 1'b1;
        end
        `RV32_STORE_FP : begin
           illegal_instruction = (ms_fs == `FS_OFF);
           src_f_sel = 1'b1;
           uses_frs2 = 1'b1;
           imm_type = `IMM_S;
           dmem_write_unkilled = 1'b1;
        end
        `RV32_BRANCH : begin
           uses_rs2 = 1'b1;
           bra = 1'b1;
           branch_taken = cmp_true;
           src_b_sel = `SRC_B_RS2;
           case (funct3)
             `RV32_FUNCT3_BEQ : alu_op = `ALU_OP_SEQ;
             `RV32_FUNCT3_BNE : alu_op = `ALU_OP_SNE;
             `RV32_FUNCT3_BLT : alu_op = `ALU_OP_SLT;
             `RV32_FUNCT3_BLTU : alu_op = `ALU_OP_SLTU;
             `RV32_FUNCT3_BGE : alu_op = `ALU_OP_SGE;
             `RV32_FUNCT3_BGEU : alu_op = `ALU_OP_SGEU;
             default : illegal_instruction = 1'b1;
           endcase // case (funct3)
        end
        `RV32_JAL : begin
           jal = 1'b1;
           uses_rs1 = 1'b0;
           src_a_sel = `SRC_A_PC;
           src_b_sel = `SRC_B_FOUR;
           wr_reg_unkilled_DX = 1'b1;
        end
        `RV32_JALR : begin
           illegal_instruction = (funct3 != 0);
           jalr = 1'b1;
           src_a_sel = `SRC_A_PC;
           src_b_sel = `SRC_B_FOUR;
           wr_reg_unkilled_DX = 1'b1;
        end
        `RV32_MISC_MEM : begin
           case (funct3)
             `RV32_FUNCT3_FENCE : begin
                if ((inst_DX[31:28] == 0) && (rs1_addr == 0) && (reg_to_wr_DX == 0))
                  ; // most fences are no-ops
                else
                  illegal_instruction = 1'b1;
             end
             `RV32_FUNCT3_FENCE_I : begin
                if ((inst_DX[31:20] == 0) && (rs1_addr == 0) && (reg_to_wr_DX == 0))
                  fence_i = 1'b1;
                else
                  illegal_instruction = 1'b1;
             end
             default : illegal_instruction = 1'b1;
           endcase // case (funct3)
        end
        `RV32_OP_IMM : begin
           alu_op = alu_op_arith;
           wr_reg_unkilled_DX = 1'b1;
           if(inst_DX[25]&((funct3==`RV32_FUNCT3_SLL)|(funct3==`RV32_FUNCT3_SRA_SRL))) // shamt[5] != 0
             illegal_instruction = 1'b1;
        end
        `RV32_OP  : begin
           uses_rs2 = 1'b1;
           src_b_sel = `SRC_B_RS2;
           alu_op = alu_op_arith;
           wr_reg_unkilled_DX = 1'b1;
           if (funct7 == `RV32_FUNCT7_MUL_DIV) begin
              uses_md_unkilled = 1'b1;
              wb_src_sel_DX = `WB_SRC_MD;
           end
        end
        `RV32_SYSTEM : begin
           wb_src_sel_DX = `WB_SRC_CSR;
           wr_reg_unkilled_DX = (funct3 != `RV32_FUNCT3_PRIV);
           case (funct3)
             `RV32_FUNCT3_PRIV : begin
                if ((rs1_addr == 0) && (reg_to_wr_DX == 0)) begin
                   case (funct12)
                     `RV32_FUNCT12_ECALL : ecall = 1'b1;
                     `RV32_FUNCT12_EBREAK : ebreak = 1'b1;
                     `RV32_FUNCT12_MRET : begin
                        if (ms_prv == 0)
                          illegal_instruction = 1'b1;
                        else
                          mret_unkilled = 1'b1;
                     end
                     `RV32_FUNCT12_WFI : wfi_unkilled_DX = 1'b1;
                     default : illegal_instruction = 1'b1;
                   endcase // case (funct12)
                end // if ((rs1_addr == 0) && (reg_to_wr_DX == 0))
             end // case: `RV32_FUNCT3_PRIV
             `RV32_FUNCT3_CSRRW : csr_cmd = `CSR_WRITE;
             `RV32_FUNCT3_CSRRS : csr_cmd = (rs1_addr == 0) ? `CSR_READ : `CSR_SET;
             `RV32_FUNCT3_CSRRC : csr_cmd = (rs1_addr == 0) ? `CSR_READ : `CSR_CLEAR;
             `RV32_FUNCT3_CSRRWI : csr_cmd = `CSR_WRITE;
             `RV32_FUNCT3_CSRRSI : csr_cmd = (rs1_addr == 0) ? `CSR_READ : `CSR_SET;
             `RV32_FUNCT3_CSRRCI : csr_cmd = (rs1_addr == 0) ? `CSR_READ : `CSR_CLEAR;
             default : illegal_instruction = 1'b1;
           endcase // case (funct3)
        end
        `RV32_AUIPC : begin
           uses_rs1 = 1'b0;
           src_a_sel = `SRC_A_PC;
           imm_type = `IMM_U;
           wr_reg_unkilled_DX = 1'b1;
        end
        `RV32_LUI : begin
           uses_rs1 = 1'b0;
           src_a_sel = `SRC_A_ZERO;
           imm_type = `IMM_U;
           wr_reg_unkilled_DX = 1'b1;
        end
        `RV32_OP_FP : begin
           illegal_instruction = (ms_fs == `FS_OFF);
           src_b_sel = `SRC_B_ZERO;
           case (funct7)
             `RV32_FUNCT7_FMVSX : begin
                wr_freg_unkilled_DX = 1'b1;
                bypass_freg_unkilled_DX = 1'b1;
                uses_md_unkilled = 1'b1;
                wb_fsrc_sel_DX = `WB_SRC_ALU;
             end
             `RV32_FUNCT7_FMVXS :begin
                src_f_sel = 1'b1;
                uses_rs1 = 1'b0;
                uses_frs1 = 1'b1;
                wr_reg_unkilled_DX = 1'b1;
                uses_md_unkilled = 1'b1;
                wb_src_sel_DX = `WB_SRC_MD;
             end
             `RV32_FUNCT7_FSGNJ : begin
                src_f_sel = 1'b1;
                uses_rs1 = 1'b0;
                uses_frs1 = 1'b1;
                uses_frs2 = 1'b1;
                wr_freg_unkilled_DX = 1'b1;
                bypass_freg_unkilled_DX = 1'b1;
                uses_md_unkilled = 1'b1;
             end
             `RV32_FUNCT7_FADDS,
             `RV32_FUNCT7_FSUBS,
             `RV32_FUNCT7_FMULS : begin
                src_f_sel = 1'b1;
                uses_rs1 = 1'b0;
                uses_frs1 = 1'b1;
                uses_frs2 = 1'b1;
                wr_freg_unkilled_DX = 1'b1;
                bypass_freg_unkilled_DX = 1'b0;
                uses_md_unkilled = 1'b1;
             end
             default : begin
                illegal_instruction = 1'b1;
             end
           endcase
        end
        `RV32_MADD,
        `RV32_NMADD,
        `RV32_MSUB,
        `RV32_NMSUB : begin
           illegal_instruction = (ms_fs == `FS_OFF);
           src_b_sel = `SRC_B_ZERO;
           src_f_sel = 1'b1;
           uses_rs1 = 1'b0;
           uses_frs1 = 1'b1;
           uses_frs2 = 1'b1;
           uses_frs3 = 1'b1;
           wr_freg_unkilled_DX = 1'b1;
           bypass_freg_unkilled_DX = 1'b0;
           uses_md_unkilled = 1'b1;
        end
        default : begin
           illegal_instruction = 1'b1;
        end
      endcase // case (opcode)
   end // always @ (*)

   assign add_or_sub = ((opcode == `RV32_OP) && (funct7[5])) ? `ALU_OP_SUB : `ALU_OP_ADD;
   assign srl_or_sra = (funct7[5]) ? `ALU_OP_SRA : `ALU_OP_SRL;

   assign md_req_valid = uses_md;

   always @(*) begin
      if(opcode==`RV32_OP) begin
         md_req_op = `MDF_OP_MUL;
         md_req_in_1_signed = 0;
         md_req_in_2_signed = 0;
         md_req_out_sel = `MD_OUT_LO;
         case (funct3)
           `RV32_FUNCT3_MUL : begin
           end
           `RV32_FUNCT3_MULH : begin
              md_req_in_1_signed = 1;
              md_req_in_2_signed = 1;
              md_req_out_sel = `MD_OUT_HI;
           end
           `RV32_FUNCT3_MULHSU : begin
              md_req_in_1_signed = 1;
              md_req_out_sel = `MD_OUT_HI;
           end
           `RV32_FUNCT3_MULHU : begin
              md_req_out_sel = `MD_OUT_HI;
           end
           `RV32_FUNCT3_DIV : begin
              md_req_op = `MDF_OP_DIV;
              md_req_in_1_signed = 1;
              md_req_in_2_signed = 1;
              md_req_out_sel = `MD_OUT_HI;
           end
           `RV32_FUNCT3_DIVU : begin
              md_req_op = `MDF_OP_DIV;
              md_req_out_sel = `MD_OUT_HI;
           end
           `RV32_FUNCT3_REM : begin
              md_req_op = `MDF_OP_DIV;
              md_req_in_1_signed = 1;
              md_req_in_2_signed = 1;
           end
           `RV32_FUNCT3_REMU : begin
              md_req_op = `MDF_OP_DIV;
           end
         endcase
      end else if(opcode==`RV32_OP_FP)begin
         md_req_op = `MDF_OP_NOP;
         md_req_in_1_signed = 0;
         md_req_in_2_signed = 0;
         md_req_out_sel = `MD_OUT_HI;
         case (funct7)
           `RV32_FUNCT7_FSGNJ : begin
              md_req_op = `MDF_OP_SGN;
           end
           `RV32_FUNCT7_FADDS : begin
              md_req_op = `MDF_OP_FAD;
           end
           `RV32_FUNCT7_FSUBS : begin
              md_req_op = `MDF_OP_FSB;
           end
           `RV32_FUNCT7_FMULS : begin
              md_req_op = `MDF_OP_FML;
           end
         endcase
      end else if(opcode==`RV32_MADD)begin
         md_req_in_1_signed = 0;
         md_req_in_2_signed = 0;
         md_req_out_sel = `MD_OUT_HI;
         md_req_op = `MDF_OP_FMA;
      end else if(opcode==`RV32_NMADD)begin
         md_req_in_1_signed = 0;
         md_req_in_2_signed = 0;
         md_req_out_sel = `MD_OUT_HI;
         md_req_op = `MDF_OP_FNA;
      end else if(opcode==`RV32_MSUB)begin
         md_req_in_1_signed = 0;
         md_req_in_2_signed = 0;
         md_req_out_sel = `MD_OUT_HI;
         md_req_op = `MDF_OP_FMS;
      end else if(opcode==`RV32_NMSUB)begin
         md_req_in_1_signed = 0;
         md_req_in_2_signed = 0;
         md_req_out_sel = `MD_OUT_HI;
         md_req_op = `MDF_OP_FNS;
      end else begin
         md_req_op = `MDF_OP_NOP;
         md_req_in_1_signed = 0;
         md_req_in_2_signed = 0;
         md_req_out_sel = `MD_OUT_HI;
      end
   end

   always @(*) begin
      case (funct3)
        `RV32_FUNCT3_ADD_SUB : alu_op_arith = add_or_sub;
        `RV32_FUNCT3_SLL : alu_op_arith = `ALU_OP_SLL;
        `RV32_FUNCT3_SLT : alu_op_arith = `ALU_OP_SLT;
        `RV32_FUNCT3_SLTU : alu_op_arith = `ALU_OP_SLTU;
        `RV32_FUNCT3_XOR : alu_op_arith = `ALU_OP_XOR;
        `RV32_FUNCT3_SRA_SRL : alu_op_arith = srl_or_sra;
        `RV32_FUNCT3_OR : alu_op_arith = `ALU_OP_OR;
        `RV32_FUNCT3_AND : alu_op_arith = `ALU_OP_AND;
        default : alu_op_arith = `ALU_OP_ADD;
      endcase // case (funct3)
   end // always @ begin

   assign mret = mret_unkilled && !kill_DX;
   assign dmem_read = dmem_read_unkilled && !kill_DX;
   assign dmem_write = dmem_write_unkilled && !kill_DX;
   assign wr_reg_DX = wr_reg_unkilled_DX && !kill_DX;
   assign wr_freg_DX = wr_freg_unkilled_DX && !kill_DX;
   assign bypass_freg_DX = bypass_freg_unkilled_DX && !kill_DX;
   assign uses_md = uses_md_unkilled && !kill_DX;
   assign wfi_DX = wfi_unkilled_DX && !kill_DX;
   assign csr_req = (kill_DX) ? 1'b0 : |(csr_cmd);
   assign redirect = (branch_taken || jal || jalr || mret) && !kill_DX;

   always @(*) begin
      if (exception || interrupt_taken) begin
         PC_src_sel = `PC_HANDLER;
//      end else if (replay_IF || (stall_IF && !imem_wait)) begin
      end else if (replay_IF) begin
         PC_src_sel = `PC_REPLAY;
      end else if (mret_unkilled) begin
         PC_src_sel = `PC_EPC;
//      end else if (branch_taken) begin
      end else if (bra) begin
         PC_src_sel = `PC_BRANCH_TARGET;
      end else if (jal) begin
         PC_src_sel = `PC_JAL_TARGET;
      end else if (jalr) begin
         PC_src_sel = `PC_JALR_TARGET;
      end else begin
         PC_src_sel = `PC_PLUS_FOUR;
      end
   end // always @ begin

   // WB stage ctrl

   always @(posedge clk) begin
      if (reset) begin
         prev_killed_WB <= 0;
         had_ex_WB <= 0;
         wr_reg_unkilled_WB <= 0;
         wr_freg_unkilled_WB <= 0;
         bypass_freg_unkilled_WB <= 0;
         dmem_read_WB <= 0;
         dmem_write_WB <= 0;
         uses_md_WB <= 0;
         wfi_unkilled_WB <= 0;
      end else if (!stall_WB) begin
         prev_killed_WB <= killed_DX;
         had_ex_WB <= ex_DX;
         wr_reg_unkilled_WB <= wr_reg_DX;
         wr_freg_unkilled_WB <= wr_freg_DX;
         bypass_freg_unkilled_WB <= bypass_freg_DX;
         wb_src_sel_WB <= wb_src_sel_DX;
         wb_fsrc_sel_WB <= wb_fsrc_sel_DX;
         prev_ex_code_WB <= ex_code_DX;
         reg_to_wr_WB <= reg_to_wr_DX;
         dmem_read_WB <= dmem_read;
         dmem_write_WB <= dmem_write;
         uses_md_WB <= uses_md;
         wfi_unkilled_WB <= wfi_DX;
      end
   end

   // WFI handling
   // can't be killed while in WB stage
   assign active_wfi_WB = !prev_killed_WB && wfi_unkilled_WB 
                          && !(interrupt_taken || interrupt_pending);

   assign kill_WB = stall_WB || ex_WB;
   assign stall_WB = ((dmem_wait && (dmem_read_WB||dmem_write_WB)) || (uses_md_WB && !md_resp_valid) || active_wfi_WB) && !exception;
   assign dmem_access_exception = dmem_badmem_e;
   assign ex_WB = had_ex_WB || dmem_access_exception;
   assign killed_WB = prev_killed_WB || kill_WB;

   always @(*) begin
      ex_code_WB = prev_ex_code_WB;
      if (!had_ex_WB) begin
         if (dmem_access_exception) begin
            ex_code_WB = (wr_reg_unkilled_WB|wr_freg_unkilled_WB) ?
                         `ECODE_LOAD_ACCESS_FAULT :
                         `ECODE_STORE_AMO_ACCESS_FAULT;
         end
      end
   end

   assign exception_WB = ex_WB;
   assign exception_code_WB = ex_code_WB;
   assign wr_reg_WB = wr_reg_unkilled_WB && !kill_WB;
   assign wr_freg_WB = wr_freg_unkilled_WB && !kill_WB;
   assign bypass_freg_WB = bypass_freg_unkilled_WB && !kill_WB;
   assign retire_WB = !(kill_WB || killed_WB);

   // Hazard logic

   assign load_in_WB = dmem_read_WB;

   assign raw_rs1 = (wr_reg_unkilled_WB && (rs1_addr == reg_to_wr_WB) &&
                     (rs1_addr != 0) && uses_rs1);
   assign raw_frs1={(wr_freg_FWB && (rs1_addr == freg_to_wr_FWB) && uses_frs1),
                    (wr_freg_unkilled_WB && (rs1_addr == reg_to_wr_WB) && uses_frs1)};
   assign bypass_rs1 = raw_rs1;
   assign bypass_frs1 = raw_frs1;

   assign raw_rs2 = (wr_reg_unkilled_WB && (rs2_addr == reg_to_wr_WB) &&
                     (rs2_addr != 0) && uses_rs2);
   assign raw_frs2={(wr_freg_FWB && (rs2_addr == freg_to_wr_FWB) && uses_frs2),
                    (wr_freg_unkilled_WB && (rs2_addr == reg_to_wr_WB) && uses_frs2)};
   assign bypass_rs2 = raw_rs2;
   assign bypass_frs2 = raw_frs2;

   assign raw_frs3={(wr_freg_FWB && (rs3_addr == freg_to_wr_FWB) && uses_frs3),
                    (wr_freg_unkilled_WB && (rs3_addr == reg_to_wr_WB) && uses_frs3)};
   assign bypass_frs3 = raw_frs3;

   assign raw_on_busy_md = uses_md_WB && (raw_rs1 || raw_rs2 || raw_frs1[0] || raw_frs2[0] || raw_frs3[0]) &&
                           !md_resp_valid && !bypass_freg_WB;
   assign load_use = load_in_WB && (raw_rs1 || raw_rs2);
   assign fpu_use = (wr_freg_WB  && (raw_frs1[0] || raw_frs2[0] || raw_frs3[0]) && !bypass_freg_WB)||
                    (wr_freg_FWB && (raw_frs1[1] || raw_frs2[1] || raw_frs3[1]) && !bypass_freg_FWB);

   // FWB stage ctrl

   always @(posedge clk) begin
      if (reset) begin
         wr_freg_FWB <= 0;
         bypass_freg_FWB <= 0;
         freg_to_wr_FWB <= 0;
      end else if (~stall_FWB) begin
         wr_freg_FWB <= wr_freg_WB;
         bypass_freg_FWB <= bypass_freg_WB;
         freg_to_wr_FWB <= reg_to_wr_WB;
         wb_fsrc_sel_FWB <= wb_fsrc_sel_WB;
      end
   end

   assign stall_FWB = 1'b0;

endmodule // vscale_ctrl
