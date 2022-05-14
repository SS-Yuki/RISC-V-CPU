`ifndef __ALU_SV
`define __ALU_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif


module alu
	import common::*;
	import pipes::*;(
	input word_t a,
	input word_t b,
	input alufunc_t alufunc,
	output word_t alu_result
);
	u32 tem1;
	u64 tem2;
	always_latch begin
		alu_result = '0;
		unique case(alufunc)
			ALU_ADD: alu_result = a + b;
			ALU_SUB: alu_result = a - b;
			ALU_AND: alu_result = a & b;
			ALU_OR: alu_result = a | b;
			ALU_XOR: alu_result = a ^ b;
			ALU_ASSIGN: alu_result = b;

			ALU_SLL: alu_result = a << b[5:0];
			ALU_SLT: alu_result = ($signed(a) < $signed(b)) ? 1 : 0;
			ALU_SLTU:alu_result = (a < b) ? 1 : 0;
			ALU_SRA: alu_result = $signed(a) >>> b[5:0];
			ALU_SRL: alu_result = a >> b[5:0];

			ALU_ADDW: begin
				tem2 = a + b;
				alu_result = {{32{tem2[31]}}, tem2[31:0]};
			end
			ALU_SUBW: begin
				tem2 = a - b;
				alu_result = {{32{tem2[31]}}, tem2[31:0]};
			end
			ALU_SLLW: begin
				tem2 = a << b[4:0];
				alu_result = {{32{tem2[31]}}, tem2[31:0]};
			end
			ALU_SRAW: begin
				tem1 = $signed(a[31:0]) >>> b[4:0];
				alu_result = {{32{tem1[31]}}, tem1[31:0]};
			end
			ALU_SRLW: begin
				tem1 = a[31:0] >> b[4:0];
				alu_result = {{32{tem1[31]}}, tem1[31:0]};
			end
			default: begin
				
			end
		endcase
	end
	
endmodule

`endif

