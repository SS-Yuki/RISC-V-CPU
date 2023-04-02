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

    
    always_comb begin 
        dataF.csr_data = '0;
        dataF.csr_data.ra = raw_instr[31:20];
        dataF.csr_data.wa = raw_instr[31:20];

        if (~(pc[1:0] == 2'b00)) begin
            dataF.csr_data.is_exception = ON;
            dataF.csr_data.exception = EXCEPTION_INST_ADDR_MISALIGNED;
        end
    end

endmodule

`endif 