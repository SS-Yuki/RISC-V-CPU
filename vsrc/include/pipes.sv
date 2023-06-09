`ifndef __PIPES_SV
`define __PIPES_SV


`ifdef VERILATOR
`include "include/common.sv"
`endif
package pipes;
	import common::*;
/* Define instrucion decoding rules here */
parameter ON = 1'b1;
parameter OFF = 1'b0;

parameter THREE_TH0 = 3'b000;
parameter THREE_TH1 = 3'b001;
parameter THREE_TH2 = 3'b010;
parameter THREE_TH3 = 3'b011;
parameter THREE_TH4 = 3'b100;
parameter THREE_TH5 = 3'b101;
parameter THREE_TH6 = 3'b110;
parameter THREE_TH7 = 3'b111;

parameter TWO_TH0 = 2'b00;
parameter TWO_TH1 = 2'b01;
parameter TWO_TH2 = 2'b10;
parameter TWO_TH3 = 2'b11;

parameter TH0 = 1'b0;
parameter TH1 = 1'b1;

parameter F7_TypeI = 7'b0010011;
parameter F7_TypeI_W = 7'b0011011;
parameter F7_TypeI_L = 7'b0000011;

parameter F7_CSR = 7'b1110011;

parameter F7_TypeR = 7'b0110011;
parameter F7_TypeR_W = 7'b0111011;

parameter F7_TypeB = 7'b1100011;

parameter F7_TypeS = 7'b0100011;

parameter F7_LUI = 7'b0110111;
parameter F7_AUIPC = 7'b0010111;
parameter F7_JAL = 7'b1101111;
parameter F7_JALR = 7'b1100111;

parameter F3_ADDI = 3'b000;
parameter F3_ANDI = 3'b111;
parameter F3_ORI = 3'b110;
parameter F3_XORI = 3'b100;

parameter F3_SLLI = 3'b001;
parameter F3_SLTI = 3'b010;
parameter F3_SLTIU = 3'b011;
parameter F3_SRAI_SRLI = 3'b101;

parameter F3_ADDIW = 3'b000;
parameter F3_SLLIW = 3'b001;
parameter F3_SRAIW_SRLIW = 3'b101;

parameter F3_ADD_SUB = 3'b000;
parameter F3_AND = 3'b111;
parameter F3_OR = 3'b110;
parameter F3_XOR = 3'b100;

parameter F3_SLL = 3'b001;
parameter F3_SLT = 3'b010;
parameter F3_SLTU = 3'b011;
parameter F3_SRA_SRL = 3'b101;

parameter F3_ADDW_SUBW = 3'b000;
parameter F3_SLLW = 3'b001;
parameter F3_SRAW_SRLW = 3'b101;

parameter F3_MUL = 3'b000;
parameter F3_DIV = 3'b100;
parameter F3_DIVU = 3'b101;
parameter F3_REM = 3'b110;
parameter F3_REMU = 3'b111;

parameter F3_MULW = 3'b000;
parameter F3_DIVW = 3'b100;
parameter F3_DIVUW = 3'b101;
parameter F3_REMW = 3'b110;
parameter F3_REMUW = 3'b111;

parameter F3_BEQ = 3'b000;
parameter F3_BNE = 3'b001;
parameter F3_BLT = 3'b100;
parameter F3_BGE = 3'b101;
parameter F3_BLTU = 3'b110;
parameter F3_BGEU = 3'b111;

parameter F3_LD = 3'b011;
parameter F3_LB = 3'b000;
parameter F3_LH = 3'b001;
parameter F3_LW = 3'b010;
parameter F3_LBU = 3'b100;
parameter F3_LHU = 3'b101;
parameter F3_LWU = 3'b110;

parameter F3_SD = 3'b011;
parameter F3_SB = 3'b000;
parameter F3_SH = 3'b001;
parameter F3_SW = 3'b010;

parameter F3_CSRRW = 3'b001;
parameter F3_CSRRS = 3'b010;
parameter F3_CSRRC = 3'b011;
parameter F3_CSRRWI = 3'b101;
parameter F3_CSRRSI = 3'b110;
parameter F3_CSRRCI = 3'b111;

parameter F3_ECALL_MRET = 3'b000;

parameter F12_ECALL = 12'b0000_0000_0000;
parameter F12_MRET = 12'b0011_0000_0010;

parameter EXCEPTION_INST_ADDR_MISALIGNED_CODE = 64'h0000_0000_0000_0000;
parameter EXCEPTION_LOAD_ADDR_MISALIGNED_CODE = 64'h0000_0000_0000_0004;
parameter EXCEPTION_STORE_ADDR_MISALIGNED_CODE = 64'h0000_0000_0000_0006;
parameter EXCEPTION_ILLEGAL_INST_CODE = 64'h0000_0000_0000_0002;
parameter EXCEPTION_ECALL_FROM_U_CODE = 64'h0000_0000_0000_0008;
parameter EXCEPTION_ECALL_FROM_M_CODE = 64'h0000_0000_0000_000b;

parameter INTERRUPT_SOFTWARE_CODE = 64'h8000_0000_0000_0003;
parameter INTERRUPT_TIMER_CODE = 64'h8000_0000_0000_0007;
parameter INTERRUPT_EXTERNAL_CODE = 64'h8000_0000_0000_000b;
   

/* Define pipeline structures here */
typedef enum logic [6:0] {
	UNKNOWN, ADDI, ANDI, ORI, XORI, ADD, SUB, AND, OR, XOR, 
	LUI, AUIPC, BEQ, JAL, JALR, LD, SD, SLLI, SLTI, SLTIU, 
	SRAI, SRLI, ADDIW, SLLIW, SRAIW, SRLIW, SLL, SLT, SLTU, 
	SRA, SRL, ADDW, SUBW, SLLW, SRAW, SRLW, BNE, BLT, BGE, BGEU,
	BLTU, SB, SH, SW, LB, LH, LW, LBU, LHU, LWU, MUL, MULW, DIV, 
	DIVW, DIVU, DIVUW, REM, REMW, REMU, REMUW, CSRRW, CSRRS, CSRRC, 
	CSRRWI, CSRRSI, CSRRCI, MRET, ECALL
}decode_op_t;

typedef enum logic [4:0] {
	ALU_UNKNOWN, ALU_ADD, ALU_SUB, ALU_AND, ALU_OR, ALU_XOR, ALU_ASSIGN,
	ALU_SLL, ALU_SLT, ALU_SLTU, ALU_SRA, ALU_SRL, ALU_ADDW, ALU_SUBW, ALU_SLLW, 
	ALU_SRAW, ALU_SRLW, ALU_MUL, ALU_MULW, ALU_DIV, ALU_DIVW, ALU_DIVU, ALU_DIVUW, 
	ALU_REM, ALU_REMW, ALU_REMU, ALU_REMUW, ALU_AND_NOT
}alufunc_t;

typedef enum logic [4:0] {
	NO_EXCEPTION,
	EXCEPTION_INST_ADDR_MISALIGNED,
	EXCEPTION_LOAD_ADDR_MISALIGNED,
	EXCEPTION_STORE_ADDR_MISALIGNED,
	EXCEPTION_ILLEGAL_INST,
	EXCEPTION_ECALL_FROM_U,
	EXCEPTION_ECALL_FROM_M
}exception_t;

typedef enum logic [1:0] {
	TYPE_REG, TYPE_IMM, TYPE_CSR
}srcb_t;

typedef struct packed {
	decode_op_t op;
	alufunc_t alufunc;
	u1 srca_flag;
	srcb_t srcb_flag;
	u1 regwrite;
	u1 branch;
	u1 jump;
	u1 jalr;
	u1 memwrite;
	u1 memread;
	u1 memtoreg;
	msize_t msize;
	u1 mem_unsigned;
	u1 mulalu_type;
}control_t;

typedef struct packed {
	csr_addr_t wa;
	csr_addr_t ra;
	word_t wd;
	alufunc_t alufunc_csr;
	u1 imm_flag;
	u1 wvalid;
	u1 is_mret;
	u1 is_ecall;
	u1 is_exception;
	exception_t exception;
} csr_data_t;

typedef struct packed {
	u32 raw_instr;
	u64 pc;
	u1 en;
	csr_data_t csr_data;
} fetch_data_t;

typedef struct packed {
	creg_addr_t ra1, ra2;
	creg_addr_t dst;
	word_t rd1, rd2;
	word_t csr_rd;
	word_t imm;
	control_t ctl;
	u64 pc;
	u1 en;
	csr_data_t csr_data;
}decode_data_t;

typedef struct packed {
	word_t alu_result;
	word_t rd2;
	creg_addr_t dst;
	control_t ctl;
	u1 branch_flag;
	u64 pc;
	u1 en;
	csr_data_t csr_data;
}excute_data_t;

typedef struct packed {
	word_t mem_data;
	creg_addr_t dst;
	word_t alu_result;
	control_t ctl;
	u64 pc;
	u64 jump_pc;
	u1 jump_flag;
	u64 pcplus4;
	u1 en;
	csr_data_t csr_data;
}memory_data_t;

typedef struct packed {
	word_t wdata;
	creg_addr_t dst;
	control_t ctl;
	u64 pc;
	u1 en;
} write_data_t;

endpackage

`endif
