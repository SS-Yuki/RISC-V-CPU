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
    input dbus_resp_t dresp,
    input u1 mem_is_exception,
    input exception_t mem_exception,
    input u64 pc,
    input u1 jump_flag
);
    assign dataM.mem_data = finish ? data2 : data1;
    assign dataM.dst = dataE.dst;
    assign dataM.alu_result = dataE.alu_result;
    assign dataM.ctl = dataE.ctl;
    assign dataM.pc = dataE.pc;
    assign dataM.pcplus4 = dataE.pc + 4;
    assign dataM.jump_flag = jump_flag;
    assign dataM.jump_pc = pc;
    assign dataM.en = dataE.en;

    always_comb begin 
        dataM.csr_data = dataE.csr_data;
        if (~dataE.csr_data.is_exception) begin
            dataM.csr_data.is_exception = mem_is_exception;
            dataM.csr_data.exception = mem_exception;
        end
        else begin 
        end
    end
    
endmodule

`endif 