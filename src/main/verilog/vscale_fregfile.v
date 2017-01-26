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
   input                       wen,
   input [`REG_ADDR_WIDTH-1:0] wa,
   input [`XPR_LEN-1:0]        wd
   );

   reg [`XPR_LEN-1:0]          data [31:0];
   wire                        wen_internal;

   // fpga-style zero register
   assign wen_internal = wen;

   assign rd1 = data[ra1];
   assign rd2 = data[ra2];
   assign rd3 = data[ra3];

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
