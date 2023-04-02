`ifndef __CSR_SV
`define __CSR_SV


`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/decode/decoder.sv"
`include "include/csr_pkg.sv"

`else

`endif

module csr
	import common::*;
    import pipes::*;
	import csr_pkg::*;(
	input logic clk, 
    input logic reset,
	input memory_data_t dataM,
	input csr_addr_t csr_ra,
	input u1 stall,
	input u1 trint, 
	input u1 swint, 
	input u1 exint,
    output word_t rd,
	output u1 interrupt_flag,
	output u64 pcselect_mepc,
    output u64 pcselect_mtvec
);
	csr_regs_t regs, regs_nxt;
    u2 mode, mode_nxt;
	u64 pc;

	assign pcselect_mepc = regs.mepc;
    assign pcselect_mtvec = regs.mtvec;

	always_ff @(posedge clk) begin
		if (reset) begin
			regs <= '0;
			regs.mcause[1] <= 1'b1;
			regs.mepc[31] <= 1'b1;

            mode <= 2'b11;

			pc <= '0;
		end 
		else if (~stall) begin
			regs <= regs_nxt;
            mode <= mode_nxt;

			if (dataM.csr_data.is_mret) begin
				pc <= regs.mepc;
			end
			else if (dataM.en) begin
				pc <= dataM.jump_flag ? dataM.jump_pc : dataM.pc + 4;
			end
			else begin
				
			end
		end
		else begin
			
		end
	end

	always_comb begin
		rd = '0;
		unique case(csr_ra)
			CSR_MIE: rd = regs.mie;
			CSR_MIP: rd = regs.mip;
			CSR_MTVEC: rd = regs.mtvec;
			CSR_MSTATUS: rd = regs.mstatus;
			CSR_MSCRATCH: rd = regs.mscratch;
			CSR_MEPC: rd = regs.mepc;
			CSR_MCAUSE: rd = regs.mcause;
			CSR_MCYCLE: rd = regs.mcycle;
			CSR_MTVAL: rd = regs.mtval;
			default: begin
				rd = '0;
			end
		endcase
	end

	always_comb begin
		regs_nxt = regs;
		regs_nxt.mcycle = regs.mcycle + 1;

        mode_nxt = mode;

		regs_nxt.mip[7] = trint;
		regs_nxt.mip[3] = swint;
		regs_nxt.mip[11] = exint;

		interrupt_flag = '0;

		if (dataM.csr_data.wvalid) begin
			unique case(dataM.csr_data.wa)
				CSR_MIE: regs_nxt.mie = dataM.csr_data.wd;
				CSR_MIP:  regs_nxt.mip = dataM.csr_data.wd;
				CSR_MTVEC: regs_nxt.mtvec = dataM.csr_data.wd;
				CSR_MSTATUS: regs_nxt.mstatus = dataM.csr_data.wd;
				CSR_MSCRATCH: regs_nxt.mscratch = dataM.csr_data.wd;
				CSR_MEPC: regs_nxt.mepc = dataM.csr_data.wd;
				CSR_MCAUSE: regs_nxt.mcause = dataM.csr_data.wd;
				CSR_MCYCLE: regs_nxt.mcycle = dataM.csr_data.wd;
				CSR_MTVAL: regs_nxt.mtval = dataM.csr_data.wd;
				default: begin
					
				end
			endcase
			regs_nxt.mstatus.sd = regs_nxt.mstatus.fs != 0;
		end 
        else if (dataM.csr_data.is_mret) begin
			regs_nxt.mstatus.mie = regs.mstatus.mpie;
			regs_nxt.mstatus.mpie = 1'b1;
			regs_nxt.mstatus.mpp = 2'b0;
			regs_nxt.mstatus.xs = 0;

            mode_nxt = regs.mstatus.mpp;
		end
        else if (dataM.csr_data.is_ecall) begin
            unique case(mode)
                2'b00: begin
                    regs_nxt.mcause = EXCEPTION_ECALL_FROM_U_CODE;
                end
                2'b11: begin
                    regs_nxt.mcause = EXCEPTION_ECALL_FROM_M_CODE;
                end
                default:begin
                end
            endcase

            regs_nxt.mepc = dataM.pc;

            regs_nxt.mstatus.mpie = regs.mstatus.mie;
            regs_nxt.mstatus.mie = 1'b0;

            regs_nxt.mstatus.mpp = mode;

            mode_nxt = 2'b11;
		end
        else if (dataM.csr_data.is_exception) begin
			unique case(dataM.csr_data.exception)
                EXCEPTION_INST_ADDR_MISALIGNED: begin
                    regs_nxt.mcause = EXCEPTION_INST_ADDR_MISALIGNED_CODE;
                end
                EXCEPTION_LOAD_ADDR_MISALIGNED: begin
                    regs_nxt.mcause = EXCEPTION_LOAD_ADDR_MISALIGNED_CODE;
                end
                EXCEPTION_STORE_ADDR_MISALIGNED: begin
                    regs_nxt.mcause = EXCEPTION_STORE_ADDR_MISALIGNED_CODE;
                end
                EXCEPTION_ILLEGAL_INST: begin
                    regs_nxt.mcause = EXCEPTION_ILLEGAL_INST_CODE;
                end
                default:begin
                end
            endcase

            regs_nxt.mepc = dataM.pc;

            regs_nxt.mstatus.mpie = regs.mstatus.mie;
            regs_nxt.mstatus.mie = 1'b0;

            regs_nxt.mstatus.mpp = mode;

            mode_nxt = 2'b11;
		end
		else if(regs.mstatus.mie & regs.mie[7] & trint) begin
			regs_nxt.mepc = dataM.en ? dataM.pc : pc;

			regs_nxt.mcause = INTERRUPT_TIMER_CODE;

            regs_nxt.mstatus.mpie = regs.mstatus.mie;
            regs_nxt.mstatus.mie = 1'b0;

            regs_nxt.mstatus.mpp = mode;

			mode_nxt = 2'b11;

			interrupt_flag = ON;
		end
		else if (regs.mstatus.mie & regs.mie[3] & swint) begin
            regs_nxt.mepc = dataM.en ? dataM.pc : pc;

			regs_nxt.mcause = INTERRUPT_SOFTWARE_CODE;

            regs_nxt.mstatus.mpie = regs.mstatus.mie;
            regs_nxt.mstatus.mie = 1'b0;

            regs_nxt.mstatus.mpp = mode;

			mode_nxt = 2'b11;

			interrupt_flag = ON;
		end
		else if (regs.mstatus.mie & regs.mie[11] & exint) begin
            regs_nxt.mepc = dataM.en ? dataM.pc : pc;

			regs_nxt.mcause = INTERRUPT_EXTERNAL_CODE;

            regs_nxt.mstatus.mpie = regs.mstatus.mie;
            regs_nxt.mstatus.mie = 1'b0;

            regs_nxt.mstatus.mpp = mode;

			mode_nxt = 2'b11;

			interrupt_flag = ON;
		end
		else begin 
        end
	end
	
endmodule

`endif