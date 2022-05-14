`ifndef _ID_EX_REG_SV
`define _ID_EX_REG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module id_ex_reg
    import common::*;
    import pipes::*;(
    input u1 clk,
	input u1 reset,
	input u1 load_stall,
	input u1 jump_flag,
	input u1 handshake_stall,
    input decode_data_t dataD_nxt,
    output decode_data_t dataD
);
    always_ff @(posedge clk) begin
		if(reset) begin
			dataD <= '0;
		end
		else if(handshake_stall) begin
			dataD <= dataD;
		end
		else if (jump_flag || load_stall) begin
			dataD <= '0;
		end
		else begin
			dataD <= dataD_nxt;
		end
	end
endmodule

`endif 