`ifndef _EX_MEM_REG_SV
`define _EX_MEM_REG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module ex_mem_reg
    import common::*;
    import pipes::*;(
    input clk,
	input reset,
	input u1 jump_flag,
	input u1 handshake_stall,
	input u1 data_ok,
    input excute_data_t dataE_nxt,
    output excute_data_t dataE
);
    always_ff @(posedge clk) begin
		if(reset) begin
			dataE <= '0;
		end
		else if(handshake_stall) begin
			dataE <= dataE;
		end
		else if (jump_flag) begin
			dataE <= '0;
		end
		else begin
			dataE <= dataE_nxt;
		end
	end
endmodule

`endif 