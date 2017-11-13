`include "vscale_hasti_constants.vh"
`include "vscale_ctrl_constants.vh"
`include "vscale_csr_addr_map.vh"
`include "vscale_platform_constants.vh"

module vscale_core
  (
   input                           clk,
   input                           reset,
   input [`N_EXT_INTS-1:0]         ext_interrupts, 
   output [`HASTI_ADDR_WIDTH-1:0]  imem_addr,
   output                          imem_read,
   output                          imem_write,
   output [`HASTI_SIZE_WIDTH-1:0]  imem_size,
   output [`HASTI_BUS_WIDTH-1:0]   imem_wdata,
   input [`HASTI_BUS_WIDTH-1:0]    imem_rdata,
   input                           imem_ready,
   input [`HASTI_RESP_WIDTH-1:0]   imem_resp,
   output [`HASTI_ADDR_WIDTH-1:0]  dmem_addr,
   output                          dmem_read,
   output                          dmem_write,
   output [`HASTI_SIZE_WIDTH-1:0]  dmem_size,
   output [`HASTI_BUS_WIDTH-1:0]   dmem_wdata,
   input [`HASTI_BUS_WIDTH-1:0]    dmem_rdata,
   input                           dmem_ready,
   input [`HASTI_RESP_WIDTH-1:0]   dmem_resp
   );

   assign imem_read = 1'b1;
   assign imem_write = 1'b0;
   assign imem_wdata[`HASTI_BUS_WIDTH-1:0] = 0;
   assign imem_size[`HASTI_SIZE_WIDTH-1:0] = `HASTI_SIZE_WORD;
   wire   imem_wait = ~imem_ready;
   wire   imem_badmem_e = (imem_resp == `HASTI_RESP_ERROR);

   wire   dmem_wait = ~dmem_ready;
   wire   dmem_badmem_e = (dmem_resp == `HASTI_RESP_ERROR);

   vscale_pipeline pipeline(
                            .clk(clk),
                            .ext_interrupts(ext_interrupts),
                            .reset(reset),
                            .imem_wait(imem_wait),
                            .imem_addr(imem_addr),
                            .imem_rdata(imem_rdata),
                            .imem_badmem_e(imem_badmem_e),
                            .dmem_wait(dmem_wait),
                            .dmem_read(dmem_read),
                            .dmem_write(dmem_write),
                            .dmem_size(dmem_size),
                            .dmem_addr(dmem_addr),
                            .dmem_wdata(dmem_wdata),
                            .dmem_rdata(dmem_rdata),
                            .dmem_badmem_e(dmem_badmem_e)
                            );

endmodule // vscale_core

