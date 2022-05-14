`ifndef _MEMORY_END_SV
`define _MEMORY_END_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module memory_end
    import common::*;
    import pipes::*;(
    input u1 clk,
	input u1 reset,
    input u1 data_ok,
    input u1 handshake_stall,
	input word_t read_data,
    output u1 finish,
    output word_t store_data
);
    always_ff @(posedge clk) begin
		if(reset) begin
			finish <= OFF;
            store_data <= '0;
		end
		else if (handshake_stall && data_ok) begin
			finish <= ON;
            store_data <= read_data;
		end
        else if (~handshake_stall) begin
			finish <= OFF;
            store_data <= '0;
		end
        else begin
			finish <= finish;
            store_data <= store_data;
		end
	end
endmodule

`endif 