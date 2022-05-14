`ifndef _WDATA_SELECT_SV
`define _WDATA_SELECT_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module wdata_select
    import common::*;
    import pipes::*;(
    input word_t alu_result,
    input word_t pcplus4,
    input word_t mem_data,
    input control_t ctl,
    output word_t wdata
);
    always_comb begin
        if (ctl.memtoreg) begin
            wdata = mem_data;
        end
        else if (ctl.jump) begin
            wdata = pcplus4;
        end
        else begin
            wdata = alu_result;
        end
    end
        
    
endmodule

`endif 