`ifndef _FETCH_SV
`define _FETCH_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module fetch 
    import common::*;
    import pipes::*;(
    output fetch_data_t dataF,
    input u32 raw_instr,
    input u64 pc
);
    assign dataF.raw_instr = raw_instr;
    assign dataF.pc = pc;
    assign dataF.en = ON;
endmodule

`endif 