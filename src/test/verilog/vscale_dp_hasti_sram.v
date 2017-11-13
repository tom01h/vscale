`include "vscale_hasti_constants.vh"

module vscale_dp_hasti_sram
  (
   input                          hclk,
   input                          hresetn,
   input [`HASTI_ADDR_WIDTH-1:0]  p0_addr,
   input                          p0_read,
   input                          p0_write,
   input [`HASTI_SIZE_WIDTH-1:0]  p0_size,
   input [`HASTI_BUS_WIDTH-1:0]   p0_wdata,
   output [`HASTI_BUS_WIDTH-1:0]  p0_rdata,
   output                         p0_ready,
   output                         p0_resp,
   input [`HASTI_ADDR_WIDTH-1:0]  p1_addr,
   input                          p1_read,
   input                          p1_write,
   input [`HASTI_SIZE_WIDTH-1:0]  p1_size,
   input [`HASTI_BUS_WIDTH-1:0]   p1_wdata,
   output [`HASTI_BUS_WIDTH-1:0]  p1_rdata,
   output                         p1_ready,
   output                         p1_resp
   );

   parameter nwords = 65536;

   reg [`HASTI_BUS_WIDTH-1:0]     mem [nwords-1:0];

   // p0

   // flops
   wire [`HASTI_BUS_NBYTES-1:0]   p0_wmask_lut = (p0_size == 0) ? `HASTI_BUS_NBYTES'h1 : (p0_size == 1) ? `HASTI_BUS_NBYTES'h3 : `HASTI_BUS_NBYTES'hf;
   wire [`HASTI_BUS_NBYTES-1:0]   p0_wmask_shift = p0_wmask_lut << p0_addr[1:0];
   wire [`HASTI_BUS_WIDTH-1:0]    p0_wmask = {{8{p0_wmask_shift[3]}},{8{p0_wmask_shift[2]}},{8{p0_wmask_shift[1]}},{8{p0_wmask_shift[0]}}};

   wire [`HASTI_ADDR_WIDTH-1:0]   p0_raddr = p0_addr >> 2;
   reg [`HASTI_ADDR_WIDTH-1:0]    p0_reg_raddr;

   always @(posedge hclk) begin
      p0_reg_raddr <= p0_raddr;
      if (p0_write) begin
         mem[(p0_addr>>2)] <= (mem[(p0_addr>>2)] & ~p0_wmask) | (p0_wdata & p0_wmask);
      end
   end

   assign p0_rdata = mem[p0_reg_raddr];
   assign p0_ready = 1'b1;
   assign p0_resp = `HASTI_RESP_OKAY;



   // p1

   wire [`HASTI_ADDR_WIDTH-1:0] p1_raddr = p1_addr >> 2;
   reg [`HASTI_ADDR_WIDTH-1:0]  p1_reg_raddr;

   always @(posedge hclk) begin
      p1_reg_raddr <= p1_raddr;
   end

   assign p1_rdata = mem[p1_reg_raddr];
   assign p1_ready = 1'b1;
   assign p1_resp = `HASTI_RESP_OKAY;

endmodule // vscale_dp_hasti_sram

