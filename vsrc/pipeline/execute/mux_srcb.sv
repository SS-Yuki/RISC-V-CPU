`ifndef _MUX_SRCB_SV
`define _MUX_SRCB_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module mux_srcb
    import common::*;
    import pipes::*;(
    input word_t word_reg,
    input word_t word_imm,
    input word_t word_csr,
    input srcb_t srcb_flag,
    output word_t src
);
    always_comb begin 
        src = '0;
        unique case(srcb_flag)
            TYPE_REG: begin
                src = word_reg;
            end
            TYPE_IMM: begin
                src = word_imm;
            end
            TYPE_CSR: begin
                src = word_csr;
            end
            default:begin
            end
        endcase
    end

endmodule

`endif 