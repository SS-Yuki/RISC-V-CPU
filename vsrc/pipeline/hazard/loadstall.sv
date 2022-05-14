`ifndef _LOADSTALL_SV
`define _LOADSTALL_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module loadstall
    import common::*;
    import pipes::*;(
    input creg_addr_t ra1,
    input creg_addr_t ra2,
    input creg_addr_t dstE,
    input u1 memtoreg,
    output u1 load_stall
);
    always_comb begin
        load_stall = '0;
        if (((ra1 == dstE) || (ra2 == dstE)) && (memtoreg)) begin
            load_stall = ON;
        end
        else begin
            
        end
    end
        
    
endmodule

`endif 