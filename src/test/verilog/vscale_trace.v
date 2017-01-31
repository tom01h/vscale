         if(inst_WB[14:12]==0 && inst_WB[6:2]==5'h18 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : beq      x%02d x%02d %6d", rs1, rs2, bimm);
         if(inst_WB[14:12]==1 && inst_WB[6:2]==5'h18 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : bne      x%02d x%02d %6d", rs1, rs2, bimm);
         if(inst_WB[14:12]==4 && inst_WB[6:2]==5'h18 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : blt      x%02d x%02d %6d", rs1, rs2, bimm);
         if(inst_WB[14:12]==5 && inst_WB[6:2]==5'h18 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : bge      x%02d x%02d %6d", rs1, rs2, bimm);
         if(inst_WB[14:12]==6 && inst_WB[6:2]==5'h18 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : bltu     x%02d x%02d %6d", rs1, rs2, bimm);
         if(inst_WB[14:12]==7 && inst_WB[6:2]==5'h18 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : bgeu     x%02d x%02d %6d", rs1, rs2, bimm);
         if(inst_WB[14:12]==0 && inst_WB[6:2]==5'h19 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : jalr     x%02d     %6d", rs1, imm12);
         if(inst_WB[6:2]==5'h1b && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : jal              %6d", jimm20);
         if(inst_WB[6:2]==5'h0D && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : lui              %6d", imm20);
         if(inst_WB[6:2]==5'h05 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : auipc            %6d", imm20);
         if(inst_WB[14:12]==0 && inst_WB[6:2]==5'h04 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : addi     x%02d     %6d", rs1, imm12);
         if(inst_WB[31:26]==0 && inst_WB[14:12]==1 && inst_WB[6:2]==5'h04 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : slli     x%02d    ", rs1);
         if(inst_WB[14:12]==2 && inst_WB[6:2]==5'h04 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : slti     x%02d     %6d", rs1, imm12);
         if(inst_WB[14:12]==3 && inst_WB[6:2]==5'h04 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : sltiu    x%02d     %6d", rs1, imm12);
         if(inst_WB[14:12]==4 && inst_WB[6:2]==5'h04 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : xori     x%02d     %6d", rs1, imm12);
         if(inst_WB[31:26]==0 && inst_WB[14:12]==5 && inst_WB[6:2]==5'h04 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : srli     x%02d    ", rs1);
         if(inst_WB[31:26]==16 && inst_WB[14:12]==5 && inst_WB[6:2]==5'h04 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : srai     x%02d    ", rs1);
         if(inst_WB[14:12]==6 && inst_WB[6:2]==5'h04 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : ori      x%02d     %6d", rs1, imm12);
         if(inst_WB[14:12]==7 && inst_WB[6:2]==5'h04 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : andi     x%02d     %6d", rs1, imm12);
         if(inst_WB[31:25]==0 && inst_WB[14:12]==0 && inst_WB[6:2]==5'h0C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : add      x%02d x%02d", rs1, rs2);
         if(inst_WB[31:25]==32 && inst_WB[14:12]==0 && inst_WB[6:2]==5'h0C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : sub      x%02d x%02d", rs1, rs2);
         if(inst_WB[31:25]==0 && inst_WB[14:12]==1 && inst_WB[6:2]==5'h0C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : sll      x%02d x%02d", rs1, rs2);
         if(inst_WB[31:25]==0 && inst_WB[14:12]==2 && inst_WB[6:2]==5'h0C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : slt      x%02d x%02d", rs1, rs2);
         if(inst_WB[31:25]==0 && inst_WB[14:12]==3 && inst_WB[6:2]==5'h0C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : sltu     x%02d x%02d", rs1, rs2);
         if(inst_WB[31:25]==0 && inst_WB[14:12]==4 && inst_WB[6:2]==5'h0C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : xor      x%02d x%02d", rs1, rs2);
         if(inst_WB[31:25]==0 && inst_WB[14:12]==5 && inst_WB[6:2]==5'h0C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : srl      x%02d x%02d", rs1, rs2);
         if(inst_WB[31:25]==32 && inst_WB[14:12]==5 && inst_WB[6:2]==5'h0C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : sra      x%02d x%02d", rs1, rs2);
         if(inst_WB[31:25]==0 && inst_WB[14:12]==6 && inst_WB[6:2]==5'h0C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : or       x%02d x%02d", rs1, rs2);
         if(inst_WB[31:25]==0 && inst_WB[14:12]==7 && inst_WB[6:2]==5'h0C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : and      x%02d x%02d", rs1, rs2);
         if(inst_WB[14:12]==0 && inst_WB[6:2]==5'h06 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : addiw    x%02d     %6d", rs1, imm12);
         if(inst_WB[31:25]==0 && inst_WB[14:12]==1 && inst_WB[6:2]==5'h06 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : slliw    x%02d    ", rs1);
         if(inst_WB[31:25]==0 && inst_WB[14:12]==5 && inst_WB[6:2]==5'h06 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : srliw    x%02d    ", rs1);
         if(inst_WB[31:25]==32 && inst_WB[14:12]==5 && inst_WB[6:2]==5'h06 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : sraiw    x%02d    ", rs1);
         if(inst_WB[31:25]==0 && inst_WB[14:12]==0 && inst_WB[6:2]==5'h0E && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : addw     x%02d x%02d", rs1, rs2);
         if(inst_WB[31:25]==32 && inst_WB[14:12]==0 && inst_WB[6:2]==5'h0E && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : subw     x%02d x%02d", rs1, rs2);
         if(inst_WB[31:25]==0 && inst_WB[14:12]==1 && inst_WB[6:2]==5'h0E && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : sllw     x%02d x%02d", rs1, rs2);
         if(inst_WB[31:25]==0 && inst_WB[14:12]==5 && inst_WB[6:2]==5'h0E && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : srlw     x%02d x%02d", rs1, rs2);
         if(inst_WB[31:25]==32 && inst_WB[14:12]==5 && inst_WB[6:2]==5'h0E && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : sraw     x%02d x%02d", rs1, rs2);
         if(inst_WB[14:12]==0 && inst_WB[6:2]==5'h00 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : lb       x%02d     %6d", rs1, imm12);
         if(inst_WB[14:12]==1 && inst_WB[6:2]==5'h00 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : lh       x%02d     %6d", rs1, imm12);
         if(inst_WB[14:12]==2 && inst_WB[6:2]==5'h00 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : lw       x%02d     %6d", rs1, imm12);
         if(inst_WB[14:12]==3 && inst_WB[6:2]==5'h00 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : ld       x%02d     %6d", rs1, imm12);
         if(inst_WB[14:12]==4 && inst_WB[6:2]==5'h00 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : lbu      x%02d     %6d", rs1, imm12);
         if(inst_WB[14:12]==5 && inst_WB[6:2]==5'h00 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : lhu      x%02d     %6d", rs1, imm12);
         if(inst_WB[14:12]==6 && inst_WB[6:2]==5'h00 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : lwu      x%02d     %6d", rs1, imm12);
         if(inst_WB[14:12]==0 && inst_WB[6:2]==5'h08 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : sb       x%02d x%02d", rs1, rs2);
         if(inst_WB[14:12]==1 && inst_WB[6:2]==5'h08 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : sh       x%02d x%02d", rs1, rs2);
         if(inst_WB[14:12]==2 && inst_WB[6:2]==5'h08 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : sw       x%02d x%02d", rs1, rs2);
         if(inst_WB[14:12]==3 && inst_WB[6:2]==5'h08 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : sd       x%02d x%02d", rs1, rs2);
         if(inst_WB[14:12]==0 && inst_WB[6:2]==5'h03 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : fence           ");
         if(inst_WB[14:12]==1 && inst_WB[6:2]==5'h03 && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : fence.i         ");
         if(inst_WB[31:25]==1 && inst_WB[14:12]==0 && inst_WB[6:2]==5'h0C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : mul      x%02d x%02d", rs1, rs2);
         if(inst_WB[31:25]==1 && inst_WB[14:12]==1 && inst_WB[6:2]==5'h0C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : mulh     x%02d x%02d", rs1, rs2);
         if(inst_WB[31:25]==1 && inst_WB[14:12]==2 && inst_WB[6:2]==5'h0C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : mulhsu   x%02d x%02d", rs1, rs2);
         if(inst_WB[31:25]==1 && inst_WB[14:12]==3 && inst_WB[6:2]==5'h0C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : mulhu    x%02d x%02d", rs1, rs2);
         if(inst_WB[31:25]==1 && inst_WB[14:12]==4 && inst_WB[6:2]==5'h0C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : div      x%02d x%02d", rs1, rs2);
         if(inst_WB[31:25]==1 && inst_WB[14:12]==5 && inst_WB[6:2]==5'h0C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : divu     x%02d x%02d", rs1, rs2);
         if(inst_WB[31:25]==1 && inst_WB[14:12]==6 && inst_WB[6:2]==5'h0C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : rem      x%02d x%02d", rs1, rs2);
         if(inst_WB[31:25]==1 && inst_WB[14:12]==7 && inst_WB[6:2]==5'h0C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : remu     x%02d x%02d", rs1, rs2);
         if(inst_WB[11:7]==0 && inst_WB[19:15]==0 && inst_WB[31:20]==12'h000 && inst_WB[14:12]==0 && inst_WB[6:2]==5'h1C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : ecall           ");
         if(inst_WB[11:7]==0 && inst_WB[19:15]==0 && inst_WB[31:20]==12'h001 && inst_WB[14:12]==0 && inst_WB[6:2]==5'h1C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : ebreak          ");
         if(inst_WB[11:7]==0 && inst_WB[19:15]==0 && inst_WB[31:20]==12'h002 && inst_WB[14:12]==0 && inst_WB[6:2]==5'h1C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : uret            ");
         if(inst_WB[11:7]==0 && inst_WB[19:15]==0 && inst_WB[31:20]==12'h102 && inst_WB[14:12]==0 && inst_WB[6:2]==5'h1C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : sret            ");
         if(inst_WB[11:7]==0 && inst_WB[19:15]==0 && inst_WB[31:20]==12'h202 && inst_WB[14:12]==0 && inst_WB[6:2]==5'h1C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : hret            ");
         if(inst_WB[11:7]==0 && inst_WB[19:15]==0 && inst_WB[31:20]==12'h302 && inst_WB[14:12]==0 && inst_WB[6:2]==5'h1C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : mret            ");
         if(inst_WB[11:7]==0 && inst_WB[19:15]==0 && inst_WB[31:20]==12'h7b2 && inst_WB[14:12]==0 && inst_WB[6:2]==5'h1C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : dret            ");
         if(inst_WB[11:7]==0 && inst_WB[31:20]==12'h104 && inst_WB[14:12]==0 && inst_WB[6:2]==5'h1C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : sfence.vm x%02d    ", rs1);
         if(inst_WB[11:7]==0 && inst_WB[19:15]==0 && inst_WB[31:20]==12'h105 && inst_WB[14:12]==0 && inst_WB[6:2]==5'h1C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : wfi             ");
         if(inst_WB[14:12]==1 && inst_WB[6:2]==5'h1C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : csrrw    x%02d     %6d", rs1, imm12);
         if(inst_WB[14:12]==2 && inst_WB[6:2]==5'h1C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : csrrs    x%02d     %6d", rs1, imm12);
         if(inst_WB[14:12]==3 && inst_WB[6:2]==5'h1C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : csrrc    x%02d     %6d", rs1, imm12);
         if(inst_WB[14:12]==5 && inst_WB[6:2]==5'h1C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : csrrwi   x%02d     %6d", rs1, imm12);
         if(inst_WB[14:12]==6 && inst_WB[6:2]==5'h1C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : csrrsi   x%02d     %6d", rs1, imm12);
         if(inst_WB[14:12]==7 && inst_WB[6:2]==5'h1C && inst_WB[1:0]==3)
           $fwrite(F_HANDLE," : csrrci   x%02d     %6d", rs1, imm12);
