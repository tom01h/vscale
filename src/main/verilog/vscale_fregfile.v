`include "rv32_opcodes.vh"

module vscale_fregfile
  (
   input                       clk,
   input [`REG_ADDR_WIDTH-1:0] ra1,
   output [`XPR_LEN-1:0]       rd1,
   input [`REG_ADDR_WIDTH-1:0] ra2,
   output [`XPR_LEN-1:0]       rd2,
   input [`REG_ADDR_WIDTH-1:0] ra3,
   output [`XPR_LEN-1:0]       rd3,
   input [1:0]                 bypass_rs1,
   input [1:0]                 bypass_rs2,
   input [1:0]                 bypass_rs3,
   input [`XPR_LEN-1:0]        bypass_data0,
   input [`XPR_LEN-1:0]        bypass_data1,
   input                       wen,
   input [`REG_ADDR_WIDTH-1:0] wa,
   input [`XPR_LEN-1:0]        wd
   );

   reg [`XPR_LEN-1:0]          data [31:0];
   wire                        wen_internal;

   // fpga-style zero register
   assign wen_internal = wen;

   assign rd1 = (bypass_rs1[0]) ? bypass_data0 : (bypass_rs1[1]) ? bypass_data1 : data[ra1];
   assign rd2 = (bypass_rs2[0]) ? bypass_data0 : (bypass_rs2[1]) ? bypass_data1 : data[ra2];
   assign rd3 = (bypass_rs3[0]) ? bypass_data0 : (bypass_rs3[1]) ? bypass_data1 : data[ra3];

   always @(posedge clk) begin
      if (wen_internal) begin
         data[wa] <= wd;
      end
   end

`ifndef SYNTHESIS
   integer i;
   initial begin
      for (i = 0; i < 32; i = i + 1) begin
         data[i] = $random;
      end
   end
`endif

endmodule // vscale_regfile
