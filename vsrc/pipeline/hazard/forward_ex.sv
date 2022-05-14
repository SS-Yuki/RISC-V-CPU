`ifndef _FORWARD_EX_SV
`define _FORWARD_EX_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module forward_ex
    import common::*;
    import pipes::*;(
    input creg_addr_t rs,
    input creg_addr_t writeregM,
    input creg_addr_t writeregW,
    input u1 regwriteM,
    input u1 regwriteW,
    input word_t rdM,
    input word_t rdW,
    input word_t rdE,
    output word_t rd
);
    always_comb begin
        if ((rs != '0) && (rs == writeregM) && regwriteM) begin
            rd = rdM;
        end 
        else if ((rs != '0) && (rs == writeregW) && regwriteW) begin
            rd = rdW;
        end
        else begin
            rd = rdE;
        end
    end
        
    
endmodule

`endif 