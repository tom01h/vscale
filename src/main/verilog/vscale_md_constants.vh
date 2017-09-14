`define RISCV

`define MDF_OP_WIDTH 4
`define MDF_OP_MUL `MDF_OP_WIDTH'h0
`define MDF_OP_DIV `MDF_OP_WIDTH'h1
`define MDF_OP_NOP `MDF_OP_WIDTH'h2
`define MDF_OP_SGN `MDF_OP_WIDTH'h3
`define MDF_OP_FAD `MDF_OP_WIDTH'h4
`define MDF_OP_FSB `MDF_OP_WIDTH'h5
`define MDF_OP_FML `MDF_OP_WIDTH'h6

`define MDF_OP_FMA `MDF_OP_WIDTH'h8
`define MDF_OP_FMS `MDF_OP_WIDTH'h9
`define MDF_OP_FNA `MDF_OP_WIDTH'ha
`define MDF_OP_FNS `MDF_OP_WIDTH'hb
`define MDF_OP_FDV `MDF_OP_WIDTH'hc
`define MDF_OP_FRT `MDF_OP_WIDTH'hd

`define MD_OUT_LO  1'b0
`define MD_OUT_HI  1'b1

