`ifndef HANDSHAKE_SV
`define HANDSHAKE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module handshake
    import common::*;
    import pipes::*;(
    input u1 valid,
    input u1 data_ok,
    output u1 handle
);
    always_comb begin
        handle = valid && ~data_ok;
    end
        
    
endmodule

`endif 