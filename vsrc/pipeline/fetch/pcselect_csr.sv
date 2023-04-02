`ifndef _PCSELECT_CSR_SV
`define _PCSELECT_CSR_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 


module pcselect_csr
    import common::*;
    import pipes::*;(
    input u64 pc_nxt0,
    input u64 pcselect_mepc,
    input u1 mepc_flag,
    input u64 pcselect_mtvec,
    input u1 mtvec_flag,
    input u64 pc,
	input u1 csr_w_flag,
    output u64 pc_nxt
);  
    always_comb begin
        pc_nxt = pc_nxt0;
        if (csr_w_flag) begin
            pc_nxt = pc + 4;
        end
        else if (mepc_flag) begin
            pc_nxt = pcselect_mepc;
        end
        else if (mtvec_flag) begin
            pc_nxt = pcselect_mtvec;
        end
        else begin
            
        end
    end

    
    
endmodule

`endif 