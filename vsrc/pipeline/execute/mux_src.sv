`ifndef _MUX_SRC_SV
`define _MUX_SRC_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module mux_src
    import common::*;
    import pipes::*;(
    input word_t src1,
    input word_t src2,
    input u1 flag,
    output word_t src
);
    assign src = flag ? src1 : src2;
endmodule

`endif 