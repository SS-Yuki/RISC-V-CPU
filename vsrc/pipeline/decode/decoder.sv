`ifndef _DECODER_SV
`define _DECODER_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module decoder 
    import common::*;
    import pipes::*;(
    input u32 raw_instr,
    output control_t ctl,
    output word_t imm
);
    wire [6:0] f7 = raw_instr[6:0];
    wire [2:0] f3 = raw_instr[14:12];

    always_comb begin 
        ctl = '0;
        imm = '0;
        unique case(f7)
            F7_TypeI: begin
                ctl.srcb_flag = ON;
                unique case(f3)
                    F3_ADDI: begin
                        ctl.op = ADDI;
                        ctl.alufunc = ALU_ADD;
                        ctl.regwrite = ON;
                        imm = {{52{raw_instr[31]}}, raw_instr[31:20]};
                    end
                    F3_ANDI: begin
                        ctl.op = ANDI;
                        ctl.alufunc = ALU_AND;
                        ctl.regwrite = ON;
                        imm = {{52{raw_instr[31]}}, raw_instr[31:20]};
                    end
                    F3_ORI: begin
                        ctl.op = ORI;
                        ctl.alufunc = ALU_OR;
                        ctl.regwrite = ON;
                        imm = {{52{raw_instr[31]}}, raw_instr[31:20]};
                    end
                    F3_XORI: begin
                        ctl.op = XORI;
                        ctl.alufunc = ALU_XOR;
                        ctl.regwrite = ON;
                        imm = {{52{raw_instr[31]}}, raw_instr[31:20]};
                    end
                    F3_SLLI: begin
                        ctl.op = SLLI;
                        ctl.alufunc = ALU_SLL;
                        ctl.regwrite = ON;
                        imm = {{58{1'b0}}, raw_instr[25:20]};
                    end
                    F3_SLTI: begin
                        ctl.op = SLTI;
                        ctl.alufunc = ALU_SLT;
                        ctl.regwrite = ON;
                        imm = {{52{raw_instr[31]}}, raw_instr[31:20]};
                    end
                    F3_SLTIU: begin
                        ctl.op = SLTIU;
                        ctl.alufunc = ALU_SLTU;
                        ctl.regwrite = ON;
                        imm = {{52{raw_instr[31]}}, raw_instr[31:20]};
                    end
                    F3_SRAI_SRLI: begin
                        ctl.op = raw_instr[30] ? SRAI : SRLI;
                        ctl.alufunc = raw_instr[30] ? ALU_SRA : ALU_SRL;
                        ctl.regwrite = ON;
                        imm = {{58{1'b0}}, raw_instr[25:20]};
                    end
                    default: begin
                    end
                endcase
            end
            F7_TypeI_W: begin
                ctl.srcb_flag = ON;
                unique case(f3)
                    F3_ADDIW: begin
                        ctl.op = ADDIW;
                        ctl.alufunc = ALU_ADDW;
                        ctl.regwrite = ON;
                        imm = {{52{raw_instr[31]}}, raw_instr[31:20]};
                    end
                    F3_SLLIW: begin
                        ctl.op = SLLIW;
                        ctl.alufunc = ALU_SLLW;
                        ctl.regwrite = (raw_instr[25] == 1'b0) ? ON : OFF;
                        imm = {{58{raw_instr[25]}}, raw_instr[25:20]};
                    end
                    F3_SRAIW_SRLIW: begin
                        ctl.op = raw_instr[30] ? SRAIW : SRLIW;
                        ctl.alufunc = raw_instr[30] ? ALU_SRAW : ALU_SRLW;
                        ctl.regwrite = (raw_instr[25] == 1'b0) ? ON : OFF;
                        imm = {{58{raw_instr[25]}}, raw_instr[25:20]};
                    end
                    default: begin
                    end
                endcase
            end
            F7_TypeR: begin
                unique case(raw_instr[25])
                    OFF: begin
                        unique case(f3)
                            F3_ADD_SUB: begin
                                ctl.op = raw_instr[30] ? SUB : ADD;
                                ctl.alufunc = raw_instr[30] ? ALU_SUB : ALU_ADD;
                                ctl.regwrite = ON;
                            end
                            F3_AND: begin
                                ctl.op = AND;
                                ctl.alufunc = ALU_AND;
                                ctl.regwrite = ON;
                            end
                            F3_OR: begin
                                ctl.op = OR;
                                ctl.alufunc = ALU_OR;
                                ctl.regwrite = ON;
                            end
                            F3_XOR: begin
                                ctl.op = XOR;
                                ctl.alufunc = ALU_XOR;
                                ctl.regwrite = ON;
                            end
                            F3_SLL: begin
                                ctl.op = SLL;
                                ctl.alufunc = ALU_SLL;
                                ctl.regwrite = ON;
                            end
                            F3_SLT: begin
                                ctl.op = SLT;
                                ctl.alufunc = ALU_SLT;
                                ctl.regwrite = ON;
                            end
                            F3_SLTU: begin
                                ctl.op = SLTU;
                                ctl.alufunc = ALU_SLTU;
                                ctl.regwrite = ON;
                            end
                            F3_SRA_SRL: begin
                                ctl.op = raw_instr[30] ? SRA : SRL;
                                ctl.alufunc = raw_instr[30] ? ALU_SRA : ALU_SRL;
                                ctl.regwrite = ON;
                            end
                            default:begin
                            end
                        endcase
                    end
                    ON: begin
                        ctl.mulalu_type = ON;
                        unique case(f3)
                            F3_MUL: begin
                                ctl.op = MUL;
                                ctl.alufunc = ALU_MUL;
                                ctl.regwrite = ON;
                            end
                            F3_DIV: begin
                                ctl.op = DIV;
                                ctl.alufunc = ALU_DIV;
                                ctl.regwrite = ON;
                            end
                            F3_DIVU: begin
                                ctl.op = DIVU;
                                ctl.alufunc = ALU_DIVU;
                                ctl.regwrite = ON;
                            end
                            F3_REM: begin
                                ctl.op = REM;
                                ctl.alufunc = ALU_REM;
                                ctl.regwrite = ON;
                            end
                            F3_REMU: begin
                                ctl.op = REMU;
                                ctl.alufunc = ALU_REMU;
                                ctl.regwrite = ON;
                            end
                            default:begin
                            end
                        endcase
                    end
                endcase
                
            end
            F7_TypeR_W: begin
                unique case(raw_instr[25])
                    OFF: begin
                        unique case(f3)
                            F3_ADDW_SUBW: begin
                                ctl.op = raw_instr[30] ? SUBW : ADDW;
                                ctl.alufunc = raw_instr[30] ? ALU_SUBW : ALU_ADDW;
                                ctl.regwrite = ON;
                            end
                            F3_SLLW: begin
                                ctl.op = SLLW;
                                ctl.alufunc = ALU_SLLW;
                                ctl.regwrite = ON;
                            end
                            F3_SRAW_SRLW: begin
                                ctl.op = raw_instr[30] ? SRAW : SRLW;
                                ctl.alufunc = raw_instr[30] ? ALU_SRAW : ALU_SRLW;
                                ctl.regwrite = ON;
                            end
                            default:begin
                            end
                        endcase
                    end
                    ON: begin
                        ctl.mulalu_type = ON;
                        unique case(f3)
                            F3_MULW: begin
                                ctl.op = MULW;
                                ctl.alufunc = ALU_MULW;
                                ctl.regwrite = ON;
                            end
                            F3_DIVW: begin
                                ctl.op = DIVW;
                                ctl.alufunc = ALU_DIVW;
                                ctl.regwrite = ON;
                            end
                            F3_DIVUW: begin
                                ctl.op = DIVUW;
                                ctl.alufunc = ALU_DIVUW;
                                ctl.regwrite = ON;
                            end
                            F3_REMW: begin
                                ctl.op = REMW;
                                ctl.alufunc = ALU_REMW;
                                ctl.regwrite = ON;
                            end
                            F3_REMUW: begin
                                ctl.op = REMUW;
                                ctl.alufunc = ALU_REMUW;
                                ctl.regwrite = ON;
                            end
                            default:begin
                            end
                        endcase
                    end
                endcase
                
            end
            F7_LUI: begin
                imm = {{32{raw_instr[31]}}, raw_instr[31:12], {12{1'b0}}};
                ctl.op = LUI; 
                ctl.regwrite = ON;
                ctl.alufunc = ALU_ASSIGN;
                ctl.srcb_flag = ON;
            end
            F7_AUIPC: begin
                imm = {{32{raw_instr[31]}}, raw_instr[31:12], {12{1'b0}}};
                ctl.op = AUIPC; 
                ctl.regwrite = ON;
                ctl.alufunc = ALU_ADD;
                ctl.srca_flag = ON;
                ctl.srcb_flag= ON;
            end
            F7_TypeB: begin
                imm = {{52{raw_instr[31]}}, raw_instr[7], raw_instr[30:25], raw_instr[11:8], 1'b0};
                ctl.alufunc = ALU_ADD;
                ctl.srca_flag = ON;
                ctl.srcb_flag = ON;
                ctl.branch = ON; 
                unique case(f3)
                    F3_BEQ: begin
                        ctl.op = BEQ;
                    end
                    F3_BNE: begin
                        ctl.op = BNE;
                    end
                    F3_BGE: begin
                        ctl.op = BGE;
                    end
                    F3_BLT: begin
                        ctl.op = BLT;
                    end
                    F3_BGEU: begin
                        ctl.op = BGEU;
                    end
                    F3_BLTU: begin
                        ctl.op = BLTU;
                    end
                    default:begin
                    end
                endcase
            end
            F7_JAL: begin
                imm = {{44{raw_instr[31]}}, raw_instr[19:12], raw_instr[20], raw_instr[30:21], 1'b0};
                ctl.op = JAL; 
                ctl.regwrite = ON;
                ctl.jump = ON;
                ctl.alufunc = ALU_ADD;
                ctl.srca_flag = ON;
                ctl.srcb_flag = ON;
            end
            F7_JALR: begin
                imm = {{52{raw_instr[31]}}, raw_instr[31:20]};
                ctl.op = JALR; 
                ctl.regwrite = ON;
                ctl.jump = ON;
                ctl.jalr = ON;
                ctl.alufunc = ALU_ADD;
                ctl.srcb_flag = ON;
            end
            F7_TypeI_L: begin
                imm = {{52{raw_instr[31]}}, raw_instr[31:20]};
                ctl.regwrite = ON;
                ctl.alufunc = ALU_ADD;
                ctl.srcb_flag = ON;
                ctl.memread = ON;
                ctl.memtoreg = ON;
                unique case(f3)
                    F3_LD: begin
                        ctl.op = LD; 
                        ctl.msize = MSIZE8;
                        ctl.mem_unsigned = OFF;
                    end
                    F3_LB: begin
                        ctl.op = LB;
                        ctl.msize = MSIZE1;
                        ctl.mem_unsigned = OFF;
                    end
                    F3_LH: begin
                        ctl.op = LH;
                        ctl.msize = MSIZE2;
                        ctl.mem_unsigned = OFF;
                    end
                    F3_LW: begin
                        ctl.op = LW;
                        ctl.msize = MSIZE4;
                        ctl.mem_unsigned = OFF;
                    end
                    F3_LBU: begin
                        ctl.op = LBU;
                        ctl.msize = MSIZE1;
                        ctl.mem_unsigned = ON;
                    end
                    F3_LHU: begin
                        ctl.op = LHU;
                        ctl.msize = MSIZE2;
                        ctl.mem_unsigned = ON;
                    end
                    F3_LWU: begin
                        ctl.op = LWU;
                        ctl.msize = MSIZE4;
                        ctl.mem_unsigned = ON;
                    end
                    default:begin
                    end
                endcase
            end
            F7_TypeS: begin
                imm = {{52{raw_instr[31]}}, raw_instr[31:25], raw_instr[11:7]}; 
                ctl.alufunc = ALU_ADD;
                ctl.srcb_flag = ON;
                ctl.memwrite = ON;
                unique case(f3)
                    F3_SD: begin
                        ctl.op = SD; 
                        ctl.msize = MSIZE8;
                    end
                    F3_SB: begin
                        ctl.op = SB;
                        ctl.msize = MSIZE1;
                    end
                    F3_SH: begin
                        ctl.op = SH;
                        ctl.msize = MSIZE2;
                    end
                    F3_SW: begin
                        ctl.op = SW;
                        ctl.msize = MSIZE4;
                    end
                    default:begin
                    end
                endcase
            end
            default: begin
            end
        endcase
        
    end

endmodule
`endif 