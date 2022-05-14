`ifndef _MEMORY_SV
`define _MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module memory 
    import common::*;
    import pipes::*;(
    output memory_data_t dataM,
    input excute_data_t dataE,
    input u1 finish,
    input word_t data1,
    input word_t data2,
    input dbus_resp_t dresp
);
    assign dataM.mem_data = finish ? data2 : data1;
    assign dataM.dst = dataE.dst;
    assign dataM.alu_result = dataE.alu_result;
    assign dataM.ctl = dataE.ctl;
    assign dataM.pc = dataE.pc;
    assign dataM.pcplus4 = dataE.pc + 4;
    assign dataM.en = dataE.en;
    
endmodule

`endif 