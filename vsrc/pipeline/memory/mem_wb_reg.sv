`ifndef _MEM_WB_REG_SV
`define _MEM_WB_REG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module mem_wb_reg
    import common::*;
    import pipes::*;(
    input clk,
	input reset,
	input u1 handshake_stall,
	input u1 jump_flag,
	input u1 data_ok,
    input memory_data_t dataM_nxt,
    output memory_data_t dataM
);
    always_ff @(posedge clk) begin
		if(reset) begin
			dataM <= '0;
		end
		else if(handshake_stall) begin
			dataM <= dataM;
		end
		else begin
			dataM <= dataM_nxt;
		end
	end
endmodule

`endif 