`ifndef _IF_ID_REG_SV
`define _IF_ID_REG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module if_id_reg
    import common::*;
    import pipes::*;(
    input clk,
	input reset,
	input u1 load_stall,
	input u1 jump_flag,
	input u1 handshake_stall,
	input u1 csr_flush,
    input fetch_data_t dataF_nxt,
    output fetch_data_t dataF
);
    always_ff @(posedge clk) begin
		if(reset) begin
			dataF <= '0;
		end
		else if (handshake_stall) begin
			dataF <= dataF;
		end
		else if (jump_flag | csr_flush) begin
			dataF <= '0;
		end
		else if (load_stall) begin
			dataF <= dataF;
		end
		else begin
			dataF <= dataF_nxt;
		end
	end
endmodule

`endif 