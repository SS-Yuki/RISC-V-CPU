`ifndef __CORE_SV
`define __CORE_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "include/config.sv"
`include "include/csr_pkg.sv"
`include "pipeline/decode/decode.sv"
`include "pipeline/decode/decoder.sv"
`include "pipeline/decode/id_ex_reg.sv"
`include "pipeline/execute/alu.sv"
`include "pipeline/execute/alu_mul.sv"
`include "pipeline/execute/divider_32.sv"
`include "pipeline/execute/divider_64.sv"
`include "pipeline/execute/multiplier_64.sv"
`include "pipeline/execute/ex_mem_reg.sv"
`include "pipeline/execute/execute.sv"
`include "pipeline/execute/mux_srca.sv"
`include "pipeline/execute/mux_srcb.sv"
`include "pipeline/fetch/fetch.sv"
`include "pipeline/fetch/pc_reg.sv"
`include "pipeline/fetch/if_id_reg.sv"
`include "pipeline/fetch/pcselect.sv"
`include "pipeline/fetch/pcselect_csr.sv"
`include "pipeline/memory/memory.sv"
`include "pipeline/memory/mem_wb_reg.sv"
`include "pipeline/memory/read_memory.sv"
`include "pipeline/memory/write_memory.sv"
`include "pipeline/memory/exce_mem.sv"
`include "pipeline/regfile/regfile.sv"
`include "pipeline/writeback/wdata_select.sv"
`include "pipeline/writeback/writeback.sv"
`include "pipeline/hazard/forward_ex.sv"
`include "pipeline/hazard/forward_id.sv"
`include "pipeline/hazard/loadstall.sv"
`include "pipeline/hazard/handshake.sv"
`include "pipeline/hazard/handshake_reg.sv"
`include "pipeline/hazard/flush_csr.sv"
`include "pipeline/csr/csr.sv"


`else

