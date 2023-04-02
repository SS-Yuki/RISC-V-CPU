`ifndef _DECODE_SV
`define _DECODE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/decode/decoder.sv"
`else

`endif

module decode
    import common::*;
    import pipes::*;(
    output decode_data_t dataD,
    output creg_addr_t ra1, 
    output creg_addr_t ra2, 
    output csr_addr_t csr_ra, 
    input fetch_data_t dataF,
    input word_t rd1, 
    input word_t rd2,
    input word_t csr_rd
);
    csr_data_t csr_ctl;

    decoder decoder (
        .raw_instr(dataF.raw_instr),
        .ctl(dataD.ctl),
        .imm(dataD.imm),
        .csr_ctl(csr_ctl)
    );

    assign ra1 = dataF.raw_instr[19:15];
    assign ra2 = dataF.raw_instr[24:20];
    assign csr_ra = dataF.raw_instr[31:20];

    assign dataD.ra1 = dataF.raw_instr[19:15];
    assign dataD.ra2 = dataF.raw_instr[24:20];
    assign dataD.dst = dataF.raw_instr[11:7];

    assign dataD.rd1 = rd1;
    assign dataD.rd2 = rd2;
    assign dataD.csr_rd = csr_rd;
    assign dataD.pc = dataF.pc;
    assign dataD.en = dataF.en;

    always_comb begin 
        dataD.csr_data = dataF.csr_data;

        if (~dataF.csr_data.is_exception && dataD.en) begin
            dataD.csr_data.alufunc_csr = csr_ctl.alufunc_csr;
            dataD.csr_data.imm_flag = csr_ctl.imm_flag;
            dataD.csr_data.wvalid = csr_ctl.wvalid;
            dataD.csr_data.is_mret = csr_ctl.is_mret;
            dataD.csr_data.is_ecall = csr_ctl.is_ecall;

            dataD.csr_data.is_exception = csr_ctl.is_exception;
            dataD.csr_data.exception = csr_ctl.exception;
        end
        else begin
            
        end
    end

    
endmodule
`endif 