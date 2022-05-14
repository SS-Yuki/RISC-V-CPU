`ifndef _FORWARD_ID_SV
`define _FORWARD_ID_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module forward_id
    import common::*;
    import pipes::*;(
    input creg_addr_t rs,
    input creg_addr_t writeregW,
    input u1 regwriteW,
    input word_t rdW,
    input word_t rd0,
    output word_t rd
);
    always_comb begin
        if ((rs != '0) && (rs == writeregW) && regwriteW) begin
            rd = rdW;
        end
        else begin
            rd = rd0;
        end
    end
        
    
endmodule

`endif 