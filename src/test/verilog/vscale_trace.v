         if(inst[14:12]==0 && inst[6:2]==5'h18 && inst[1:0]==3)
           $fwrite(F_HANDLE," : beq      x%02d x%02d %6d", rs1, rs2, bimm);
         if(inst[14:12]==1 && inst[6:2]==5'h18 && inst[1:0]==3)
           $fwrite(F_HANDLE," : bne      x%02d x%02d %6d", rs1, rs2, bimm);
         if(inst[14:12]==4 && inst[6:2]==5'h18 && inst[1:0]==3)
           $fwrite(F_HANDLE," : blt      x%02d x%02d %6d", rs1, rs2, bimm);
         if(inst[14:12]==5 && inst[6:2]==5'h18 && inst[1:0]==3)
           $fwrite(F_HANDLE," : bge      x%02d x%02d %6d", rs1, rs2, bimm);
         if(inst[14:12]==6 && inst[6:2]==5'h18 && inst[1:0]==3)
           $fwrite(F_HANDLE," : bltu     x%02d x%02d %6d", rs1, rs2, bimm);
         if(inst[14:12]==7 && inst[6:2]==5'h18 && inst[1:0]==3)
           $fwrite(F_HANDLE," : bgeu     x%02d x%02d %6d", rs1, rs2, bimm);
         if(inst[14:12]==0 && inst[6:2]==5'h19 && inst[1:0]==3)
           $fwrite(F_HANDLE," : jalr     x%02d     %6d", rs1, imm12);
         if(inst[6:2]==5'h1b && inst[1:0]==3)
           $fwrite(F_HANDLE," : jal              %6d", jimm20);
         if(inst[6:2]==5'h0D && inst[1:0]==3)
           $fwrite(F_HANDLE," : lui              %6d", imm20);
         if(inst[6:2]==5'h05 && inst[1:0]==3)
           $fwrite(F_HANDLE," : auipc            %6d", imm20);
         if(inst[14:12]==0 && inst[6:2]==5'h04 && inst[1:0]==3)
           $fwrite(F_HANDLE," : addi     x%02d     %6d", rs1, imm12);
         if(inst[31:26]==0 && inst[14:12]==1 && inst[6:2]==5'h04 && inst[1:0]==3)
           $fwrite(F_HANDLE," : slli     x%02d    ", rs1);
         if(inst[14:12]==2 && inst[6:2]==5'h04 && inst[1:0]==3)
           $fwrite(F_HANDLE," : slti     x%02d     %6d", rs1, imm12);
         if(inst[14:12]==3 && inst[6:2]==5'h04 && inst[1:0]==3)
           $fwrite(F_HANDLE," : sltiu    x%02d     %6d", rs1, imm12);
         if(inst[14:12]==4 && inst[6:2]==5'h04 && inst[1:0]==3)
           $fwrite(F_HANDLE," : xori     x%02d     %6d", rs1, imm12);
         if(inst[31:26]==0 && inst[14:12]==5 && inst[6:2]==5'h04 && inst[1:0]==3)
           $fwrite(F_HANDLE," : srli     x%02d    ", rs1);
         if(inst[31:26]==16 && inst[14:12]==5 && inst[6:2]==5'h04 && inst[1:0]==3)
           $fwrite(F_HANDLE," : srai     x%02d    ", rs1);
         if(inst[14:12]==6 && inst[6:2]==5'h04 && inst[1:0]==3)
           $fwrite(F_HANDLE," : ori      x%02d     %6d", rs1, imm12);
         if(inst[14:12]==7 && inst[6:2]==5'h04 && inst[1:0]==3)
           $fwrite(F_HANDLE," : andi     x%02d     %6d", rs1, imm12);
         if(inst[31:25]==0 && inst[14:12]==0 && inst[6:2]==5'h0C && inst[1:0]==3)
           $fwrite(F_HANDLE," : add      x%02d x%02d", rs1, rs2);
         if(inst[31:25]==32 && inst[14:12]==0 && inst[6:2]==5'h0C && inst[1:0]==3)
           $fwrite(F_HANDLE," : sub      x%02d x%02d", rs1, rs2);
         if(inst[31:25]==0 && inst[14:12]==1 && inst[6:2]==5'h0C && inst[1:0]==3)
           $fwrite(F_HANDLE," : sll      x%02d x%02d", rs1, rs2);
         if(inst[31:25]==0 && inst[14:12]==2 && inst[6:2]==5'h0C && inst[1:0]==3)
           $fwrite(F_HANDLE," : slt      x%02d x%02d", rs1, rs2);
         if(inst[31:25]==0 && inst[14:12]==3 && inst[6:2]==5'h0C && inst[1:0]==3)
           $fwrite(F_HANDLE," : sltu     x%02d x%02d", rs1, rs2);
         if(inst[31:25]==0 && inst[14:12]==4 && inst[6:2]==5'h0C && inst[1:0]==3)
           $fwrite(F_HANDLE," : xor      x%02d x%02d", rs1, rs2);
         if(inst[31:25]==0 && inst[14:12]==5 && inst[6:2]==5'h0C && inst[1:0]==3)
           $fwrite(F_HANDLE," : srl      x%02d x%02d", rs1, rs2);
         if(inst[31:25]==32 && inst[14:12]==5 && inst[6:2]==5'h0C && inst[1:0]==3)
           $fwrite(F_HANDLE," : sra      x%02d x%02d", rs1, rs2);
         if(inst[31:25]==0 && inst[14:12]==6 && inst[6:2]==5'h0C && inst[1:0]==3)
           $fwrite(F_HANDLE," : or       x%02d x%02d", rs1, rs2);
         if(inst[31:25]==0 && inst[14:12]==7 && inst[6:2]==5'h0C && inst[1:0]==3)
           $fwrite(F_HANDLE," : and      x%02d x%02d", rs1, rs2);
         if(inst[14:12]==0 && inst[6:2]==5'h06 && inst[1:0]==3)
           $fwrite(F_HANDLE," : addiw    x%02d     %6d", rs1, imm12);
         if(inst[31:25]==0 && inst[14:12]==1 && inst[6:2]==5'h06 && inst[1:0]==3)
           $fwrite(F_HANDLE," : slliw    x%02d    ", rs1);
         if(inst[31:25]==0 && inst[14:12]==5 && inst[6:2]==5'h06 && inst[1:0]==3)
           $fwrite(F_HANDLE," : srliw    x%02d    ", rs1);
         if(inst[31:25]==32 && inst[14:12]==5 && inst[6:2]==5'h06 && inst[1:0]==3)
           $fwrite(F_HANDLE," : sraiw    x%02d    ", rs1);
         if(inst[31:25]==0 && inst[14:12]==0 && inst[6:2]==5'h0E && inst[1:0]==3)
           $fwrite(F_HANDLE," : addw     x%02d x%02d", rs1, rs2);
         if(inst[31:25]==32 && inst[14:12]==0 && inst[6:2]==5'h0E && inst[1:0]==3)
           $fwrite(F_HANDLE," : subw     x%02d x%02d", rs1, rs2);
         if(inst[31:25]==0 && inst[14:12]==1 && inst[6:2]==5'h0E && inst[1:0]==3)
           $fwrite(F_HANDLE," : sllw     x%02d x%02d", rs1, rs2);
         if(inst[31:25]==0 && inst[14:12]==5 && inst[6:2]==5'h0E && inst[1:0]==3)
           $fwrite(F_HANDLE," : srlw     x%02d x%02d", rs1, rs2);
         if(inst[31:25]==32 && inst[14:12]==5 && inst[6:2]==5'h0E && inst[1:0]==3)
           $fwrite(F_HANDLE," : sraw     x%02d x%02d", rs1, rs2);
         if(inst[14:12]==0 && inst[6:2]==5'h00 && inst[1:0]==3)
           $fwrite(F_HANDLE," : lb       x%02d     %6d", rs1, imm12);
         if(inst[14:12]==1 && inst[6:2]==5'h00 && inst[1:0]==3)
           $fwrite(F_HANDLE," : lh       x%02d     %6d", rs1, imm12);
         if(inst[14:12]==2 && inst[6:2]==5'h00 && inst[1:0]==3)
           $fwrite(F_HANDLE," : lw       x%02d     %6d", rs1, imm12);
         if(inst[14:12]==3 && inst[6:2]==5'h00 && inst[1:0]==3)
           $fwrite(F_HANDLE," : ld       x%02d     %6d", rs1, imm12);
         if(inst[14:12]==4 && inst[6:2]==5'h00 && inst[1:0]==3)
           $fwrite(F_HANDLE," : lbu      x%02d     %6d", rs1, imm12);
         if(inst[14:12]==5 && inst[6:2]==5'h00 && inst[1:0]==3)
           $fwrite(F_HANDLE," : lhu      x%02d     %6d", rs1, imm12);
         if(inst[14:12]==6 && inst[6:2]==5'h00 && inst[1:0]==3)
           $fwrite(F_HANDLE," : lwu      x%02d     %6d", rs1, imm12);
         if(inst[14:12]==0 && inst[6:2]==5'h08 && inst[1:0]==3)
           $fwrite(F_HANDLE," : sb       x%02d x%02d", rs1, rs2);
         if(inst[14:12]==1 && inst[6:2]==5'h08 && inst[1:0]==3)
           $fwrite(F_HANDLE," : sh       x%02d x%02d", rs1, rs2);
         if(inst[14:12]==2 && inst[6:2]==5'h08 && inst[1:0]==3)
           $fwrite(F_HANDLE," : sw       x%02d x%02d", rs1, rs2);
         if(inst[14:12]==3 && inst[6:2]==5'h08 && inst[1:0]==3)
           $fwrite(F_HANDLE," : sd       x%02d x%02d", rs1, rs2);
         if(inst[14:12]==0 && inst[6:2]==5'h03 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fence           ");
         if(inst[14:12]==1 && inst[6:2]==5'h03 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fence.i         ");
         if(inst[31:25]==1 && inst[14:12]==0 && inst[6:2]==5'h0C && inst[1:0]==3)
           $fwrite(F_HANDLE," : mul      x%02d x%02d", rs1, rs2);
         if(inst[31:25]==1 && inst[14:12]==1 && inst[6:2]==5'h0C && inst[1:0]==3)
           $fwrite(F_HANDLE," : mulh     x%02d x%02d", rs1, rs2);
         if(inst[31:25]==1 && inst[14:12]==2 && inst[6:2]==5'h0C && inst[1:0]==3)
           $fwrite(F_HANDLE," : mulhsu   x%02d x%02d", rs1, rs2);
         if(inst[31:25]==1 && inst[14:12]==3 && inst[6:2]==5'h0C && inst[1:0]==3)
           $fwrite(F_HANDLE," : mulhu    x%02d x%02d", rs1, rs2);
         if(inst[31:25]==1 && inst[14:12]==4 && inst[6:2]==5'h0C && inst[1:0]==3)
           $fwrite(F_HANDLE," : div      x%02d x%02d", rs1, rs2);
         if(inst[31:25]==1 && inst[14:12]==5 && inst[6:2]==5'h0C && inst[1:0]==3)
           $fwrite(F_HANDLE," : divu     x%02d x%02d", rs1, rs2);
         if(inst[31:25]==1 && inst[14:12]==6 && inst[6:2]==5'h0C && inst[1:0]==3)
           $fwrite(F_HANDLE," : rem      x%02d x%02d", rs1, rs2);
         if(inst[31:25]==1 && inst[14:12]==7 && inst[6:2]==5'h0C && inst[1:0]==3)
           $fwrite(F_HANDLE," : remu     x%02d x%02d", rs1, rs2);
         if(inst[11:7]==0 && inst[19:15]==0 && inst[31:20]==12'h000 && inst[14:12]==0 && inst[6:2]==5'h1C && inst[1:0]==3)
           $fwrite(F_HANDLE," : ecall           ");
         if(inst[11:7]==0 && inst[19:15]==0 && inst[31:20]==12'h001 && inst[14:12]==0 && inst[6:2]==5'h1C && inst[1:0]==3)
           $fwrite(F_HANDLE," : ebreak          ");
         if(inst[11:7]==0 && inst[19:15]==0 && inst[31:20]==12'h002 && inst[14:12]==0 && inst[6:2]==5'h1C && inst[1:0]==3)
           $fwrite(F_HANDLE," : uret            ");
         if(inst[11:7]==0 && inst[19:15]==0 && inst[31:20]==12'h102 && inst[14:12]==0 && inst[6:2]==5'h1C && inst[1:0]==3)
           $fwrite(F_HANDLE," : sret            ");
         if(inst[11:7]==0 && inst[19:15]==0 && inst[31:20]==12'h202 && inst[14:12]==0 && inst[6:2]==5'h1C && inst[1:0]==3)
           $fwrite(F_HANDLE," : hret            ");
         if(inst[11:7]==0 && inst[19:15]==0 && inst[31:20]==12'h302 && inst[14:12]==0 && inst[6:2]==5'h1C && inst[1:0]==3)
           $fwrite(F_HANDLE," : mret            ");
         if(inst[11:7]==0 && inst[19:15]==0 && inst[31:20]==12'h7b2 && inst[14:12]==0 && inst[6:2]==5'h1C && inst[1:0]==3)
           $fwrite(F_HANDLE," : dret            ");
         if(inst[11:7]==0 && inst[31:20]==12'h104 && inst[14:12]==0 && inst[6:2]==5'h1C && inst[1:0]==3)
           $fwrite(F_HANDLE," : sfence.vm x%02d    ", rs1);
         if(inst[11:7]==0 && inst[19:15]==0 && inst[31:20]==12'h105 && inst[14:12]==0 && inst[6:2]==5'h1C && inst[1:0]==3)
           $fwrite(F_HANDLE," : wfi             ");
         if(inst[14:12]==1 && inst[6:2]==5'h1C && inst[1:0]==3)
           $fwrite(F_HANDLE," : csrrw    x%02d     %6d", rs1, imm12);
         if(inst[14:12]==2 && inst[6:2]==5'h1C && inst[1:0]==3)
           $fwrite(F_HANDLE," : csrrs    x%02d     %6d", rs1, imm12);
         if(inst[14:12]==3 && inst[6:2]==5'h1C && inst[1:0]==3)
           $fwrite(F_HANDLE," : csrrc    x%02d     %6d", rs1, imm12);
         if(inst[14:12]==5 && inst[6:2]==5'h1C && inst[1:0]==3)
           $fwrite(F_HANDLE," : csrrwi   x%02d     %6d", rs1, imm12);
         if(inst[14:12]==6 && inst[6:2]==5'h1C && inst[1:0]==3)
           $fwrite(F_HANDLE," : csrrsi   x%02d     %6d", rs1, imm12);
         if(inst[14:12]==7 && inst[6:2]==5'h1C && inst[1:0]==3)
           $fwrite(F_HANDLE," : csrrci   x%02d     %6d", rs1, imm12);
         if(inst[31:27]==5'h00 && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fadd.s   f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h01 && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fsub.s   f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h02 && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fmul.s   f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h03 && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fdiv.s   f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h04 && inst[14:12]==0 && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fsgnj.s  f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h04 && inst[14:12]==1 && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fsgnjn.s f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h04 && inst[14:12]==2 && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fsgnjx.s f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h05 && inst[14:12]==0 && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fmin.s   f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h05 && inst[14:12]==1 && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fmax.s   f%02d f%02d", rs1, rs2);
         if(inst[24:20]==0 && inst[31:27]==5'h0B && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fsqrt.s  f%02d    ", rs1);
         if(inst[31:27]==5'h00 && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fadd.d   f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h01 && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fsub.d   f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h02 && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fmul.d   f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h03 && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fdiv.d   f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h04 && inst[14:12]==0 && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fsgnj.d  f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h04 && inst[14:12]==1 && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fsgnjn.d f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h04 && inst[14:12]==2 && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fsgnjx.d f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h05 && inst[14:12]==0 && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fmin.d   f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h05 && inst[14:12]==1 && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fmax.d   f%02d f%02d", rs1, rs2);
         if(inst[24:20]==1 && inst[31:27]==5'h08 && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.s.d f%02d    ", rs1);
         if(inst[24:20]==0 && inst[31:27]==5'h08 && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.d.s f%02d    ", rs1);
         if(inst[24:20]==0 && inst[31:27]==5'h0B && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fsqrt.d  f%02d    ", rs1);
         if(inst[31:27]==5'h00 && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fadd.q   f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h01 && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fsub.q   f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h02 && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fmul.q   f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h03 && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fdiv.q   f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h04 && inst[14:12]==0 && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fsgnj.q  f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h04 && inst[14:12]==1 && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fsgnjn.q f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h04 && inst[14:12]==2 && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fsgnjx.q f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h05 && inst[14:12]==0 && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fmin.q   f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h05 && inst[14:12]==1 && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fmax.q   f%02d f%02d", rs1, rs2);
         if(inst[24:20]==3 && inst[31:27]==5'h08 && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.s.q f%02d    ", rs1);
         if(inst[24:20]==0 && inst[31:27]==5'h08 && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.q.s f%02d    ", rs1);
         if(inst[24:20]==3 && inst[31:27]==5'h08 && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.d.q f%02d    ", rs1);
         if(inst[24:20]==1 && inst[31:27]==5'h08 && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.q.d f%02d    ", rs1);
         if(inst[24:20]==0 && inst[31:27]==5'h0B && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fsqrt.q  f%02d    ", rs1);
         if(inst[31:27]==5'h14 && inst[14:12]==0 && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fle.s    f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h14 && inst[14:12]==1 && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : flt.s    f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h14 && inst[14:12]==2 && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : feq.s    f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h14 && inst[14:12]==0 && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fle.d    f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h14 && inst[14:12]==1 && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : flt.d    f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h14 && inst[14:12]==2 && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : feq.d    f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h14 && inst[14:12]==0 && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fle.q    f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h14 && inst[14:12]==1 && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : flt.q    f%02d f%02d", rs1, rs2);
         if(inst[31:27]==5'h14 && inst[14:12]==2 && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : feq.q    f%02d f%02d", rs1, rs2);
         if(inst[24:20]==0 && inst[31:27]==5'h18 && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.w.s f%02d    ", rs1);
         if(inst[24:20]==1 && inst[31:27]==5'h18 && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.wu.s f%02d    ", rs1);
         if(inst[24:20]==2 && inst[31:27]==5'h18 && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.l.s f%02d    ", rs1);
         if(inst[24:20]==3 && inst[31:27]==5'h18 && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.lu.s f%02d    ", rs1);
         if(inst[24:20]==0 && inst[31:27]==5'h1C && inst[14:12]==0 && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fmv.x.s  f%02d    ", rs1);
         if(inst[24:20]==0 && inst[31:27]==5'h1C && inst[14:12]==1 && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fclass.s f%02d    ", rs1);
         if(inst[24:20]==0 && inst[31:27]==5'h18 && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.w.d f%02d    ", rs1);
         if(inst[24:20]==1 && inst[31:27]==5'h18 && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.wu.d f%02d    ", rs1);
         if(inst[24:20]==2 && inst[31:27]==5'h18 && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.l.d f%02d    ", rs1);
         if(inst[24:20]==3 && inst[31:27]==5'h18 && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.lu.d f%02d    ", rs1);
         if(inst[24:20]==0 && inst[31:27]==5'h1C && inst[14:12]==0 && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fmv.x.d  f%02d    ", rs1);
         if(inst[24:20]==0 && inst[31:27]==5'h1C && inst[14:12]==1 && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fclass.d f%02d    ", rs1);
         if(inst[24:20]==0 && inst[31:27]==5'h18 && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.w.q f%02d    ", rs1);
         if(inst[24:20]==1 && inst[31:27]==5'h18 && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.wu.q f%02d    ", rs1);
         if(inst[24:20]==2 && inst[31:27]==5'h18 && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.l.q f%02d    ", rs1);
         if(inst[24:20]==3 && inst[31:27]==5'h18 && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.lu.q f%02d    ", rs1);
         if(inst[24:20]==0 && inst[31:27]==5'h1C && inst[14:12]==0 && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fmv.x.q  f%02d    ", rs1);
         if(inst[24:20]==0 && inst[31:27]==5'h1C && inst[14:12]==1 && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fclass.q f%02d    ", rs1);
         if(inst[24:20]==0 && inst[31:27]==5'h1A && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.s.w f%02d    ", rs1);
         if(inst[24:20]==1 && inst[31:27]==5'h1A && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.s.wu f%02d    ", rs1);
         if(inst[24:20]==2 && inst[31:27]==5'h1A && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.s.l f%02d    ", rs1);
         if(inst[24:20]==3 && inst[31:27]==5'h1A && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.s.lu f%02d    ", rs1);
         if(inst[24:20]==0 && inst[31:27]==5'h1E && inst[14:12]==0 && inst[26:25]==0 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fmv.s.x  f%02d    ", rs1);
         if(inst[24:20]==0 && inst[31:27]==5'h1A && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.d.w f%02d    ", rs1);
         if(inst[24:20]==1 && inst[31:27]==5'h1A && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.d.wu f%02d    ", rs1);
         if(inst[24:20]==2 && inst[31:27]==5'h1A && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.d.l f%02d    ", rs1);
         if(inst[24:20]==3 && inst[31:27]==5'h1A && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.d.lu f%02d    ", rs1);
         if(inst[24:20]==0 && inst[31:27]==5'h1E && inst[14:12]==0 && inst[26:25]==1 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fmv.d.x  f%02d    ", rs1);
         if(inst[24:20]==0 && inst[31:27]==5'h1A && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.q.w f%02d    ", rs1);
         if(inst[24:20]==1 && inst[31:27]==5'h1A && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.q.wu f%02d    ", rs1);
         if(inst[24:20]==2 && inst[31:27]==5'h1A && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.q.l f%02d    ", rs1);
         if(inst[24:20]==3 && inst[31:27]==5'h1A && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fcvt.q.lu f%02d    ", rs1);
         if(inst[24:20]==0 && inst[31:27]==5'h1E && inst[14:12]==0 && inst[26:25]==3 && inst[6:2]==5'h14 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fmv.q.x  f%02d    ", rs1);
         if(inst[14:12]==2 && inst[6:2]==5'h01 && inst[1:0]==3)
           $fwrite(F_HANDLE," : flw      f%02d     %6d", rs1, imm12);
         if(inst[14:12]==3 && inst[6:2]==5'h01 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fld      f%02d     %6d", rs1, imm12);
         if(inst[14:12]==4 && inst[6:2]==5'h01 && inst[1:0]==3)
           $fwrite(F_HANDLE," : flq      f%02d     %6d", rs1, imm12);
         if(inst[14:12]==2 && inst[6:2]==5'h09 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fsw      f%02d f%02d", rs1, rs2);
         if(inst[14:12]==3 && inst[6:2]==5'h09 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fsd      f%02d f%02d", rs1, rs2);
         if(inst[14:12]==4 && inst[6:2]==5'h09 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fsq      f%02d f%02d", rs1, rs2);
         if(inst[26:25]==0 && inst[6:2]==5'h10 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fmadd.s  f%02d f%02d", rs1, rs2);
         if(inst[26:25]==0 && inst[6:2]==5'h11 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fmsub.s  f%02d f%02d", rs1, rs2);
         if(inst[26:25]==0 && inst[6:2]==5'h12 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fnmsub.s f%02d f%02d", rs1, rs2);
         if(inst[26:25]==0 && inst[6:2]==5'h13 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fnmadd.s f%02d f%02d", rs1, rs2);
         if(inst[26:25]==1 && inst[6:2]==5'h10 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fmadd.d  f%02d f%02d", rs1, rs2);
         if(inst[26:25]==1 && inst[6:2]==5'h11 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fmsub.d  f%02d f%02d", rs1, rs2);
         if(inst[26:25]==1 && inst[6:2]==5'h12 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fnmsub.d f%02d f%02d", rs1, rs2);
         if(inst[26:25]==1 && inst[6:2]==5'h13 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fnmadd.d f%02d f%02d", rs1, rs2);
         if(inst[26:25]==3 && inst[6:2]==5'h10 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fmadd.q  f%02d f%02d", rs1, rs2);
         if(inst[26:25]==3 && inst[6:2]==5'h11 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fmsub.q  f%02d f%02d", rs1, rs2);
         if(inst[26:25]==3 && inst[6:2]==5'h12 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fnmsub.q f%02d f%02d", rs1, rs2);
         if(inst[26:25]==3 && inst[6:2]==5'h13 && inst[1:0]==3)
           $fwrite(F_HANDLE," : fnmadd.q f%02d f%02d", rs1, rs2);