`endif

module core 
	import common::*;
	import pipes::*;(
	input logic clk, reset,
	output ibus_req_t  ireq,
	input  ibus_resp_t iresp,
	output dbus_req_t  dreq,
	input  dbus_resp_t dresp,
	input logic trint, swint, exint
);
	/* TODO: Add your pipeline here. */

	u64 pc, pc_nxt, pc_nxt0;
	fetch_data_t dataF, dataF_nxt;
	decode_data_t dataD, dataD_nxt;
	excute_data_t dataE, dataE_nxt;
	memory_data_t dataM, dataM_nxt;
	write_data_t dataW;

	u32 raw_instr;
	creg_addr_t ra1, ra2;
	word_t rd1, rd2;
	word_t rd1_f, rd2_f;
	word_t rd1_new, rd2_new;
	word_t srca, srcb, alu_result, wdata;
	word_t mdata, mem_store;
	word_t alu_data, alu_store;

	u1 load_stall, jump_flag;
	u1 dbus_handle, ibus_handle;
	u1 alu_handle;
	u1 alu_valid;
	u1 alu_data_ok;
	u1 handshake_stall;
	u1 memfinish;
	u1 alufinish;
	u1 skip;

	csr_addr_t csr_ra;
	word_t csr_rd;
	word_t alu_csr_result;

	word_t alu_csr_srcb;

	u64 csr_mepc;
	u64 csr_mtvec;

	u1 mem_is_exception;
	exception_t mem_exception;

	u1 csr_flush;

	u64 ex_mem_counter;
	u64 id_ex_counter;
	u64 mem_wb_counter;
	u64 pc_reg_counter;

	u1 interrupt_flag;
	
	assign handshake_stall = dbus_handle | ibus_handle | alu_handle;

	assign skip = (dataW.ctl.memread || dataW.ctl.memwrite) && (dataM.alu_result[31] == 1'b0);

	//ireq
	always_comb begin
		ireq.valid = (pc[1:0] == 2'b00);
		if (csr_flush & (ex_mem_counter == '0)) begin
			ireq.valid = '0;
		end
		else begin
			
		end
	end
	assign ireq.addr = pc;
	assign raw_instr = iresp.data;

	//dreq
	always_comb begin
		dreq.valid = (dataE.ctl.memread | dataE.ctl.memwrite) & (~memfinish) & (~mem_is_exception);
		if (csr_flush & (ex_mem_counter == '0)) begin
			dreq.valid = '0;
		end
		else begin
			
		end
	end
	assign dreq.addr = dataE.alu_result;
	
	//多周期ALU
	always_comb begin
		alu_valid = dataD.ctl.mulalu_type & (~alufinish);
		if (csr_flush & (id_ex_counter == '0)) begin
			alu_valid = '0;
		end
		else begin
			
		end
	end
	assign alu_handle = alu_valid & (~alu_data_ok);


	//-------取指-------
	pcselect pcselect (
		.pcplus4(pc + 4),
		.pcjump(dataE.alu_result),
		.ctl(dataE.ctl),
		.branch_flag(dataE.branch_flag),
		.pc_nxt(pc_nxt0),
		.csr_flush(csr_flush),
		.jump_flag
	);

	pcselect_csr pcselect_csr (
		.pc_nxt0(pc_nxt0),
    	.pcselect_mepc(csr_mepc),
		.mepc_flag(dataM.csr_data.is_mret),
		.pcselect_mtvec(csr_mtvec),
		.mtvec_flag(dataM.csr_data.is_exception | interrupt_flag),
		.pc(dataM.pc),
		.csr_w_flag(dataM.csr_data.wvalid),
		.pc_nxt(pc_nxt)
	);

	pc_reg pc_reg (
		.counter(pc_reg_counter),
		.pc,
		.pc_nxt,
		.clk,
		.reset,
		.load_stall,
		.jump_flag,
		.handshake_stall,
		.csr_flush(csr_flush)
	);

	handshake ibus_handshake (
		.valid(ireq.valid),
		.data_ok(iresp.data_ok),
		.handle(ibus_handle)
	);

	fetch fetch (
		.dataF(dataF_nxt),
		.raw_instr(raw_instr),
		.pc
	);

	if_id_reg if_id_reg (
		.clk,
		.reset,
		.load_stall,
		.jump_flag,
		.handshake_stall,
		.csr_flush(csr_flush),
		.dataF_nxt,
		.dataF
	);


	//-------译码-------
	forward_id forward_id_a (
		.rs(ra1),
		.writeregW(dataW.dst),
		.regwriteW(dataW.ctl.regwrite),
		.rdW(dataW.wdata),
		.rd0(rd1),
		.rd(rd1_f)
	);

	forward_id forward_id_b (
		.rs(ra2),
		.writeregW(dataW.dst),
		.regwriteW(dataW.ctl.regwrite),
		.rdW(dataW.wdata),
		.rd0(rd2),
		.rd(rd2_f)
	);


	decode decode (
		.dataD(dataD_nxt),
		.ra1, 
		.ra2,
		.csr_ra,
		.dataF,
		.rd1(rd1_f), 
		.rd2(rd2_f),
		.csr_rd
	);

	loadstall loadstall (
		.ra1, 
		.ra2,
		.dstE(dataD.dst),
		.memtoreg(dataD.ctl.memtoreg),
		.load_stall,
		.csr_flush(csr_flush)
	);

	id_ex_reg id_ex_reg (
		.clk,
		.reset,
		.load_stall,
		.jump_flag,
		.handshake_stall,
		.csr_flush(csr_flush),
		.dataD_nxt,
		.dataD,
		.counter(id_ex_counter)
	);

	//-------执行-------
	forward_ex forward_ex_a (
		.rs(dataD.ra1),
		.writeregM(dataE.dst),
		.writeregW(dataW.dst),
		.regwriteM(dataE.ctl.regwrite),
		.regwriteW(dataW.ctl.regwrite),
		.rdM(dataE.alu_result),
		.rdW(dataW.wdata),
		.rdE(dataD.rd1),
		.rd(rd1_new)
	);

	forward_ex forward_ex_b (
		.rs(dataD.ra2),
		.writeregM(dataE.dst),
		.writeregW(dataW.dst),
		.regwriteM(dataE.ctl.regwrite),
		.regwriteW(dataW.ctl.regwrite),
		.rdM(dataE.alu_result),
		.rdW(dataW.wdata),
		.rdE(dataD.rd2),
		.rd(rd2_new)
	);

	mux_srca mux_srca (
		.src1(dataD.pc),
		.src2(rd1_new),
		.flag(dataD.ctl.srca_flag),
		.src(srca)
	);

	mux_srcb mux_srcb (
		.word_reg(rd2_new),
    	.word_imm(dataD.imm),
		.word_csr(dataD.csr_rd),
		.srcb_flag(dataD.ctl.srcb_flag),
		.src(srcb)
	);

	alu alu(
		.a(srca),
		.b(srcb),
		.alufunc(dataD.ctl.alufunc),
		.alu_result
	);

	mux_srca mux_csr_scrb (
		.src1(dataD.imm),
		.src2(srca),
		.flag(dataD.csr_data.imm_flag),
		.src(alu_csr_srcb)
	);

	alu alu_csr(
		.a(dataD.csr_rd),
		.b(alu_csr_srcb),
		.alufunc(dataD.csr_data.alufunc_csr),
		.alu_result(alu_csr_result)
	);

	alu_mul alu_mul(
		.clk, 
		.reset, 
		.a(srca),
		.b(srcb),
		.alufunc(dataD.ctl.alufunc),
		.valid(alu_valid),
		.alu_result(alu_data),
		.data_ok(alu_data_ok)
	);

	handshake_reg alu_end(
		.clk,
		.reset,
		.data_ok(alu_data_ok),
		.handshake_stall,
		.read_data(alu_data),
		.finish(alufinish),
		.store_data(alu_store)
	);

	execute execute (
		.sin_result(alu_result),
		.mul_result_s(alu_store),
		.mul_result_d(alu_data),
		.alu_csr_result,
		.finish(alufinish),
		.dataD,
		.rd1(rd1_new),
		.rd2(rd2_new),
		.dataE(dataE_nxt)
	);

	ex_mem_reg ex_mem_reg (
		.clk,
		.reset,
		.jump_flag,
		.handshake_stall,
		.csr_flush(csr_flush),
		.data_ok(dresp.data_ok),
		.dataE_nxt,
		.dataE,
		.counter(ex_mem_counter)
	);


	//-------访存-------
	exce_mem exce_mem (
		.addr(dataE.alu_result),
		.memread(dataE.ctl.memread),
		.memwrite(dataE.ctl.memwrite),
		.msize(dataE.ctl.msize),
		.en(dataE.en),
		.is_exception(mem_is_exception),
		.exception(mem_exception)
	);

	read_memory read_memory (
		.mem_data(dresp.data),
		.mem_addr(dataE.alu_result),
		.msize(dataE.ctl.msize),
		.mem_unsigned(dataE.ctl.mem_unsigned),
		.data(mdata)
	);

	write_memory write_memory(
		.mem_addr(dataE.alu_result),
		.rd2(dataE.rd2),
		.msize(dataE.ctl.msize),
		.memwrite(dataE.ctl.memwrite),
		.wd(dreq.data),
		.strobe(dreq.strobe)
	);

	handshake_reg memory_end(
		.clk,
		.reset,
		.data_ok(dresp.data_ok),
		.handshake_stall,
		.read_data(mdata),
		.finish(memfinish),
		.store_data(mem_store)
	);


	memory memory (
		.dataM(dataM_nxt),
    	.dataE,
		.finish(memfinish),
		.data1(mdata),
		.data2(mem_store),
    	.dresp,
		.mem_is_exception(mem_is_exception),
    	.mem_exception(mem_exception),
		.pc(pc_nxt0),
		.jump_flag
	);

	handshake dbus_handshake (
		.valid(dreq.valid),
		.data_ok(dresp.data_ok),
		.handle(dbus_handle)
	);

	mem_wb_reg mem_wb_reg(
		.clk,
		.reset,
		.handshake_stall,
		.jump_flag,
		.csr_flush(csr_flush),
		.data_ok(dresp.data_ok),
		.dataM_nxt,
    	.dataM,
		.counter(mem_wb_counter)
	);

	//-------写回-------
	wdata_select wdata_select (
		.alu_result(dataM.alu_result),
    	.pcplus4(dataM.pcplus4),
    	.mem_data(dataM.mem_data),
    	.ctl(dataM.ctl),
    	.wdata
	);

	writeback writeback (
		.dataM,
		.wdata,
		.dataW
	);

	csr csr(
		.clk, 
		.reset,
		.csr_ra(csr_ra),
		.stall(handshake_stall),
		.dataM(dataM),
		.trint, 
		.swint, 
		.exint,
		.rd(csr_rd),
		.pcselect_mepc(csr_mepc),
		.pcselect_mtvec(csr_mtvec),
		.interrupt_flag
	);

	flush_csr flush_csr(
		.csr_data(dataM.csr_data),
		.interrupt_flag,
    	.flush(csr_flush)
	);

	regfile regfile(
		.clk, 
		.reset,
		.ra1,
		.ra2,
		.rd1,
		.rd2,
		.wvalid(dataW.ctl.regwrite),
		.wa(dataW.dst),
		.wd(dataW.wdata)
	);



`ifdef VERILATOR
	DifftestInstrCommit DifftestInstrCommit(
		.clock              (clk),
		.coreid             (0),
		.index              (0),
		.valid              (dataW.en && (~handshake_stall)),
		.pc                 (dataW.pc),
		.instr              (0),
		.skip               ,
		.isRVC              (0),
		.scFailed           (0),
		.wen                (dataW.ctl.regwrite),
		.wdest              ({3'b0, dataW.dst}),
		.wdata              (dataW.wdata)
	);
	      
	DifftestArchIntRegState DifftestArchIntRegState (
		.clock              (clk),
		.coreid             (0),
		.gpr_0              (regfile.regs_nxt[0]),
		.gpr_1              (regfile.regs_nxt[1]),
		.gpr_2              (regfile.regs_nxt[2]),
		.gpr_3              (regfile.regs_nxt[3]),
		.gpr_4              (regfile.regs_nxt[4]),
		.gpr_5              (regfile.regs_nxt[5]),
		.gpr_6              (regfile.regs_nxt[6]),
		.gpr_7              (regfile.regs_nxt[7]),
		.gpr_8              (regfile.regs_nxt[8]),
		.gpr_9              (regfile.regs_nxt[9]),
		.gpr_10             (regfile.regs_nxt[10]),
		.gpr_11             (regfile.regs_nxt[11]),
		.gpr_12             (regfile.regs_nxt[12]),
		.gpr_13             (regfile.regs_nxt[13]),
		.gpr_14             (regfile.regs_nxt[14]),
		.gpr_15             (regfile.regs_nxt[15]),
		.gpr_16             (regfile.regs_nxt[16]),
		.gpr_17             (regfile.regs_nxt[17]),
		.gpr_18             (regfile.regs_nxt[18]),
		.gpr_19             (regfile.regs_nxt[19]),
		.gpr_20             (regfile.regs_nxt[20]),
		.gpr_21             (regfile.regs_nxt[21]),
		.gpr_22             (regfile.regs_nxt[22]),
		.gpr_23             (regfile.regs_nxt[23]),
		.gpr_24             (regfile.regs_nxt[24]),
		.gpr_25             (regfile.regs_nxt[25]),
		.gpr_26             (regfile.regs_nxt[26]),
		.gpr_27             (regfile.regs_nxt[27]),
		.gpr_28             (regfile.regs_nxt[28]),
		.gpr_29             (regfile.regs_nxt[29]),
		.gpr_30             (regfile.regs_nxt[30]),
		.gpr_31             (regfile.regs_nxt[31])
	);
	      
	DifftestTrapEvent DifftestTrapEvent(
		.clock              (clk),
		.coreid             (0),
		.valid              (0),
		.code               (0),
		.pc                 (0),
		.cycleCnt           (0),
		.instrCnt           (0)
	);
	DifftestCSRState DifftestCSRState(
		.clock              (clk),
		.coreid             (0),
        .priviledgeMode     (csr.mode_nxt),
		.mstatus            (csr.regs_nxt.mstatus),
		.sstatus            (csr.regs_nxt.mstatus & 64'h800000030001e000),
		.mepc               (csr.regs_nxt.mepc),
		.sepc               (0),
		.mtval              (csr.regs_nxt.mtval),
		.stval              (0),
		.mtvec              (csr.regs_nxt.mtvec),
		.stvec              (0),
		.mcause             (csr.regs_nxt.mcause),
		.scause             (0),
		.satp               (0),
		.mip                (csr.regs_nxt.mip),
        .mie                (csr.regs_nxt.mie),
		.mscratch           (csr.regs_nxt.mscratch),
		.sscratch           (0),
		.mideleg            (0),
		.medeleg            (0)
	);    

	DifftestArchFpRegState DifftestArchFpRegState(
		.clock              (clk),
		.coreid             (0),
		.fpr_0              (0),
		.fpr_1              (0),
		.fpr_2              (0),
		.fpr_3              (0),
		.fpr_4              (0),
		.fpr_5              (0),
		.fpr_6              (0),
		.fpr_7              (0),
		.fpr_8              (0),
		.fpr_9              (0),
		.fpr_10             (0),
		.fpr_11             (0),
		.fpr_12             (0),
		.fpr_13             (0),
		.fpr_14             (0),
		.fpr_15             (0),
		.fpr_16             (0),
		.fpr_17             (0),
		.fpr_18             (0),
		.fpr_19             (0),
		.fpr_20             (0),
		.fpr_21             (0),
		.fpr_22             (0),
		.fpr_23             (0),
		.fpr_24             (0),
		.fpr_25             (0),
		.fpr_26             (0),
		.fpr_27             (0),
		.fpr_28             (0),
		.fpr_29             (0),
		.fpr_30             (0),
		.fpr_31             (0)
	);
	
`endif
endmodule
`endif