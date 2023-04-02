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
	input u1 csr_flush,
	input u1 data_ok,
    input excute_data_t dataE_nxt,
    output excute_data_t dataE,
	output u64 counter
);
    always_ff @(posedge clk) begin
		if(reset) begin
			dataE <= '0;
			counter <= '0;
		end
		else if(handshake_stall) begin
			dataE <= dataE;
			counter <= counter + 1;
		end
		else if (jump_flag | csr_flush) begin
			dataE <= '0;
			counter <= '0;
		end
		else begin
			dataE <= dataE_nxt;
			counter <= '0;
		end
	end
endmodule

`endif 