`ifndef _EXECUTE_SV
`define _EXECUTE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module execute
    import common::*;
    import pipes::*;(
    input word_t sin_result,
    input word_t mul_result_s,
    input word_t mul_result_d,
    input u1 finish,
	input decode_data_t dataD,
    input word_t rd1,
    input word_t rd2,
    output excute_data_t dataE
);
    assign dataE.alu_result = dataD.ctl.mulalu_type ? (finish ? mul_result_s : mul_result_d)
                                                    : sin_result;
    assign dataE.rd2 = rd2;
	assign dataE.dst = dataD.dst;
    assign dataE.ctl = dataD.ctl;
    assign dataE.pc = dataD.pc;
	assign dataE.en = dataD.en;

    always_comb begin 
        dataE.branch_flag = '0;
        unique case(dataD.ctl.op)
            BEQ: dataE.branch_flag = (rd1 == rd2) ? ON : OFF;
            BNE: dataE.branch_flag = (rd1 != rd2) ? ON : OFF;
            BLT: dataE.branch_flag = ($signed(rd1) < $signed(rd2)) ? ON : OFF;
            BGE: dataE.branch_flag = ($signed(rd1) >= $signed(rd2)) ? ON : OFF;
            BLTU: dataE.branch_flag = (rd1 < rd2) ? ON : OFF;
            BGEU: dataE.branch_flag = (rd1 >= rd2) ? ON : OFF;
            default: begin
            end
        endcase
    end
	
endmodule

`endif 