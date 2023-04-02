`ifndef _FLUSH_CSR_SV
`define _FLUSH_CSR_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module flush_csr
    import common::*;
    import pipes::*;(
    input csr_data_t csr_data,
    input u1 interrupt_flag,
    output u1 flush
);
    always_comb begin 
        if(csr_data.wvalid | csr_data.is_mret | csr_data.is_exception | interrupt_flag) begin
			flush = ON;
		end
		else begin
            flush = OFF;
		end
    end
        
endmodule

`endif 