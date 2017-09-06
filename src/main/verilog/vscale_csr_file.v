`include "rv32_opcodes.vh"
`include "vscale_csr_addr_map.vh"
`include "vscale_ctrl_constants.vh"
`include "vscale_platform_constants.vh"

module vscale_csr_file
  (
   input                       clk,
   input [`N_EXT_INTS-1:0]     ext_interrupts,
   input                       reset,
   input                       req,
   input [`CSR_ADDR_WIDTH-1:0] addr,
   input [`CSR_CMD_WIDTH-1:0]  cmd,
   input [`XPR_LEN-1:0]        wdata,
   output reg [`PRV_WIDTH-1:0] ms_prv,
   output reg [`FS_WIDTH-1:0]  ms_fs,
   output                      illegal_access,
   output reg [`XPR_LEN-1:0]   rdata,
   input                       retire,
   input [4:0]                 md_resp_fflag,
   input                       exception,
   input [`ECODE_WIDTH-1:0]    exception_code,
   input                       mret,
   input [`XPR_LEN-1:0]        exception_load_addr,
   input [`XPR_LEN-1:0]        exception_PC,
   output [`XPR_LEN-1:0]       handler_PC,
   output [`XPR_LEN-1:0]       epc,
   output                      interrupt_pending,
   output reg                  interrupt_taken
   );

   reg [`CSR_COUNTER_WIDTH-1:0] cycle_full;
   reg [`CSR_COUNTER_WIDTH-1:0] time_full;
   reg [`CSR_COUNTER_WIDTH-1:0] instret_full;
   reg [1:0]                    ms_mpp;
   reg                          ms_mpie, ms_upie, ms_mie, ms_uie;
   reg [`XPR_LEN-1:0]           fcsr;//TEMP//TEMP//
   reg [`XPR_LEN-1:0]           mtvec;
   wire [`XPR_LEN-1:0]          stvec = 32'h0; //TEMP//TEMP//rv32mi-p-csr
   reg [`XPR_LEN-1:0]           utvec; //TEMP//TEMP//
   reg [`XPR_LEN-1:0]           mie;
   reg                          mtip;
   reg                          msip;
   reg [`XPR_LEN-1:0]           mtimecmp;
   reg [`CSR_COUNTER_WIDTH-1:0] mtime_full;
   reg [`XPR_LEN-1:0]           mscratch;
   reg [`XPR_LEN-1:0]           mepc;
   reg [`ECODE_WIDTH-1:0]       mecode;
   reg                          mint;
   reg [`XPR_LEN-1:0]           mbadaddr;

   wire [`XPR_LEN-1:0]          mvendorid = 32'h00000000;
   wire [`XPR_LEN-1:0]          marchid   = 32'h00000000;
   wire [`XPR_LEN-1:0]          mimpid    = 32'h00008000;
   wire [`XPR_LEN-1:0]          mhartid   = 32'h00000000;

   wire [`XPR_LEN-1:0]          mstatus;
   wire [`XPR_LEN-1:0]          misa      = 32'h40101120;
   reg [`XPR_LEN-1:0]           medeleg;
   reg [`XPR_LEN-1:0]           mideleg;
   wire [`XPR_LEN-1:0]          mip;
   wire [`XPR_LEN-1:0]          mcause;

   wire                         mtimer_expired;

   wire                         wen;
   wire                         illegal_region;
   reg                          defined;
   reg [`XPR_LEN-1:0]           wdata_internal;
   wire                         uinterrupt;
   wire                         minterrupt;
   reg [`ECODE_WIDTH-1:0]       interrupt_code;

   wire                         code_imem;


   assign handler_PC = mtvec;

   assign wen = req & (cmd[1] || cmd[0]);

   assign illegal_region = ((cmd[1] || cmd[0]) && (addr[11:10] == 2'b11))
     || (cmd[2] && addr[9:8] > ms_prv);

   assign illegal_access = illegal_region || (cmd[2] && !defined);

   always @(*) begin
      case (cmd)
        `CSR_SET   : wdata_internal = rdata |  wdata;
        `CSR_CLEAR : wdata_internal = rdata & ~wdata;
        default : wdata_internal = wdata;
      endcase // case (cmd)
   end // always @ begin

   assign uinterrupt = 1'b0;
   assign minterrupt = ms_mie & (|(mie & mip));
   assign interrupt_pending = |mip;

   always @(*) begin
      interrupt_code = `ICODE_TIMER;
      case (ms_prv)
        `PRV_U : interrupt_taken = (ms_uie && uinterrupt) || minterrupt;
        `PRV_M : interrupt_taken = (ms_uie && minterrupt);
        default : interrupt_taken = 1'b1;
      endcase // case (ms_prv)
   end

   always @(posedge clk) begin
      if (reset) begin
         ms_fs <= 2'b00;
      end else if (wen && addr == `CSR_ADDR_MSTATUS) begin
         ms_fs <= wdata_internal[14:13];
      end //TEMP//TEMP//for Dirty
   end
   always @(posedge clk) begin
      if (reset) begin
         ms_mpp[1:0] <= 2'b00;
         ms_mpie <= 1'b0;
         ms_upie <= 1'b0;
         ms_mie <= 1'b0;
         ms_uie <= 1'b0;
         ms_prv <= 2'b11;
      end else if (wen && addr == `CSR_ADDR_MSTATUS) begin
         ms_mpp[1:0] <= wdata_internal[12:11];
         ms_mpie <= wdata_internal[7];
         ms_upie <= wdata_internal[4];
         ms_mie <= wdata_internal[3];
         ms_uie <= wdata_internal[0];
      end else if (exception) begin
         // no delegation to U means all exceptions go to M
         ms_mpp[1:0] <= ms_prv[1:0];
         if(ms_prv[1:0] == 2'b11) begin
            ms_mpie <= ms_mie;
         end else begin
            ms_mpie <= ms_uie;
         end
         ms_mie <= 1'b0;
         ms_prv <= 2'b11;
      end else if (mret) begin
         ms_mpp[1:0] <= 2'b00;
         ms_prv <= ms_mpp[1:0];
         ms_mpie <= 1'b1;
         if(ms_mpp[1:0] == 2'b11) begin
            ms_mie <= ms_mpie;
         end else begin
            ms_uie <= ms_mpie;
         end
      end
   end // always @ (posedge clk)

   assign epc = mepc;

   // this implementation has SD, VM, MPRV, XS, and FS set to 0
   assign mstatus = {19'b0, ms_mpp[1:0], 3'b000, ms_mpie, 2'b00, ms_upie, ms_mie, 2'b00, ms_uie};

   assign mtimer_expired = (mtimecmp == mtime_full[0+:`XPR_LEN]);

   always @(posedge clk) begin
      if (reset) begin
         mtip <= 0;
         msip <= 0;
      end else begin
         if (mtimer_expired)
           mtip <= 1;
         if (wen && addr == `CSR_ADDR_MTIMECMP)
           mtip <= 0;
         if (wen && addr == `CSR_ADDR_MIP) begin
            mtip <= wdata_internal[7];
            msip <= wdata_internal[3];
         end
      end // else: !if(reset)
   end // always @ (posedge clk)
   assign mip = {ext_interrupts,mtip,3'b0,msip,3'b0};


   always @(posedge clk) begin
      if (reset) begin
         mie <= 0;
      end else if (wen && addr == `CSR_ADDR_MIE) begin
         mie <= wdata_internal;
      end
   end // always @ (posedge clk)

   always @(posedge clk) begin
      if (interrupt_taken)
        mepc <= (exception_PC & {{30{1'b1}},2'b0}) + `XPR_LEN'h4;
      if (exception)
        mepc <= exception_PC & {{30{1'b1}},2'b0};
      if (wen && addr == `CSR_ADDR_MEPC)
        mepc <= wdata_internal & {{30{1'b1}},2'b0};
   end

   always @(posedge clk) begin
      if (reset) begin
         mecode <= 0;
         mint <= 0;
      end else if (wen && addr == `CSR_ADDR_MCAUSE) begin
         mecode <= wdata_internal[3:0];
         mint <= wdata_internal[31];
      end else begin
         if (interrupt_taken) begin
            mecode <= interrupt_code;
            mint <= 1'b1;
         end else if (exception) begin
            mecode <= exception_code;
            mint <= 1'b0;
         end
      end // else: !if(reset)
   end // always @ (posedge clk)
   assign mcause = {mint,27'b0,mecode};

   assign code_imem = (exception_code == `ECODE_INST_ADDR_MISALIGNED)
     || (exception_code == `ECODE_INST_ADDR_MISALIGNED);

   always @(posedge clk) begin
      if (exception)
        mbadaddr <= (code_imem) ? exception_PC : exception_load_addr;
      if (wen && addr == `CSR_ADDR_MBADADDR)
        mbadaddr <= wdata_internal;
   end

   always @(*) begin
      case (addr)
// read by RDCYCLE/RCTIME/RCINSTRES instructon
//        `CSR_ADDR_CYCLE     : begin rdata = cycle_full[0+:`XPR_LEN]; defined = 1'b1; end
//        `CSR_ADDR_TIME      : begin rdata = time_full[0+:`XPR_LEN]; defined = 1'b1; end
//        `CSR_ADDR_INSTRET   : begin rdata = instret_full[0+:`XPR_LEN]; defined = 1'b1; end
        `CSR_ADDR_CYCLEH    : begin rdata = cycle_full[`XPR_LEN+:`XPR_LEN]; defined = 1'b1; end
        `CSR_ADDR_TIMEH     : begin rdata = time_full[`XPR_LEN+:`XPR_LEN]; defined = 1'b1; end
        `CSR_ADDR_INSTRETH  : begin rdata = instret_full[`XPR_LEN+:`XPR_LEN]; defined = 1'b1; end
        `CSR_ADDR_MVENDORID : begin rdata = mvendorid; defined = 1'b1; end
        `CSR_ADDR_MARCHID   : begin rdata = marchid; defined = 1'b1; end
        `CSR_ADDR_MIMPID    : begin rdata = mimpid; defined = 1'b1; end
        `CSR_ADDR_MHARTID   : begin rdata = mhartid; defined = 1'b1; end
        `CSR_ADDR_MSTATUS   : begin rdata = mstatus; defined = 1'b1; end
        `CSR_ADDR_MISA      : begin rdata = misa; defined = 1'b1; end
        `CSR_ADDR_MTVEC     : begin rdata = mtvec; defined = 1'b1; end
        `CSR_ADDR_STVEC     : begin rdata = stvec; defined = 1'b1; end
        `CSR_ADDR_MEDELEG   : begin rdata = medeleg; defined = 1'b1; end
        `CSR_ADDR_MIDELEG   : begin rdata = mideleg; defined = 1'b1; end
        `CSR_ADDR_MIE       : begin rdata = mie; defined = 1'b1; end
        `CSR_ADDR_MTIMECMP  : begin rdata = mtimecmp; defined = 1'b1; end
        `CSR_ADDR_MTIME     : begin rdata = mtime_full[0+:`XPR_LEN]; defined = 1'b1; end
        `CSR_ADDR_MTIMEH    : begin rdata = mtime_full[`XPR_LEN+:`XPR_LEN]; defined = 1'b1; end
        `CSR_ADDR_MSCRATCH  : begin rdata = mscratch; defined = 1'b1; end
        `CSR_ADDR_MEPC      : begin rdata = mepc; defined = 1'b1; end
        `CSR_ADDR_MCAUSE    : begin rdata = mcause; defined = 1'b1; end
        `CSR_ADDR_MBADADDR  : begin rdata = mbadaddr; defined = 1'b1; end
        `CSR_ADDR_MIP       : begin rdata = mip; defined = 1'b1; end
// read by RDCYCLE/RCTIME/RCINSTRES instructon
//        `CSR_ADDR_CYCLEW    : begin rdata = cycle_full[0+:`XPR_LEN]; defined = 1'b1; end
//        `CSR_ADDR_TIMEW     : begin rdata = time_full[0+:`XPR_LEN]; defined = 1'b1; end
//        `CSR_ADDR_INSTRETW  : begin rdata = instret_full[0+:`XPR_LEN]; defined = 1'b1; end
        `CSR_ADDR_CYCLEHW   : begin rdata = cycle_full[`XPR_LEN+:`XPR_LEN]; defined = 1'b1; end
        `CSR_ADDR_TIMEHW    : begin rdata = time_full[`XPR_LEN+:`XPR_LEN]; defined = 1'b1; end
        `CSR_ADDR_INSTRETHW : begin rdata = instret_full[`XPR_LEN+:`XPR_LEN]; defined = 1'b1; end
        `CSR_ADDR_FCSR      : begin rdata = fcsr&32'h0ff; defined = 1'b1; end
        `CSR_ADDR_FFLAGS    : begin rdata = {27'h0,fcsr[4:0]}; defined = 1'b1; end
        `CSR_ADDR_FRM       : begin rdata = {29'h0,fcsr[7:5]}; defined = 1'b1; end
        default : begin rdata = 0; defined = 1'b0; end
      endcase // case (addr)
   end // always @ (*)


   always @(posedge clk) begin
      if (reset) begin
         cycle_full <= 0;
         time_full <= 0;
         instret_full <= 0;
         mtime_full <= 0;
         mtvec <= 'h100;
         mtimecmp <= 0;
         mscratch <= 0;
         fcsr <= 0;
      end else begin
         cycle_full <= cycle_full + 1;
         time_full <= time_full + 1;
         fcsr[4:0] <= fcsr[4:0] | md_resp_fflag;
         if (retire)
           instret_full <= instret_full + 1;
         mtime_full <= mtime_full + 1;
         if (wen) begin
            case (addr)
              `CSR_ADDR_CYCLE     : cycle_full[0+:`XPR_LEN] <= wdata_internal;
              `CSR_ADDR_TIME      : time_full[0+:`XPR_LEN] <= wdata_internal;
              `CSR_ADDR_INSTRET   : instret_full[0+:`XPR_LEN] <= wdata_internal;
              `CSR_ADDR_CYCLEH    : cycle_full[`XPR_LEN+:`XPR_LEN] <= wdata_internal;
              `CSR_ADDR_TIMEH     : time_full[`XPR_LEN+:`XPR_LEN] <= wdata_internal;
              `CSR_ADDR_INSTRETH  : instret_full[`XPR_LEN+:`XPR_LEN] <= wdata_internal;
              // mvendorid is read-only
              // marchid is read-only
              // mimpid is read-only
              // mhartid is read-only
              // mstatus handled separately
              // misa is read-only
              `CSR_ADDR_MTVEC     : mtvec <= wdata_internal & {{30{1'b1}},2'b0};
              `CSR_ADDR_STVEC     : ;//TEMP//TEMP//rv32mi-p-csr
              `CSR_ADDR_MEDELEG   : medeleg <= wdata_internal;
              `CSR_ADDR_MIDELEG   : mideleg <= wdata_internal;
              // mie handled separately
              `CSR_ADDR_MTIMECMP  : mtimecmp <= wdata_internal;
              `CSR_ADDR_MTIME     : mtime_full[0+:`XPR_LEN] <= wdata_internal;
              `CSR_ADDR_MTIMEH    : mtime_full[`XPR_LEN+:`XPR_LEN] <= wdata_internal;
              `CSR_ADDR_MSCRATCH  : mscratch <= wdata_internal;
              // mepc handled separately
              // mcause handled separately
              // mbadaddr handled separately
              // mip handled separately
              `CSR_ADDR_CYCLEW    : cycle_full[0+:`XPR_LEN] <= wdata_internal;
              `CSR_ADDR_TIMEW     : time_full[0+:`XPR_LEN] <= wdata_internal;
              `CSR_ADDR_INSTRETW  : instret_full[0+:`XPR_LEN] <= wdata_internal;
              `CSR_ADDR_CYCLEHW   : cycle_full[`XPR_LEN+:`XPR_LEN] <= wdata_internal;
              `CSR_ADDR_TIMEHW    : time_full[`XPR_LEN+:`XPR_LEN] <= wdata_internal;
              `CSR_ADDR_INSTRETHW : instret_full[`XPR_LEN+:`XPR_LEN] <= wdata_internal;
              `CSR_ADDR_FCSR      : fcsr <= wdata_internal;
              `CSR_ADDR_FFLAGS    : fcsr[4:0] <= wdata_internal[4:0];
              `CSR_ADDR_FRM       : fcsr[7:5] <= wdata_internal[2:0];
              default : ;
            endcase // case (addr)
         end // if (wen)
      end // else: !if(reset)
   end // always @ (posedge clk)



endmodule // vscale_csr_file
