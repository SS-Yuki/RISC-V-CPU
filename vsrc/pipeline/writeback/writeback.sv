`ifndef _WRITEBACK_SV
`define _WRITEBACK_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module writeback
    import common::*;
    import pipes::*;(
    input memory_data_t dataM,
    input word_t wdata,
    output write_data_t dataW
);
    assign dataW.wdata = wdata;
    assign dataW.dst = dataM.dst;
    assign dataW.ctl = dataM.ctl;
    assign dataW.pc = dataM.pc;
    assign dataW.en = dataM.en;
    
endmodule

`endif 