`include "vscale_ctrl_constants.vh"
`include "vscale_csr_addr_map.vh"
`include "vscale_hasti_constants.vh"
`include "vscale_platform_constants.vh"

module vscale_sim_top(
                      input      clk,
                      input      reset
                      );

   wire                          resetn;

   wire [`HASTI_ADDR_WIDTH-1:0]  imem_addr;
   wire                          imem_read;
   wire                          imem_write;
   wire [`HASTI_SIZE_WIDTH-1:0]  imem_size;
   wire [`HASTI_BUS_WIDTH-1:0]   imem_wdata;
   wire [`HASTI_BUS_WIDTH-1:0]   imem_rdata;
   wire                          imem_ready;
   wire [`HASTI_RESP_WIDTH-1:0]  imem_resp;

   wire [`HASTI_ADDR_WIDTH-1:0]  dmem_addr;
   wire                          dmem_read;
   wire                          dmem_write;
   wire [`HASTI_SIZE_WIDTH-1:0]  dmem_size;
   wire [`HASTI_BUS_WIDTH-1:0]   dmem_wdata;
   wire [`HASTI_BUS_WIDTH-1:0]   dmem_rdata;
   wire                          dmem_ready;
   wire [`HASTI_RESP_WIDTH-1:0]  dmem_resp;

   assign resetn = ~reset;

   wire [63:0]                   cycle = vscale.pipeline.csr.cycle_full;
   wire [31:0]                   PC_DX = vscale.pipeline.PC_DX;
   wire [31:0]                   inst_DX = vscale.pipeline.inst_DX;
   wire                          stall_DX = vscale.pipeline.stall_DX;
   wire                          stall_WB = vscale.pipeline.stall_WB;
   wire                          retire_WB = vscale.pipeline.retire_WB;
   wire                          wr_reg_WB = vscale.pipeline.wr_reg_WB;
   wire [4:0]                    reg_to_wr_WB = vscale.pipeline.reg_to_wr_WB;
   wire [31:0]                   wb_data_WB = vscale.pipeline.wb_data_WB;
   wire                          wr_freg_WB = vscale.pipeline.ctrl.wr_freg_WB;
   wire                          wr_freg_FWB = vscale.pipeline.wr_freg_FWB;
   wire [4:0]                    freg_to_wr_FWB = vscale.pipeline.freg_to_wr_FWB;
   wire [31:0]                   wb_data_FWB = vscale.pipeline.wb_data_FWB;
   wire                          exception_WB = vscale.pipeline.exception_WB;
   wire [`ECODE_WIDTH-1:0]       exception_code_WB = vscale.pipeline.exception_code_WB;

   reg [31:0]                    inst;
   reg [31:0]                    PC_WB;
   reg [31:0]                    inst_WB;
   reg                           retire_FWB;
   reg [31:0]                    PC_FWB;
   reg [31:0]                    inst_FWB;

   wire signed [12:0]            bimm = {inst_WB[31],inst_WB[7],inst_WB[30:25],inst_WB[11:8],1'b0};
   wire signed [11:0]            immhl = {inst_WB[31:25],inst_WB[11:7]};
   wire signed [11:0]            imm12 = {inst_WB[31:20]};
   wire signed [11:0]            imm20 = {inst_WB[31:12]};
   wire signed [11:0]            jimm20 = {inst_WB[31],inst_WB[19:12],inst_WB[20],inst_WB[30:21],1'b0};
   reg [4:0]                     rs1;
   reg [4:0]                     rs2;
   reg [4:0]                     rs3;
   wire [4:0]                    rd = {inst_WB[11:7]};

   integer                       F_HANDLE;
   initial F_HANDLE = $fopen("trace.log","w");
   always @ (posedge clk) begin
      if(~stall_WB) begin
         retire_FWB <= retire_WB & wr_freg_WB;
         PC_FWB <= PC_WB;
         inst_FWB <= inst_WB;
      end
      if(~stall_DX) begin
         PC_WB <= PC_DX;
         inst_WB <= inst_DX;
      end
      if(retire_FWB)begin
         $fwrite(F_HANDLE,"(%04d): PC = %08x, inst = %08x", cycle, PC_FWB, inst_FWB);
         if(wr_freg_FWB)
           $fwrite(F_HANDLE,", f%02d <= %08x",freg_to_wr_FWB, wb_data_FWB);
         inst = inst_FWB;
         rs1 = {inst[19:15]};
         rs2 = {inst[24:20]};
         rs3 = {inst[31:27]};
`include "vscale_trace.v"
         $fdisplay(F_HANDLE,"");
      end
      if(~reset & retire_WB & ~wr_freg_WB)begin
         $fwrite(F_HANDLE,"[%04d]: PC = %08x, inst = %08x", cycle, PC_WB, inst_WB);
         if(wr_reg_WB && reg_to_wr_WB)
           $fwrite(F_HANDLE,", x%02d <= %08x",reg_to_wr_WB, wb_data_WB);
         else
           $fwrite(F_HANDLE,"                 ");
         inst = inst_WB;
         rs1 = {inst[19:15]};
         rs2 = {inst[24:20]};
         rs3 = {inst[31:27]};
`include "vscale_trace.v"
         $fdisplay(F_HANDLE,"");
      end else if(~retire_WB)begin
         $fdisplay(F_HANDLE,"[%04d]", cycle);
      end
      if(exception_WB)
        $fdisplay(F_HANDLE,"EXCEPTION : %02d",exception_code_WB);
   end

   vscale_core vscale(
                      .clk(clk),
                      .reset(reset),
                      .ext_interrupts(`N_EXT_INTS'b0),
                      .imem_addr(imem_addr),
                      .imem_read(imem_read),
                      .imem_write(imem_write),
                      .imem_size(imem_size),
                      .imem_wdata(imem_wdata),
                      .imem_rdata(imem_rdata),
                      .imem_ready(imem_ready),
                      .imem_resp(imem_resp),
                      .dmem_addr(dmem_addr),
                      .dmem_read(dmem_read),
                      .dmem_write(dmem_write),
                      .dmem_size(dmem_size),
                      .dmem_wdata(dmem_wdata),
                      .dmem_rdata(dmem_rdata),
                      .dmem_ready(dmem_ready),
                      .dmem_resp(dmem_resp)
                      );

   vscale_dp_hasti_sram hasti_mem(
                                  .hclk(clk),
                                  .hresetn(resetn),
                                  .p1_addr(imem_addr),
                                  .p1_read(imem_read),
                                  .p1_write(imem_write),
                                  .p1_size(imem_size),
                                  .p1_wdata(imem_wdata),
                                  .p1_rdata(imem_rdata),
                                  .p1_ready(imem_ready),
                                  .p1_resp(imem_resp),
                                  .p0_addr(dmem_addr),
                                  .p0_read(dmem_read),
                                  .p0_write(dmem_write),
                                  .p0_size(dmem_size),
                                  .p0_wdata(dmem_wdata),
                                  .p0_rdata(dmem_rdata),
                                  .p0_ready(dmem_ready),
                                  .p0_resp(dmem_resp)
                                  );

endmodule // vscale_sim_top
