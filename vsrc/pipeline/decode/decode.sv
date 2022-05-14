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
    output creg_addr_t ra1, ra2, 
    input fetch_data_t dataF,
    input word_t rd1, rd2
);

    decoder decoder (
        .raw_instr(dataF.raw_instr),
        .ctl(dataD.ctl),
        .imm(dataD.imm)
    );

    assign ra1 = dataF.raw_instr[19:15];
    assign ra2 = dataF.raw_instr[24:20];
    assign dataD.ra1 = dataF.raw_instr[19:15];
    assign dataD.ra2 = dataF.raw_instr[24:20];
    assign dataD.dst = dataF.raw_instr[11:7];
    assign dataD.rd1 = rd1;
    assign dataD.rd2 = rd2;
    assign dataD.pc = dataF.pc;
    assign dataD.en = dataF.en;

    
endmodule
`endif 